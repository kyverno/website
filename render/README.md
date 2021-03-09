# render

This folder contains a Golang program to convert Kyverno policies YAML definitions to markdown that can be included as content for the website.

The program clones a Git repo (e.g. https://github.com/kyverno/policies/) and uses a built-in template.

## Build

```sh
go build github.com/kyverno/website/render
```

## Usage

Build (see above) or retrieve the executable:

```sh
go get github.com/kyverno/website/render
```

Then execute against the Kyverno policies repository and render markdown to the `content/en/policies/` folder:

```sh
render https://github.com/kyverno/policies/main content/en/policies/
```
