import { createContext, useContext } from 'react';
import { RootStore, rootStore } from './RootStore';

export const StoreContext = createContext<RootStore>(rootStore);

export function useStore(): RootStore {
  return useContext(StoreContext);
}
