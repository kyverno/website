---
title: Installation Methods
description: Methods for installing the Kyverno CLI
weight: 15
---

## Install via Homebrew

The Kyverno CLI can also be installed with [Homebrew](https://brew.sh/) as a [formula](https://formulae.brew.sh/formula/kyverno#default).

```sh
brew install kyverno
```

## Install via Krew

You can use [Krew](https://github.com/kubernetes-sigs/krew) to install the Kyverno CLI:

```sh
# Install Kyverno CLI using kubectl krew plugin manager
kubectl krew install kyverno

# test the Kyverno CLI
kubectl kyverno version  
```

## Install via AUR (archlinux)

You can install the Kyverno CLI via your favorite AUR helper (e.g. [yay](https://github.com/Jguer/yay))

```sh
yay -S kyverno-git
```

## Install in GitHub Actions

The Kyverno CLI can be installed in GitHub Actions using [kyverno-cli-installer](https://github.com/marketplace/actions/kyverno-cli-installer) from the GitHub Marketplace. Please refer to [kyverno-cli-installer](https://github.com/marketplace/actions/kyverno-cli-installer) for more information.

## Manual Binary Installation

The Kyverno CLI may also be installed by manually downloading the compiled binary available on the [releases page](https://github.com/kyverno/kyverno/releases). An example of installing the Kyverno CLI v1.12.0 on a Linux x86_64 system is shown below.

```sh
curl -LO https://github.com/kyverno/kyverno/releases/download/v1.12.0/kyverno-cli_v1.12.0_linux_x86_64.tar.gz
tar -xvf kyverno-cli_v1.12.0_linux_x86_64.tar.gz
sudo cp kyverno /usr/local/bin/
```

## Building the CLI from source

You can also build the CLI binary from the Git repository (requires Go).

```sh
git clone https://github.com/kyverno/kyverno
cd kyverno
make build-cli
sudo mv ./cmd/cli/kubectl-kyverno/kubectl-kyverno /usr/local/bin/
```
