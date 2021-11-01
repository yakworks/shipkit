### v1.0.41

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.40...v1.0.41)
- Adds support for postgresql (#33) [link](https://github.com/yakworks/shipkit/commit/737428ea7c15c39b5487301119a9d06c7bc1e122)

### v1.0.40

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.39...v1.0.40)
- if then check on databases fro default ports (#32) [link](https://github.com/yakworks/shipkit/commit/9b35866b2152feb20d32e7270f7e968cc3b5c495)

### v1.0.39

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.38...v1.0.39)
- fix docker stop and added psql as shortcut for postgresql (#31) [link](https://github.com/yakworks/shipkit/commit/5e6f0cdcdfbe5b308c704e6c30390b00b170aaa0)

### v1.0.38

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.37...v1.0.38)
- Env goals psql (#30) [link](https://github.com/yakworks/shipkit/commit/f27b70a77195f485db89a6776682b702f70d5352)

### v1.0.37

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.36...v1.0.37)
- add testing env as option, easier to recall than testenv, moved mysql back to default for db (#29) [link](https://github.com/yakworks/shipkit/commit/00b125defe6903eebd9aecc5c8bc3a0953fe0b16)

### v1.0.36

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.35...v1.0.36)
- adds postgressql as option for DBMS (#28) [link](https://github.com/yakworks/shipkit/commit/dea305ba0ee60da5b671272c49d1e4f33e94b316)

### v1.0.35

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.34...v1.0.35)
- escape the $1 and $2 so they dont get piked up and replaced. (#27) [link](https://github.com/yakworks/shipkit/commit/9c9fbe8bdf45b4785bc22ad4611f41a7d297e682)

### v1.0.34

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.33...v1.0.34)
- valult.decrypt to keep it shorter and simpler, update readme for unused gpg.passphrase to clearly indicate its no longer used (#26) [link](https://github.com/yakworks/shipkit/commit/5e95512e9eeb3c18a847ea60d8b4f3231bfbdc90)

### v1.0.33

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.32...v1.0.33)
- removes secrets.make from defaults in spring and k8s-commons.make, need to add vault in separately (#25) [link](https://github.com/yakworks/shipkit/commit/af37bf97309e5bcbbf0de9749202245ca51dce79)

### v1.0.32

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.31...v1.0.32)
- add sops.make for mozillas sops encryption. cleaned up comments (#24) [link](https://github.com/yakworks/shipkit/commit/e0f92412b84d112178353569da98aaf82915f714)

### v1.0.31

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.30...v1.0.31)
- just remove the ship.docker and require it to be be implemented in main [link](https://github.com/yakworks/shipkit/commit/cc558902720df902648679b58ed7a2601c13b05e)

### v1.0.30

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.29...v1.0.30)
- just unwrapped the releasable check from ship.docker, its not needed (#23) [link](https://github.com/yakworks/shipkit/commit/375840782f9308370d3ef467eb0b418a59d4f9ba)

### v1.0.29

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.28...v1.0.29)
- Tpl sed heredoc (#22) [link](https://github.com/yakworks/shipkit/commit/18a130b4c6debbadeadd17e6415a1ed02cc574c8)

### v1.0.28

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.27...v1.0.28)
- dry_run will set the RELEASABLE_BRANCH now so its easier to test (#21) [link](https://github.com/yakworks/shipkit/commit/cec432168808afa92147b983a0fe6d3aa11a1a6d)

### v1.0.27

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.26...v1.0.27)
- Tweaks (#20) [link](https://github.com/yakworks/shipkit/commit/76ff51b1fe013075a38f3e467e781577476c69f5)
- Tweaks (#19) [link](https://github.com/yakworks/shipkit/commit/5fa7d25b52489f53fc83b7366279b8040b179b37)

### v1.0.26

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.25...v1.0.26)
- fix RELEASABLE_BRANCH variable order [link](https://github.com/yakworks/shipkit/commit/9ffaf5a79348762383b828884483f3ab271db973)
- added ability to pass in env=some.env to make so to run an env file with it. (#18) [link](https://github.com/yakworks/shipkit/commit/840eed470a943a1521059eb6a3578fa8b63c242e)

### v1.0.25

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.24...v1.0.25)
- bad var for db docker (#17) [link](https://github.com/yakworks/shipkit/commit/5dff7374f84c16cb6bc3333284ca8b6d3f76d8ed)

### v1.0.24

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.23...v1.0.24)
- Fixed a typo with one quote missing (#16) [link](https://github.com/yakworks/shipkit/commit/7ee11cd68f95bde81502b61feaf32a0bedf017f3)

### v1.0.23

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.22...v1.0.23)
- feat: if package.json exists then will update it with new version too in ship.version (#15) [link](https://github.com/yakworks/shipkit/commit/ef9485db4ebc676a98b631f3ac09db305705c320)

### v1.0.22

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.21...v1.0.22)
- move back to old way with shell for init_vars [link](https://github.com/yakworks/shipkit/commit/c2262e95b7a7d18299f66a9c12b6f8a1b86b406c)
- feat: cleaner VERBOSE now. dependency now on sinclude MAKE_ENV_FILE so its not doing the goofy subshell thing and stays in target (#14) [link](https://github.com/yakworks/shipkit/commit/11c8b90f22a50ab392d2dd7013c8e45aede3436f)

### v1.0.21

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.20...v1.0.21)
- fix test [link](https://github.com/yakworks/shipkit/commit/7ded8f9cf1b7b6a0ff6f6eda9bbef14287b23e97)
- Fix gradle script (#13) [link](https://github.com/yakworks/shipkit/commit/ace607e934e51c4df91de5ff193af33e5f7a8246)

### v1.0.20

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.19...v1.0.20)
- feat: added VERBOSE flag for running and better logr messages. (#12) [link](https://github.com/yakworks/shipkit/commit/e1e7c24758504d118a38f9b55344ca59e8db6075)

### v1.0.19

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.18...v1.0.19)
- feat: add git check so its not required to kick up make. (#11) [link](https://github.com/yakworks/shipkit/commit/1632c20c72816353bf7234d5aeb27b8dbeae27e7)

### v1.0.18

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.17...v1.0.18)
- fix: db_docker_url -> docker_db_url (#10) [link](https://github.com/yakworks/shipkit/commit/d08056e9c27140e9a3a30264fcb64cf7ba1ddd58)

### v1.0.17

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.16...v1.0.17)
- feat: make env unde db consistent with app (#9) [link](https://github.com/yakworks/shipkit/commit/0b6ecb03f51c6a8b7fdb03dc51e44a5ae3a85412)

### v1.0.16

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.15...v1.0.16)
- feat: git secretes to check download on each goal (#8) [link](https://github.com/yakworks/shipkit/commit/994f8da55e7ff6a6598610205da1b85812e69ba6)

### v1.0.15

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.14...v1.0.15)
- feat: add colors using tput and secrets goals for git-secret (#7) [link](https://github.com/yakworks/shipkit/commit/ac621759beaf0d148ee097e6e8fd05d5c22dbc62)

### v1.0.14

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.13...v1.0.14)
- fix: bad function name in kube [link](https://github.com/yakworks/shipkit/commit/e56f0a0ae8b66b74449b6b2764a99ca8f3c3ade3)

### v1.0.13

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.12...v1.0.13)
- fix:  ship.github-release name change [link](https://github.com/yakworks/shipkit/commit/3a6a31bf34f6199e2caa4739b5b216bed8ec7e06)
- fix: updates bad paths in test [link](https://github.com/yakworks/shipkit/commit/fbb4d6ea0464df4c09c7701a98d983518c0a58f0)
- refactor: clean up core name from bashify, called it bashkit for consitency [link](https://github.com/yakworks/shipkit/commit/8b2a4b2912476ee28f6a53b75c37bc528ed7e765)
- Feat/init db env and major overhaul (#6) [link](https://github.com/yakworks/shipkit/commit/0a9eb51e05d5a7a33c9fd102e47c55a7addef0db)

### v1.0.12

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.11...v1.0.12)

### v1.0.11

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.10...v1.0.11)
- fix: make jar call, $$JAVA_HOME/bin/jar so dont depend on jar exe being on path [link](https://github.com/yakworks/shipkit/commit/9a1dcbd4c222692c022b95f7f0a346f6ea0d2375)

### v1.0.10

[Full Changelog](https://github.com/yakworks/shipkit/compare/v1.0.9...v1.0.10)
- fix: ship-libs depended on publish-lib without s, make BUILD_VERSION puVar [link](https://github.com/yakworks/shipkit/commit/c00de9b4c5b31263420494fc7dfd5a09058a8452)

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
