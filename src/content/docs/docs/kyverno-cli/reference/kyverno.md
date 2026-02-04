---
title: "kyverno"
weight: 35
---
## kyverno

Kubernetes Native Policy Management.

### Synopsis

Kubernetes Native Policy Management.
  
  The Kyverno CLI provides a command-line interface to work with Kyverno resources.
  It can be used to validate and test policy behavior to resources prior to adding them to a cluster.
  
  The Kyverno CLI comes with additional commands to help creating and manipulating various Kyverno resources.
  
  NOTE: To enable experimental commands, environment variable "KYVERNO_EXPERIMENTAL" should be set true or 1.


```
kyverno [flags]
```

### Options

```
      --add_dir_header                   If true, adds the file directory to the header of the log messages
      --alsologtostderr                  log to standard error as well as files (no effect when -logtostderr=true)
  -h, --help                             help for kyverno
      --kubeconfig string                Paths to a kubeconfig. Only required if out-of-cluster.
      --log_backtrace_at traceLocation   when logging hits line file:N, emit a stack trace (default :0)
      --log_dir string                   If non-empty, write log files in this directory (no effect when -logtostderr=true)
      --log_file string                  If non-empty, use this log file (no effect when -logtostderr=true)
      --log_file_max_size uint           Defines the maximum size a log file can grow to (no effect when -logtostderr=true). Unit is megabytes. If the value is 0, the maximum file size is unlimited. (default 1800)
      --logtostderr                      log to standard error instead of files (default true)
      --one_output                       If true, only write logs to their native severity level (vs also writing to each lower severity level; no effect when -logtostderr=true)
      --skip_headers                     If true, avoid header prefixes in the log messages
      --skip_log_headers                 If true, avoid headers when opening log files (no effect when -logtostderr=true)
      --stderrthreshold severity         logs at or above this threshold go to stderr when writing to files and stderr (no effect when -logtostderr=true or -alsologtostderr=true) (default 2)
  -v, --v Level                          number for the log level verbosity
      --vmodule moduleSpec               comma-separated list of pattern=N settings for file-filtered logging
```

### SEE ALSO

* [kyverno apply](/docs/kyverno-cli/reference/kyverno_apply)	 - Applies policies on resources.
* [kyverno completion](/docs/kyverno-cli/reference/kyverno_completion)	 - Generate the autocompletion script for kyverno for the specified shell.
* [kyverno create](/docs/kyverno-cli/reference/kyverno_create)	 - Helps with the creation of various Kyverno resources.
* [kyverno docs](/docs/kyverno-cli/reference/kyverno_docs)	 - Generates reference documentation.
* [kyverno jp](/docs/kyverno-cli/reference/kyverno_jp)	 - Provides a command-line interface to JMESPath, enhanced with Kyverno specific custom functions.
* [kyverno json](/docs/kyverno-cli/reference/kyverno_json)	 - Runs tests against any json compatible payloads/policies.
* [kyverno migrate](/docs/kyverno-cli/reference/kyverno_migrate)	 - Migrate one or more resources to the stored version.
* [kyverno test](/docs/kyverno-cli/reference/kyverno_test)	 - Run tests from a local filesystem or a remote git repository.
* [kyverno version](/docs/kyverno-cli/reference/kyverno_version)	 - Prints the version of Kyverno CLI.

