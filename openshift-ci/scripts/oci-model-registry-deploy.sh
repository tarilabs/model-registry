#!/bin/bash

# Define variables for ODH deployment deployment
OPENDATAHUB_SUBSCRIPTION="openshift-ci/resources/opendatahub-subscription.yaml"
DSC_INITIALIZATION_MANIFEST="openshift-ci/resources/model-registry-DSCInitialization.yaml"
DATA_SCIENCE_CLUSTER_MANIFEST="openshift-ci/resources/opendatahub-data-science-cluster.yaml"
MODEL_REGISTRY_DB_MANIFEST="openshift-ci/resources/model-registry-operator/mysql-db.yaml"
MODEL_REGISTRY_SAMPLE_MANIFEST="openshift-ci/resources/model-registry-operator/modelregistry_v1alpha1_modelregistry.yaml"
source "openshift-ci/scripts/colour_text_variables.sh"


# Function to deploy and wait for deployment
deploy_and_wait() {
    local manifest=$1
    local resource_name=$(basename -s .yaml $manifest)
    local wait_time=$2
    
    sleep $wait_time
    
    echo "Deploying $resource_name from $manifest..."

    if oc apply -f $manifest --wait=true --timeout=300s; then
        echo -e "${GREEN}✔ Success:${NC} Deployment of $resource_name succeeded."
    else
        echo -e "${RED}Error:${NC} Deployment of $resource_name failed or timed out." >&2
        return 1
    fi
}

check_deployment_availability() {
    local namespace="$1"
    local deployment="$2"
    local timeout=300  # Timeout in seconds
    local start_time=$(date +%s)

    # Loop until timeout
    while (( $(date +%s) - start_time < timeout )); do
        # Get the availability status of the deployment
        local deployment_status=$(oc get deployment "$deployment" -n "$namespace" --no-headers -o custom-columns=:.status.availableReplicas)

        # Check if the deployment is available
        if [[ $deployment_status != "" ]]; then
            echo -e "${GREEN}✔ Success:${NC} Deployment $deployment is available"
            return 0  # Success
        fi

        sleep 5  # Wait for 5 seconds before checking again
    done

    echo -e "${RED}Error:${NC}  Timeout reached. Deployment $deployment did not become available within $timeout seconds"
    return 1  # Failure
}

check_pod_status() {
    local namespace="$1"
    local pod_selector="$2"
    local expected_ready_containers="$3"
    local timeout=300  # Timeout in seconds
    local start_time=$(date +%s)
    
    # Loop until timeout
    while (( $(date +%s) - start_time < timeout )); do
        # Get the list of pods in the specified namespace matching the provided partial names
        local pod_list=$(oc get pods -n $namespace $pod_selector --no-headers -o custom-columns=NAME:.metadata.name)
        
        # Iterate over each pod in the list
        while IFS= read -r pod_name; do
            # Get the pod info
            local pod_info=$(oc get pod "$pod_name" -n "$namespace" --no-headers)

            # Extract pod status and ready status from the info
            local pod_name=$(echo "$pod_info" | awk '{print $1}')
            local pod_status=$(echo "$pod_info" | awk '{print $3}')
            local pod_ready=$(echo "$pod_info" | awk '{print $2}')
            local ready_containers=$(echo "$pod_ready" | cut -d'/' -f1)

            # Check if the pod is Running and all containers are ready
            if [[ $pod_status == "Running" ]] && [[ $ready_containers -eq $expected_ready_containers ]]; then
                echo -e "${GREEN}✔ Success:${NC} Pod $pod_name is running and $ready_containers out of $expected_ready_containers containers are ready"
                return 0  # Success
            else
                echo -e "${YELLOW}! INFO:${NC}  Pod $pod_name is not running or does not have $expected_ready_containers containers ready"
            fi
        done <<< "$pod_list"

        sleep 5  # Wait for 5 seconds before checking again
    done

    echo -e "${RED}X Failure:${NC} Timeout reached. No pod matching '$pod_name_partial' became ready within $timeout seconds"
    return 1  # Failure
}

check_route_status() {
    local namespace="$1"
    local route_name="$2"
    local key="items"
    local interval=5
    local timeout=300
    local start_time=$(date +%s)

    while (( $(date +%s) - start_time < timeout )); do
        # Get the route URL
        local route=$(oc get route -n "$namespace" "$route_name" -o jsonpath='{.spec.host}')
        local route_url="http://$route"

        if [[ -z "$route_url" ]]; then
             echo -e "${RED}Error:${NC}  Route '$route_name' does not exist in namespace '$namespace'"
            return 1
        else 
            echo -e "${GREEN}✔ Success:${NC} Route '$route_name' exists in namespace '$namespace'"
        fi

        # Test if the route is live
        local response=$(curl -s -o /dev/null -w "%{http_code}" "$route_url/api/model_registry/v1alpha2/registered_models")

        # Check if the response status code is 200 OK or 404 Not Found
        if [[ "$response" == "200" ]]; then
            echo -e "${GREEN}✔ Success:${NC} Route server is reachable. Status code: 200 OK"
            return 0
        elif [[ "$response" == "404" ]]; then
            echo -e "${GREEN}✔ Success:${NC} Route server is reachable. Status code: 404 Not Found"
            return 0
        else
            echo -e "${RED}Error:${NC}  Route server is unreachable. Status code: $response"
        fi

        sleep "$interval"
    done

    echo -e "${RED}Error:${NC}  Timeout reached. Route '$route_name' did not become live within $timeout seconds."
    return 1
}

# Run the deployment tests.
run_deployment_tests() {
    check_deployment_availability default model-registry-db
    check_deployment_availability default modelregistry-sample
    check_pod_status default "-l name=model-registry-db" 1
    check_pod_status default "-l app=modelregistry-sample" 2
    check_route_status "default" "modelregistry-sample-http"
}

# Main function for orchestrating deployments
main() {   
    deploy_and_wait $OPENDATAHUB_SUBSCRIPTION 0
    deploy_and_wait $DSC_INITIALIZATION_MANIFEST 20
    check_pod_status "opendatahub" "-l component.opendatahub.io/name=model-registry-operator" 2
    deploy_and_wait $DATA_SCIENCE_CLUSTER_MANIFEST 0
    deploy_and_wait $MODEL_REGISTRY_DB_MANIFEST 20
    deploy_and_wait $MODEL_REGISTRY_SAMPLE_MANIFEST 20
    run_deployment_tests
}

# Execute main function
main