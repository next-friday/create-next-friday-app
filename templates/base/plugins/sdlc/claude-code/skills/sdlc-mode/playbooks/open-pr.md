# Open the pull request

Branch from the latest `origin/main`, and open the pull request ready for review. Name the branch as the project's contributing guide says and fill the body from `.github/pull_request_template.md`. Never merge a pull request: a person merges it with `--squash` after code owner approval, bottom-up for a stack of pull requests.

1. Clean the diff against the default branch. Remove debug output, commented-out code, changes the plan does not name, and comments that add nothing the code does not show.
2. Do what the project's `AGENTS.md` and `CONTRIBUTING.md` require for this kind of change.
3. When step 1 or 2 changed a file, run the checks the project's agent instructions name again. When one fails, fix the code and run it again. Commit only when they pass.
4. Review the commit before you push it, as `playbooks/review.md` step 2 says, and fix every Important finding; a fix is a new commit, which is reviewed again. Then write the full hash of the reviewed commit to the file `git rev-parse --git-path sdlc-review` names. The plugin's push hook refuses a push whose last commit is not that hash, and a push whose commits change a file the change's `plan.md` does not name without changing `plan.md` in the same commit.
5. Push the branch and open the pull request ready for review, as this playbook's opening paragraph says. When the branch already has a pull request, update that one. Fill the body from `.github/pull_request_template.md`:
   - what changed and why, with the paths of `intent/<change>/spec.md` and `plan.md` when they exist;
   - `Closes #<issue>` for each issue that already exists and that the change closes. When there is none, write what the template's own section asks for, and leave it out when the template has no such section.
   - each check you ran, with its result copied from the output.

   When you cannot open a pull request from this session, say so, give the pushed branch's name, and go on to step 6: the review reads the pushed branch's diff.

6. Go on in the same turn, without asking: follow `playbooks/review.md`. Put the findings of step 4 in its comment.

**Hands off to:** `playbooks/review.md`; an agent; in the same turn, as soon as step 5 is done.
