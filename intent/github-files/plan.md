# Plan: GitHub files, recorded after the build

Accepted by: @joetakara.

The change was built before this repository committed a plan for each change. The product owner accepted this record when the open specs were closed, so it lists where each requirement is in the tree rather than a plan made before the code.

## Files that change

- `templates/base/SECURITY.md` (changed): reporters write to the security contact.
- `templates/base/SETUP.md` (changed): the step that replaces the contact, and the security settings.
- `templates/base/.github/workflows/secret-scan.yml` (existing): gitleaks and TruffleHog.
- `templates/base/.github/ISSUE_TEMPLATE/documentation.yml` and `.github/ISSUE_TEMPLATE/documentation.yml` (new): the documentation issue form.
- `CONTRIBUTING.md` and each stack's `CONTRIBUTING.md` (changed): how to ignore a formatting commit in blame.

## Order of work

1. Built before this record; the Proof names where.

## Risks

- None open: each requirement is in the tree, as the Proof names.

## Proof

- 1: `templates/base/SECURITY.md` names `security@example.com`, and `templates/base/SETUP.md`, step 2, replaces it.
- 2: the root `SECURITY.md` links Private Vulnerability Reporting.
- 3: `templates/base/SETUP.md`, step 3, turns on Dependabot alerts and security updates, and secret scanning with Secret Protection only.
- 4: `templates/base/.github/workflows/secret-scan.yml` runs gitleaks and TruffleHog.
- 5: both `documentation.yml` forms carry the labels `documentation` and `needs triage`.
- 6: no `.git-blame-ignore-revs` is committed, and `CONTRIBUTING.md` says how to add one.
- 7: `pnpm verify` passes in a generated project of each stack.
