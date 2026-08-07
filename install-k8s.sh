#!/usr/bin/env bash

set -e

if ! command -v istioctl &>/dev/null; then
    brew install istioctl
fi

if ! command -v kubectl &>/dev/null; then
    brew install kubectl
fi

if ! command -v helm &>/dev/null; then
    brew install helm
fi

if ! command -v kubecolor &>/dev/null; then
    brew install kubecolor
fi

if ! command -v kubectx &>/dev/null; then
    brew install kubectx
fi

if ! command -v k9s &>/dev/null; then
    brew install k9s
fi

if ! command -v minikube &>/dev/null; then
    brew install minikube
fi

exit 0

# TODO: add to zsh completions
# source <(kubectl completion zsh)
