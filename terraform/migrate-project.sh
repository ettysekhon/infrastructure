#!/bin/bash
set -euo pipefail

if [ $# -ne 2 ]; then
    echo "Usage: $0 OLD_PROJECT_ID NEW_PROJECT_ID"
    echo "Example: $0 simple-gcp-data-pipeline my-new-project"
    exit 1
fi

OLD_PROJECT="$1"
NEW_PROJECT="$2"
OLD_BUCKET="tf-state-${OLD_PROJECT}"
NEW_BUCKET="tf-state-${NEW_PROJECT}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Migrating from: $OLD_BUCKET"
echo "Migrating to:   $NEW_BUCKET"
echo ""

find "$SCRIPT_DIR" -type f \( -name "*.tf" -o -name "*.hcl" \) -exec \
    sed -i '' "s/${OLD_BUCKET}/${NEW_BUCKET}/g" {} \;

sed -i '' "s/project_id.*=.*\"${OLD_PROJECT}\"/project_id     = \"${NEW_PROJECT}\"/g" \
    "$SCRIPT_DIR/config/terraform.tfvars"

echo "Updated files:"
grep -rl "$NEW_BUCKET" "$SCRIPT_DIR" --include="*.tf" --include="*.hcl" | sed 's|^|  |'

echo ""
echo "Next steps:"
echo "  1. Update project_number in config/terraform.tfvars"
echo "  2. Run bootstrap in new project"
echo "  3. make apply"
