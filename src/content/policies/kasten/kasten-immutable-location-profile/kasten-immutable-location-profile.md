---
title: 'Check Kasten Location Profile is Immutable'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - config.kio.kasten.io/v1alpha1/Profile
tags: []
version: 1.6.0
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/kasten/kasten-immutable-location-profile/kasten-immutable-location-profile.yaml" target="-blank">/kasten/kasten-immutable-location-profile/kasten-immutable-location-profile.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: kasten-immutable-location-profile
  annotations:
    policies.kyverno.io/title: Check Kasten Location Profile is Immutable
    policies.kyverno.io/category: Veeam Kasten
    policies.kyverno.io/subject: config.kio.kasten.io/v1alpha1/Profile
    kyverno.io/kyverno-version: 1.12.1
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: 1.25-1.30
    policies.kyverno.io/description: Ensure Kasten Location Profiles have enabled immutability to prevent unintentional or malicious changes to backup data.
spec:
  validationFailureAction: Audit
  rules:
    - name: kasten-immutable-location-profile
      match:
        resources:
          kinds:
            - Profile
      validate:
        message: All Kasten Location Profiles must have immutability enabled.
        pattern:
          spec:
            (type): Location
            locationSpec:
              objectStore:
                protectionPeriod: '*'
```
