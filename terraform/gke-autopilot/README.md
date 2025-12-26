# GKE Autopilot Terraform Module

## Overview

This module provisions a **Google Kubernetes Engine (GKE) Autopilot** cluster. It is designed to provide a secure, managed Kubernetes environment with minimal operational overhead.

Key features configured by this module:

- **Autopilot Mode**: Enabled by default to abstract node management and improve security posture.
- **Regional Availability**: Deployed regionally (defaulting to `europe-west2`) for high availability.
- **Identity**: Configured with Workload Identity Federation for secure GitHub Actions integration.
- **Standardised Naming**: Enforces naming conventions based on environment, whilst allowing overrides where necessary.

## Project Structure

```bash
terraform/gke-autopilot
├── Makefile
├── README.md
├── main.tf
├── outputs.tf
├── tests
│   └── unit.tftest.hcl
└── variables.tf
```

## Usage

To include this module in your Terraform configuration, use the following block:

```hcl
module "gke_autopilot" {
  source = "./modules/gke-autopilot"

  project_id = "my-project-id"
  
  # Optional overrides
  environment  = "prod"
  region       = "europe-west2"
  cluster_name = "my-custom-cluster" # Defaults to mcp-{environment}-autopilot

  # Identity & Access Configuration
  project_number                = "123456789012"
  github_owner                  = "my-org"
  workload_identity_pool_id     = "my-pool"
  workload_identity_provider_id = "my-provider"
  service_account_name          = "terraform-sa"
  github_actions_sa_email       = "terraform-sa@my-project.iam.gserviceaccount.com"
}
```

## Inputs

| Name | Description | Type | Default | Required |
| ------ | ------------- | ------ | --------- | :--------: |
| `project_id` | The Google Cloud Project ID where the cluster will be created. | `string` | n/a | yes |
| `region` | The GCP region for the cluster. | `string` | `europe-west2` | no |
| `environment` | The target environment (e.g., `dev`, `prod`). Used for naming if `cluster_name` is unset. | `string` | `dev` | no |
| `cluster_name` | Explicit name for the cluster. If null, defaults to `mcp-{environment}-autopilot`. | `string` | `null` | no |
| `project_number` | The GCP Project Number. | `string` | n/a | yes |
| `github_owner` | The GitHub organization or user owner of the repository. | `string` | n/a | yes |
| `workload_identity_pool_id` | The ID of the Workload Identity Pool. | `string` | n/a | yes |
| `workload_identity_provider_id` | The ID of the Workload Identity Provider. | `string` | n/a | yes |
| `service_account_name` | The name of the Service Account used for operations. | `string` | n/a | yes |
| `github_actions_sa_email` | The email address of the Service Account used by GitHub Actions. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ------ | ------------- |
| `cluster_name` | The name of the created GKE cluster. |
| `region` | The region where the cluster is deployed. |
| `cluster_id` | The unique identifier of the cluster. |
| `cluster_endpoint` | The IP address of the cluster master endpoint. |

## Testing

This module uses the native `terraform test` framework for unit testing.

### Running Tests

Ensure you have Terraform v1.6+ installed.

```bash
terraform init
terraform test
```

The tests cover:

- **Default Configuration**: Verifies standard naming conventions and default region.
- **Custom Configuration**: Verifies that overrides for names and regions are respected.
- **Security Controls**: Asserts that Autopilot is enabled and deletion protection is configured as expected for the module's current state.
