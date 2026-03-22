import { AuthStore } from './AuthStore';
import { OrderStore } from './OrderStore';
import { UserManagementStore } from './UserManagementStore';
import { ChemistStore } from './ChemistStore';
import { RegionStore } from './RegionStore';
import { ConsentStore } from './ConsentStore';
import { UIStore } from './UIStore';

export class RootStore {
  authStore: AuthStore;
  orderStore: OrderStore;
  userManagementStore: UserManagementStore;
  chemistStore: ChemistStore;
  regionStore: RegionStore;
  consentStore: ConsentStore;
  uiStore: UIStore;

  constructor() {
    this.authStore = new AuthStore();
    this.orderStore = new OrderStore();
    this.userManagementStore = new UserManagementStore();
    this.chemistStore = new ChemistStore();
    this.regionStore = new RegionStore();
    this.consentStore = new ConsentStore();
    this.uiStore = new UIStore();
  }
}

export const rootStore = new RootStore();
