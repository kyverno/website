# Render

This folder contains a Golang program to convert Kyverno policies YAML definitions to markdown that can be included as content for the website.

The program clones a Git repo (e.g. https://github.com/kyverno/policies/) and uses a built-in template.

## Build

```sh
# Get the render package
go get github.com/kyverno/website/render
# Build the binary
go build github.com/kyverno/website/render
```

## Usage

Execute against the Kyverno policies repository and render markdown to the `content/en/policies/` folder:

```sh
# Run render as built locally. Move into PATH if desired. May need to add execute bit.
./render https://github.com/kyverno/policies/main content/en/policies/
```

## Extend

To expose more data inside the generated policies markdown file, edit `template.go` file.

For example, let's say you want to scrape a field called `version` and `label` from under annotations. If your policy yaml file looked like this:

```yaml
<!-- somepolicy.yaml file -->
...
metadata:
  name: add-networkpolicy
  annotations:
    policies.kyverno.io/title: Add Network Policy
    policies.kyverno.io/category: Multi-Tenancy
    policies.kyverno.io/version: V1
    policies.kyverno.io/label: network
...
```

In `template.go`, you would expose that data as follows

```yaml
var policyTemplate = `---
...
version: {{ index $annotations "policies.kyverno.io/version" }}
label: {{ index $annotations "policies.kyverno.io/label" }}
...
---
```

> ellipsis (...) indicate truncated code.

After this step you will need to make edits in two other locations:

1. ../layouts/index.json
2. ../config/_default/params.toml

### Update filters index

Ensure that the `version` & `label` key-value pairs are included in the json index. `../layouts/index.json`

For example, in this block:

```
    {{- $.Scratch.Add "index" (dict 
      "title" $page.Title
      "body" .Params.description
      "link" $page.RelPermalink 
      "policy" $policy
      "category" .Params.category 
      "version" .Params.version
      "subject" .Params.subject
      "filters" (printf "%s::%s::%s::%s" $policy .Params.category .Params.version .Params.subject)
    ) -}}
```

Follow the pattern and duplicate the "subject" line. In the "filters" line, add an additional `::%s` and then the `.Params.<foo>` entry. This adds the entry to the filter and matches the returned results.

### Update policyFilters entries

Ensure that `version` & `label` that you used under the [extend](#extend) step are listed as a `filterID` as follows:

```toml
<!-- ../config/_default/params.toml  -->
...
[[policyFilters]]
title = "Version"
filterID = "version"
weight = 3

[[policyFilters]]
title = "Tags/Labels"
filterID = "label"
weight = 4
...
```
The `weight` parameter controls the ordering of the filters on the page. Higher number equals further down on the page.
