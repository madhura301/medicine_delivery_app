#!/usr/bin/env bash
# Runs BOTH validation layers against a locally-running backend:
#   1. API contract suite  (Playwright, ~110 endpoints)
#   2. Functional flows     (validate_functional.py, PDF sign-off scenarios)
# Prereqs: Postgres up (MedicineDeliveryNew), backend on $API_BASE against local
# Postgres with a real blob string and SmsSettings:Provider=Console.
# See functional/README.md for the exact backend launch command.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_BASE="${API_BASE:-http://localhost:5000}"
failed=0

echo "== Pharmaish full validation ==  API=$API_BASE"

if ! curl -sf "$API_BASE/swagger/index.html" >/dev/null 2>&1; then
  echo "Backend not reachable at $API_BASE. Start it first (see functional/README.md)." >&2
  exit 2
fi

echo -e "\n-- [1/2] API contract suite (Playwright) --"
( cd "$ROOT/e2e" && npx playwright test --project=api --reporter=line ) || { failed=1; echo "API suite FAILED"; }

echo -e "\n-- [2/2] Functional flows (PDF sign-off scenarios) --"
API_BASE="$API_BASE" python "$ROOT/functional/validate_functional.py" || { failed=1; echo "Functional flows FAILED"; }

if [ "$failed" -ne 0 ]; then echo -e "\nRESULT: FAILURES ABOVE"; exit 1; fi
echo -e "\nRESULT: ALL GREEN"
