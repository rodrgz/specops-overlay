# Concerns

Template note: fill this file in the repository that adopts SpecOps Overlay.
Until then, the fields below are placeholders, not project facts.

Use this file to capture known risks, constraints, tradeoffs, and operational
concerns that should influence planning and implementation in the adopting
repository.

## Fill After Adoption

- Security concerns:
- Privacy or compliance concerns:
- Performance limits:
- Reliability risks:
- Migration or rollout risks:
- Known technical debt:
- Local development constraints:
- Production constraints:

## OpenSpec Use

When creating OpenSpec proposals and designs, call out relevant concerns and
explain how the change handles them.

## Secret Scanning

Do not commit secrets in source files, docs, fixtures, logs, or generated
evidence. In this overlay repository, `scripts/validate.sh` scans tracked files
for obvious secret patterns. Adopting repositories should keep an equivalent
secret scanning gate in local validation or CI.
