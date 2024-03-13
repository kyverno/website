---
title: jp
weight: 30
---

The Kyverno CLI has a `jp` subcommand which makes it possible to test not only the custom filters endemic to Kyverno but also the full array of capabilities of JMESPath included in the `jp` tool itself [here](https://github.com/jmespath/jp). By passing in either through stdin or a file, both for input JSON or YAML documents and expressions, the `jp` subcommand will evaluate any JMESPath expression and supply the output.

Examples:

List available Kyverno custom JMESPath filters. Please refer to the JMESPath documentation page [here](/docs/writing-policies/jmespath/) for extensive details on each custom filter. Note this does not show the built-in JMESPath filters available upstream, only the custom Kyverno filters.

```sh
$ kyverno jp function
Name: add
  Signature: add(any, any) any
  Note:      does arithmetic addition of two specified values of numbers, quantities, and durations

Name: base64_decode
  Signature: base64_decode(string) string
  Note:      decodes a base 64 string

Name: base64_encode
  Signature: base64_encode(string) string
  Note:      encodes a regular, plaintext and unencoded string to base64

Name: compare
  Signature: compare(string, string) number
  Note:      compares two strings lexicographically
<snip>
```

Test a custom JMESPath filter using stdin inputs.

```sh
$ echo '{"foo": "BAR"}' | kyverno jp query 'to_lower(foo)'
Reading from terminal input.
Enter input object and hit Ctrl+D.
# to_lower(foo)
"bar"
```

Test a custom JMESPath filter using an input JSON file. YAML files are also supported.

```sh
$ cat foo.json
{"bar": "this-is-a-dashed-string"}

$ kyverno jp query -i foo.json "split(bar, '-')"
# split(bar, '-')
[
  "this",
  "is",
  "a",
  "dashed",
  "string"
]
```

Test a custom JMESPath filter as well as an upstream JMESPath filter.

```sh
$ kyverno jp query -i foo.json "split(bar, '-') | length(@)"
# split(bar, '-') | length(@)
5
```

Test a custom JMESPath filter using an expression from a file.

```sh
$ cat add
add(`1`,`2`)

$ echo {} | kyverno jp query -q add
Reading from terminal input.
Enter input object and hit Ctrl+D.
# add(`1`,`2`)
3
```

Test upstream JMESPath functionality using an input JSON file and show cleaned output.

```sh
$ cat pod.json
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "mypod",
    "namespace": "foo"
  },
  "spec": {
    "containers": [
      {
        "name": "busybox",
        "image": "busybox"
      }
    ]
  }
}

$ kyverno jp query -i pod.json 'spec.containers[0].name' -u
# spec.containers[0].name
busybox
```

Parse a JMESPath expression and show the corresponding [AST](https://en.wikipedia.org/wiki/Abstract_syntax_tree) to see how it was interpreted.

```sh
$ kyverno jp parse 'request.object.metadata.name | truncate(@, `9`)'
# request.object.metadata.name | truncate(@, `9`)
ASTPipe {
  children: {
    ASTSubexpression {
      children: {
        ASTSubexpression {
          children: {
            ASTSubexpression {
              children: {
                ASTField {
                  value: "request"
                }
                ASTField {
                  value: "object"
                }
            }
            ASTField {
              value: "metadata"
            }
        }
        ASTField {
          value: "name"
        }
    }
    ASTFunctionExpression {
      value: "truncate"
      children: {
        ASTCurrentNode {
        }
        ASTLiteral {
          value: 9
        }
    }
}
```

For more specific information on writing JMESPath for use in Kyverno, see the [JMESPath page](/docs/writing-policies/jmespath/).
