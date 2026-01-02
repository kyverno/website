#!/usr/bin/env bash

rm -rf ./src/content/docs/docs/kyverno-cli/reference/kyverno*.md
docker run --user root -v ${PWD}:/work --rm ghcr.io/kyverno/kyverno-cli docs	\
  --autogenTag=false															\
  --website																	\
  --noDate																	\
  --markdownLinks																\
  --output "/work/src/content/docs/docs/kyverno-cli/reference"