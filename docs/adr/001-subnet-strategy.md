# ADR-001: Subnet Strategy for Rep-2 VPC

**Status:** Accepted  
**Date:** 2026-07-04  
**Deciders:** Albert Rubio

## Context

We are building a free-tier AWS VPC as a Terraform + networking learning exercise. Requirements:

- VPC CIDR: `10.0.0.0/16`
- Two Availability Zones
- Public and private subnet split
- Must demonstrate proper subnetting practices (hand-carved CIDRs vs `cidrsubnet()`)
- Must stay within free-tier constraints (no paid resources)

## Decision

We will first manually calculate (hand-carve) the subnet CIDRs on paper to demonstrate understanding of subnetting fundamentals. We will then implement the same design using Terraform’s `cidrsubnet()` function and verify equivalence with a zero-change `plan`.

Final subnet layout:
- `10.0.0.0/24` – Public Subnet AZ-1
- `10.0.1.0/24` – Public Subnet AZ-2
- `10.0.10.0/24` – Private Subnet AZ-1
- `10.0.11.0/24` – Private Subnet AZ-2

**Important constraint:** This exercise will **not** include NAT Gateways. Private subnets will have no outbound internet access.

## Block Boundaries (Summary CIDRs)

Both public subnets (`10.0.0.0/24` + `10.0.1.0/24`) are summarized by `10.0.0.0/23`.  
Both private subnets (`10.0.10.0/24` + `10.0.11.0/24`) are summarized by `10.0.10.0/23`.

These summary CIDRs enable clean tier-level route table entries and security rules. Note that this numbering scheme has asymmetric growth characteristics: public subnets (starting at netnum 0) can expand cleanly to four subnets and still summarize as one `/22`, while private subnets (starting at netnum 10) would fragment into two separate `/23` blocks if expanded the same way.

## Alternatives Considered

| Option                        | Pros                                      | Cons                                              | Verdict |
|------------------------------|-------------------------------------------|---------------------------------------------------|---------|
| Hardcode all CIDRs manually   | Simple, explicit, good for learning       | Error-prone at scale, repetitive                  | Accepted as baseline step |
| Use `cidrsubnet()` function   | Dynamic, maintainable, follows best practices | Requires understanding of the function            | Accepted as final implementation |
| Use `/28` subnets             | More subnets possible                     | High overhead (AWS reserves 5 IPs per subnet), harder to read | Rejected |
| Use larger subnets (e.g. /22) | More IPs per subnet                       | Fewer total subnets, less subnetting practice     | Rejected |

## Consequences

**Positive:**
- Demonstrates both manual subnetting skill and Terraform automation
- Each tier (public and private) is cleanly summarizable as a single `/23`, enabling simple tier-level route table entries and security rules
- Zero-change plan proves the hand-carved and `cidrsubnet()` approaches are equivalent
- Creates a repeatable, maintainable subnetting pattern

**Negative:**
- Requires doing the math twice (once by hand, once in code)
- Private subnets have no outbound internet access in this version

**Neutral:**
- Still comfortably within free-tier limits (no NAT Gateway)

## Acceptance Criteria

- Hand-carved design matches `cidrsubnet()` output exactly
- `terraform plan` shows zero changes after switching to `cidrsubnet()`
- No NAT Gateway is created in the configuration