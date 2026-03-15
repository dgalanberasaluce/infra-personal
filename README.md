# Infrastructure
Repository to manage my personal infrastructure.

This repository contains the configuration files and documentation used to test, deploy and manage my self-hosted infrastructure.

It serves as:
- A single source of truth for infrastructure and services
- A learning playground for DevOps, SRE, and platform engineering concepts
- A reproducible and documented setup for experimentation and automation

## Tech Stack

The homelab is built using a combination of the following tools:

- Terraform/OpenTofu: Infrastructure provisioning
- Ansible: Configuration management and host provisioning
- Docker / Docker Compose: Application and service orchestration

## Development
Secret detection setup:
- `brew install pre-commit gitleaks`
- Create `.pre-commit-config.yaml`
- Run `pre-commit install` to set up the pre-commit hooks
- Create `.gitleaksignore` to specify patterns to ignore during secret detection

## References
- https://github.com/JamesTurland/JimsGarage
- https://github.com/lingrino/infra-personal
- https://github.com/ChristianLempa
- https://github.com/mkuthan/homelab-public
