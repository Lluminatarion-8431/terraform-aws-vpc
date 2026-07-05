# Multi-AZ AWS VPC — Terraform Infrastructure as Code

> A clean, design-first AWS VPC built with Terraform to demonstrate real engineering discipline.

---

## Project Overview

This project shows what happens when you treat infrastructure as **real engineering work** instead of just clicking buttons in the console.

I built a multi-AZ AWS VPC in two deliberate phases:

- **Phase 1**: Hand-calculated every subnet CIDR on paper to prove I actually understand subnetting fundamentals.
- **Phase 2**: Refactored the entire design to use Terraform’s `cidrsubnet()` function — and proved it with a **zero-diff plan**.

The result is a clean, well-documented VPC with proper public/private tier separation and explicit route table isolation.

---

## Key Technical Highlights

- **Design-first approach** — Every major decision documented in ADR-001 before writing code
- **Zero-diff refactoring** — Moved from hand-carved CIDRs to `cidrsubnet()` with no infrastructure drift
- **Explicit private route tables** — Clean separation between public and private tiers (no implicit routing)
- **Multi-AZ design** — Workloads spread across two Availability Zones
- **Full lifecycle demonstrated** — plan → apply → update-in-place → destroy
- **100% free-tier compliant** — No NAT Gateways or paid resources
- **Professional Git history** — Phased commits with clear intent

---

## Architecture Decision Record

All important design decisions are captured in `docs/adr/`.

- **[ADR-001: Subnet Strategy for Rep-2 VPC](docs/adr/001-subnet-strategy.md)**  
  Covers hand-carved vs programmatic subnetting, tier summarization, and constraints.

---

## Subnet Design

| Tier      | Name        | CIDR            | AZ          | Public IP | Route Table     |
|-----------|-------------|------------------|-------------|-----------|-----------------|
| Public    | public-1    | `10.0.0.0/24`    | us-west-2a  | Yes       | Public          |
| Public    | public-2    | `10.0.1.0/24`    | us-west-2b  | Yes       | Public          |
| Private   | private-1   | `10.0.10.0/24`   | us-west-2a  | No        | Private         |
| Private   | private-2   | `10.0.11.0/24`   | us-west-2b  | No        | Private         |

**Summary CIDRs:**
- Public tier: `10.0.0.0/23`
- Private tier: `10.0.10.0/23`

---

## Architecture

```
[ Internet ]
      ↓
[ Internet Gateway ]
      ↓
[ Public Subnets (AZ-1 & AZ-2) ]  ← Public Route Table
      ↓
[ Private Subnets (AZ-1 & AZ-2) ] ← Private Route Table (isolated)
```

Private subnets have **no outbound internet access** by design (free-tier constraint).

---

## What This Project Demonstrates

- Strong understanding of AWS networking and subnetting fundamentals
- Ability to follow a structured, **design-first** engineering process
- Safe and verifiable refactoring using Infrastructure as Code
- Discipline in documentation, Git history, and Architecture Decision Records
- Production-minded thinking (isolation, summarization, explicit intent)

---

## Repository Structure

```
terraform-aws-vpc/
├── main.tf
├── docs/
│   └── adr/
│       └── 001-subnet-strategy.md
├── .gitignore
├── terraform.lock.hcl
└── README.md
```

---

## Technologies Used

- **Terraform**
- **AWS** (VPC, Subnets, Internet Gateway, Route Tables)
- **Git + GitHub**

---

## Quick Start

```bash
git clone https://github.com/Lluminatarion-8431/terraform-aws-vpc.git
cd terraform-aws-vpc
terraform init
terraform plan
terraform apply
```

---

## Related Work

- [engineering-log](https://github.com/Lluminatarion-8431/engineering-log) — Personal engineering knowledge system
- Part of ongoing Network Engineering & DevOps portfolio development

---

**Built with care.** Not hype.

---