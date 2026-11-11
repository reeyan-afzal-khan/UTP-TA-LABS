# Bundled drawing and listing dependencies

| Package | Version | License |
| --- | --- | --- |
| [CeTZ](https://typst.app/universe/package/cetz/) | 0.5.3 | LGPL-3.0-or-later |
| [Codly](https://typst.app/universe/package/codly/) | 2.0.0 | MIT |
| [oxifmt](https://typst.app/universe/package/oxifmt/) | 1.0.0 | MIT OR Apache-2.0 |
| [elembic](https://typst.app/universe/package/elembic/) | 1.1.1 | MIT OR Apache-2.0 |

These are pinned Typst Universe sources. Each directory retains upstream licenses and source. Imports and the CeTZ plugin path are relocated to repository-root paths so builds do not require a user's package cache or network access. No upstream drawing algorithms were changed. Project-specific styles and geometry adapters live in `.shared/typst`, outside these packages.
