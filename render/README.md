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
