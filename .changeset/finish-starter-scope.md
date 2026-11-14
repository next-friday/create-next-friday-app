---
"@next-friday/create-app": minor
---

A generated project runs on Node.js 26.13.0 with the `@next-friday/*` configs at 5.2.1 and pnpm 12.18.0, holds new dependencies for seven days at install, and lets `@next-friday/*` updates skip Dependabot's cooldown. The turborepo images build from `turbo prune`, and its tasks run two at a time. The `sdlc` plugin runs `pnpm verify` before an agent's turn ends, refuses a push whose commit was not reviewed or whose plan does not name a changed file, and `pnpm plan:check` refuses a branch that changes code without a plan and a fix that edits an existing test. A rejected intent or spec is merged with `Status: rejected.`, and `SETUP.md` shows who acts at each stage.
