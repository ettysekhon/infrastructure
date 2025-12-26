# Terraform – Shared Infrastructure (GCP)

This repository contains the **foundational Google Cloud infrastructure** used across multiple application repositories.

The primary objective is to provide **secure, reusable, and auditable** infrastructure components, including Workload Identity Federation (WIF), GKE Autopilot clusters, and Artifact Registries.

---

## What This Repository Is

This repo owns **shared, low-churn infrastructure**, specifically:

- GitHub Actions → GCP authentication via **Workload Identity Federation**
- The Google Cloud service account used by CI/CD pipelines
- The backing GCS bucket used for Terraform remote state
- **GKE Autopilot** clusters for containerised workloads
- **Artifact Registry** repositories for container images

This infrastructure is intentionally separated from application repositories
to avoid duplication, drift, and accidental privilege escalation.

---

## Repository Structure

```text
terraform/
├── artifact-registry/ # Artifact Registry configuration
│   ├── backend.tf
│   ├── main.tf
│   ├── providers.tf
│   └── variables.tf
│
├── bootstrap/ # One-time bootstrap (remote state bucket)
│   ├── main.tf
│   └── .terraform.lock.hcl
│
├── gke-autopilot/ # GKE Autopilot cluster
│   ├── Makefile
│   ├── README.md
│   ├── main.tf
│   ├── outputs.tf
│   ├── tests/
│   └── variables.tf
│
├── identity/ # WIF + Service Account
│   ├── main.tf
│   ├── providers.tf
│   ├── versions.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── .terraform.lock.hcl
│
└── modules/ # Shared modules
    └── artifact-registry/
```

Each directory under `terraform/` is a **stand-alone Terraform root module** with its own backend and provider lock file.

This is deliberate and follows HashiCorp best practice.

---

## Terraform Versioning

- Terraform `>= 1.14`
- Google provider `~> 7.x`
- Provider versions are locked per root module via `.terraform.lock.hcl`

Lock files **must be committed**.

---

## Bootstrap (Run Once)

The `bootstrap` module creates the GCS bucket used for remote state.

Run this **once per project**:

```bash
cd terraform/bootstrap
terraform init
terraform apply -var="project_id=<PROJECT_ID>"
```

The bucket is protected with `prevent_destroy = true`.

---

## Identity (Workload Identity Federation)

The `identity` module creates:

- A Workload Identity Pool
- A GitHub OIDC provider
- A service account for CI/CD
- IAM bindings allowing GitHub Actions to impersonate the service account

This module is **idempotent** and safe to re-apply.

### Example

```bash
cd terraform/identity
terraform init
terraform apply
-var="project_id=<PROJECT_ID>"
-var="github_owner=<GITHUB_ORG_OR_USER>"
```

---

## GKE Autopilot

The `gke-autopilot` module provisions a regional, secure-by-default Kubernetes cluster.

- **Autopilot Mode**: Enabled
- **Network**: Private nodes (default)
- **Security**: Workload Identity enabled

Example:

```bash
cd terraform/gke-autopilot
terraform init
terraform apply -var="project_id=<PROJECT_ID>"
```

---

## Artifact Registry

The `artifact-registry` module creates repositories for storing Docker images.

- **Format**: Docker
- **Cleanup Policies**: Configurable

---

## Outputs

The following outputs are intentionally exposed for consumption by
application repositories:

- `service_account_email`
- `wif_provider`

These values are injected into GitHub Actions as secrets.

---

## State Management

- Terraform state is stored in **Google Cloud Storage**
- Local state files are never committed
- State locking and versioning are enabled

This repository assumes **one state bucket per GCP project**.

---

## Importing Existing Infrastructure

If identity resources already exist (e.g. created manually via `gcloud`),
they **must be imported** before applying Terraform.

This is expected behaviour and not an error.

---

## Security Notes

- No service account keys are created
- Authentication uses short-lived OIDC tokens
- Access is restricted by GitHub repository owner
- Fine-grained repository scoping can be added if required

---

## Intended Usage Pattern

- This repo is applied rarely
- Application repos reference its outputs
- CI/CD pipelines authenticate via WIF
- No application repo creates identity infrastructure

This separation is intentional.

---

## Ownership

This repository is considered **platform infrastructure**.

Changes should be:
    - Reviewed carefully
    - Applied deliberately
    - Communicated to dependent repositories
