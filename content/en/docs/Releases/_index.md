---
title:  "Release"
weight: 55
description:  Kyverno Version Release Notes.
---

## Kyverno v1.4.2
**Note:** With Helm installed Kyverno, upgrading to Kyverno 1.4.2+ (Helm chart v2.0.2) from a version prior to 1.4.2 (Helm chart v2.0.2) will require extra steps. Please refer to the official doc for the upgrade.

### Changed
- Add DurationOperator to handle duration comparison operations (#2213)
- Add special variable substitution logic for preconditions (#1930)
- Support disallow pod exec operation [(#2146)]()
- Metrics re-design to deal with cardinality explosion (#2121)
- 
### Bug Fixes
- Fix removing `engineresponses` variable from Kyverno CLI, as it is not used by the policy report.[(#2252)](https://github.com/kyverno/kyverno/pull/2252)
- Fix Updating cli comment for skipping `request.object.*` variables[(#2242)](https://github.com/kyverno/kyverno/pull/2242) 
- Fix Helm Chart - Network Policy Support[(#2210)](https://github.com/kyverno/kyverno/pull/2210)
- Added backward compatibility | Resolving variables from the resource passed | CLI [(#2222)](https://github.com/kyverno/kyverno/pull/2222)
- Rule changed by adding variable substituting deep copy logic [(#2216)](https://github.com/kyverno/kyverno/pull/2216)
- Add ServiceMonitor in helm chart ([#1984)](https://github.com/kyverno/kyverno/pull/1984)
- Fix iterates the chart version so that it's built, and chart versions become incremented as part of the normal PR/merge process if chart elements are changed [(#2111)](https://github.com/kyverno/kyverno/pull/2111)
- Configurable success events on policies & resources. Generating failure events on policies by default. [(#1939)](https://github.com/kyverno/kyverno/pull/1939)

## Kyverno v1.4.1
**Note:** To upgrade from 1.4.0, you will need to manually remove the selector app: kyverno from the Deployment or delete the Deployment and then upgrade to 1.4.1.

### Changed
- 
### Bug Fixes
- Integrate LitmusChaos - Pod Memory Hog experiment [(#2014)](https://github.com/kyverno/kyverno/pull/2014)
- Fix replacing pod security standard from default to baseline [(#1977)](https://github.com/kyverno/kyverno/pull/1977)
- Fix adding loop for namespace to validate all the resources [(#2024)](https://github.com/kyverno/kyverno/pull/2024)
- Fix Helm deployment name issue [(#2045)](https://github.com/kyverno/kyverno/pull/2045)[(#2070)](https://github.com/kyverno/kyverno/pull/2070)
- Correction to ca and cert namespace [(#2048)](https://github.com/kyverno/kyverno/pull/2048)
- Fix adding: http/https regex to kyverno CLI [(#2054)](https://github.com/kyverno/kyverno/pull/2054)
- Move log to debug for wildcard pattern matching [(#2064)](https://github.com/kyverno/kyverno/pull/2064)
- adding support for policies.kyverno.io/scored annotation [(#1976)](https://github.com/kyverno/kyverno/pull/1976)
  
## Kyverno v1.4.0
**Note:** there was a selector app: kyverno added to the Deployment of the Kyverno Helm chart, it could impact the upgrade process as the selector field cannot be modified during an upgrade. This selector will be removed in 1.4.1, you can comment it out during the upgrade. Thanks to @andriktr for reporting the issue.
For HA, currently recommended minimum replicas is 3.

### Changed
- Develop and integrate Prometheus metrics-exporter for exposing Kyverno's cluster-wide metrics [(#1877)](https://github.com/kyverno/kyverno/pull/1877)
### Bug Fixes
- Fix for recommanded Kubernetes labels and custom labels [(#1873)](https://github.com/kyverno/kyverno/pull/1873)
- Fix Helm chart metrics service to allow NodePort [(#2035)](https://github.com/kyverno/kyverno/pull/2035)
- Fix enabling webhooks configuration via Helm [(#2032)](https://github.com/kyverno/kyverno/pull/2032)
- Allow metrics service annotations to be defined separate from main service [(#1988)](https://github.com/kyverno/kyverno/pull/1988)
- Fix updatingn the annotation `lastRequestTimestamp` from active instances [(#2019)](https://github.com/kyverno/kyverno/pull/2019)
- Customize `namespaceSelector` of Webhookconfigurations [(#2003)](https://github.com/kyverno/kyverno/pull/2003)
- Fix: mutate policies kept applying to these terminating Pods [(#1978)](https://github.com/kyverno/kyverno/pull/1978)
- fix slack link [(#2009)](https://github.com/kyverno/kyverno/pull/2009)
- Fix prometheus panics [(#2015)](https://github.com/kyverno/kyverno/pull/2015)
- moved label bot yaml to workflows [(#2021)](https://github.com/kyverno/kyverno/pull/2021)
- Improve log message for generate policies [(#1993)](https://github.com/kyverno/kyverno/pull/1993)
- updating minio verison [(#1956)](https://github.com/kyverno/kyverno/pull/1956)
- Add e2e test cases for generate policy flow [(#1951)](https://github.com/kyverno/kyverno/pull/1951)
- fix operator matching with spacing [(#1946)](https://github.com/kyverno/kyverno/pull/1946)
- Update e2e tests to latest kind and Kubernetes versions [(#1973)](https://github.com/kyverno/kyverno/pull/1974)

## Kyverno v1.3.6
**Notes**
### Changed
- 
### Bug Fixes
- 
- 
- 
## Kyverno v1.3.5
**Notes**
### Changed
- 
### Bug Fixes
- Fix variable substitution in `NumericOperatorHandler` [(#1721)](https://github.com/kyverno/kyverno/milestone/40?closed=1)
- fixes variable substitution in context.apiCall.jmesPath [(#1728)](https://github.com/kyverno/kyverno/pull/1728)
- 
- 
## Kyverno v1.3.4
**Notes**
### Changed
- 
### Bug Fixes
- 
- 
- 
## Kyverno v1.3.3
**Notes**
### Changed
- 
### Bug Fixes
- 
- 
- 
## Kyverno v1.3.2
**Notes**
### Changed
- 
### Bug Fixes
- 
- 
- 
## Kyverno v1.3.
**Notes**
### Changed
- 
### Bug Fixes
- 
- 
- 
## Kyverno v1.3.0
**Notes**
### Changed
- 
### Bug Fixes
- 
- 
- 
## Kyverno v1.2.1
**Notes**
### Changed
- 
### Bug Fixes
- 
- 
- 
## Kyverno v1.2.0
