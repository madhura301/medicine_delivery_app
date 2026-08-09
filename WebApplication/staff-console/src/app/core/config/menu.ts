import { UserRole } from '../models/enums';

export interface MenuItem {
  label: string;
  icon: string;
  route: string;
  roles: readonly UserRole[];
}

export interface MenuGroup {
  label: string;
  icon: string;
  children: MenuItem[];
}

export type MenuEntry = MenuItem | MenuGroup;

export function isGroup(entry: MenuEntry): entry is MenuGroup {
  return 'children' in entry;
}

const ALL_STAFF: readonly UserRole[] = ['Admin', 'Manager', 'CustomerSupport'];
const ADMIN_MANAGER: readonly UserRole[] = ['Admin', 'Manager'];

/**
 * The single definition the sidebar renders from. Roles here mirror the access matrix in
 * docs/FUNCTIONAL_SPEC.md §12 — items a role cannot use are hidden, not disabled.
 *
 * Delivery Boys is Admin/Manager only: CustomerSupport lacks the DeliveryRead permission, so
 * GET /api/Deliveries would 403 for them (spec §13.3).
 */
export const MENU: readonly MenuEntry[] = [
  { label: 'Dashboard', icon: 'dashboard', route: '/dashboard', roles: ALL_STAFF },
  { label: 'Managers', icon: 'manage_accounts', route: '/managers', roles: ADMIN_MANAGER },
  { label: 'Customer Support', icon: 'support_agent', route: '/customer-support', roles: ALL_STAFF },
  { label: 'Delivery Boys', icon: 'two_wheeler', route: '/delivery-boys', roles: ADMIN_MANAGER },
  { label: 'Chemists', icon: 'local_pharmacy', route: '/chemists', roles: ALL_STAFF },
  { label: 'Customers', icon: 'people', route: '/customers', roles: ALL_STAFF },
  {
    label: 'Regions',
    icon: 'map',
    children: [
      { label: 'Support Regions', icon: 'headset_mic', route: '/regions/support', roles: ALL_STAFF },
      { label: 'Delivery Regions', icon: 'moped', route: '/regions/delivery', roles: ALL_STAFF },
    ],
  },
  {
    label: 'Orders',
    icon: 'receipt_long',
    children: [
      { label: 'All Orders', icon: 'list_alt', route: '/orders/all', roles: ADMIN_MANAGER },
      {
        label: 'Awaiting Assignment',
        icon: 'hourglass_empty',
        route: '/orders/awaiting-assignment',
        roles: ALL_STAFF,
      },
      { label: 'With Chemist', icon: 'local_pharmacy', route: '/orders/with-chemist', roles: ALL_STAFF },
      {
        label: 'With Customer Support',
        icon: 'support_agent',
        route: '/orders/with-support',
        roles: ALL_STAFF,
      },
      { label: 'With Manager', icon: 'escalator_warning', route: '/orders/with-manager', roles: ALL_STAFF },
      { label: 'Out for Delivery', icon: 'local_shipping', route: '/orders/with-delivery', roles: ALL_STAFF },
    ],
  },
];

export function visibleMenu(role: UserRole | null): MenuEntry[] {
  if (!role) {
    return [];
  }

  return MENU.reduce<MenuEntry[]>((acc, entry) => {
    if (isGroup(entry)) {
      const children = entry.children.filter((child) => child.roles.includes(role));
      if (children.length) {
        acc.push({ ...entry, children });
      }
    } else if (entry.roles.includes(role)) {
      acc.push(entry);
    }
    return acc;
  }, []);
}
