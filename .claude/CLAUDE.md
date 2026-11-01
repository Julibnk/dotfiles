# Global User Preferences

## Language and response style

- **Answer in the language I write in**: if I write in Spanish, answer in Spanish; if I write in English, answer in English.

## Hard rules — never break these

- **gcloud CLI**: never run any `gcloud` command, for any reason. If a task needs one, tell me the command and I will run it myself.

- **YouTrack MCP (admin)**: never use the YouTrack MCP for workspace admin — users, permissions, project settings. Use it only to read tickets and issues tied to code work.

- **Commits need my OK first; pushes are mine**: when the work is ready, propose the commit — the files you will stage, the ones you will leave out (including my earlier changes), and the message — then wait. Run `git commit` only after I approve that commit in the same session, even when a skill's steps say to commit. Never run `git push`; I push myself.

- **External artifacts**: never create or change YouTrack tickets, PRs, issue comments or Slack messages without my explicit OK in that same session. "I want a ticket about X" is the request, not the approval. Write the full draft, show it to me, and wait. Research and drafting need no approval — only the call that publishes does.

- **Prisma/DB commands** (`prisma:push`, `migrate`): suggest them and offer to run them, then wait. I run those myself. Code edits you apply directly.

## Code comments

- **General behaviour, not decisions**: a comment says what the code does. Add detail only where the code does not explain itself.
- **Do not narrate the change**: no "now it's X", no "we used to use Y", no "we changed Z". Present tense, describing behaviour — git already holds the history. Test: would it still make sense read in six months, by someone who never saw the PR?
- **Human-readable**: write comments as short, natural sentences with proper articles and connectors — never as a bare sequence of keywords.
- **Short**: one line is usually enough. Cut blocks of 3+ lines that justify a design or copy prose from a spec; that belongs in the PR. One-line docstrings on classes, functions and modules are fine — do not strip them.
- **No ticket codes** (`PRDT-XXXX`, `ENG-XXX`) inside comments. The link to the ticket lives in the branch, the commit or the PR. Exception: `// TODO:` markers for deferred work.
- **No `.scratch/` references**: not in code, comments, docstrings, tests, READMEs or PR descriptions — and not indirectly either ("the spec directory", "owned by a separate spec"). It is local, throwaway material that expires on merge. State the reason or the status directly ("Choosing that seam is still pending"). Exception: the repo's `AGENTS.md`, which documents the convention on purpose.

## Code style (TS)

- **Plain functions over arrow functions**: use `function` declarations (e.g. `export async function foo() {}`) instead of arrows assigned to a const (`const foo = async () => {}`) for named functions — services, controllers, helpers. Arrows only for inline callbacks (`.map(x => …)`) where a name adds nothing. Use hoisting to keep helpers at the end of the file.
- **Function names start with a verb**: `add_data`, `sort_by_id`, `index_canonical_names`, `match_candidate_name`. Never noun phrases (`canonical_names_by_normalized`) or adjectives (`normalized`). Same for private helpers and for test factories (`make_element`, not `element`).
- **Group helpers by what they do**: 1–3 files per feature, named for the behaviour (`menuTree.ts`, `menuValidation.ts`). Never one file per function. Mirror tests 1:1 (`menuTree.test.ts`). No barrels of micro-modules.
- **camelCase for files and directories**, with dot suffixes for the file type: `dashboardMenu.service.ts`, `dashboardMenu.routes.ts`, `features/dashboardMenu/`. Never kebab-case.
- **Inline `export interface`** for new types, instead of the two-step `export type { Foo }`, even where the repo uses the two-step form. Keep two steps for barrels that re-export from several files.

## Tooling

- **JSON**: use `jq` as the main tool to read, filter and transform JSON — API responses, config files, and so on. Prefer it over one-off Python or Node scripts.
- **YAML**: use `yq` to read, filter and transform YAML — k8s/Config Connector manifests, workflows, config files. Never pull YAML fields out with `rg`/`sed`/`awk` or an ad-hoc Python/Node parser: `yq` handles multi-document files (`---`), block scalars and anchors correctly. For multi-document files use `yq eval-all`, or `yq '...' file.yml` with the right flag.
- **File search**: always use `rg` (ripgrep), never `grep`. That includes recursive searches — `rg` is recursive by default.

## Branches, commits and PRs

- **YouTrack naming**: branches are `PRDT-1234-short-description` — the issue ID plus a short kebab-case description taken from the summary. The PR title carries the `[PRDT-1234] Description` prefix.
- **Semantic commits**: proposed commit messages follow Conventional Commits — `type(scope): description`. Types: `feat`, `fix`, `chore`, `refactor`, `test`, `docs`, `style`, `perf`, `ci`, `build`. Add the scope in parentheses when the change belongs to one feature (`feat(ai-mapping): improve shared contract`); leave it out otherwise (`chore: bump dependencies`). Write the description in lowercase and in the imperative mood, with no trailing period.
- Before you create a branch or a PR, read the issue with the YouTrack MCP (`get_issue`) to get the real summary and context. If the MCP is not available, ask me for the title instead of inventing one.
- PRs target `master` and go through `gh`. The body must reference the YouTrack issue.
- **Guardrail: never open a PR on your own.** Run `gh pr create` (or a push that opens a PR) only when I ask for it in that session. "Finish the task" and "commit this" do NOT mean create the PR.

## Where to get information

- **Issues and work status** → YouTrack MCP (reads only; the no-admin rule above still holds).
- **Product, feature or user questions** → Slack MCP (search channels and threads) and GitBook MCP (`GitBook MCP` / `Octane11 Docs`).
- If one of these MCPs is not connected in the session, say so instead of answering from memory.
