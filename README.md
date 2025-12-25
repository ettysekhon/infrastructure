# Terraform – Identity & Workload Identity Federation (GCP)

This repository contains the **foundational Google Cloud identity infrastructure**
used across multiple application repositories.

The primary objective is to provide a **secure, reusable, and auditable**
Workload Identity Federation (WIF) setup for GitHub Actions without using
long-lived service account keys.

---

## What This Repository Is

This repo owns **shared, low-churn infrastructure**, specifically:

- GitHub Actions → GCP authentication via **Workload Identity Federation**
- The Google Cloud service account used by CI/CD pipelines
- The backing GCS bucket used for Terraform remote state

This infrastructure is intentionally separated from application repositories
to avoid duplication, drift, and accidental privilege escalation.

---

## Repository Structure

```text
terraform/
├── bootstrap/ # One-time bootstrap (remote state bucket)
│ ├── main.tf
│ └── .terraform.lock.hcl
│
├── identity/ # WIF + Service Account
│ ├── main.tf
│ ├── providers.tf
│ ├── versions.tf
│ ├── variables.tf
│ ├── outputs.tf
│ └── .terraform.lock.hcl
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
