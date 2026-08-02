import { Injectable, computed, inject } from '@angular/core';
import { AuthStore } from '../auth/auth.store';
import { UserRole } from '../models/enums';

/**
 * What each role may do, mirroring docs/FUNCTIONAL_SPEC.md §12.
 *
 * This is a UI convenience only. The JWT carries no permission claims and the API has no
 * "my permissions" endpoint, so this map is hand-maintained and can drift from the server's real
 * rules — every screen must still handle a 403 from the API.
 */
export interface Capabilities {
  manageManagers: boolean;
  manageCustomerSupport: boolean;
  manageDeliveryBoys: boolean;
  manageChemists: boolean;
  hardDeleteChemist: boolean;
  manageCustomers: boolean;
  manageRegions: boolean;
  listAllOrders: boolean;
  reassignOrder: boolean;
  cancelOrder: boolean;
}

const CAPABILITIES: Record<UserRole, Capabilities> = {
  Admin: {
    manageManagers: true,
    manageCustomerSupport: true,
    manageDeliveryBoys: true,
    manageChemists: true,
    hardDeleteChemist: true,
    manageCustomers: true,
    manageRegions: true,
    listAllOrders: true,
    reassignOrder: true,
    cancelOrder: true,
  },
  Manager: {
    // Only an Admin holds ManagerSupportCreate, so a Manager sees the roster read-only.
    manageManagers: false,
    manageCustomerSupport: true,
    manageDeliveryBoys: true,
    manageChemists: true,
    hardDeleteChemist: false,
    manageCustomers: true,
    manageRegions: true,
    listAllOrders: true,
    reassignOrder: true,
    cancelOrder: true,
  },
  CustomerSupport: {
    manageManagers: false,
    manageCustomerSupport: false,
    manageDeliveryBoys: false,
    manageChemists: true,
    hardDeleteChemist: false,
    manageCustomers: true,
    manageRegions: false,
    listAllOrders: false,
    reassignOrder: true,
    cancelOrder: true,
  },
  Customer: emptyCapabilities(),
  Chemist: emptyCapabilities(),
  DeliveryBoy: emptyCapabilities(),
};

function emptyCapabilities(): Capabilities {
  return {
    manageManagers: false,
    manageCustomerSupport: false,
    manageDeliveryBoys: false,
    manageChemists: false,
    hardDeleteChemist: false,
    manageCustomers: false,
    manageRegions: false,
    listAllOrders: false,
    reassignOrder: false,
    cancelOrder: false,
  };
}

@Injectable({ providedIn: 'root' })
export class CapabilityService {
  private readonly auth = inject(AuthStore);

  readonly current = computed<Capabilities>(() => {
    const role = this.auth.role();
    return role ? CAPABILITIES[role] : emptyCapabilities();
  });

  can(capability: keyof Capabilities): boolean {
    return this.current()[capability];
  }
}
