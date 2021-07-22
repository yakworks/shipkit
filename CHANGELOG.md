### v1.0.9

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.8...v1.0.9)
- feat: fix bad spacing sep for vault_url, [link](https://github.com/yakworks/shipkit/commit/3b72df16c2775f5275db10bddc5afb21d8f5b4d2)

### v1.0.8

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.7...v1.0.8)
- fix: yaml was failing with set -euo pipefail, fixed and commented out unset_variables for now. added ship- methods for spring gradle publish and docker [link](https://github.com/yakworks/shipkit/commit/43fde24c571b0f8da6e1db107b259ca2dab45cd3)

### v1.0.7

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.6...v1.0.7)
- feat: shellcheck, added logr, renamed release.make to ship-version, everything runs through the make_shell now (#5) [link](https://github.com/yakworks/shipkit/commit/dee01e81d66553c21b035ce53b7f1410d50d89dc)

### v1.0.7

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.6...v1.0.7)
- feat: added logr, renamed release.make to ship-version, everything runs through the make_shell now [link](https://github.com/yakworks/shipkit/commit/78be6d96f8e3a1ecc14f50306b82b5cb759b15b9)

### v1.0.7

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.6...v1.0.7)
- feat: added logr, renamed release.make to ship-version, everything runs through the make_shell now [link](https://github.com/yakworks/shipkit/commit/78be6d96f8e3a1ecc14f50306b82b5cb759b15b9)

### v1.0.6

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.5...v1.0.6)
- fix: bad name for k8s-pages-delete-deployment [link](https://github.com/yakworks/shipkit/commit/b2d0d4e191a624ab1b9d2410db379bb88ba42f73)

### v1.0.5

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.4...v1.0.5)
- fix: bad target name for ship-github-create [link](https://github.com/yakworks/shipkit/commit/2661ecbba820633055b1153b9c4bf43bd2255493)
- feat: bring consitency to main names to call from CI, name them all ship-. [link](https://github.com/yakworks/shipkit/commit/c0ff9beabf848bb20c09950e8217207efeea81b2)

### v1.0.4

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.3...v1.0.4)
- fix: beafed up tests for versions, made version file configurables and added option for whether to snapshot on bump [link](https://github.com/yakworks/shipkit/commit/391835c70549798bd081a4f2752e5558777e2321)
- feat: remove snapshot for relase, added some reference links, don't automatically set the snapshot back to true. will add variable that can be set for this in future [link](https://github.com/yakworks/shipkit/commit/f6e7131401d429bc5698d2542a9e39cc16a92d3e)
- line 23: version: unbound variable (#3) [link](https://github.com/yakworks/shipkit/commit/76d74c0ba81109c4a06b61eeb4de44ddb0812ca5)

### v1.0.3

Initial Release
