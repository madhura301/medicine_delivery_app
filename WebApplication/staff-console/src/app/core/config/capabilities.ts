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
  /**
   * Hand an order to a delivery partner. Normally the chemist's job, deliberately extended to
   * staff so they can step in. Gated server-side by UpdateOrders, which all three roles hold.
   */
  assignDelivery: boolean;
  /**
   * Change a user's login username or reset their password. Gated server-side by
   * ManagerUpdateUsers, which Admin and Manager hold but CustomerSupport does not.
   */
  manageUserAccounts: boolean;
  /**
   * Accept or reject an order that has been routed to this chemist's own store. Gated server-side
   * by UpdateOrders, which the Chemist role holds; the API additionally refuses unless the order is
   * currently AssignedToChemist.
   */
  acceptRejectOrders: boolean;
  /** True for the store-scoped role: sees only its own orders, never the org-wide screens. */
  ownStoreOnly: boolean;
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
    manageUserAccounts: true,
    assignDelivery: true,
    acceptRejectOrders: false,
    ownStoreOnly: false,
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
    manageUserAccounts: true,
    assignDelivery: true,
    acceptRejectOrders: false,
    ownStoreOnly: false,
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
    manageUserAccounts: false,
    assignDelivery: true,
    acceptRejectOrders: false,
    ownStoreOnly: false,
  },
  Customer: emptyCapabilities(),
  // A chemist signs in to work their own store's order queue and nothing else: no rosters, no
  // regions, no other store's orders. Assigning a delivery partner is theirs by design.
  Chemist: {
    ...emptyCapabilities(),
    acceptRejectOrders: true,
    assignDelivery: true,
    ownStoreOnly: true,
  },
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
    manageUserAccounts: false,
    assignDelivery: false,
    acceptRejectOrders: false,
    ownStoreOnly: false,
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
