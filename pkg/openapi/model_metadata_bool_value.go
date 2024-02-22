/*
Model Registry REST API

REST API for Model Registry to create and manage ML model metadata

API version: v1alpha1
*/

// Code generated by OpenAPI Generator (https://openapi-generator.tech); DO NOT EDIT.

package openapi

import (
	"encoding/json"
)

// checks if the MetadataBoolValue type satisfies the MappedNullable interface at compile time
var _ MappedNullable = &MetadataBoolValue{}

// MetadataBoolValue A bool property value.
type MetadataBoolValue struct {
	BoolValue    bool   `json:"bool_value"`
	MetadataType string `json:"metadataType"`
}

// NewMetadataBoolValue instantiates a new MetadataBoolValue object
// This constructor will assign default values to properties that have it defined,
// and makes sure properties required by API are set, but the set of arguments
// will change when the set of required properties is changed
func NewMetadataBoolValue(boolValue bool, metadataType string) *MetadataBoolValue {
	this := MetadataBoolValue{}
	this.BoolValue = boolValue
	this.MetadataType = metadataType
	return &this
}

// NewMetadataBoolValueWithDefaults instantiates a new MetadataBoolValue object
// This constructor will only assign default values to properties that have it defined,
// but it doesn't guarantee that properties required by API are set
func NewMetadataBoolValueWithDefaults() *MetadataBoolValue {
	this := MetadataBoolValue{}
	var metadataType string = "MetadataBoolValue"
	this.MetadataType = metadataType
	return &this
}

// GetBoolValue returns the BoolValue field value
func (o *MetadataBoolValue) GetBoolValue() bool {
	if o == nil {
		var ret bool
		return ret
	}

	return o.BoolValue
}

// GetBoolValueOk returns a tuple with the BoolValue field value
// and a boolean to check if the value has been set.
func (o *MetadataBoolValue) GetBoolValueOk() (*bool, bool) {
	if o == nil {
		return nil, false
	}
	return &o.BoolValue, true
}

// SetBoolValue sets field value
func (o *MetadataBoolValue) SetBoolValue(v bool) {
	o.BoolValue = v
}

// GetMetadataType returns the MetadataType field value
func (o *MetadataBoolValue) GetMetadataType() string {
	if o == nil {
		var ret string
		return ret
	}

	return o.MetadataType
}

// GetMetadataTypeOk returns a tuple with the MetadataType field value
// and a boolean to check if the value has been set.
func (o *MetadataBoolValue) GetMetadataTypeOk() (*string, bool) {
	if o == nil {
		return nil, false
	}
	return &o.MetadataType, true
}

// SetMetadataType sets field value
func (o *MetadataBoolValue) SetMetadataType(v string) {
	o.MetadataType = v
}

func (o MetadataBoolValue) MarshalJSON() ([]byte, error) {
	toSerialize, err := o.ToMap()
	if err != nil {
		return []byte{}, err
	}
	return json.Marshal(toSerialize)
}

func (o MetadataBoolValue) ToMap() (map[string]interface{}, error) {
	toSerialize := map[string]interface{}{}
	toSerialize["bool_value"] = o.BoolValue
	toSerialize["metadataType"] = o.MetadataType
	return toSerialize, nil
}

type NullableMetadataBoolValue struct {
	value *MetadataBoolValue
	isSet bool
}

func (v NullableMetadataBoolValue) Get() *MetadataBoolValue {
	return v.value
}

func (v *NullableMetadataBoolValue) Set(val *MetadataBoolValue) {
	v.value = val
	v.isSet = true
}

func (v NullableMetadataBoolValue) IsSet() bool {
	return v.isSet
}

func (v *NullableMetadataBoolValue) Unset() {
	v.value = nil
	v.isSet = false
}

func NewNullableMetadataBoolValue(val *MetadataBoolValue) *NullableMetadataBoolValue {
	return &NullableMetadataBoolValue{value: val, isSet: true}
}

func (v NullableMetadataBoolValue) MarshalJSON() ([]byte, error) {
	return json.Marshal(v.value)
}

func (v *NullableMetadataBoolValue) UnmarshalJSON(src []byte) error {
	v.isSet = true
	return json.Unmarshal(src, &v.value)
}
