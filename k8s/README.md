common kubernetes templates for deployment

these should be called with `kube_tools kubeApplyTpl example.tpl.yml` usually through make as it relys on the 
build/make/makefile.env to be generated for variable replacement

Future roadmap:
- use helm
- move these to another repo to keep bin small