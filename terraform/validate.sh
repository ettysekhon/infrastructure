#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPLY_MODE="${1:-}"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

log_info "Checking prerequisites..."

command -v terraform &>/dev/null || { log_error "Terraform not found"; exit 1; }
command -v gcloud &>/dev/null || { log_error "gcloud not found"; exit 1; }

if ! gcloud auth application-default print-access-token &>/dev/null; then
    log_warn "Not authenticated. Running: gcloud auth application-default login"
    gcloud auth application-default login
fi

log_info "Prerequisites OK"

BUCKET_NAME=$(grep '^bucket' "$SCRIPT_DIR/backend.hcl" | cut -d'"' -f2)
if gsutil ls "gs://$BUCKET_NAME" &>/dev/null; then
    log_info "State bucket: $BUCKET_NAME"
else
    log_error "State bucket not found: $BUCKET_NAME"
    log_error "Run bootstrap first: cd bootstrap && terraform init && terraform apply"
    exit 1
fi

run_stack() {
    local name=$1
    local dir=$2
    
    log_info "[$name] Initialising..."
    cd "$SCRIPT_DIR/$dir"
    rm -rf .terraform .terraform.lock.hcl 2>/dev/null || true
    terraform init -backend-config=../backend.hcl -reconfigure -input=false
    
    log_info "[$name] Planning..."
    if [ "$APPLY_MODE" = "--apply" ]; then
        terraform apply -auto-approve
    else
        terraform plan
    fi
}

log_info "[config] Initialising..."
cd "$SCRIPT_DIR/config"
rm -rf .terraform .terraform.lock.hcl 2>/dev/null || true
terraform init -backend-config=../backend.hcl -reconfigure -input=false

log_info "[config] Planning..."
if terraform plan -detailed-exitcode; then
    log_info "[config] No changes"
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 2 ]; then
        if [ "$APPLY_MODE" = "--apply" ]; then
            log_info "[config] Applying..."
            terraform apply -auto-approve
        else
            log_warn "[config] Changes detected - run with --apply"
        fi
    else
        log_error "[config] Plan failed"
        exit 1
    fi
fi

run_stack "identity" "identity"
run_stack "cluster" "cluster"
run_stack "artifact-registry" "artifact-registry"
run_stack "namespaces" "namespaces"

echo ""
log_info "Validation complete"
[ "$APPLY_MODE" != "--apply" ] && log_info "Run with --apply to apply changes"
