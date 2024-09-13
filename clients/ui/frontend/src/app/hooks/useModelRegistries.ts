import * as React from 'react';
import useFetchState, { FetchState, FetchStateCallbackPromise } from '~/utilities/useFetchState';
import { ModelRegistry } from '~/app/types';
import { getListModelRegistries } from '~/app/api/k8s';

const useModelRegistries = (): FetchState<ModelRegistry[]> => {
  const listModelRegistries = React.useMemo(() => getListModelRegistries(''), []);
  const callback = React.useCallback<FetchStateCallbackPromise<ModelRegistry[]>>(
    (opts) => listModelRegistries(opts),
    [listModelRegistries],
  );
  return useFetchState(callback, [], { initialPromisePurity: true });
};

export default useModelRegistries;
