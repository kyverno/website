package main

var policyTemplate = `---
{{- $annotations := .Policy.ObjectMeta.Annotations }}
title: "{{ .Title }}"
category: {{ index $annotations "policies.kyverno.io/category" }}
version: {{ index $annotations "policies.kyverno.io/minversion" }}
policyType: "{{ .Type }}"
description: >
    {{ index $annotations "policies.kyverno.io/description" }}
---

## Policy Definition
<a href="{{ .RawURL }}" target="-blank">{{ .Path }}</a>
` + "\n" + "```yaml\n" + "{{ .YAML }}" + "\n```\n"
