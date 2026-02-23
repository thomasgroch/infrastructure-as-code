#!/bin/bash
# Single comprehensive integration test
# Usage: ./run-tests.sh [target_host]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-localhost}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Passbolt Infrastructure Integration Test Suite  ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""
echo "Target: $TARGET"
echo ""

# Run Ansible syntax check first
echo "→ Checking Ansible syntax..."
ansible-playbook -i "$SCRIPT_DIR/../ansible/inventory" "$SCRIPT_DIR/../ansible/playbooks/site.yml" --syntax-check

echo -e "${GREEN}✓${NC} Ansible syntax OK"
echo ""

# Run the deployment if target is localhost
if [[ "$TARGET" == "localhost" ]]; then
    echo "→ Running deployment (check mode)..."
    ansible-playbook -i "$SCRIPT_DIR/../ansible/inventory" "$SCRIPT_DIR/../ansible/playbooks/site.yml" --check --diff || true
    echo ""
    
    echo "→ Running deployment (actual)..."
    ansible-playbook -i "$SCRIPT_DIR/../ansible/inventory" "$SCRIPT_DIR/../ansible/playbooks/site.yml"
    echo ""
fi

# Run integration tests
echo "→ Running integration tests..."
python3 /opt/passbolt-autofill/test_autofill.py

TEST_RESULT=$?

if [[ $TEST_RESULT -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}              🎉 ALL TESTS PASSED!                 ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}═══════════════════════════════════════════════════${NC}"
    echo -e "${RED}              ❌ SOME TESTS FAILED                 ${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════${NC}"
    exit 1
fi
