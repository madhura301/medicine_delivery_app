import { MenuItem, isGroup, visibleMenu } from './menu';

function routesFor(role: Parameters<typeof visibleMenu>[0]): string[] {
  return visibleMenu(role).flatMap((entry) =>
    isGroup(entry) ? entry.children.map((c) => c.route) : [(entry as MenuItem).route],
  );
}

describe('visibleMenu', () => {
  it('gives an Admin everything', () => {
    const routes = routesFor('Admin');
    expect(routes).toContain('/managers');
    expect(routes).toContain('/delivery-boys');
    expect(routes).toContain('/orders/all');
    expect(routes).toContain('/regions/support');
    expect(routes).toContain('/regions/delivery');
  });

  it('hides All Orders from CustomerSupport, who lacks ListAllOrders', () => {
    const routes = routesFor('CustomerSupport');
    expect(routes).not.toContain('/orders/all');
    expect(routes).toContain('/orders/with-support');
  });

  it('hides Delivery Boys from CustomerSupport, who lacks DeliveryRead', () => {
    expect(routesFor('CustomerSupport')).not.toContain('/delivery-boys');
    expect(routesFor('Manager')).toContain('/delivery-boys');
  });

  it('hides Managers from CustomerSupport', () => {
    expect(routesFor('CustomerSupport')).not.toContain('/managers');
  });

  it('shows nothing when there is no role', () => {
    expect(visibleMenu(null)).toEqual([]);
  });

  it('drops a group entirely when none of its children are visible', () => {
    for (const entry of visibleMenu('CustomerSupport')) {
      if (isGroup(entry)) {
        expect(entry.children.length).toBeGreaterThan(0);
      }
    }
  });
});
