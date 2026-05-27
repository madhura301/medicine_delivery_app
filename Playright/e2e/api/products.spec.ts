import { test, expect } from '../fixtures/api.fixture';

/**
 * Covers ProductsController (`/api/products`). Plan §7.1 (Products) + §7.3/§7.4.
 *
 * Contract (verified against ProductsController.cs — DTOs are inline there):
 *  - class-level [Authorize]; per-action policies Read/Create/Update/DeleteProducts
 *  - GET    /api/products            -> 200 Product[]            (RequireReadProductsPermission)
 *  - GET    /api/products/{id}       -> 200 Product | 404        (RequireReadProductsPermission)
 *  - POST   /api/products            -> 201 + Location, Product  (RequireCreateProductsPermission)
 *  - PUT    /api/products/{id}       -> 200 Product | 404        (RequireUpdateProductsPermission)
 *  - DELETE /api/products/{id}       -> 204 | 404                (RequireDeleteProductsPermission)
 *  Product = { id:int, name, price:decimal, category }
 *  Storage is an in-memory static list seeded with 4 items (ids 1-4) — specs are
 *  self-cleaning (delete what they create) and never touch the seeded 4.
 *
 * Role-by-role 403 grid is intentionally NOT here — it lives in
 * authorization-matrix.spec.ts (single source of truth for the permission map).
 */

test.describe.serial('Products API', () => {
  test('GET /api/products requires auth -> 401 without a token', async ({ api }) => {
    const res = await api.get('/api/products');
    expect(res.status()).toBe(401);
  });

  test('POST /api/products requires auth -> 401 without a token', async ({ api }) => {
    const res = await api.post('/api/products', { data: { name: 'X', price: 1, category: 'Y' } });
    expect(res.status()).toBe(401);
  });

  test('GET /api/products (admin) returns the seeded catalogue', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get('/api/products');
    expect(res.status()).toBe(200);
    const list = await res.json();
    expect(Array.isArray(list)).toBeTruthy();
    expect(list.length).toBeGreaterThanOrEqual(4);
    const sample = list[0];
    expect(sample).toHaveProperty('id');
    expect(sample).toHaveProperty('name');
    expect(sample).toHaveProperty('price');
    expect(sample).toHaveProperty('category');
  });

  test('GET /api/products/1 (admin) returns the seeded Aspirin product', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get('/api/products/1');
    expect(res.status()).toBe(200);
    const p = await res.json();
    expect(p.id).toBe(1);
    expect(typeof p.name).toBe('string');
  });

  test('GET /api/products/{unknown} -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get('/api/products/999999');
    expect(res.status()).toBe(404);
  });

  test('full CRUD lifecycle (admin): create -> read -> update -> delete', async ({ apiAs }) => {
    const admin = await apiAs('admin');

    // CREATE -> 201 + Location header
    const created = await admin.post('/api/products', {
      data: { name: 'E2E Test Syrup', price: 42.5, category: 'E2E' },
    });
    expect(created.status(), await created.text()).toBe(201);
    const product = await created.json();
    expect(product.id).toBeGreaterThan(4);
    expect(product.name).toBe('E2E Test Syrup');
    expect(product.price).toBe(42.5);
    const location = created.headers()['location'];
    expect(location, 'CreatedAtAction should set a Location header').toBeTruthy();

    const id = product.id as number;

    // READ back the new product
    const got = await admin.get(`/api/products/${id}`);
    expect(got.status()).toBe(200);
    expect((await got.json()).name).toBe('E2E Test Syrup');

    // it appears in the list
    const list = await (await admin.get('/api/products')).json();
    expect((list as Array<{ id: number }>).some((x) => x.id === id)).toBeTruthy();

    // UPDATE
    const updated = await admin.put(`/api/products/${id}`, {
      data: { name: 'E2E Test Syrup v2', price: 50, category: 'E2E' },
    });
    expect(updated.status()).toBe(200);
    expect((await updated.json()).name).toBe('E2E Test Syrup v2');

    // DELETE -> 204
    const del = await admin.delete(`/api/products/${id}`);
    expect(del.status()).toBe(204);

    // now gone -> 404
    expect((await admin.get(`/api/products/${id}`)).status()).toBe(404);
  });

  test('PUT /api/products/{unknown} -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.put('/api/products/999999', {
      data: { name: 'nope', price: 1, category: 'z' },
    });
    expect(res.status()).toBe(404);
  });

  test('DELETE /api/products/{unknown} -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.delete('/api/products/999999')).status()).toBe(404);
  });
});
