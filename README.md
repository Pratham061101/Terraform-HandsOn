# Terraform Hands-On

A hands-on collection of Terraform configurations for learning and practicing Infrastructure as Code (IaC). This repository is intended as a sandbox to explore Terraform fundamentals (providers, resources, variables, outputs, state), safe workflows (plan/apply/destroy), and common patterns you’ll use in real projects.

> Note: I can’t see this repository’s current folder structure from here, so the sections below are written to be **structure-agnostic**. After you paste it in, please update the **Repository Structure** section to match your actual directories (examples/modules/provider-specific folders, etc.).

---

## Contents

- [Terraform Hands-On](#terraform-hands-on)
  - [Who this is for](#who-this-is-for)
  - [Prerequisites](#prerequisites)
  - [Recommended setup](#recommended-setup)
  - [Repository structure](#repository-structure)
  - [Quickstart (safe workflow)](#quickstart-safe-workflow)
  - [Configuration](#configuration)
    - [Variables](#variables)
    - [Environment variables](#environment-variables)
    - [Credentials and secrets](#credentials-and-secrets)
  - [State & backends](#state--backends)
  - [Common commands](#common-commands)
  - [Destroy / cleanup](#destroy--cleanup)
  - [Best practices & safety](#best-practices--safety)
  - [Troubleshooting](#troubleshooting)
  - [Contributing](#contributing)
  - [License](#license)

---

## Who this is for

- Beginners learning Terraform from scratch
- Engineers practicing repeatable Terraform workflows
- Anyone who wants a set of small, runnable Terraform exercises

---

## Prerequisites

- **Terraform** installed (recommended: latest stable in the `1.x` series)
- Access to the target platform you’re provisioning (cloud account, Kubernetes cluster, etc.)
- Relevant CLI tools if applicable, for example:
  - AWS CLI / Azure CLI / gcloud
  - kubectl (if working with Kubernetes)
- Git

Optional but recommended:
- **tflint** (linting)
- **terraform-docs** (auto-generate module docs)
- **pre-commit** (format/lint hooks)

---

## Recommended setup

### 1) Verify Terraform

```bash
terraform version
```

### 2) Format-on-save / formatting

Terraform formatting is built-in:

```bash
terraform fmt -recursive
```

---

## Repository structure

Update this section to reflect your repo:

- `examples/` – runnable Terraform examples (start here)
- `modules/` – reusable Terraform modules (DRY building blocks)
- `environments/` – environment-specific compositions (dev/stage/prod)
- `scripts/` – helper scripts (bootstrap, cleanup, etc.)
- `README.md` – you are here

If your repository uses different directories, rename the bullets accordingly.

---

## Quickstart (safe workflow)

> Always start with `init`, run `validate`, inspect `plan`, then `apply`. Prefer small, incremental changes.

1) Go to an example directory (pick one that contains `.tf` files):

```bash
cd examples/<example-name>
```

2) Initialize:

```bash
terraform init
```

3) Validate:

```bash
terraform validate
```

4) Plan (recommended: write a plan file):

```bash
terraform plan -out tfplan
```

5) Apply:

```bash
terraform apply tfplan
```

---

## Configuration

### Variables

Terraform input variables can be provided via:

- `-var 'name=value'`
- `-var-file="file.tfvars"`
- Environment variables with the `TF_VAR_` prefix

Recommended pattern:

1) Copy an example variables file (if present):

```bash
cp terraform.tfvars.example terraform.tfvars
```

2) Edit `terraform.tfvars` locally.

> Do not commit `terraform.tfvars` if it contains environment-specific values or secrets.

### Environment variables

Terraform supports useful environment variables:

- `TF_LOG` (debug logging): `TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`
- `TF_LOG_PATH` (log output file)
- `TF_INPUT=0` (disable interactive prompts in CI)
- `TF_CLI_ARGS_plan` / `TF_CLI_ARGS_apply` (default CLI args)

Example:

```bash
export TF_INPUT=0
export TF_LOG=INFO
```

### Credentials and secrets

- **Never hardcode secrets** in `.tf` files or commit secret `.tfvars`.
- Use your platform’s standard credential mechanism:
  - AWS: profiles, environment variables, or SSO
  - Azure: `az login` / managed identity
  - GCP: `gcloud auth application-default login` / workload identity
- For sensitive values:
  - Mark Terraform variables as `sensitive = true`
  - Prefer secret managers (AWS Secrets Manager, Azure Key Vault, GCP Secret Manager)

---

## State & backends

Terraform state is critical.

- For learning: local state is fine.
- For teams: use a **remote backend** with:
  - encryption at rest
  - access control (least privilege)
  - state locking (prevents concurrent applies)

Typical remote backend options:
- AWS: S3 backend + DynamoDB lock table
- Azure: Azure Storage backend + blob lease locking
- GCP: GCS backend (and locking approach depending on workflow)

> If you add backend configuration, document it in each example/environment and avoid committing secrets.

---

## Common commands

From a directory containing Terraform configuration:

### Initialize

```bash
terraform init
```

### Format

```bash
terraform fmt -recursive
```

### Validate

```bash
terraform validate
```

### Plan

```bash
terraform plan
```

### Apply

```bash
terraform apply
```

### Show outputs

```bash
terraform output
```

### Show state (careful: may contain sensitive data)

```bash
terraform state list
terraform state show <resource_address>
```

---

## Destroy / cleanup

To tear down resources created by a configuration:

```bash
terraform destroy
```

If you used a plan file approach, you can also do:

```bash
terraform plan -destroy -out destroy.tfplan
terraform apply destroy.tfplan
```

> Warning: `destroy` is irreversible and may delete production resources if you target the wrong workspace/account/subscription/project.

---

## Best practices & safety

- **Use least privilege** IAM/role permissions
- Keep examples small and focused; prefer **reusable modules** to avoid duplication (DRY)
- Always review `terraform plan` before applying
- Prefer remote state for shared work
- Use `terraform fmt` and `terraform validate` in CI
- Pin provider versions (and Terraform version) to ensure reproducible runs
- Add resource tags/labels for ownership and cost tracking
- Be mindful of cost: some examples may create billable infrastructure

Suggested `.gitignore` entries (add these if not present):

```gitignore
# Terraform
**/.terraform/*
*.tfstate
*.tfstate.*
crash.log
crash.*.log
*.tfvars
*.tfvars.json
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraform.lock.hcl.bak

# IDE
.vscode/
.idea/
.DS_Store
```

> Note: In many repos you *do* commit `.terraform.lock.hcl` (recommended) for deterministic provider installs. Only ignore it if you have a specific reason.

---

## Troubleshooting

### `Error: Failed to query available provider packages`

- Check internet access / proxy settings
- Run `terraform init -upgrade`
- Verify provider source and version constraints

### `Error: No valid credential sources found`

- Confirm you are logged in (`aws sts get-caller-identity`, `az account show`, `gcloud auth list`, etc.)
- Ensure environment variables/profiles are set correctly
- Check that you are targeting the correct account/subscription/project

### State lock issues

If using a remote backend and you hit a lock:

- Ensure no other `apply` is running
- Investigate the lock record (DynamoDB / storage lease)
- As a last resort, use:

```bash
terraform force-unlock <LOCK_ID>
```

Only do this if you’re sure the lock is stale.

---

## Contributing

Contributions are welcome.

Guidelines:
- Keep examples minimal and well-named
- Prefer module reuse over copy/paste (DRY)
- Add/update documentation when behavior changes
- Run before committing:
  - `terraform fmt -recursive`
  - `terraform validate`
  - `terraform plan` (where applicable)

If you add modules, consider documenting inputs/outputs and adding a short usage example.

---

## License

If this repository contains a `LICENSE` file, that license applies.

If no license file is present yet, consider adding one (MIT/Apache-2.0 are common for learning repos). Until then, default copyright rules apply.

---

## Acknowledgements

- [Terraform by HashiCorp](https://www.terraform.io/)
