---
name: planet-template-update
description: Update and review Planet's bundled template collection in PlanetSiteTemplates. Use when Codex is working in /Users/livid/Developer/PlanetSiteTemplates and needs to run git pull plus git submodule update --remote, analyze submodule pointer changes, inspect template diffs, validate metadata such as template.json buildNumber, and create a commit with a detailed message describing bundled Planet template updates.
---

# Planet Template Update

## Overview

Use this skill for Planet's bundled template collection in PlanetSiteTemplates, where built-in site templates are tracked as submodules under `Sources/PlanetSiteTemplates/Resources/`.

The goal is to update template submodule pointers, understand the upstream template changes behind each pointer bump, run focused validation, and commit only the reviewed submodule updates with a clear multi-paragraph message.

## Update Workflow

1. Start from the PlanetSiteTemplates repository root.
2. Check `git status --short`. If there are unrelated local changes before the update, stop and ask unless the user explicitly said to include them.
3. Run the helper script:

```bash
tools/planet-template-update/scripts/update-and-report.sh --update
```

The zsh helper runs `git pull --ff-only`, `git submodule update --init --remote`, prints superproject status, and reports each changed submodule with old/new SHAs, commit log, diff stat, changed files, and current template metadata.

If sandboxing blocks network access or Git metadata writes, rerun the same command with escalation. Do not replace this with ad hoc commands unless the script itself fails for a real reason.

## Review Workflow

For every changed submodule path reported by the helper:

1. Inspect the upstream commit range:

```bash
git -C <submodule-path> log --oneline --decorate <old-sha>..<new-sha>
git -C <submodule-path> diff --stat <old-sha>..<new-sha>
git -C <submodule-path> diff --name-status <old-sha>..<new-sha>
```

2. Read the actual diffs for changed template, JavaScript, CSS, metadata, and hook files. Use `git -C <submodule-path> diff <old-sha>..<new-sha> -- <file>` for targeted reads.
3. Check `template.json` when it changed or when the template behavior changed:
   - JSON must parse with `jq empty`.
   - `buildNumber` should increase when bundled users need the update. Planet compares existing and bundled build numbers before overwriting installed built-in templates.
   - New settings should have clear names, correct types, safe defaults, and descriptions that match actual behavior.
4. Check template/runtime changes for escaping, optional data, path handling, page-type scope, and generated markup compatibility with Planet's Stencil/Jinja-style templates.
5. Summarize findings first if there are bugs or risks. Do not commit a known blocker unless the user explicitly asks to proceed.

## Validation

Run these before committing reviewed changes:

```bash
git diff --submodule=log --ignore-submodules=none
git diff --check
```

For every changed `template.json`, run:

```bash
jq empty <submodule-path>/template.json
```

Run `swift test` as a package smoke test when time permits. If it fails only because `PlanetSiteTemplatesTests.testBuiltInTemplates` expects `1` template while the package currently loads multiple built-in templates, report that as existing test drift rather than a template update regression.

## Commit Workflow

1. Stage only the reviewed submodule pointer paths:

```bash
git add <submodule-path> [...]
```

2. Create a detailed commit message. For one template, use:

```text
Update <Template> template for <main change>

Advance the bundled <Template> template submodule from <old-sha> to <new-sha>.

This brings in <Template>'s <feature/fix> support:
- <specific upstream change>
- <specific upstream change>
- <metadata or compatibility change>

<Why this matters for generated Planet sites or bundled template users.>
```

For multiple templates, use:

```text
Update bundled site templates

Advance bundled template submodules to their latest reviewed upstream revisions.

<Template A> moves from <old-sha> to <new-sha>:
- <specific upstream change>
- <specific upstream change>

<Template B> moves from <old-sha> to <new-sha>:
- <specific upstream change>

<Why these updates matter for Planet users.>
```

3. Commit with the message. Prefer `git commit -F <message-file>` for multi-paragraph messages when shell quoting would be fragile.
4. Confirm with `git status --short` and `git log -1 --format=fuller`.
5. Final response should include the commit hash, any review findings or residual test failures, and whether the working tree is clean.
