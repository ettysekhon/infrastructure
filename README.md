# Infrastructure

Shared GCP infrastructure for platform services. Manages GKE, Artifact Registry, and GitHub Actions authentication via Workload Identity Federation.

## Quick Start

```bash
cd terraform

make validate  # Plan all stacks
make apply     # Apply all stacks
make format    # Format terraform files
make clean     # Remove .terraform dirs
```

## Architecture

```text
config ─────────────────────────────────────────────────────────────
   │    Single source of truth: project_id, region, environment
   │
   ├─► identity ──► WIF provider, service account
   │
   ├─► cluster ──► cluster endpoint, CA cert
   │       │
   │       └─► namespaces ──► auth-platform, meal-planner
   │
   └─► artifact-registry ──► container registry URL
```

All stacks read from upstream via `terraform_remote_state`. No value re-derivation.

## Structure

```text
terraform/
├── Makefile              # Common commands
├── validate.sh           # Validation script
├── backend.hcl           # State bucket config
├── config/               # Source of truth
│   └── terraform.tfvars  # <-- Edit this for project config
├── bootstrap/            # Creates state bucket (run once)
├── identity/             # GitHub Actions WIF
├── cluster/              # Kubernetes cluster (spot nodes, zonal)
├── artifact-registry/    # Container registry
├── namespaces/           # K8s namespaces
└── modules/              # Shared modules
```

## Bootstrap (First Time Only)

```bash
cd terraform/bootstrap
terraform init
terraform apply -var="project_id=YOUR_PROJECT"
```

Then run `make apply` from the terraform directory.

## Configuration

All project config lives in `terraform/config/terraform.tfvars`:

```hcl
project_id     = "your-gcp-project-id"
project_number = "123456789012"
github_owner   = "your-github-org"
environment    = "dev"
region         = "europe-west2"
```

## Migrating to New GCP Project

Update two files:

1. `terraform/config/terraform.tfvars` — project values
2. `terraform/backend.hcl` — state bucket name

Then update GitHub secrets: `GCP_PROJECT_ID`, `GCP_WIF_PROVIDER`, `GCP_WIF_SA`

Re-run bootstrap, then `make apply`.

## Outputs

Exposed for application repos:

| Stack             | Output                  | Description             |
|-------------------|-------------------------|-------------------------|
| identity          | `wif_provider`          | Full WIF provider path  |
| identity          | `service_account_email` | GitHub Actions SA       |
| cluster           | `cluster_endpoint`      | K8s API endpoint        |
| artifact-registry | `repository_url`        | Docker registry URL     |
| namespaces        | `namespace_*`           | Created namespace names |

## Multi-Environment

Use workspace prefixes:

```bash
terraform init -backend-config=../backend.hcl -backend-config="prefix=prod/platform/config"
```

Or separate backend files: `backend-dev.hcl`, `backend-prod.hcl`

## Security

- No service account keys — OIDC tokens only
- WIF scoped to GitHub owner
- State bucket versioning enabled
- Deletion protection on state bucket
