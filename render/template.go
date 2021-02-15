package main

var policyTemplate = `---
type: "docs"
title: {{ .Title }}
linkTitle: {{ .Title }}
weight: {{ .Weight }}
description: >
    {{ index .Policy.ObjectMeta.Annotations "policies.kyverno.io/description" }}
category: {{ index .Policy.ObjectMeta.Annotations "policies.kyverno.io/category" }}
{{ .Rules }}
---

## Policy Definition
<a href="{{ .RawURL }}" target="-blank">{{ .Path }}</a>
` + "\n" + "```yaml\n" + "{{ .YAML }}" + "\n```\n"
