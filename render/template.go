package main

var policyTemplate = `---
{{- $annotations := .Policy.ObjectMeta.Annotations }}
title: "{{ .Title }}"
linkTitle: "{{ .Title }}"
weight: {{ .Weight }}
repo: "https://github.com/kyverno/policies/blob/main{{ .Path }}"
description: >
    {{ index $annotations "policies.kyverno.io/description" }}
category: {{ index $annotations "policies.kyverno.io/category" }}
{{ .Rules }}
---

## Policy Definition
<a href="{{ .RawURL }}" target="-blank">{{ .Path }}</a>
` + "\n" + "```yaml\n" + "{{ .YAML }}" + "\n```\n"
