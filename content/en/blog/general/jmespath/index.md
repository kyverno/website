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

In Release 1.9 Kyverno has added several new custom filters for handling and manipulating time.
### Time_add

#### Description
The `time_add()` filter is used to take a starting, absolute time in RFC 3339 format, and add some duration to it. Duration can be specified in terms of seconds, minutes, and hours. For times not given in RFC 3339, use the `time_parse()` function to convert the source time into RFC 3339.

#### Arguments
- **Input**: Time start string, Time duration string
- **Output**: Time end string
#### Usecases
**Example**: `time_add('2023-01-12T12:37:56-05:00','6h')` results in the value `"2023-01-12T18:37:56-05:00"`.

We can use `time_add()` to get the right input for other time based filters

`"{{ time_add('{{ time_now_utc() }}','4h') | time_to_cron(@) }}"` expression uses `time_add()` in addition to `time_now_utc()` and `time_to_cron()` to get the current time and add four hours to it in order to write out the new schedule, in Cron format.

### Time_after

#### Description
The `time_after()` filter is used to determine whether one absolute time is after another absolute time where both times are in RFC 3339 format. The output is a boolean response where `true` if the end time is after the begin time and `false` if it is not.

#### Arguments
- **Input**: Time end (String), Time begin (String)
- **Output**: Boolean
#### Usecases
**Example**: `time_after('2023-01-12T14:07:55-05:00','2023-01-12T19:05:59Z')` results in the value `true`.

The `time_after()` filter can be used as a control condition.
`"{{ time_after('{{time_now_utc() }}','2023-01-12T00:00:00Z') }}"` expression uses `time_after()` in addition to `time_now_utc()`. The resulting boolean can be used as control condition to allow or deny admission.

### Time_before

#### Description
The `time_before()` filter is used to determine whether one absolute time is before another absolute time where both times are in RFC 3339 format.

#### Arguments
- **Input**: Time end (String), Time begin (String)
- **Output**: Boolean
#### Usecase
**Example**: `time_before('2023-01-12T19:05:59Z','2023-01-13T19:05:59Z')` results in the value `true`.

The `time_before()` filter can be used as a control condition.
`"{{ time_before('{{ time_now_utc() }}','2023-01-31T00:00:00Z') }}"` expression uses `time_before()` in addition to `time_now_utc()`. The resulting boolean can be used as control condition to allow or deny admission.


### Time_between

#### Description
The `time_between()` filter is used to check if a given time is between a range of two other times where all time is expected in RFC 3339 format.

#### Arguments
- **Input**: Time to check (String), Time start (String), Time end (String)
- **Output**: Boolean`a
#### Usecases
**Example**: `time_between('2023-01-12T19:05:59Z','2023-01-01T19:05:59Z','2023-01-15T19:05:59Z')` results in the value `true`.

The `time_between()` filter can be used as a control condition.
`"{{ time_between('{{ time_now_utc() }}','2023-01-01T00:00:00Z','2023-01-31T23:59:59Z') }}"` expresssion uses `time_between()` in addition to `time_now_utc()` to establish a boundary of a policy's function. Between 1 January 2023 and 31 January 2023.

### Time_diff

#### Description
The `time_diff()` filter calculates the amount of time between a start and end time where start and end are given in RFC 3339 format. The output, a string, is the duration and may be a negative duration.
#### Arguments
- **Input**: Time start (String), Time duration (String)
- **Output**: Duration (String) 
#### Usecases
**Example**: `time_diff('2023-01-10T00:00:00Z','2023-01-11T00:00:00Z')` results in the value `"24h0m0s"`.

`"{{ time_diff('{{metadata.scanFinishedOn}}','{{ time_now_utc() }}') }}"` expression uses the `time_diff()` filter in addition to `time_now_utc()`. This filter can be used to ensure that a vulnerability scan for a given container image is no more than 24 hours old.

### Time_now

#### Description
The `time_now()` filter returns the current time in RFC 3339 format.

#### Arguments
- **Input**: None
- **Output**: Current Time (string)

#### Usecases
`time_now()` can be used to provide input for other jmes filter.
`time_now()` filter can be used in addition to `time_add()` and `time_to_cron()` to generate a ClusterCleanupPolicy from 4 hours after the triggering PolicyException is created, converting it into cron format for use by the ClusterCleanupPolicy.

### Time_now_utc
#### Description
The `time_now_utc()` filter returns the current UTC time in RFC 3339 format. The returned time will be presented in UTC regardless of the time zone returned. 

#### Arguments
- **Input**: None
- **Output**: Current Time (string)
#### Usecases
`time_now_utc()` can be used to provide input for other jmes filter.
`"{{ time_add('{{ time_now_utc() }}','4h') | time_to_cron(@) }}"` expression uses the `time_now_utc()` filter in addition to `time_add()` and `time_to_cron()`. It can be used to generate a ClusterCleanupPolicy from 4 hours after the triggering PolicyException is created, converting it into cron format for use by the ClusterCleanupPolicy.

### Time_parse
#### Description
The `time_parse()` filter converts an input time, given some other format, to RFC 3339 format. d

#### Arguments
- **Input**: Time format (String), Time to convert (String)
- **Output**: Time in RFC 3339 (String)
#### Usecases
**Example**: `time_parse('Mon Jan 02 2006 15:04:05 -0700', 'Fri Jun 22 2022 17:45:00 +0100')` results in the output of `"2022-06-22T17:45:00+01:00"`.

`time_parse()` can be used to convert one timeformat to another and can be used to make annotations.
### Time_since
#### Description
The `time_since()` filter is used to calculate the difference between a start and end period of time where the end may either be a static definition or the then-current time. 

#### Arguments
- **Input**: Time format (String), Time start (String), Time end (String)
- **Output**: Time difference (String)
#### Usecases
**Example**: `time_since('','2022-04-10T03:14:05-07:00','2022-04-11T03:14:05-07:00')` will result in the output of `"24h0m0s"`.

`"{{ time_since('', '{{ imageData.configData.created }}', '') }}"` expression uses `time_since()` to compare the time a container image was created to the present time, blocking if that difference is greater than a certain amount of time.

### Time_to_cron

#### Description
The `time_to_cron()` filter takes in a time in RFC 3339 format and outputs the equivalent Cron-style expression.

#### Arguments
- **Input**: Time (String)
- **Output**: Cron expression (String)
#### Usecases
**Example**: `time_to_cron('2022-04-11T03:14:05-07:00')` results in the output `"14 3 11 4 1"`.

`"{{ time_add('{{ time_now_utc() }}','4h') | time_to_cron(@) }}"` expression uses the `time_to_cron()` filter in addition to `time_add()` and `time_now_utc()` and can be used to generate a ClusterCleanupPolicy from 4 hours after the triggering PolicyException is created, converting it into cron format for use by the ClusterCleanupPolicy.

### Time_truncate
#### Description
The `time_truncate()` filter takes in a time in RFC 3339 format and a duration and outputs the nearest rounded down time that is a multiple of that duration.

#### Arguments
- **Input**: Time in RFC 3339 (String), Duration (String)
- **Output**: Time in RFC 3339 (String)
#### Usecases
**Example**: `time_truncate('2023-01-12T17:37:00Z','1h')` results in the output `"2023-01-12T17:00:00Z"`. 

`"{{ time_truncate('{{ @ }}','2h') }}"` expression can be used to get the current value of the `thistime` annotation and round it down to the nearest multiple of 2 hours which, when `thistime` is set to a value of `"2021-01-02T23:04:05Z"` should result in the Service being mutated with the value `"2021-01-02T22:00:00Z"`.

### Time_utc
#### Description
The `time_utc()` filter takes in a time in RFC 3339 format with a time offset and presents the same time in UTC/Zulu.

#### Arguments
- **Input**: Time in RFC 3339 (String)
- **Output**: Time in RFC 3339 (String)
#### Usecases
**Example**: `time_utc('2021-01-02T18:04:05-05:00')` results in the output `"2021-01-02T23:04:05Z"`.

`time_utc()`'s output can be used as an input for other JMES filters or as annotations.
`"{{ time_utc('{{ @ }}') }}"` expression can be used as annotation for creation time.

## Summary

JMESPath is a powerful and robust tool for selecting, extracting and manipulating time in JSON.