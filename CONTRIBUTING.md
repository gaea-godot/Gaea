# Contributing to Gaea

Gaea only exists thanks to its contributors. Here's how you can become one:

## 🐞 Reporting Bugs or Requesting Features

If you find any bugs, or you have an idea for a feature, [open an issue](https://github.com/gaea-godot/gaea/issues/new/choose) on this repo (unless it's related to the documentation, in which case we'd appreciate it if the issue was opened on the [doc repo](https://github.com/gaea-godot/rtd-docs)). When reporting bugs, please provide accurate and extended information, especially about how to reproduce the bug, your Godot and Gaea version, etc. Issue templates are available.

## 🔧 Contributing Code

All code changes should be made in a personal fork and requested through pull requests. This means Gaea follows the [Github Flow](https://docs.github.com/en/get-started/using-github/github-flow), and you'll have to follow it aswell. In addition to this, PRs to Gaea have to follow a few rules:

- PRs should mainly fix one issue. It's better to make a few smaller PRs than one big one. If a big one is necessary, please discuss it before on the related issue, the Discussions page, or on the linked Discord server.
- They have to pass a few unit tests and a formatting check (which means code added to Gaea has to roughly follow the [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)).
- When updating your forks with upstream changes, you'll have to use [rebase](https://git-scm.com/book/en/v2/Git-Branching-Rebasing).
- Document your code, using [documentation comments](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html).
- If your PR fixes/closes an issue, [include it in the description](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue).

### Writing Unit Tests

When contributing, especially if it's a new feature and/or node, we recommend writing unit tests. These are done using the [GdUnit4 plugin](https://github.com/MikeSchulze/gdUnit4), which has its own [documentation](https://mikeschulze.github.io/gdUnit4/testing/first-test/). They're kept under `./testing/`, inside 1 of 4 categories:

- `generation/`: For general `GaeaGenerator` tests, or for testing full generations. Shouldn't be necessary for most PRs.
- `graph_nodes/`: For testing specific `GaeaNodeResource`s, each of which should be kept in subfolders. When adding new graph nodes, please include tests for each one.
- `rendering/`: For `GaeaRenderer` tests, normally done by creating a small scene with a generator, a renderer and the node it will be rendered to (TileMap, GridMap, etc.). When adding new renderers, please include tests for each one.
- `other/`: For any tests that don't fit the previous category (e.g. `GaeaGraph` tests, interfaces, editor-related tests).

When writing tests, we try to generally follow the [fail fast](https://mikeschulze.github.io/gdUnit4/testing/first-test/#multiple-assertions-fail-fast) guideline. Unit tests should also be kept small and separated.


## Closing Thoughts

Overall, if you're confused about something when contributing, we'll guide you through it. We appreciate anyone who wants to help with this project.
