import { Order } from '../../../core/models/api.models';
import { AssignTo } from '../../../core/models/enums';
import { BUCKETS, bucketBySlug, bucketLabel, currentOwner, formatAmount } from './order-buckets';

function order(overrides: Partial<Order>): Order {
  return {
    orderId: 1,
    orderNumber: 'ABC123',
    customerId: 'c1',
    customerName: 'Test Buyer',
    customerAddressId: 'a1',
    medicalStoreId: null,
    customerSupportId: null,
    managerId: null,
    deliveryId: null,
    assignTo: AssignTo.Customer,
    assignedByType: 0,
    medicalStoreName: null,
    customerSupportName: null,
    managerName: null,
    deliveryBoyName: null,
    orderType: 0,
    orderInputType: 2,
    orderInputFileLocation: null,
    orderInputText: null,
    orderBillFileLocation: null,
    orderStatus: 0,
    orderPaymentStatus: 0,
    cancellationReason: null,
    totalAmount: null,
    createdOn: '2026-07-29T12:00:00Z',
    updatedOn: null,
    assignmentHistory: null,
    payments: null,
    ...overrides,
  };
}

describe('bucket definitions', () => {
  it('covers every AssignTo value plus "all"', () => {
    const buckets = BUCKETS.map((b) => b.bucket);
    expect(buckets).toContain('all');
    for (const value of [
      AssignTo.Customer,
      AssignTo.Chemist,
      AssignTo.CustomerSupport,
      AssignTo.Delivery,
      AssignTo.Manager,
    ]) {
      expect(buckets).toContain(value);
    }
  });

  it('resolves a slug, defaulting to All Orders for an unknown one', () => {
    expect(bucketBySlug('with-manager').bucket).toBe(AssignTo.Manager);
    expect(bucketBySlug('nonsense').bucket).toBe('all');
  });

  it('labels a NULL AssignTo (arriving as 0) as awaiting assignment', () => {
    expect(bucketLabel(AssignTo.Customer)).toBe('Awaiting Assignment');
  });
});

describe('currentOwner', () => {
  it('uses assignTo, not whichever id happens to be set', () => {
    // A delivered order keeps its delivery id but has moved out of the Delivery bucket.
    const handedBack = order({
      assignTo: AssignTo.Chemist,
      deliveryId: 7,
      deliveryBoyName: 'Old Partner',
      medicalStoreName: 'HealthPlus Pharmacy',
    });

    expect(currentOwner(handedBack)).toBe('HealthPlus Pharmacy');
  });

  it('names the support agent, manager and delivery partner in their own buckets', () => {
    expect(
      currentOwner(order({ assignTo: AssignTo.CustomerSupport, customerSupportName: 'Sumit' })),
    ).toBe('Sumit');
    expect(currentOwner(order({ assignTo: AssignTo.Manager, managerName: 'Rahul' }))).toBe('Rahul');
    expect(currentOwner(order({ assignTo: AssignTo.Delivery, deliveryBoyName: 'Vikram' }))).toBe(
      'Vikram',
    );
  });

  it('says unassigned when the order still sits with the customer', () => {
    expect(currentOwner(order({ assignTo: AssignTo.Customer }))).toBe('Unassigned');
  });

  it('falls back to a role name when the API sent no display name', () => {
    expect(currentOwner(order({ assignTo: AssignTo.Chemist }))).toBe('Chemist');
  });
});

describe('formatAmount', () => {
  it('renders rupees to two decimals', () => {
    expect(formatAmount(250)).toBe('₹250.00');
  });

  it('renders an em dash when there is no amount', () => {
    expect(formatAmount(null)).toBe('—');
  });
});
