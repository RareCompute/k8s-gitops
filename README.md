# 🧪 k8s-gitops

This is the Rare Compute GitOps repository. It represents our efforts to streamline all Kubernetes deployments into one source of truth. Infrastructure is built on [Talos](https://www.talos.dev/) and deployed using [Talhelper](https://github.com/budimanjojo/talhelper), [helmfile](https://github.com/helmfile/helmfile) and [Flux](https://github.com/fluxcd/flux2). Dployment requires the necessary CLI tools. Taskfiles and scripts adapted from brettinternet's [homeops](https://github.com/brettinternet/homeops)

## ✅ Requirements

- [Taskfile](https://taskfile.dev/)
- [Cilium](https://github.com/cilium/cilium)
- [Flux](https://github.com/fluxcd/flux2)
- [helmfile](https://github.com/helmfile/helmfile)
- [Direnv](https://github.com/direnv/direnv)
- [Talosctl](https://github.com/siderolabs/talos)
- [Talhelper](https://github.com/budimanjojo/talhelper)
- [SOPS](https://github.com/getsops/sops)
- [age](https://github.com/FiloSottile/age)
- [Docker](https://www.docker.com/) for some tools
