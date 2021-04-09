# The Kyverno Website

https://kyverno.io

## Preview instructions

* This site makes use of the [Docsy](https://docsy.dev) theme.
  [Hugo Extended](https://gohugo.io/getting-started/installing#fetch-from-github) is required to render it.
* `git clone https://github.com/kyverno/website kyverno-website/ --recurse-submodules`
* `cd kyverno-website`
* `hugo server -v`

## Rendering Policies to Markdown

See [render](/render/README.md) folder.

## Customize settings

Edit the `.toml` files inside the `config/_default` dir
## Style and typographical conventions

The Kyverno website has established several writing conventions in the interest of consistency and accuracy.

### Voice

Active voice is preferred in most writing examples. Ex., "this ClusterPolicy mutates incoming Pods..." and not "incoming Pods are mutated by this ClusterPolicy".

### Code styling

* Kubernetes resource kinds are considered proper nouns and are distinguished from other nouns by the initial letter capitalization. Ex., "a Kubernetes Pod will be annotated".
* Anything intended to be proper code or typed at a CLI is formatting using Markdown code syntax with backticks or in blocks (surrounded by three backticks).
* Code represented in blocks should prefer a syntax declaration for this theme's highlighting ability. Ex., when displaying YAML notate the code block with three backticks and "yaml".
