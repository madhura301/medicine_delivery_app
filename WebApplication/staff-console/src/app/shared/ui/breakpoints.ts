/**
 * The console's own breakpoints, kept in one place so the CDK queries and the SCSS media queries
 * cannot drift apart. These follow docs/FUNCTIONAL_SPEC.md §3.3 rather than Material's Handset /
 * Tablet definitions, which sit at different widths.
 *
 * < 768px  — stacked cards, off-canvas navigation
 * ≥ 768px  — tables, docked navigation
 */
export const HANDSET_QUERY = '(max-width: 767.98px)';
