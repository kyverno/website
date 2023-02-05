---
date: 2023-02-05
title: Custom JMESPath in Kyverno
linkTitle: Custom JMESPath in Kyverno
description: How the Kyverno project uses the JSON query language, JMESPath.
draft: false
---

Kyverno allows complex selections and manipulation of fields and values almost anywhere using the JSON query language, JMESPath. This blog attempts to explain an bit about JMESPath and how it is used in Kyverno.

## About JMESPath

[JMESPath](https://jmespath.org/) (pronounced "James path") is a JSON query language created by James Saryerwinnie and is the language that Kyverno supports to perform more complex selections of fields and values and also manipulation thereof by using one or more [filters](https://jmespath.org/specification.html#filter-expressions). If you're familiar with `kubectl` and Kubernetes already, this might ring a bell in that it's similar to [JSONPath](https://github.com/json-path/JsonPath). JMESPath can be used almost anywhere in Kyverno although is an optional component depending on the type and complexity of a Kyverno policy or rule that is being written. While many policies can be written with simple overlay patterns, others require more detailed selection and transformation. The latter is where JMESPath is useful. The complete specifications of JMESPath can be read on the official site's [specifications page](https://jmespath.org/specification.html). For a comprehensive deepdive on JMESPath in Kyverno, you can read [Kyverno's JMESPath docs](https://main.kyverno.io/docs/writing-policies/jmespath/)

## Custom JMESPath Filters in Kyverno

In addition to the filters available in the upstream JMESPath library which Kyverno uses, there are also many new and custom filters developed for Kyverno's use found nowhere else. These filters augment the already robust capabilities of JMESPath to bring new functionality and capabilities which help solve common use cases in running Kubernetes. The filters endemic to Kyverno can be used in addition to any of those found in the upstream JMESPath library used by Kyverno and do not represent replaced or removed functionality.

For in depth explaination of all JMESPath functions with example, refer to the [documentation](https://main.kyverno.io/docs/writing-policies/jmespath/#custom-filters).

### Add

#### Description
The `add()` filter simply adds two values of the same type (Number, Quantitiy or Duration) and returns the sum.
#### Arguments
**Input**: Value1, Value2
**Output**: Value1 + Value2

Note: Value1 and Value2 should have the same type.
#### Example
`add('10h', '1h')` returns `11h`.

### Base64Decode

#### Description
The `base64_decode()` filter takes in a base64-encoded string and produces the decoded output.
#### Arguments
**Input**: String
**Output**: Input string as decode by command `base64 --decode`.

#### Example
`base64_decode('SGVsbG8sIHdvcmxkIQ==')` returns `Hello, world!`.


### Base64Encode

#### Description
The `base64_encode()` filter takes in a regular, plaintext and unencoded string and produces a base64-encoded output.
#### Arguments
**Input**: String
**Output**: Input string as decode by command `base64`.

#### Example
`base64_decode('Hello, world!')` returns `SGVsbG8sIHdvcmxkIQ==`.

### Compare

#### Description
The `compare()` filter is provided as an analog to the inbuilt function to Golang of the same name. It compares two strings lexicographically where the first string is compared against the second.
#### Arguments
**Input**: String, String
**Output**: 
`0` if Value1 == Value2
`1` if Value1 >= Value2
`-1` if Value1 <= Value2

#### Example
`compare('b', 'a')` returns `1`.

### Divide

#### Description
The `divide()` filter performs arithmetic divide capabilities between two input fields (Number, Quantitiy or Duration) and produces an output quotient.
#### Arguments
**Input**: Value1, Value2
**Output**: Value1 / Value2

Note: Value1 and Value2 should have the same type.
#### Example
`divide('12Ki', '200')` returns `61.0`.

### Equal_fold

#### Description
The `equal_fold()` filter is designed to provide text case folding for two sets of strings as inputs. 
#### Arguments
**Input**: String, String
**Output**: Boolean

#### Example
`equal_fold('Go', 'go')` returns `true`.

### Items

#### Description
The `items()` filter iterates on map keys (ex., annotations or labels) and converts them to an array of objects with key/value attributes with custom names.
#### Arguments
**Input**: Object, String, String
**Output**: Array/Object

#### Example
`items("["A", "B", "C"]","myKey","myValue")` returns `[{ "myKey": 0, "myValue": "A" }, { "myKey": 1, "myValue": "B" }, { "myKey": 2, "myValue": "C" }]`.

### Label_match

#### Description
The `label_match()` filter compares two sets of Kubernetes labels (both key and value) and outputs a boolean response if they are equivalent.
#### Arguments
**Input**: Object, Object
**Output**: Boolean

### Modulo

#### Description
The modulo() filter returns the modulo or remainder between a division of two numbers.
#### Arguments
**Input**: Number, Number
**Output**: Number

#### Example
`modulo('13s', '2s')` returns `1s`.

### Multiply

#### Description
The `multiply()` filter performs arithmetic multiplication capabilities between two input fields (Number, Quantitiy or Duration) and produces an output quotient.
#### Arguments
**Input**: Value1, Value2
**Output**: Value1 * Value2

Note: Value1 and Value2 should have the same type.
#### Example
`divide('12Ki', '2')` returns `24Ki`.

### Object_from_list

#### Description
The `object_from_list()` filter takes an array of objects and, based on the selected keys, produces a map. This is essentially the inverse of the `items()` filter.
#### Arguments
**Input**: Array/string,	Array/string
**Output**: Object

#### Example
`object_from_list('["key1", "key2"]', '["1", "2"]')` returns `{ "key1": 1.0, "key2": "2"}`.

### Parse_json

#### Description
The `parse_json()` filter takes in a string of any valid encoded JSON and parses it into a fully-formed JSON object.
#### Arguments
**Input**: String
**Output**: Any

### Parse_yaml

#### Description
The `parse_yaml()` filter is the YAML equivalent of the `parse_json()` filter and takes in a string of any valid YAML document, serializes it into JSON, and parses it so it may be processed by JMESPath. 
#### Arguments
**Input**: String
**Output**: Any

### Path_canonicalize

#### Description
The `path_canonicalize()` filter is used to normalize or canonicalize a given path by removing excess slashes.
#### Arguments
**Input**: String
**Output**: String

#### Example
`path_canonicalize('///var/run/containerd/containerd.sock')` returns `/var/run/containerd/containerd.sock`.

### Pattern_match

#### Description
The `pattern_match()` filter is used to perform a simple, non-regex match by specifying an input pattern and the string or number to which it should be compared. 
#### Arguments
**Input**: String, String
**Output**: Boolean
