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
The `multiply()` filter performs arithmetic multiplication capabilities between two input fields (Number, Quantitiy or Duration) and produces an output.
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

### Random

#### Description
The `random()` filter is used to generate a random sequence of string data based upon the input pattern, expressed as regex.
#### Arguments
**Input**: String
**Output**: String

#### Example
`random('[0-9a-z]{5}')` will produce a string output of exactly 5 characters long composed of numbers in the collection 0-9 and lower-case letters in the collection a-z. 

### Regex_match

#### Description
The `regex_match()` filter is similar to the pattern_match() filter except it accepts standard regular expressions as the comparison format.
#### Arguments
**Input**: String, String or Number
**Output**: Boolean

#### Example
`regex_match('^[1-7]$','1')` returns `true`. 

### Regex_replace_all

#### Description
The `regex_replace_all()` filter is similar to the replace_all() filter only differing by the first and third inputs being a valid regular expression rather than a static string. For literal replacement, see regex_replace_all_literal(). 
#### Arguments
**Input**: Regex String, String or Number, Regex String or Number
**Output**: String

### Regex_replace_all_literal

#### Description
The `regex_replace_all_literal()` filter is similar to the regex_replace_all() filter with the third input being a static string used for literal replacement.
#### Arguments
**Input**: Regex String, String or Number, String or Number
**Output**: String

### Replace

#### Description
The `replace()` filter is similar to the replace_all() filter except it takes a fourth input (a number) to specify how many instances of the source string should be replaced with the replacement string in a parent.
#### Arguments
**Input**: String, String, String, Number
**Output**: String

#### Example
`replace('Lorem ipsum dolor sit amet', 'ipsum', 'muspi', '-1')` returns `Lorem muspi dolor sit ame`. 

### Replace_all

#### Description
The `replace_all()` filter is used to find and replace all instances of one string with another in an overall parent string.
#### Arguments
**Input**: String, String, String
**Output**: String

#### Example
`replace_all('Lorem ipsum ipsum dolor sit amet', 'ipsum', 'muspi')` returns `Lorem muspi muspi dolor sit ame`. 

### Semver_compare

#### Description
The `semver_compare()` filter compares two strings which comply with the semantic versioning schema and outputs a boolean response as to the position of the second relative to the first.
#### Arguments
**Input**: String, String
**Output**: Boolean

### Split

#### Description
The `split()` filter is used to take in an input string, a character or sequence found within that string, and split the source into an array of strings.
#### Arguments
**Input**: String, String
**Output**: Array/String

#### Example
`"split('Hello, Gophers', ', ')` returns `['Hello', 'Gophers']`. 

### Subtract

#### Description
The `subtract()` filter performs arithmetic subtraction capabilities between two input fields (Number, Quantitiy or Duration) and produces an output.
#### Arguments
**Input**: Value1, Value2
**Output**: Value1 - Value2

Note: Value1 and Value2 should have the same type.
#### Examples
`subtract('10h', '1h')` returns `9h`.

### Time_add

#### Description
The `time_add()` filter is used to take a starting, absolute time in RFC 3339 format, and add some duration to it. Duration can be specified in terms of seconds, minutes, and hours. For times not given in RFC 3339, use the `time_parse()` function to convert the source time into RFC 3339.

#### Arguments
**Input**: Time start string, Time duration string
**Output**: Time end string
#### Example
`time_add('2023-01-12T12:37:56-05:00','6h')` results in the value `"2023-01-12T18:37:56-05:00"`.

### Time_after

#### Description
The `time_after()` filter is used to determine whether one absolute time is after another absolute time where both times are in RFC 3339 format. The output is a boolean response where `true` if the end time is after the begin time and `false` if it is not.

#### Arguments
**Input**: Time end (String), Time begin (String)
**Output**: Boolean
#### Example
`time_after('2023-01-12T14:07:55-05:00','2023-01-12T19:05:59Z')` results in the value `true`.
### Time_before

#### Description
The `time_before()` filter is used to determine whether one absolute time is before another absolute time where both times are in RFC 3339 format.

#### Arguments
**Input**: Time end (String), Time begin (String)
**Output**: Boolean
#### Example
`time_before('2023-01-12T19:05:59Z','2023-01-13T19:05:59Z')` results in the value `true`.

### Time_between

#### Description
The `time_between()` filter is used to check if a given time is between a range of two other times where all time is expected in RFC 3339 format.

#### Arguments
**Input**: Time to check (String), Time start (String), Time end (String)
**Output**: Boolean
#### Example
`time_between('2023-01-12T19:05:59Z','2023-01-01T19:05:59Z','2023-01-15T19:05:59Z')` results in the value `true`.
### Time_diff

#### Description
The `time_diff()` filter calculates the amount of time between a start and end time where start and end are given in RFC 3339 format. The output, a string, is the duration and may be a negative duration.
#### Arguments
**Input**: Time start (String), Time duration (String)
**Output**: Duration (String) 
#### Example
`time_diff('2023-01-10T00:00:00Z','2023-01-11T00:00:00Z')` results in the value `"24h0m0s"`.

### Time_now

#### Description
The `time_now()` filter returns the current time in RFC 3339 format.

#### Arguments
**Input**: None
**Output**: Current Time (string)

### Time_now_utc
#### Description
The `time_now_utc()` filter returns the current UTC time in RFC 3339 format. The returned time will be presented in UTC regardless of the time zone returned. 

#### Arguments
**Input**: None
**Output**: Current Time (string)

### Time_parse
#### Description
The `time_parse()` filter converts an input time, given some other format, to RFC 3339 format. d

#### Arguments
**Input**: Time format (String), Time to convert (String)
**Output**: Time in RFC 3339 (String)
#### Example
The expression `time_parse('Mon Jan 02 2006 15:04:05 -0700', 'Fri Jun 22 2022 17:45:00 +0100')` results in the output of `"2022-06-22T17:45:00+01:00"`.
### Time_since
#### Description
The `time_since()` filter is used to calculate the difference between a start and end period of time where the end may either be a static definition or the then-current time. 

#### Arguments
**Input**: Time format (String), Time start (String), Time end (String)
**Output**: Time difference (String)
#### Example
 `time_since('','2022-04-10T03:14:05-07:00','2022-04-11T03:14:05-07:00')` will result in the output of `"24h0m0s"`.

### Time_to_cron

#### Description
The `time_to_cron()` filter takes in a time in RFC 3339 format and outputs the equivalent Cron-style expression.

#### Arguments
**Input**: Time (String)
**Output**: Cron expression (String)
#### Example
`time_to_cron('2022-04-11T03:14:05-07:00')` results in the output `"14 3 11 4 1"`.

### Time_truncate
#### Description
The `time_truncate()` filter takes in a time in RFC 3339 format and a duration and outputs the nearest rounded down time that is a multiple of that duration.

#### Arguments
**Input**: Time in RFC 3339 (String), Duration (String)
**Output**: Time in RFC 3339 (String)
#### Example
`time_truncate('2023-01-12T17:37:00Z','1h')` results in the output `"2023-01-12T17:00:00Z"`. 

### Time_utc
#### Description
The `time_utc()` filter takes in a time in RFC 3339 format with a time offset and presents the same time in UTC/Zulu.

#### Arguments
**Input**: Time in RFC 3339 (String)
**Output**: Time in RFC 3339 (String)
#### Example
`time_utc('2021-01-02T18:04:05-05:00')` results in the output `"2021-01-02T23:04:05Z"`.

### To_lower
#### Description
The `to_lower()` filter takes in a string and outputs the same string with all lower-case letters. It is the opposite of [`to_upper()`](#to_upper).

#### Arguments
**Input**: String
**Output**: String
#### Example
`to_upper('QWERTY')` return `qwerty`.
### To_upper
#### Description
The `to_upper()` filter takes in a string and outputs the same string with all upper-case letters. It is the opposite of [`to_lower()`](#to_lower).

#### Arguments
**Input**: String
**Output**: String
#### Example
`to_upper('qwerty')` return `QWERTY`.

### Trim

#### Desription
The `trim()` filter takes a string containing a "source" string, a second string representing a collection of discrete characters, and outputs the remainder of the source when both ends of the source string are trimmed by characters appearing in the collection. 

#### Arguments
**Input**: String, String
**Output**: String
#### Example
 `trim('¡¡¡Hello, Gophers!!!', '!!')` will result in the output `Hello, Gophers`.

### Truncate
#### Description
The `truncate()` filter takes a string, a number, and shortens (truncates) that string from the beginning to only include the desired number of characters. 
#### Arguments
**Input**: String
**Output**: Number
#### Example
`truncate('foobar', '3')` willresult in the output of `foo`.
### x509_decode
#### Description
The `x509_decode()` filter takes in a string which is a PEM-encoded X509 certificate, and outputs a JSON object with the decoded certificate details.
#### Arguments
**Input**: PEM-encoded X509 certificate String
**Output**: JSON Object
## Summary

JMESPath is a powerful and robust tool for selecting, extracting and manipulating data in JSON.