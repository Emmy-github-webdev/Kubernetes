# Terraform CI/CD Architecture

This repository implements an enterprise-grade Terraform delivery model designed for security, repeatability, auditability, and operational confidence. The approach combines GitHub Actions, OIDC-based AWS authentication, reusable workflows, policy scanning, drift detection, and environment approvals to make infrastructure changes safer and more governable.

## Why this approach is the right choice

This architecture is not just automation; it is a governance framework for infrastructure delivery.

### 1. Secure by default
- Uses OIDC authentication instead of static AWS access keys.
- Eliminates long-lived credentials from GitHub secrets.
- Reduces the risk of accidental credential exposure and improves compliance posture.

### 2. Reusable and scalable
- A single reusable workflow powers all environments.
- The same validation, planning, and security gates apply consistently across dev, staging, and prod.
- This keeps the platform easy to extend as the infrastructure footprint grows.

### 3. Quality gates before deployment
- Runs Terraform format checks, validation, TFLint, and Checkov in CI.
- Prevents low-quality or non-compliant infrastructure changes from reaching production.
- Creates a stronger engineering standard than basic plan/apply pipelines.

### 4. Safer production operations
- Uses GitHub Environments to enforce approvals before production-level actions.
- Supports manual destroy operations with explicit control.
- Uses immutable plan artifacts so the apply step is based on a verified, generated plan rather than a fresh ad-hoc run.

### 5. Operational visibility and drift control
- Generates PR comments with plan summaries and security results.
- Adds scheduled drift detection to identify infrastructure changes that happened outside the normal pipeline.
- Improves reliability and reduces surprise changes in deployed environments.

---

## Repository structure

The recommended layout for this setup is:
```
.github/
  workflows/
    terraform.yml
    reusable-terraform.yml
    terraform-drift.yml

infra/
  environments/
    dev/
    staging/
    prod/
  terraform/
  
```
---

## Workflow design

### 1. Main CI/CD workflow
File: .github/workflows/terraform.yml

This workflow acts as the entry point for:
- pushes to develop, staging, main, and feature branches
- pull requests targeting staging and main
- manual workflow dispatch

It determines the target environment and action, then calls the reusable Terraform workflow.

### 2. Reusable Terraform workflow
File: .github/workflows/reusable-terraform.yml

This is the core execution path and includes:
- Terraform setup and caching
- OIDC-based AWS authentication
- terraform init
- terraform fmt -check
- terraform validate
- TFLint
- Checkov
- terraform plan
- plan artifact generation
- PR plan comments
- apply / destroy execution for approved paths

### 3. Drift detection workflow
File: .github/workflows/terraform-drift.yml

This workflow runs on a schedule and on demand to detect configuration drift between the desired Terraform state and the actual cloud infrastructure.

---

## Security and compliance benefits

This design improves the organization’s infrastructure posture in several important ways:

- No static AWS keys stored in GitHub secrets
- Least-privilege access through OIDC role assumption
- Mandatory checks before deployment
- Security scanning with Checkov
- Linting with TFLint
- Environment-level approval controls
- Full audit trail through GitHub Actions logs and artifacts

This is exactly the kind of automation leadership expects from a mature cloud platform team.

---

## Why this is better than a basic Terraform pipeline

A basic pipeline usually does only this:
- terraform init
- terraform apply

That is not enough for production-grade infrastructure.

This architecture adds the controls that matter:
- policy and quality enforcement
- secure authentication
- approval workflows
- drift visibility
- repeatable deployment behavior
- clearer reviewer feedback on pull requests

In short, this is a platform-grade delivery model rather than a simple script runner.

---

## Operational advantages

- Faster onboarding for new engineers because the workflow is centralized
- Consistent behavior across environments
- Easier troubleshooting because every run is logged and traceable
- Better protection against accidental changes and unsafe deployments
- Stronger alignment with cloud governance and compliance expectations

---

## Recommended governance next steps

To fully operationalize this model, the following should be enabled:

1. Configure GitHub Environments for dev, staging, and prod
2. Add required reviewers to protected environments
3. Set up branch protection rules on main and staging
4. Ensure the AWS IAM role trusted by GitHub OIDC is correctly scoped
5. Monitor drift detection results and review findings regularly

---

## Executive summary

This Terraform CI/CD setup represents a production-ready, enterprise-aligned approach to infrastructure automation. It combines security, discipline, visibility, and control in one maintainable framework.

It is the best choice because it:
- protects cloud credentials properly
- improves deployment quality
- reduces operational risk
- supports audit and governance requirements
- scales cleanly across environments

This is the kind of architecture that gives leadership confidence that infrastructure changes are being managed responsibly and professionally.
