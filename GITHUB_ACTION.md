# GitHub Actions Terraform CI/CD Guide

This document reflects the current GitHub Actions setup in this repository and aligns with the implemented Terraform CI/CD workflow.

## Current architecture

The repository now uses three workflow files:

- .github/workflows/terraform.yml
- .github/workflows/reusable-terraform.yml
- .github/workflows/terraform-drift.yml

## What the workflows do

### 1. Main pipeline: .github/workflows/terraform.yml
This is the entry workflow for:
- pushes to develop, staging, main, and feature branches
- pull requests targeting staging and main
- manual workflow dispatch

It performs two important tasks:
1. Detects the target environment from the branch or manual input.
2. Calls the reusable Terraform workflow with the selected environment and action.

It also uses concurrency control:
- group: terraform-${{ github.ref }}
- cancel-in-progress: true

This prevents old runs from stacking up when a new change is pushed.

### 2. Reusable Terraform workflow: .github/workflows/reusable-terraform.yml
This is the main implementation path used by the CI/CD pipeline.

It currently includes:
- OIDC-based AWS authentication (no static AWS keys)
- Terraform setup and plugin cache
- terraform init
- terraform fmt -check
- terraform validate
- TFLint
- Checkov
- terraform plan
- immutable plan artifact upload
- PR plan summary comments
- apply and destroy execution for approved paths

### 3. Drift detection: .github/workflows/terraform-drift.yml
This workflow runs on a schedule and can also be triggered manually.

It checks for configuration drift across:
- dev
- staging
- prod

This helps identify infrastructure drift that may have occurred outside normal CI/CD changes.

---

## Security model

The current implementation follows an enterprise-grade security pattern:

- Uses GitHub OIDC to assume an AWS role
- Avoids storing long-lived AWS credentials in GitHub secrets
- Uses GitHub Environments for environment-specific approvals
- Uses reusable workflow logic for consistent security and deployment gates
- Stores Terraform plan outputs as artifacts for traceability and replay

---

## Operational benefits

This setup improves the platform in the following ways:

- consistent deployment behavior across environments
- lower risk of accidental credential exposure
- stronger validation and policy checks before deploy
- visibility into pull request changes through plan comments
- better control of drift and infrastructure changes over time
- safer manual operations through explicit apply/destroy paths

---

## Recommended repository governance

To fully align the workflow with production standards, configure the following in GitHub:

1. GitHub Environments for dev, staging, and prod
2. Required reviewers for protected environments
3. Branch protection rules on main and staging
4. Proper IAM trust policy for the GitHub OIDC role
5. Regular review of drift detection outputs

---

## Summary

The current GitHub Actions implementation is a secure, reusable, and production-oriented Terraform delivery model. It combines OIDC authentication, reusable workflows, validation, security scanning, drift detection, and controlled deployment paths into one consistent CI/CD approach.
