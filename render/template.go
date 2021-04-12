package main

var policyTemplate = `---
{{- $annotations := .Policy.ObjectMeta.Annotations }}
title: "{{ .Title }}"
linkTitle: "{{ .Title }}"
category: {{ index $annotations "policies.kyverno.io/category" }}
policyType: "{{ .Type }}"
repo: "https://github.com/kyverno/policies/blob/main{{ .Path }}"
weight: {{ .Weight }}
description: >
    {{ index $annotations "policies.kyverno.io/description" }}
---

## Policy Definition
<a href="{{ .RawURL }}" target="-blank">{{ .Path }}</a>
` + "\n" + "```yaml\n" + "{{ .YAML }}" + "\n```\n"
