---
date: 2023-09-06
title: "Kyverno Completes Fuzzing Security Audit"
linkTitle: "Kyverno Completes Fuzzing Security Audit"
author: Adam Korczynski
description: "Presenting the results from the fuzzing security audit"
---

Kyverno is happy to announce the completion of its fuzzing security audit. The audit was carried out by [Ada Logics](https://adalogics.com/) and is part of an initiative by the CNCF to bring fuzzing to the CNCF landscape; Fuzzing is an important part in keeping CNCF projects secure and robust, and it has found security vulnerabilities and reliability issues [in several other CNCF-hosted projects](https://www.cncf.io/blog/2023/04/18/cncf-fuzzing-open-source-projects-for-security-and-reliability/). The audit spanned July and August of 2023 and resulted in 15 fuzzers written for the Kyverno project. The fuzzers found three bugs during the audit itself and OSS-Fuzz will continue to run them after the audit has concluded to test Kyverno for bugs and vulnerabilities.

Read the full report for the audit here: [Kyverno Fuzzing Security Audit Report](kyverno-2023-fuzzing-security-audit.pdf).

## Fuzzing

Fuzzing is a technique for finding software bugs in an automated manner. In Go, this includes bugs such as nil-dereference, out-of-bounds panics, out-of-range panics, out-of-memory panics as well as logic bugs. To test your software by way of fuzzing, you need two things:

1. A fuzzing engine
2. A test harness

The fuzzing engine generates the input test cases that it makes available in the test harness. It is the user's job to set up the harness such that it passes the test cases on to the API that the harness is meant to test. Kyverno is implemented in Go, and the auditors wrote the fuzz tests using [the standard library fuzzing engine](https://go.dev/security/fuzz/). Once the user has written a harness and runs it, the fuzzer runs indefinitely until it detects a crash or the user stops it. Each time the harness runs (each fuzz iteration), the engine will generate a new test case by mutating over a collection of test cases that explore new code. This collection of test cases is called a corpus.

## Kyverno fuzzers

All of the fuzzers from the audit are hosted in Kyvernos repository in the package directory that they test. Ada Logics assessed the Kyverno code base by way of static callgraph analysis to determine the optimal entrypoints for the fuzzers and found that the validation routines for Validate, Mutate and Verify Image rules reach a large part of the Kyverno source tree. They then wrote a fuzzer for each routine which passes both a valid Kyverno Cluster Policy as well pseduo-random unstructured Kubernetes resource, testing these validation routines for both reliability and security issues. One of the issues that the fuzzers found during the audit was triggered by Kyvernos mishandling of the input resource. The Validate, Mutate and Verify Image fuzzers require a substantial setup depending on multiple mocked types, and Ada Logics did several iterations to improve their effectiveness. This included several code optimizations in the fuzzers including how the fuzzers generate policy rules and the Kubernetes resources before passing them onto the entrypoints. Another optimization was to add a dictionary; Native Go fuzzing does not support dictionaries, but OSS-Fuzz does when running the fuzzers. A dictionary is a list of tokens that the fuzzing engine will mutate over in the first iterations when starting to run a fuzzer, and it can be a great resource to get a fuzzer started with meaningful test cases. In Kyvernos case, Ada Logics scraped the json tags of several Kubernetes resource types so that the fuzzers can use these when generating the Kubernetes resources.

Besides the far-reaching Validate, Mutate and Verify Image fuzzers, the auditors added fuzzers for other high-level APIs and complex targets in Kyverno. 

All of Kyvernos fuzzers run continuously on [OSS-Fuzz](https://github.com/google/oss-fuzz) that dedicates vast resources to run Kyvernos fuzzer at scale. When a fuzzer finds a crash, OSS-Fuzz notifies the Kyverno maintainers with a crash report and a stack trace.

The fuzzers found 3 bugs during the audit. They were all found by OSS-Fuzz after the fuzzers started running continuously. Ada Logics fixed the three issues. The report includes notes from the triaging of the issues and links to the fixes. 


## Looking forward

The Kyverno fuzzers continue to test the Kyverno code base for old, hard-to-find bugs. Fixing the three issues found during the audit allowed the fuzzers to progress deeper into the logic of Kyverno and may reveal new issues that exist today but take longer to find. For this purpose, Kyverno is backed by OSS-Fuzz which dedicates excessive compute resources to the Kyverno fuzzing suite. OSS-Fuzz will also test for new bugs that get introduced into Kyverno after the fuzzing security audit has concluded, since OSS-Fuzz tests the latest Kyverno main branch every time it builds the fuzzers. In addition to running the fuzzers, OSS-Fuzz also automatically tests whether previously found crashes have been fixed and will also mark them as resolved when needed. 
