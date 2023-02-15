---
date: 2023-02-15
title: New time related JMESPath filters in Kyverno!
linkTitle: New time related JMESPath filters in Kyverno
description: Use time in your filters now!.
draft: false
---

Kyverno allows complex selections and manipulation of fields and values almost anywhere using the JSON query language, JMESPath. In release 1.9 we have added several new time related filters and this post briefly explains those new filters 

## About JMESPath

[JMESPath](https://jmespath.org/) (pronounced "James path") is a JSON query language created by James Saryerwinnie and is the language that Kyverno supports to perform more complex selections of fields and values and also manipulation thereof by using one or more [filters](https://jmespath.org/specification.html#filter-expressions). If you're familiar with `kubectl` and Kubernetes already, this might ring a bell in that it's similar to [JSONPath](https://github.com/json-path/JsonPath). JMESPath can be used almost anywhere in Kyverno although is an optional component depending on the type and complexity of a Kyverno policy or rule that is being written. While many policies can be written with simple overlay patterns, others require more detailed selection and transformation. The latter is where JMESPath is useful. The complete specifications of JMESPath can be read on the official site's [specifications page](https://jmespath.org/specification.html). For a comprehensive deepdive on JMESPath in Kyverno, you can read [Kyverno's JMESPath docs](https://main.kyverno.io/docs/writing-policies/jmespath/)

## Custom JMESPath Filters in Kyverno

In addition to the filters available in the upstream JMESPath library which Kyverno uses, there are also many new and custom filters developed for Kyverno's use found nowhere else. These filters augment the already robust capabilities of JMESPath to bring new functionality and capabilities which help solve common use cases in running Kubernetes. The filters endemic to Kyverno can be used in addition to any of those found in the upstream JMESPath library used by Kyverno and do not represent replaced or removed functionality.

For in depth explaination of all JMESPath functions with example, refer to the [documentation](https://main.kyverno.io/docs/writing-policies/jmespath/#custom-filters).

In Release 1.9 Kyverno has added several new custom filters for handling and manipulating time.
### Time_add
We have added a filter to do arithmetic addition of a duration to a given time. The `time_add()` filter takes a time and a duration and returns a time. For example, `time_add('2023-01-12T12:37:56-05:00','6h')` results in the value `"2023-01-12T18:37:56-05:00"`. Time add has been added for purposes like adding some time to the current time and passing it as an argument for other time related filters.

### Time_after

`time_after()` filter is also a new addition to our library of filters. This is used to verify whether a time is after another time and returns a boolean. It can be used directly as a validation filter, where we can check if current time is greater than a specific time or not and make decisions based on that information.

### Time_before

`time_before()` filter works similarly to the `time_after()` filter. This is used to verify whether a time is before another time and returns a boolean. For example, `time_before('2023-01-12T19:05:59Z','2023-01-13T19:05:59Z')` results in the value `true`. It can be used directly as a validation filter, where we can check if current time is less than a specific time or not and make decisions based on that information.
### Time_between

#### Description
The `time_between()` filter completes the collection of time comparision filters. This filter allows us to check whether a time occurs between a start time and an end time. It is used in the cases that require both `time_before()` and `time_after()` filter. For example, `time_between('2023-01-12T19:05:59Z','2023-01-01T19:05:59Z','2023-01-15T19:05:59Z')` results in the value `true`. It can be used directly as a validation filter, where we can check if current time is between two times or not and make decisions based on that information.
### Time_diff

The `time_diff()` filter is used to find how much time has passed between two time period. For example, `time_diff('2023-01-10T00:00:00Z','2023-01-11T00:00:00Z')` results in the value `"24h0m0s"`. It has been added for a common usecase where we want to check, whether a certain amount of time has been passed since an important event or not, such as to check whether 4 hours have passed since last scan was finished, we can use `time_diff()` filter like this `"{{ time_diff('{{metadata.scanFinishedOn}}','{{ time_now_utc() }}') }}"`
### Time_now

The `time_now()` filter, as the name suggests returns the current time. It has been introduced for the common case where we need current time as an argument for other filters. We require current time in several filters like `time_add()` and this is added for such cases.

### Time_now_utc

The `time_now_utc()` filter works similar to `time_now()` where it returns the current time according to UTC. It has been introduced for the common case where we need current time as an argument for other filters.
### Time_parse

The `Time_parse()` filter is an interesting addition where we can pass any time string in any format to convert it ino the Kyverno standard RFC 3339 format. It takes 2 arguments, the time format and the time string. For example, `time_parse('Mon Jan 02 2006 15:04:05 -0700', 'Fri Jun 22 2022 17:45:00 +0100')` results in the output of `"2022-06-22T17:45:00+01:00"`. This field has been added to allow standardization such that all the timestamps added as metadata and annotations follow the RFC 3339 format.

### Time_to_cron

In kyverno, we use cron in several places to perform job scheduling. The cron expression enables users to schedule tasks to run periodically at a specified date/time. And it's naturally a great tool for automating lots of process runs, which otherwise would require human intervention. We have added a `time_to_cron()` filter to generate a cron expression from a time. For example, `time_to_cron('2022-04-11T03:14:05-07:00')` results in the output `"14 3 11 4 1"`. This filter can be used to generate things like ClusterCleanupPolicy.

### Time_truncate
The `time_truncate()` filter is used to round the given time to the nearest duration which is specified in the arguments. For example,  `time_truncate('2023-01-12T17:37:00Z','1h')` results in the output `"2023-01-12T17:00:00Z"`. 

### Time_utc
#### Description
The `time_utc()` filter takes in a time in RFC 3339 format with a time offset and presents the same time in UTC/Zulu. It can be used in pair with `time_parse()` to convert it to UTC.

## Summary

JMESPath is a powerful and robust tool for selecting, extracting and manipulating time in JSON. With the addition of the new time based filters, we have extended the capabilitites of JMES filters in kyverno and have opened new usecases.