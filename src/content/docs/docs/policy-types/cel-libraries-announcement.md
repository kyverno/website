# New CEL Library Functions

Kyverno's CEL environment has been extended with new built-in functions across multiple libraries, enabling hashing, certificate parsing, and more.

| Library   | New Functions                                                                |
| --------- | -----------------------------------------------------------------------------|
| Hash      | `md5(value)`, `sha1(value)`, `sha256(value)`                                 |
| Math      | `math.round(value, precision)`                                               |
| X509      | `x509.decode(pem)`                                                           |
| Random    | `random()`, `random(pattern)`                                                |
| Transform | `listObjToMap(list1, list2, keyField, valueField)`                           |
| JSON      | `json.unmarshal(jsonString)`                                                 |
| YAML      | `yaml.parse(yamlString)`                                                     |
| Time      | `time.now()`, `time.truncate(timestamp, duration)`, `time.toCron(timestamp)` |
