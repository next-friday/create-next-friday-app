# Plan: Dependencies at their latest release

Accepted by: @joetakara.

## Files that change

- `.nvmrc`, `templates/base/.nvmrc` (changed): Node.js 26.13.0, the first LTS of 26.
- `package.json`, each `templates/<stack>/package.json`, and the turborepo apps' `package.json` (changed): the `@next-friday/*` configs at 5.2.1, pnpm 12.18.0, `engines.node` `>=26.13.0 <27` in the templates, and each dependency `pnpm outdated` listed at its latest release that is seven days old.
- Each stack's `Dockerfile` (changed): `node:26.13.0-alpine` by digest, and Corepack 0.36.0 installed before `corepack enable`, because Node.js 25 and later no longer ship Corepack.
- Each stack's `AGENTS.md` and `bug.yml` (changed): the Node.js version they name.
- `pnpm-workspace.yaml`, `templates/base/pnpm-workspace.yaml`, `templates/turborepo/pnpm-workspace.yaml` (changed): `minimumReleaseAge: 10080`, `@next-friday/*` excluded by pattern, and pruning of stale entries.
- `.github/dependabot.yml`, `templates/base/.github/dependabot.yml`, `templates/turborepo/.github/dependabot.yml` (changed): the npm `cooldown` excludes `@next-friday/*`.
- `README.md`, `CONTRIBUTING.md` (changed): the Node.js version of a generated project, and installing Corepack before `corepack enable`.
- `.github/workflows/ci.yml` (changed, committed by a person): Compatibility also runs Node.js 26.13.0.

## Order of work

1. The root's versions and lockfile. Check: `pnpm outdated` lists nothing, and `pnpm verify` passes on Node.js 26.13.0.
2. The templates' versions. Check: `pnpm outdated -r` in a generated project of each stack lists nothing that is seven days old.
3. The release age and Dependabot settings. Check: `pnpm verify` in a generated project of each stack with each deploy target.

## Risks

- Node.js 26 is a major: a package that rejects it fails `pnpm install` under `engineStrict`, and Node.js 26 ships no Corepack. Proof 7 covers the first; each Dockerfile installs Corepack for the second.
- Renovate is withdrawn, so Node.js majors move by hand, as each stack's `CONTRIBUTING.md` says.

## Proof

- 1: the versions above; `pnpm outdated` in the root and in each generated project lists nothing seven days old.
- 2: the `exclude` entry in each npm `cooldown`.
- 3: the `cooldown` of seven days stays in each `dependabot.yml`.
- 4: withdrawn, as the spec's status line says.
- 5: no `dependabot.yml` ignores every major.
- 6: `minimumReleaseAge: 10080` in each `pnpm-workspace.yaml`.
- 7: `pnpm verify` passes in a generated project of each stack with each deploy target, on Node.js 26.13.0.
