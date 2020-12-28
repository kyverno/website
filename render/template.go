package main

var policyTemplate = `---
type: "docs"
title: {{ .Title }}
linkTitle: {{ .Title }}
weight: {{ .Weight }}
description: >
    {{ index .Policy.ObjectMeta.Annotations "policies.kyverno.io/description" }}
---

## Category
{{ index .Policy.ObjectMeta.Annotations "policies.kyverno.io/category" }}

## Definition
[{{ .Path }}]({{ .RawURL }})
` + "\n" + "```yaml\n" + "{{ .YAML }}" + "\n```\n"
