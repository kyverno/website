---
title: JMESPath to CEL
excerpt: Express JMESPath filter logic using Kyverno's CEL-based policy engine.
sidebar:
  order: 131
---

This page maps each JMESPath custom filter from the [JMESPath guide](/docs/policy-types/cluster-policy/jmespath) to its equivalent in Kyverno's CEL-based policy engine (`ValidatingPolicy` and `MutatingPolicy`). Use it as a companion reference when migrating `ClusterPolicy` rules to the newer CEL-based policy types.

For background on the CEL libraries available in Kyverno, see [CEL Libraries](/docs/policy-types/cel-libraries).

:::note[Unsupported or partially supported filters]
The following JMESPath filters are not yet fully supported in the CEL engine:

- **`multiply()` / `divide()`** — Kubernetes quantity-aware multiplication and division are not yet available in CEL. Support is being developed as an upstream Kubernetes contribution.
- **`sum()`** — Summing an array of quantities has no direct CEL equivalent. The Kubernetes CEL quantity type supports pairwise `add()`, but there is no array-reduce equivalent.
- **`compare()`** — This filter for string lexicographical comparison is not carried forward to the CEL engine. 
- **`regex_replace_all()` / `regex_replace_all_literal()`** — CEL string extensions support regex matching (`matches()`, `find()`, `findAll()`) but not regex-based replacement. Support is being developed as an upstream Kubernetes contribution.
:::

## Quick Reference

| JMESPath Filter               | CEL Equivalent                                                     |
| ----------------------------- | ------------------------------------------------------------------ |
| `add()`                       | `quantity(q).add(quantity(q2))` / `quantity(q).add(int)`           |
| `base64_decode()`             | `base64.decode(str)`                                               |
| `base64_encode()`             | `base64.encode(str)`                                               |
| `divide()`                    | Not yet supported (upstream contribution in progress)              |
| `equal_fold()`                | `a.lowerAscii() == b.lowerAscii()`                                 |
| `image_normalize()`           | `image(str).registry()`, `.tag()`, `.repository()`                 |
| `items()`                     | `myMap.map(k, {"key": k, "value": myMap[k]})`                      |
| `label_match()`               | `map1 == map2`                                                     |
| `lookup()`                    | `map["key"]` / `array[index]`                                      |
| `md5()`                       | `md5(str)` (Hash library)                                          |
| `modulo()`                    | `a % b`                                                            |
| `multiply()`                  | Not yet supported (upstream contribution in progress)              |
| `object_from_lists()`         | `listObjToMap(...)` (Transform library)                            |
| `parse_json()`                | `json.unmarshal(str)` (JSON library)                               |
| `parse_yaml()`                | `yaml.parse(str)` (YAML library)                                   |
| `path_canonicalize()`         | `'/' + str.split('/').filter(s, s != '').join('/')`                |
| `pattern_match()`             | Use `regex_match` / `str.matches(regex)` instead                   |
| `random()`                    | `random(pattern)` (Random library)                                 |
| `regex_match()`               | `str.matches(pattern)`                                             |
| `regex_replace_all()`         | Not yet supported (upstream contribution in progress)              |
| `regex_replace_all_literal()` | Not yet supported (upstream contribution in progress)              |
| `replace()`                   | `str.replace(old, new, n)`                                         |
| `replace_all()`               | `str.replace(old, new, -1)`                                        |
| `round()`                     | `math.round(num, places)` (Math library)                           |
| `semver_compare()`            | `semver(str).isGreaterThan(semver(str2))`, `.isLessThan()`         |
| `sha1()`                      | `sha1(str)` (Hash library)                                         |
| `sha256()`                    | `sha256(str)` (Hash library)                                       |
| `split()`                     | `str.split(delimiter)`                                             |
| `subtract()`                  | `quantity(q).sub(quantity(q2))` / `quantity(q).sub(int)`           |
| `sum()`                       | Not supported (no array-reduce equivalent)                         |
| `time_add()`                  | `timestamp(str) + duration(dur)`                                   |
| `time_after()`                | `timestamp(t1) > timestamp(t2)`                                    |
| `time_before()`               | `timestamp(t1) < timestamp(t2)`                                    |
| `time_between()`              | `timestamp(t) > timestamp(start) && timestamp(t) < timestamp(end)` |
| `time_diff()`                 | `timestamp(end) - timestamp(start)`                                |
| `time_now()`                  | `time.now()`                                                       |
| `time_now_utc()`              | `time.now()`                                                       |
| `time_parse()`                | `timestamp(str)` (RFC 3339 and Unix epoch only)                    |
| `time_since()`                | `time.now() - timestamp(start)`                                    |
| `time_to_cron()`              | `time.toCron(timestamp(str))`                                      |
| `time_truncate()`             | `time.truncate(timestamp(str), duration(dur))`                     |
| `time_utc()`                  | `string(timestamp(str))`                                           |
| `to_boolean()`                | `str.lowerAscii() == "true"`                                       |
| `to_lower()`                  | `str.lowerAscii()`                                                 |
| `to_upper()`                  | `str.upperAscii()`                                                 |
| `trim()`                      | `str.trim()` / `str.replace(chars, "")`                            |
| `trim_prefix()`               | `str.replace(prefix, "", 1)`                                       |
| `truncate()`                  | `str.substring(0, n)`                                              |
| `x509_decode()`               | `x509.decode(str)` (X509 library)                                  |

## Detailed Equivalents

### Add

The JMESPath `add()` filter is unit-aware: it can sum plain numbers, Kubernetes resource quantities (e.g., `10Mi`, `500m`), and durations. In CEL, the approach depends on the type of values being added:

- **Plain numbers** — use the native `+` operator.
- **Kubernetes quantities** — use the `quantity()` constructor together with the `.add()` method, which accepts either another `quantity` or a plain integer (interpreted as bytes for memory quantities).
- **Durations** — use native CEL duration arithmetic: `duration("1h") + duration("30s")`.

The Kubernetes CEL quantity type also exposes `.sign()` (returns `1`, `-1`, or `0`) and comparison methods `isLessThan()`, `isGreaterThan()`, and `compareTo()` for combining quantity results with conditions.

| JMESPath             | CEL                                     |
| -------------------- | --------------------------------------- |
| `add(`10`, `5`)`     | `10 + 5`                                |
| `add('10Mi', '5Mi')` | `quantity("10Mi").add(quantity("5Mi"))` |
| `add('10Mi', `5`)`   | `quantity("10Mi").add(5)`               |
| `add('1h', '30s')`   | `duration("1h") + duration("30s")`      |

**Example:** This policy ensures that a container's memory request, plus a fixed 256Mi overhead reserved for an injected sidecar, does not exceed 2Gi.

JMESPath (`ClusterPolicy`):

```yaml
validate:
  failureAction: Enforce
  message: 'Container memory request plus 256Mi sidecar overhead must not exceed 2Gi.'
  foreach:
    - list: 'request.object.spec.containers'
      deny:
        conditions:
          any:
            - key: "{{ add('{{ element.resources.requests.memory || `0` }}', '256Mi') }}"
              operator: GreaterThan
              value: 2Gi
```

CEL (`ValidatingPolicy`):

```yaml
validations:
  - expression: >-
      object.spec.containers.all(c,
        quantity(c.resources.?requests.memory.orValue("0")).add(quantity("256Mi")).isLessThan(quantity("2Gi"))
      )
    message: Container memory request plus 256Mi sidecar overhead must not exceed 2Gi.
```

---

### Subtract

The JMESPath `subtract()` filter mirrors `add()` and is equally unit-aware. In CEL, the same breakdown by type applies.

| JMESPath                  | CEL                                     |
| ------------------------- | --------------------------------------- |
| `subtract(`10`, `2`)`     | `10 - 2`                                |
| `subtract('10Mi', '5Ki')` | `quantity("10Mi").sub(quantity("5Ki"))` |
| `subtract('10Mi', `5`)`   | `quantity("10Mi").sub(5)`               |
| `subtract('2h', '30s')`   | `duration("2h") - duration("30s")`      |

---

### Lookup

The JMESPath `lookup()` function retrieves a value from a map by key or from an array by index, and is primarily useful for _dynamic_ lookups where the key is itself computed at runtime. CEL supports this natively through direct map and array access.

| JMESPath               | CEL            |
| ---------------------- | -------------- |
| `lookup(map, 'mykey')` | `map["mykey"]` |
| `lookup(array, 1)`     | `array[1]`     |

**Example:**

```cel
// Map lookup
object.metadata.labels["env"]

// Array index
object.spec.containers[0].image
```

---

### Label Match

CEL allows direct comparison of maps with `==`, so `label_match()` does not need a dedicated replacement. Two label maps that are identical in content will compare as equal regardless of insertion order, matching the function's intent.

```cel
object.metadata.labels == object.spec.selector.matchLabels
```

---

### Equal Fold

The JMESPath `equal_fold()` function compares two strings case-insensitively. In CEL, normalize both to the same case before comparing.

| JMESPath           | CEL                                |
| ------------------ | ---------------------------------- |
| `equal_fold(a, b)` | `a.lowerAscii() == b.lowerAscii()` |

**Example:** This policy validates that a ConfigMap's `dept` label and its `data.dept` value are equal regardless of letter case.

JMESPath (`ClusterPolicy`):

```yaml
validate:
  failureAction: Enforce
  message: The dept label must equal the data.dept value aside from case.
  deny:
    conditions:
      any:
        - key: "{{ equal_fold('{{request.object.metadata.labels.dept}}', '{{request.object.data.dept}}') }}"
          operator: NotEquals
          value: true
```

CEL (`ValidatingPolicy`):

```yaml
validations:
  - expression: >-
      object.metadata.labels["dept"].lowerAscii() == object.data["dept"].lowerAscii()
    message: The dept label must equal the data.dept value aside from case.
```

---

### Image Normalize

The JMESPath `image_normalize()` function expands a short image reference to its canonical form, filling in the default registry (`docker.io`) and tag (`latest`) where absent. In CEL, the [Image library](/docs/policy-types/cel-libraries#image-library) parses image references and exposes each component as a method, making it straightforward to inspect or reconstruct the full reference.

| JMESPath               | CEL                                                                  |
| ---------------------- | -------------------------------------------------------------------- |
| `image_normalize(img)` | `image(img)` → `.registry()`, `.repository()`, `.tag()`, `.digest()` |

**Example:** This policy requires all container images to come from an approved internal registry.

JMESPath (`ClusterPolicy`):

```yaml
foreach:
  - list: 'request.object.spec.containers'
    deny:
      conditions:
        any:
          - key: "{{ image_normalize('{{element.image}}') | split(@, '/') | [0] }}"
            operator: NotEquals
            value: harbor.corp.org
```

CEL (`ValidatingPolicy`):

```yaml
validations:
  - expression: >-
      object.spec.containers.all(c, image(c.image).registry() == "harbor.corp.org")
    message: All images must come from harbor.corp.org.
```

---

### Truncate

The JMESPath `truncate()` function limits a string to its first N characters. In CEL, use `substring(startIndex, endIndex)` from the Kubernetes string extensions.

| JMESPath           | CEL                   |
| ------------------ | --------------------- |
| `truncate(str, n)` | `str.substring(0, n)` |

**Example:** This policy truncates a `buildhash` label to its first 12 characters.

JMESPath (`ClusterPolicy`):

```yaml
mutate:
  patchStrategicMerge:
    metadata:
      labels:
        buildhash: "{{ truncate('{{@}}', `12`) }}"
```

CEL (`MutatingPolicy`):

```yaml
variables:
- name: buildHash
  expression: object.metadata.labels["buildhash"].substring(0, 12)
mutations:
  - patchType: ApplyConfiguration
    applyConfiguration:
      expression: |
        Object{
          metadata: Object.metadata{
            labels: {
              "buildhash": variables.buildHash
            }
          }
        }
```

---

### Trim

The JMESPath `trim()` function strips a set of arbitrary characters from both ends of a string. In CEL:

- For **whitespace** trimming, use `str.trim()` from the Kubernetes string extensions.
- For **specific characters or known substrings**, compose `str.replace(chars, "")` calls.

| JMESPath                              | CEL                            |
| ------------------------------------- | ------------------------------ |
| Whitespace trimming                   | `str.trim()`                   |
| Specific character/substring trimming | `str.replace("@corp.com", "")` |

**Example:** This policy strips a domain suffix from an email annotation.

JMESPath (`ClusterPolicy`):

```yaml
mutate:
  patchStrategicMerge:
    metadata:
      annotations:
        extnameemail: "{{ trim('{{@}}','@corp.com') }}"
```

CEL (`MutatingPolicy`):

```yaml
mutations:
  - patchType: ApplyConfiguration
    applyConfiguration:
      expression: |
        Object{
          metadata: Object.metadata{
            annotations: {
              "extnameemail": object.metadata.annotations["extnameemail"].replace("@corp.com", "")
            }
          }
        }
```

---

### Trim Prefix

The JMESPath `trim_prefix()` function removes a specific string from the beginning of another string. In CEL, use `replace()` with a count of `1` to remove only the first occurrence of the prefix.

| JMESPath                   | CEL                          |
| -------------------------- | ---------------------------- |
| `trim_prefix(str, prefix)` | `str.replace(prefix, "", 1)` |

**Example:** This policy removes the `docker://` URI scheme from an image URL.

JMESPath (`ClusterPolicy`):

```yaml
imageExtractors:
  DataVolume:
    - path: /spec/source/registry/url
      jmesPath: "trim_prefix(@, 'docker://')"
```

CEL:

```cel
c.image.replace("docker://", "", 1)
```

---

### Replace / Replace All

The JMESPath `replace()` function replaces up to N occurrences of a substring; `replace_all()` replaces every occurrence. In CEL, the `replace()` function from the Kubernetes string extensions handles both cases: pass a positive integer to limit replacements, or `-1` to replace all occurrences.

| JMESPath                     | CEL                         |
| ---------------------------- | --------------------------- |
| `replace_all(str, old, new)` | `str.replace(old, new, -1)` |
| `replace(str, old, new, n)`  | `str.replace(old, new, n)`  |

**Example:** This policy normalizes a `team` annotation by replacing spaces with hyphens.

JMESPath (`ClusterPolicy`):

```yaml
mutate:
  patchStrategicMerge:
    metadata:
      annotations:
        team: "{{ replace_all('{{request.object.metadata.annotations.team}}', ' ', '-') }}"
```

CEL (`MutatingPolicy`):

```yaml
variables:
  - name: newTeam
    expression: >-
      object.metadata.annotations["team"].replace(" ", "-", -1)
mutations:
  - patchType: ApplyConfiguration
    applyConfiguration:
      expression: |
        Object{
          metadata: Object.metadata{
            annotations: {
              "team": variables.newTeam
            }
          }
        }
```

---

### Path Canonicalize

The JMESPath `path_canonicalize()` function removes redundant slashes from a filesystem path (e.g., `/var//lib///kubelet` → `/var/lib/kubelet`). In CEL, reproduce this by splitting on `/`, discarding empty segments, and rejoining.

| JMESPath                  | CEL                                                  |
| ------------------------- | ---------------------------------------------------- |
| `path_canonicalize(path)` | `'/' + path.split('/').filter(s, s != '').join('/')` |

**Example:** This policy prevents mounting the Containerd socket even when extra slashes are used in the path.

JMESPath (`ClusterPolicy`):

```yaml
foreach:
  - list: 'request.object.spec.volumes[]'
    deny:
      conditions:
        any:
          - key: '{{ path_canonicalize(element.hostPath.path) }}'
            operator: Equals
            value: '/var/run/containerd/containerd.sock'
```

CEL (`ValidatingPolicy`):

```yaml
variables:
  - name: mountsContainerdSocket
    expression: >-
      object.spec.?volumes.orValue([]).exists(v,
        has(v.hostPath) &&
        ('/' + v.hostPath.path.split('/').filter(s, s != '').join('/')) == '/var/run/containerd/containerd.sock'
      )
validations:
  - expression: variables.mountsContainerdSocket == false
    message: Mounting the Containerd socket is not allowed.
```

---

### Base64 Decode / Encode

The JMESPath `base64_decode()` and `base64_encode()` filters decode and encode base64 strings. In CEL, these are available as standard extensions.

| JMESPath             | CEL                  |
| -------------------- | -------------------- |
| `base64_decode(str)` | `base64.decode(str)` |
| `base64_encode(str)` | `base64.encode(str)` |

**Example:** This policy decodes a Secret's `license` field and blocks a known prohibited key.

JMESPath (`ClusterPolicy`):

```yaml
context:
  - name: status
    apiCall:
      jmesPath: 'data.license'
      urlPath: '/api/v1/namespaces/{{request.namespace}}/secrets/{{element.name}}'
deny:
  conditions:
    any:
      - key: '{{ status | base64_decode(@) }}'
        operator: Equals
        value: W0247-4RXD3-6TW0F-0FD63-64EFD-38180
```

CEL (`ValidatingPolicy`):

```yaml
variables:
  - name: secret
    expression: >-
      resource.Get("v1", "secrets", object.metadata.namespace, "license-secret")
  - name: licenseKey
    expression: base64.decode(variables.secret.data["license"])
validations:
  - expression: variables.licenseKey != "W0247-4RXD3-6TW0F-0FD63-64EFD-38180"
    message: This license key may not be consumed by a Secret.
```

---

### To Lower / To Upper

The JMESPath `to_lower()` and `to_upper()` functions normalize string casing. In CEL, use the Kubernetes string extensions `lowerAscii()` and `upperAscii()`.

| JMESPath        | CEL                |
| --------------- | ------------------ |
| `to_lower(str)` | `str.lowerAscii()` |
| `to_upper(str)` | `str.upperAscii()` |

**Example:** This policy normalizes a zone label to lowercase.

JMESPath (`ClusterPolicy`):

```yaml
mutate:
  patchStrategicMerge:
    metadata:
      labels:
        zonekey: "{{ to_lower('{{@}}') }}"
```

CEL (`MutatingPolicy`):

```yaml
mutations:
  - patchType: ApplyConfiguration
    applyConfiguration:
      expression: |
        Object{
          metadata: Object.metadata{
            labels: {
              "zonekey": object.metadata.labels["zonekey"].lowerAscii()
            }
          }
        }
```

---

### To Boolean

The JMESPath `to_boolean()` function converts the strings `"true"` or `"false"` to their boolean equivalents regardless of letter case. In CEL, lowercase the string and compare directly.

| JMESPath          | CEL                          |
| ----------------- | ---------------------------- |
| `to_boolean(str)` | `str.lowerAscii() == "true"` |

**Example:** This policy sets `hostIPC` from a label value.

JMESPath (`ClusterPolicy`):

```yaml
mutate:
  patchStrategicMerge:
    spec:
      hostIPC: '{{ to_boolean(request.object.metadata.labels.canuseIPC) }}'
```

CEL (`MutatingPolicy`):

```yaml
mutations:
  - patchType: ApplyConfiguration
    applyConfiguration:
      expression: |
        Object{
          spec: Object.spec{
            hostIPC: object.metadata.labels["canuseIPC"].lowerAscii() == "true"
          }
        }
```

---

### Split

The JMESPath `split()` function splits a string into an array on a delimiter. In CEL, the same function is available via the Kubernetes string extensions.

| JMESPath                      | CEL                          |
| ----------------------------- | ---------------------------- |
| `split('cat,dog,horse', ',')` | `'cat,dog,horse'.split(',')` |

**Example:** This policy validates that the `env` label on a Deployment starts with a known tier (`production` or `staging`). The label value is a hyphen-separated composite such as `production-us-east-1`.

JMESPath (`ClusterPolicy`):

```yaml
# trigger: Deployment
deny:
  conditions:
    any:
      - key: "{{ split(request.object.metadata.labels.env, '-') | [0] }}"
        operator: NotIn
        value:
          - production
          - staging
```

CEL (`ValidatingPolicy`):

```yaml
# trigger: Deployment
validations:
  - expression: >-
      object.metadata.labels["env"].split("-")[0] in ["production", "staging"]
    message: The env label must start with 'production' or 'staging'.
```

---

### Modulo

The JMESPath `modulo()` filter returns the remainder of a division. In CEL, use the `%` operator directly (integers only).

| JMESPath       | CEL     |
| -------------- | ------- |
| `modulo(a, b)` | `a % b` |

---

### Round

The JMESPath `round()` filter rounds a number to a given number of decimal places. In CEL, use the [Math library](/docs/policy-types/cel-libraries#math-library).

| JMESPath             | CEL                       |
| -------------------- | ------------------------- |
| `round(num, places)` | `math.round(num, places)` |

**Example:** This policy validates that CPU requests are rounded to at most 2 decimal places.

CEL (`ValidatingPolicy`):

```yaml
validations:
  - expression: >-
      variables.cpuRequests.all(cpu,
        cpu == 0.0 || math.round(cpu, 2) == cpu
      )
    message: CPU requests must be rounded to at most 2 decimal places.
```

---

### Regex Match

The JMESPath `regex_match()` filter tests a string against a regular expression pattern. In CEL, use the native `matches()` method.

| JMESPath                    | CEL                    |
| --------------------------- | ---------------------- |
| `regex_match(pattern, str)` | `str.matches(pattern)` |

**Example:** This policy validates that the `app.kubernetes.io/version` label on a Deployment follows semantic versioning.

JMESPath (`ClusterPolicy`):

```yaml
# trigger: Deployment
deny:
  conditions:
    any:
      - key: "{{ regex_match('^\\d+\\.\\d+\\.\\d+$', '{{request.object.metadata.labels[\"app.kubernetes.io/version\"]}}') }}"
        operator: Equals
        value: false
```

CEL (`ValidatingPolicy`):

```yaml
# trigger: Deployment
validations:
  - expression: >-
      object.metadata.labels["app.kubernetes.io/version"].matches('^\\d+\\.\\d+\\.\\d+$')
    message: The app.kubernetes.io/version label must follow semantic versioning (e.g. 1.2.3).
```

---

### Regex Replace All / Regex Replace All Literal

The JMESPath `regex_replace_all()` and `regex_replace_all_literal()` filters perform regex-based string replacement, with the former supporting capture group references in the replacement string. The CEL string extensions include `matches()`, `find()`, and `findAll()` for pattern detection but do not yet support regex replacement. Support is being developed as an upstream Kubernetes contribution.

---

### Items

The JMESPath `items()` filter converts a map into an array of objects, assigning a custom name to the key and value fields. In CEL, use the `.map()` macro to iterate over a map's keys and construct the target shape.

| JMESPath                     | CEL                                       |
| ---------------------------- | ----------------------------------------- |
| `items(map, 'key', 'value')` | `map.map(k, {"key": k, "value": map[k]})` |
| Keys only                    | `map.map(k, k)`                           |

**Example:** This policy adds a Pod's label keys as an annotation listing them.

JMESPath (`ClusterPolicy`):

```yaml
context:
  - name: labelKeys
    variable:
      jmesPath: items(request.object.metadata.labels,'key','value')[].key
mutate:
  patchStrategicMerge:
    metadata:
      annotations:
        label-keys: '{{labelKeys | join('','', @)}}'
```

CEL (`MutatingPolicy`):

```yaml
variables:
  - name: labelKeys
    expression: object.metadata.labels.map(k, k)
  - name: labelKeysStr
    expression: variables.labelKeys.join(",")
mutations:
  - patchType: ApplyConfiguration
    applyConfiguration:
      expression: |
        Object{
          metadata: Object.metadata{
            annotations: {
              "label-keys": variables.labelKeysStr
            }
          }
        }
```

---

### Object From Lists

The JMESPath `object_from_lists()` filter takes two parallel arrays and produces a map, using one array as keys and the other as values. In CEL, the [Transform library](/docs/policy-types/cel-libraries#transform-library) provides `listObjToMap()`, which performs the same operation over lists of objects by specifying which field to use as the key and which as the value.

| JMESPath                                       | CEL                                       |
| ---------------------------------------------- | ----------------------------------------- |
| `object_from_lists(envs[].name, envs[].value)` | `listObjToMap(env, env, "name", "value")` |

**Example:** This policy maps container environment variable names to their values and checks a specific key.

JMESPath (`ClusterPolicy`):

```yaml
context:
  - name: envs_to_labels
    variable:
      jmesPath: object_from_lists(envs[].name, envs[].value)
```

CEL (`ValidatingPolicy`):

```yaml
variables:
  - name: envMap
    expression: >-
      listObjToMap(
        object.spec.containers[0].env,
        object.spec.containers[0].env,
        "name",
        "value"
      )
validations:
  - expression: variables.envMap["KEY"] == "123-456-789"
    message: KEY must be 123-456-789.
```

---

### Parse JSON

The JMESPath `parse_json()` filter parses a JSON string into a structured object. In CEL, use `json.unmarshal()` from the [JSON library](/docs/policy-types/cel-libraries#json-library).

| JMESPath          | CEL                   |
| ----------------- | --------------------- |
| `parse_json(str)` | `json.unmarshal(str)` |

**Example:** This policy parses JSON-encoded approval metadata from an annotation. The annotation on the target resource looks like:

```yaml
metadata:
  annotations:
    security.approval: '{"approved": true, "approver": "alice", "ticket": "SEC-1234"}'
```

JMESPath (`ClusterPolicy`):

```yaml
deny:
  conditions:
    - key: '{{ request.object.metadata.annotations.config | parse_json(@).approved }}'
      operator: NotEquals
      value: true
```

CEL (`ValidatingPolicy`):

```yaml
variables:
  - name: approval
    expression: json.unmarshal(object.metadata.annotations["security.approval"])
validations:
  - expression: variables.approval.approved == true
    message: Deployment is not approved by security policy.
```

---

### Parse YAML

The JMESPath `parse_yaml()` filter parses a YAML string into a structured object. In CEL, use `yaml.parse()` from the [YAML library](/docs/policy-types/cel-libraries#yaml-library).

| JMESPath          | CEL               |
| ----------------- | ----------------- |
| `parse_yaml(str)` | `yaml.parse(str)` |

**Example:** This policy parses a YAML annotation and checks a nested boolean field. The annotation on the target resource looks like:

```yaml
metadata:
  annotations:
    pets: |
      species:
        name: dog
        isGoodBoi: true
```

JMESPath (`ClusterPolicy`):

```yaml
deny:
  conditions:
    - key: '{{request.object.metadata.annotations.pets | parse_yaml(@).species.isGoodBoi }}'
      operator: NotEquals
      value: true
```

CEL (`ValidatingPolicy`):

```yaml
variables:
  - name: pets
    expression: yaml.parse(object.metadata.annotations["pets"])
validations:
  - expression: variables.pets.species.isGoodBoi == true
    message: Only good bois allowed.
```

---

### MD5 / SHA1 / SHA256

The JMESPath hash filters have direct equivalents in the CEL [Hash library](/docs/policy-types/cel-libraries#hash-library).

| JMESPath      | CEL           |
| ------------- | ------------- |
| `md5(str)`    | `md5(str)`    |
| `sha1(str)`   | `sha1(str)`   |
| `sha256(str)` | `sha256(str)` |

**Example:** This policy validates the MD5 hash of an image name against an expected value.

JMESPath (`ClusterPolicy`):

```yaml
mutate:
  patchStrategicMerge:
    metadata:
      name: '{{ md5(request.object.metadata.name) }}'
```

CEL (`ValidatingPolicy`):

```yaml
variables:
  - name: expectedHash
    expression: '"403554a5dfea78d1ca4a8ff5830ac2ae"'
  - name: md5sum
    expression: md5(object.spec.template.spec.containers[0].image)
validations:
  - expression: variables.md5sum == variables.expectedHash
    messageExpression: '"Expected MD5 hash " + variables.expectedHash + ", got: " + variables.md5sum'
```

---

### Random

The JMESPath `random()` filter generates a random string matching a regex pattern. The CEL [Random library](/docs/policy-types/cel-libraries#random-library) provides the same function with identical syntax.

| JMESPath                | CEL                     |
| ----------------------- | ----------------------- |
| `random('[a-z0-9]{6}')` | `random("[a-z0-9]{6}")` |

**Example:** This policy adds a random tracking label to new Secrets.

JMESPath (`ClusterPolicy`):

```yaml
context:
  - name: randomtest
    variable:
      jmesPath: random('[a-z0-9]{6}')
mutate:
  patchStrategicMerge:
    metadata:
      labels:
        randomoutput: random-{{randomtest}}
```

CEL (`MutatingPolicy`):

```yaml
mutations:
  - patchType: ApplyConfiguration
    applyConfiguration:
      expression: |
        Object{
          metadata: Object.metadata{
            labels: {
              "randomoutput": "random-" + random("[a-z0-9]{6}")
            }
          }
        }
```

---

### Semver Compare

The JMESPath `semver_compare()` filter compares two semantic version strings and accepts operator prefixes and range expressions. In CEL, use the native Kubernetes `semver()` type which exposes `isGreaterThan()`, `isLessThan()`, `major()`, `minor()`, and `patch()` methods for precise comparisons.

| JMESPath                   | CEL                                                                       |
| -------------------------- | ------------------------------------------------------------------------- |
| `semver_compare(v, '>v2')` | `semver(v).isGreaterThan(semver(v2))`                                     |
| `semver_compare(v, '<v2')` | `semver(v).isLessThan(semver(v2))`                                        |
| `semver_compare(v, '=v2')` | `semver(v) == semver(v2)`                                                 |
| AND range `>v1 <v2`        | `semver(v).isGreaterThan(semver(v1)) && semver(v).isLessThan(semver(v2))` |
| Component check `>=4.1.x`  | `semver(v).major() == 4 && semver(v).minor() >= 1`                        |

**Example:** This policy checks that a component's version is greater than 4.5.0.

JMESPath (`ClusterPolicy`):

```yaml
conditions:
  - all:
      - key: "{{ semver_compare( {{ components[?name == 'httpclient'].version | [0] }}, '>4.5.0') }}"
        operator: Equals
        value: true
```

CEL (`ValidatingPolicy`):

```yaml
validations:
  - expression: >-
      variables.components.exists(c,
        c.name == "httpclient" &&
        semver(c.version).isGreaterThan(semver("4.5.0"))
      )
    message: httpclient version must be greater than 4.5.0.
```

---

### x509 Decode

The JMESPath `x509_decode()` filter decodes a PEM-encoded X.509 certificate into a structured object. In CEL, the [X509 library](/docs/policy-types/cel-libraries#x509-library) provides `x509.decode()` with the same capability and field structure.

| JMESPath           | CEL                |
| ------------------ | ------------------ |
| `x509_decode(pem)` | `x509.decode(pem)` |

**Example:** This policy checks that a webhook's CA certificate does not expire within the next week.

JMESPath (`ClusterPolicy`):

```yaml
deny:
  conditions:
    any:
      - key: "{{ base64_decode('{{ request.object.webhooks[0].clientConfig.caBundle }}').x509_decode(@).time_since('',NotBefore,NotAfter) }}"
        operator: LessThan
        value: 168h0m0s
```

CEL (`ValidatingPolicy`):

```yaml
validations:
  - expression: >-
      timestamp(x509.decode(string(base64.decode(object.webhooks[0].clientConfig.caBundle))).NotAfter) - time.now() > duration("168h")
    message: Certificate in the webhook will expire in less than a week.
```

---

## Time Operations

All JMESPath time filters have CEL equivalents. The CEL engine provides native `timestamp()` and `duration()` types, and the Kyverno [Time functions](/docs/policy-types/cel-libraries#time-functions) library adds `time.now()`, `time.truncate()`, and `time.toCron()`.

### time_now / time_now_utc

Both `time_now()` and `time_now_utc()` return the current time. In CEL, `time.now()` always returns a UTC timestamp and covers both.

| JMESPath         | CEL          |
| ---------------- | ------------ |
| `time_now()`     | `time.now()` |
| `time_now_utc()` | `time.now()` |

---

### time_add

| JMESPath                 | CEL                                  |
| ------------------------ | ------------------------------------ |
| `time_add(rfc3339, dur)` | `timestamp(rfc3339) + duration(dur)` |

**Example:** This policy generates a ClusterCleanupPolicy scheduled 4 hours after creation.

JMESPath (`ClusterPolicy`):

```yaml
schedule: "{{ time_add('{{ time_now_utc() }}','4h') | time_to_cron(@) }}"
```

CEL (expression):

```cel
time.toCron(time.now() + duration("4h"))
```

---

### time_after / time_before / time_between

| JMESPath                      | CEL                                                                |
| ----------------------------- | ------------------------------------------------------------------ |
| `time_after(t1, t2)`          | `timestamp(t1) > timestamp(t2)`                                    |
| `time_before(t1, t2)`         | `timestamp(t1) < timestamp(t2)`                                    |
| `time_between(t, start, end)` | `timestamp(t) > timestamp(start) && timestamp(t) < timestamp(end)` |

**Example:** This policy denies ConfigMap creation after a cluster decommission deadline.

JMESPath (`ClusterPolicy`):

```yaml
key: "{{ time_after('{{time_now_utc() }}','2023-01-12T00:00:00Z') }}"
operator: Equals
value: true
```

CEL (`ValidatingPolicy`):

```yaml
validations:
  - expression: time.now() < timestamp("2023-01-12T00:00:00Z")
    message: This cluster is being decommissioned and no further resources may be created after January 12th.
```

**Example:** Time-bounded policy active only within a date range.

JMESPath (`ClusterPolicy`):

```yaml
preconditions:
  all:
    - key: "{{ time_between('{{ time_now_utc() }}','2023-01-01T00:00:00Z','2023-01-31T23:59:59Z') }}"
      operator: Equals
      value: true
```

CEL (`ValidatingPolicy`):

```yaml
variables:
  - name: withinWindow
    expression: >-
      time.now() > timestamp("2023-01-01T00:00:00Z") &&
      time.now() < timestamp("2023-01-31T23:59:59Z")
```

---

### time_diff

| JMESPath                | CEL                                 |
| ----------------------- | ----------------------------------- |
| `time_diff(start, end)` | `timestamp(end) - timestamp(start)` |

The result in CEL is a `duration` that can be compared against `duration("24h")` or similar values.

---

### time_since

The JMESPath `time_since()` filter calculates elapsed time from a fixed start time, optionally using the current time as the end. In CEL, subtract a `timestamp()` from `time.now()` to produce a `duration`.

| JMESPath                        | CEL                                 |
| ------------------------------- | ----------------------------------- |
| `time_since('', startTime, '')` | `time.now() - timestamp(startTime)` |

**Example:** This policy blocks containers built more than 6 months ago.

JMESPath (`ClusterPolicy`):

```yaml
- key: "{{ time_since('', '{{ imageData.configData.created }}', '') }}"
  operator: GreaterThan
  value: 4380h
```

CEL (`ValidatingPolicy`):

```yaml
validations:
  - expression: >-
      object.spec.containers.all(c,
        time.now() - timestamp(variables.imageData.configData.created) <= duration("4380h")
      )
    message: Images built more than 6 months ago are prohibited.
```

---

### time_to_cron

| JMESPath                | CEL                               |
| ----------------------- | --------------------------------- |
| `time_to_cron(rfc3339)` | `time.toCron(timestamp(rfc3339))` |

---

### time_truncate

| JMESPath                      | CEL                                                |
| ----------------------------- | -------------------------------------------------- |
| `time_truncate(rfc3339, dur)` | `time.truncate(timestamp(rfc3339), duration(dur))` |

**Example:** This policy rounds a timestamp annotation down to the nearest 2-hour boundary.

JMESPath (`ClusterPolicy`):

```yaml
thistime: "{{ time_truncate('{{ @ }}','2h') }}"
```

CEL (`MutatingPolicy`):

```yaml
variables:
- name: thistime
  expression: |
    time.truncate(timestamp(object.metadata.annotations["thistime"]), duration("2h"))
mutations:
  - patchType: ApplyConfiguration
    applyConfiguration:
      expression: |
        Object{
          metadata: Object.metadata{
            annotations: {
              "thistime": string(variables.thistime)
            }
          }
        }
```

---

### time_utc

The JMESPath `time_utc()` function converts a timezone-offset RFC 3339 string to its UTC equivalent. In CEL, `timestamp()` already normalizes any RFC 3339 input (including those with timezone offsets) to UTC internally. Calling `string()` on the result produces the canonical UTC string.

| JMESPath                      | CEL                                    |
| ----------------------------- | -------------------------------------- |
| `time_utc(rfc3339WithOffset)` | `string(timestamp(rfc3339WithOffset))` |

**Example:**

JMESPath expression: `time_utc('2021-01-02T18:04:05-05:00')` → `"2021-01-02T23:04:05Z"`

CEL expression: `string(timestamp("2021-01-02T18:04:05-05:00"))` → `"2021-01-02T23:04:05Z"`

---

### time_parse

The JMESPath `time_parse()` function converts a time string to RFC 3339. In CEL, use `timestamp()` directly with an RFC 3339 string or a Unix epoch integer.

| JMESPath                                         | CEL                     |
| ------------------------------------------------ | ----------------------- |
| `time_parse(rfc3339Layout, str)`                 | `timestamp(str)`        |
| `time_parse('1702691171', '1702691171')` (epoch) | `timestamp(1702691171)` |
