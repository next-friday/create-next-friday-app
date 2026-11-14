# Plan: CI that runs what a change needs

Accepted by: @joetakara.

## Files that change

- `templates/turborepo/apps/app/Dockerfile`, `templates/turborepo/apps/backoffice/Dockerfile` (changed): a `prune` stage runs `turbo prune <app> --docker`, and the build stage installs from its output.
- `templates/turborepo/.dockerignore` (changed): lets `turbo.json` in, which `turbo prune` reads.
- `templates/turborepo/turbo.json`, `templates/deploy-railway/turborepo/turbo.json` (changed): `"concurrency": "2"`.
- `.github/workflows/ci.yml` (changed, committed by a person): the Release Integrity job is removed; the version pull request still runs the format, manifest, build, and publint checks of the other jobs.
- `.agents/rules/github-workflows.md`, `.agents/rules.json`, each stack's `.agents/rules.json`, `templates/base/.agents/rules/github-workflows.md`, and the rendered copies under `.claude/rules/` and `.cursor/rules/` (new, committed by a person): the workflow rule.
- `scripts/sync-agent-rules.ts`, `templates/base/scripts/sync-agent-rules.ts` (changed, committed by a person): the skill and subagent paths that no longer exist are removed.

## Order of work

1. The prune stage. Check: in a generated turborepo project, `turbo prune`, `pnpm install --frozen-lockfile` on its output, and the app's build pass for both apps.
2. The concurrency. Check: the `turbo.json` drift test in `test/create.test.ts`.
3. The files a person commits, in one issue. Check: `node scripts/check-agent-gates.ts`, `pnpm rules:check`, and `pnpm verify` in a generated project of each stack, with the patches applied.

## Risks

- No `docker build` proves the prune stage; its commands are run one by one, which proves the steps but not the image. The Container Image job of a generated turborepo project builds the image in its own CI.
- A concurrency of 2 is a starting value for a two-core runner; the spec's area of concern asks for it to be measured.

## Proof

- 1: the turborepo template's `affected-apps` job and the image matrix over its list.
- 2: `TURBO_FILTER=--affected` and `"concurrency": "2"` in `turbo.json`.
- 3: the `prune` stage of both Dockerfiles, proven by running its commands.
- 4: Release Integrity is removed from the root `ci.yml`.
- 5, 6: the `changes` job and the final `ci` job in the root and template `ci.yml`.
- 7: `inputs` and `futureFlags.affectedUsingTaskInputs` in `turbo.json`; the docs site is withdrawn.
- 8: the scanners stay behind `CODE_SCANNING`, as the spec's status line says.
- 9, 10: `secret-scan.yml`, diff-cover, Codecov, and the Template job's actionlint and zizmor.
- 11: `.github/labeler.yml` has no `changes` key.
- 12: `.agents/rules/github-workflows.md`, scoped to `.github/**`.
