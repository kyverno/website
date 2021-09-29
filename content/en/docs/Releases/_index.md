---
title: Releases 
linkTitle: "Releases"
weight: 120
description: Kyverno Release Notes.
---

## Kyverno v1.4.3
**Notes**

### Changed
### Bug Fixes
## Kyverno v1.4.2
**Note:** With Helm installed Kyverno, upgrading to Kyverno 1.4.2+ (Helm chart v2.0.2) from a version prior to 1.4.2 (Helm chart v2.0.2) will require extra steps. Please refer to the official doc for the upgrade.

### Changed
- Add DurationOperator to handle duration comparison operations [(#2213)](https://github.com/kyverno/kyverno/issues/2213)
- Add special variable substitution logic for preconditions [(#1930)](https://github.com/kyverno/kyverno/pull/1930)
- Support disallow pod exec operation [(#2146)](https://github.com/kyverno/kyverno/issues/2213)
- Metrics re-design to deal with cardinality explosion [(#2121)](https://github.com/kyverno/kyverno/issues/2121)
 
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
**Note:** there was a selector app: kyverno added to the Deployment of the Kyverno Helm chart, it could impact the upgrade process as the selector field cannot be modified during an upgrade. This selector will be removed in 1.4.1, you can comment it out during the upgrade. Thanks to [@andriktr](https://github.com/andriktr?tab=overview&from=2021-07-01&to=2021-07-31) for reporting the issue.
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
### Changed
- Added validation check for ensuring the existence of only 'any'/'all' [(#1791)](https://github.com/kyverno/kyverno/pull/1791).
- Handle configmap and api variable cli [(#1789)](https://github.com/kyverno/kyverno/pull/1789).
### Bug Fixes
- Update to use gvk to store OpenAPI schema [(#1906)](https://github.com/kyverno/kyverno/pull/1906).
- Pass by value in policy cache [(#1895)](https://github.com/kyverno/kyverno/pull/1895).
- Fix Improving tests to allow `skip` status and fail if tested results do not exist ([#1881)](https://github.com/kyverno/kyverno/pull/1881).
- Fix removing additionalProperties from policy schema [(#1891)](https://github.com/kyverno/kyverno/pull/1891).
- Updating synchronize lable in generated resource [(#1860)](https://github.com/kyverno/kyverno/pull/1860).
- Fix removing debug log [(#1857)](https://github.com/kyverno/kyverno/pull/1857).
- Fix Errors updating cluster policy [(#1863)](https://github.com/kyverno/kyverno/pull/1863).
- Fix for commented yaml files in Kyverno CLI [(#1849)](https://github.com/kyverno/kyverno/pull/1849).
- Support operators (>=, <, etc ...) on list values [(#1838)](https://github.com/kyverno/kyverno/pull/1838).
- Enable image substitution in the background mode [(#1846)](https://github.com/kyverno/kyverno/pull/1846).
- Disable auto-gen when a rule has mixed of kinds: pod & pod controllers [(#1847)](https://github.com/kyverno/kyverno/pull/1847).
- Fix mutate policy defaults and Fix endless look of auto-gen rules [(#1839)](https://github.com/kyverno/kyverno/pull/1839).
- Fix resolved the variables in the pattern which are replaced by values using source resource.[(#1804)](https://github.com/kyverno/kyverno/pull/1804).
- forceMutate does not handle StrategicMerge patchesJson6902 [(#1775)](https://github.com/kyverno/kyverno/pull/1775).
- Make `match.resources.kinds` required [(#1852)](https://github.com/kyverno/kyverno/pull/1852).
- Add `matchedList` to configure the matched resources in Kyverno [(#1732)](https://github.com/kyverno/kyverno/issues/1732).
- Validate policy in cli according to policy schema [(#1817)](https://github.com/kyverno/kyverno/pull/1817).
- test cases for match/exclude GVK [(#1851)](https://github.com/kyverno/kyverno/pull/1851).
- Support variables in patchesJson6902 [(#1774)](https://github.com/kyverno/kyverno/pull/1774).
- JMESPath custom functions [(#1772)](https://github.com/kyverno/kyverno/pull/1772).
 
## Kyverno v1.3.5
### Changed
- Helm chart should support envVars with sane default [(#1715)](https://github.com/kyverno/kyverno/pull/1715).
- (Update variable paths when auto generate the controller rules) and 1615 ( kyverno apply pipe through to kubectl) [(#1735)](https://github.com/kyverno/kyverno/pull/1735)
- Added functionality for delimiting multi-line block by newline characters [(#1597)](https://github.com/kyverno/kyverno/pull/1597).

### Bug Fixes
- Fix variable substitution in `NumericOperatorHandler` [(#1721)](https://github.com/kyverno/kyverno/milestone/40?closed=1).
- fixes variable substitution in context.apiCall.jmesPath [(#1728)](https://github.com/kyverno/kyverno/pull/1728)
- Fix Match endpoint to the exact Kyverno Pod's IP [(#1787)](https://github.com/kyverno/kyverno/pull/1787).
- Variable substitution [(#1785)](https://github.com/kyverno/kyverno/pull/1785).
- Fix array variables substitution [(#1800)](https://github.com/kyverno/kyverno/pull/1800).
- Remove namespace field on kind Namespace [(#1766)](https://github.com/kyverno/kyverno/pull/1766).
- Add e2e test for mutation [(#1761)](https://github.com/kyverno/kyverno/pull/1761).
- Add Support for policies.kyverno.io/severity annotation [(#1763)](https://github.com/kyverno/kyverno/pull/1763).
- Set default image registry and tag if not present [(#1762)](https://github.com/kyverno/kyverno/pull/1762).
- Fix Invalid variable validation [(#1770)](https://github.com/kyverno/kyverno/pull/1770).
- Fix exclude logic [(#1756)](https://github.com/kyverno/kyverno/pull/1756)
- Fix concurrent read/write when loading configmap data [(#1755)](https://github.com/kyverno/kyverno/pull/1755).
- Check webhooks are present during liveness [(#1748)](https://github.com/kyverno/kyverno/pull/1748).
- Fix removing permission [(#1758)](https://github.com/kyverno/kyverno/pull/1758)
- Register webhooks only once service endpoint is ready [(#1741)](https://github.com/kyverno/kyverno/pull/1741).
- Allow generatecontroller to handle Roles [(#1739)](https://github.com/kyverno/kyverno/pull/1739).
- fix variable substitution in `context.apiCall.jmesPath `[(#1728)](https://github.com/kyverno/kyverno/pull/1728).
- Add cleanup steps to remove webook configurations [(#118)](https://github.com/kyverno/website/pull/118).
- Fix variable substitution in `NumericOperatorHandler` [(#1721)](https://github.com/kyverno/kyverno/pull/1721).
- Skip generate requests for spec being same in old and updated policy [(#1723)](https://github.com/kyverno/kyverno/pull/1723).
- Kyverno CLI gives error on applying any policy on a resource [(#1707)](https://github.com/kyverno/kyverno/pull/1707).
- Policy without namespace selector gives error in Kyverno CLI- "pass the namespace labels" [(#1694)](https://github.com/kyverno/kyverno/pull/1694).
- Fix changed logic for In and NotIn for sets [(#1704)](https://github.com/kyverno/kyverno/pull/1704).
- Auto-recover policy report [(#1730)](https://github.com/kyverno/kyverno/pull/1730).
- Skipping schema check for unknown kinds [(#1736)](https://github.com/kyverno/kyverno/pull/1736).
- Added validate logic for generate to handle multiple items in array #1727)](https://github.com/kyverno/kyverno/pull/1727).
- Fix Adding validate logic for generate to handle multiple items in array [(#1727)](https://github.com/kyverno/kyverno/pull/1727).
- Enhancement/existence anchor - should loop all the items in the array [(#1719)](https://github.com/kyverno/kyverno/pull/1719).
- Fix to make the number of generate workers configurable [(#1729)](https://github.com/kyverno/kyverno/pull/1729).
- Fix API path [(#1678)](https://github.com/kyverno/kyverno/pull/1678).
- Added condition for slash in Kyverno CLI [(#1667)](https://github.com/kyverno/kyverno/pull/1667).
- Update Dockerfile; remove securityContext runAsUser [(#1695)](https://github.com/kyverno/kyverno/pull/1695).
- Fix validate on DELETE the oldResource [(#1710)](https://github.com/kyverno/kyverno/pull/1710).
- Fix adding `restrict-service-account` sample policy [(#30)](https://github.com/kyverno/policies/pull/30).
- Remove logic that handles reinvocation policy [(#1703)](https://github.com/kyverno/kyverno/pull/1703).
- Remove sample Dir and Remove testcases from test_runner [(#1686)](https://github.com/kyverno/kyverno/pull/1686).
- Kyverno CLI - Namespace Selector [(#1669)](https://github.com/kyverno/kyverno/pull/1669).
- Resolve path reference in entire rule [(#1714)](https://github.com/kyverno/kyverno/pull/1714).
- Fix empty list of failed rules [(#1709)](https://github.com/kyverno/kyverno/pull/1709).
- Failed to mutate policy [(#1767)](https://github.com/kyverno/kyverno/pull/1767).
- Fix hostNetwork toggle to the` dep.` and values manifests [(#1511)](https://github.com/kyverno/kyverno/pull/1511).
- Fix Namespace scope when extracting raw from the admission request [(#1718)](https://github.com/kyverno/kyverno/pull/1718).
- Add certificate renewer in webhook registration controller [(#1692)](https://github.com/kyverno/kyverno/pull/1692).
- Remove sample Dir and Remove testcases from test_runner [(#1686)](https://github.com/kyverno/kyverno/pull/1686).
- Add certificate renewer in webhook registration controller [(#1692)](https://github.com/kyverno/kyverno/pull/1692).
- Add Images info to variables context [(#1725)](https://github.com/kyverno/kyverno/pull/1725).
  
## Kyverno v1.3.4
### Changed
- Support for logical operations over conditions and selectors over `conditions` and `preconditions` [(#1604)](https://github.com/kyverno/kyverno/pull/1604).
- Supporting subset checking in set operations [(#1613)](https://github.com/kyverno/kyverno/pull/1613).
### Bug Fixes
- Fix for Null value doesn't work on negation's value[(#1665)](https://github.com/kyverno/kyverno/pull/1665).
- Fix for policy validation, auto-generated rules, apiCall support in mutate and generate [(#1629)](https://github.com/kyverno/kyverno/pull/1629).
- Fix for `namespaceSelector` in match prevents background scanning [(#1644)](https://github.com/kyverno/kyverno/pull/1644).
- Generate policy fails if trigger resource name exceed 58 characters [(#1631)](https://github.com/kyverno/kyverno/pull/1631).
- Fix Substituting variables in context.configMap [(#1636)](https://github.com/kyverno/kyverno/pull/1636).
- Fix adding make target to auto generate code [(#1603)](https://github.com/kyverno/kyverno/pull/1603).
- fix - policy validation, auto-generated rules, apiCall support in mutate and generate [(#1629)](https://github.com/kyverno/kyverno/pull/1629).
- fix listing operators in deny conditions [(#1641)](https://github.com/kyverno/kyverno/pull/1641).
- Switch to use annotations to store resource info in `cluster/reportChangeRequest` [(#1625)](https://github.com/kyverno/kyverno/pull/1625).
- Fix policy validation, auto-generated rules, apiCall support in mutate and generate [(#1629)](https://github.com/kyverno/kyverno/pull/1629).
- fix adding details regarding `match.resources` [(#1654)](https://github.com/kyverno/kyverno/pull/1654).
- Support `AllowMissingPathOnRemove` and `EnsurePathExistsOnAdd` in patchesJSON6902 [(#1645)](https://github.com/kyverno/kyverno/pull/1645).
- Fix Extends match / exclude to use apiGroup and apiVersion [(#1656)](https://github.com/kyverno/kyverno/pull/1656).
## Kyverno v1.3.3
### Bug Fixes
- fix gofmt check over the existing github workflows [(#1553)](https://github.com/kyverno/kyverno/pull/1553).
- Getting invalid memory address error while using kyverno with `--set` [(#1609)](https://github.com/kyverno/kyverno/pull/1609).
- Panic Fix [(#1601)](https://github.com/kyverno/kyverno/pull/1601).
- fix restricting empty value from passing through the validation checks [(#1574)](https://github.com/kyverno/kyverno/pull/1574).
  
## Kyverno v1.3.2
### Changed
- Validation of 'value' field under 'deny.conditions' in the rule object [(#1510)](https://github.com/kyverno/kyverno/pull/1510).
- Support for numeric operators [(#1536)](https://github.com/kyverno/kyverno/pull/1536).
- Fix dev mode execution [(#1477)](https://github.com/kyverno/kyverno/pull/1477).
- 
### Bug Fixes
- Panic fix in generation.go [(#1563)](https://github.com/kyverno/kyverno/pull/1563).
- Fix performed cleanups [(#1552)](https://github.com/kyverno/kyverno/pull/1552).
- Fix allowing `watch` from policy controller - cluster role `kyverno:policycontroller` [(#1562)](https://github.com/kyverno/kyverno/pull/1562).
- Fix adding `AND` logical operator support [(#1539)](https://github.com/kyverno/kyverno/pull/1539). 
- Fix test command for kyverno [(#1518)](https://github.com/kyverno/kyverno/pull/1518).
- Compare policy status before sending update request [(#1523)](https://github.com/kyverno/kyverno/pull/1523).
- Upgrade client libraries to [(0.20.2 #1547)](https://github.com/kyverno/kyverno/pull/1547).
- Reduce RCR Throttling [(#1545)](https://github.com/kyverno/kyverno/pull/1545).
- Reduce throttling requests (GET) [(#1522)](https://github.com/kyverno/kyverno/pull/1522)
- Fix handling discovery errors for metrics API group [(#1494)](https://github.com/kyverno/kyverno/pull/1494).
- Fix namespace selector [(#1532)](https://github.com/kyverno/kyverno/pull/1532).
- Upgrade client libraries to 0.20.2 [(#1547)](https://github.com/kyverno/kyverno/pull/1547).
- Update Kyverno test command [(#1608)](https://github.com/kyverno/kyverno/pull/1608).
- Adding cluster policies(default, restricted) to kyverno helm charts [(#1493)](https://github.com/kyverno/kyverno/pull/1493).
- Fix modifications in generated resource are not overridden till the next sync [(#1426)](https://github.com/kyverno/kyverno/issues/1426).
- Adding HTTP(git raw or any public url ) URL applying functionality to kyverno cli [(#1527)](https://github.com/kyverno/kyverno/pull/1527).
- Enhancing dockerfiles (multi-stage) of kyverno components and adding non-root user to the docker images [(#1495)](https://github.com/kyverno/kyverno/pull/1495).
- Fix api server lookups [(#1514)](https://github.com/kyverno/kyverno/pull/1514).
- Valid resource is blocked by namespace selector [(#1558)](https://github.com/kyverno/kyverno/pull/1558)
  
## Kyverno v1.3.1 
### Bug Fixes
- Fix support nested JMESPATH var substitution [(#1471)](https://github.com/kyverno/kyverno/pull/1471).
- Remove unnecessary JSON patches; fixes strategicMergePatch for tolerations [(#1478)](https://github.com/kyverno/kyverno/pull/1478).
  
## Kyverno v1.3.0
### Bug Fixes
- Fix handle anchors for wildcard annotations [(#1458)](https://github.com/kyverno/kyverno/pull/1458).
- Fix mutation panic [(#1462)](https://github.com/kyverno/kyverno/pull/1462).
- Improve / clean up code [(#1444)](https://github.com/kyverno/kyverno/pull/1444).
- Fix memory leak - remove item from the cache once done (audit handler) [(#1459)](https://github.com/kyverno/kyverno/pull/1459).
- Fix cleanup/generate_logs [(#1439)](https://github.com/kyverno/kyverno/pull/1439).
- Fix memory leak in CRD sync controller [(#1441)](https://github.com/kyverno/kyverno/pull/1441).
- Rename filterK8Resources to filterK8sResources [(#1452)](https://github.com/kyverno/kyverno/pull/1452).
- Skip validation patterns for delete requests [(#1428)](https://github.com/kyverno/kyverno/pull/1428).
- Bug/generate refactoring [(#1440)](https://github.com/kyverno/kyverno/pull/1440).
- Fix invalid failure event for generate policy [(#1413)](https://github.com/kyverno/kyverno/pull/1413).
- Fixes strategic merge patch [(#1414)](https://github.com/kyverno/kyverno/pull/1414).
- Reduce RCR throttling requests [(#1406)](https://github.com/kyverno/kyverno/pull/1406).
- Fix to increase default memory limit to 256 Mi [(#1402)](https://github.com/kyverno/kyverno/pull/1402)
- Generate with multiple rules [(#1400)](https://github.com/kyverno/kyverno/pull/1400).
- Reduce RCR throttling requests [(#1406)](https://github.com/kyverno/kyverno/pull/1406).
- Allow generate with no data/status [(#1391)](https://github.com/kyverno/kyverno/pull/1391).
- Added pipe for passing policy in apply [(#1382)](https://github.com/kyverno/kyverno/pull/1382).
- Filter resources excluded in config [(#1404)](https://github.com/kyverno/kyverno/pull/1404).
- Enqueing gr on getting deleted [(#1405)](https://github.com/kyverno/kyverno/pull/1405).
- Disable updates of generated resource when synchronize is set to false [(#1379)](https://github.com/kyverno/kyverno/pull/1379).
- Clean up stale RCRs [(#1373)](https://github.com/kyverno/kyverno/pull/1373).
- Fix webhook registration [(#1369)](https://github.com/kyverno/kyverno/pull/1369).
- Ignore non-policy files in CLI and improve validation messages [(#1362)](https://github.com/kyverno/kyverno/pull/1362).
- Fix pkg/webhooks/server.go [(#1372)](https://github.com/kyverno/kyverno/pull/1372).
- Fix policy report [(#1359)](https://github.com/kyverno/kyverno/pull/1359).
- Use GR lister [(#1387)](https://github.com/kyverno/kyverno/pull/1387).
- Clarify policy application behavior on pods that are managed by workload controllers [(#1380)](https://github.com/kyverno/kyverno/pull/1380).
- Change validation to match on both new and old resources.  [(#1417)](https://github.com/kyverno/kyverno/pull/1417).
- Fix wildcard keys in patterns [(#1361)](https://github.com/kyverno/kyverno/pull/1361)
- Fix to validate condition operators [(#1331)](https://github.com/kyverno/kyverno/pull/1331).
- Fix panic when building ConfigMap cache [(#1342)](https://github.com/kyverno/kyverno/pull/1342).
- Fix removing generate error message [(#1364)](https://github.com/kyverno/kyverno/pull/1364).
- Fix throttling [(#1341)](https://github.com/kyverno/kyverno/pull/1341).
- Fix validate rule [(#1368)](https://github.com/kyverno/kyverno/pull/1368).
- Add nil checks and refactor schema lookups [(#1309)](https://github.com/kyverno/kyverno/pull/1309).
- fix adding annotations check in validation [(#1305)](https://github.com/kyverno/kyverno/pull/1305).
- Fix variable validation [(#1303)](https://github.com/kyverno/kyverno/pull/1303).
- Fix updating webhook registration and monitor [(#1318)](https://github.com/kyverno/kyverno/pull/1318).
- Fix triggring generate rule [(#1355)](https://github.com/kyverno/kyverno/pull/1355)
- Match/exclude ns resource name [(#1375)](https://github.com/kyverno/kyverno/pull/1375).
- Failed to update annotation through mutate policy [(#1289)](https://github.com/kyverno/kyverno/pull/1289).
- Policy report cli testcases [(#1412)](https://github.com/kyverno/kyverno/pull/1412).
- Add logging for policy creation and deletion events [(#1445)](https://github.com/kyverno/kyverno/pull/1445).
- Failed to update annotation through mutate policy [(#1289)](https://github.com/kyverno/kyverno/pull/1289).
- Fix generate panic [(#1252)](https://github.com/kyverno/kyverno/pull/1252).
- Failed to generate `reportChangeRequest` due to exceeding the label size limit [(#1275)](https://github.com/kyverno/kyverno/pull/1275).
- Fix to allow text after patch versions [(#1230)](https://github.com/kyverno/kyverno/pull/1230).
- Improve logging message [(#1232)](https://github.com/kyverno/kyverno/pull/1232).
- Print validationFailureAction with kubectl get [(#1233)](https://github.com/kyverno/kyverno/pull/1233).
- Manage Kyverno CRDs by controller-gen [(#1245)](https://github.com/kyverno/kyverno/pull/1245).
- Add Policy Report [(#1229)](https://github.com/kyverno/kyverno/pull/1229).
- Helm namespace value [(#1210)](https://github.com/kyverno/kyverno/pull/1210).
- Fix added log level for skipped policy [(#1316)](https://github.com/kyverno/kyverno/pull/1316).
- Improve github action [(#1385)](https://github.com/kyverno/kyverno/pull/1385).
- Policyreport cli [(#1235)](https://github.com/kyverno/kyverno/pull/1235).
- Add Policy Report [(#1229)](https://github.com/kyverno/kyverno/pull/1229).
- added validation for openapi_v3 [(#1095)](https://github.com/kyverno/kyverno/pull/1095).

## Kyverno v1.2.1
### Bug Fixes
- Fix mutation failure should not block resource creation [(#633)](https://github.com/kyverno/kyverno/pull/633).
- Create Website for kyverno [(#1250)](https://github.com/kyverno/kyverno/pull/1250)[(#1196)](remove docs and update README.md).
- Fix documentation for helm [(#1187)](https://github.com/kyverno/kyverno/pull/1187).
- Update CONTRIBUTING.md [(#1203)](https://github.com/kyverno/kyverno/pull/1203).
- Add link to quick start [(#1204)](https://github.com/kyverno/kyverno/pull/1204).
- Add security context [(#1208)](https://github.com/kyverno/kyverno/pull/1208).
- Cleanup cli output [(#1180)](https://github.com/kyverno/kyverno/pull/1180).
- Publish test image [(#1179)](https://github.com/kyverno/kyverno/pull/1179).
- Fix regex for allowed variable to support spaces [(#1200)](https://github.com/kyverno/kyverno/pull/1200)
- Remove docs and update README.md [(#1196)](https://github.com/kyverno/kyverno/pull/1196).
- Fixed panic while applying policy on cluster [(#1195)](https://github.com/kyverno/kyverno/pull/1195).

## Kyverno v1.2.0 
### Changed 
- Feature/configmaps var 724 [(#1118)](https://github.com/kyverno/kyverno/pull/1118).
- Read from stdin validate [(#1171)](https://github.com/kyverno/kyverno/pull/1171)
- Configmaps var 724 [(#1118)](https://github.com/kyverno/kyverno/pull/1118)
### Bug Fixes
- Use Self-signed certificate to build TLS webhook server [(#1176)](https://github.com/kyverno/kyverno/pull/1176).
- Fixed yaml package for CLI validate [(#1151)](https://github.com/kyverno/kyverno/pull/1151).
- Fixed adding conversion of overlay to patch strategic merge [(#1138)](https://github.com/kyverno/kyverno/pull/1138).
- Parse string value to array from configMap [(#1143)](https://github.com/kyverno/kyverno/pull/1143).
- Fixed yaml package for CLI validate [(#1151)](https://github.com/kyverno/kyverno/pull/1151).
- Migrate github.com/nirmata/kyverno to github.com/kyverno/kyverno [(#1175)](https://github.com/kyverno/kyverno/pull/1175).
- Use Self-signed certificate to build TLS webhook server [(#1176)](https://github.com/kyverno/kyverno/pull/1176).
- Update best practice require-pod-probes [(#1178)](https://github.com/kyverno/kyverno/pull/1178).
- Add links in chronological order (latest first) [(#1148)](https://github.com/kyverno/kyverno/pull/1148).
- Added condition for exclude selector [(#1169)](https://github.com/kyverno/kyverno/pull/1169).
- Added conversion of overlay to patch strategic merge [(#1138)](https://github.com/kyverno/kyverno/pull/1138).
- Remove mutation message when no rules are applied [(#1162)](https://github.com/kyverno/kyverno/pull/1162).
- Update installation guides [(#1167)](https://github.com/kyverno/kyverno/pull/1167)

## Kyverno v1.1.12 
### Bug Fixes
- Bugfix policymutation [(#1119)](https://github.com/kyverno/kyverno/pull/1119).
- Fixed CLI bug - mutate resource and variable substitution [(#1123)](https://github.com/kyverno/kyverno/pull/1123)
- Generate policy with backword compatibility [(#1125)](https://github.com/kyverno/kyverno/pull/1125).
- Fixed duplicate name [(#1109)](https://github.com/kyverno/kyverno/pull/1109).
- Fix converting patches to patchesJSON6902 [(#1115)](https://github.com/kyverno/kyverno/pull/1115).
- Fixed additional anchor bug in patch strategic merge [(#1114)](https://github.com/kyverno/kyverno/pull/1114).
- Fixed policy validation and patch strategic merge bug [(#1136)](https://github.com/kyverno/kyverno/pull/1136).
- Skip policy mutation on status update [(#1112)](https://github.com/kyverno/kyverno/pull/1112).
- Update operator doc [(#1131)](https://github.com/kyverno/kyverno/pull/1131).
- Generate policy with backword compatibility [(#1125)](https://github.com/kyverno/kyverno/pull/1125).
- Bugfix policymutation [(#1119)](https://github.com/kyverno/kyverno/pull/1119).

## Kyverno v1.1.11 
  
### Bug Fixes
- Fixed return [(#1102)](https://github.com/kyverno/kyverno/pull/1102)
- Reconcile Generate request on policy update [(#1096)](https://github.com/kyverno/kyverno/pull/1096).
- Generate policy does not work on namespace update [(#1085)](https://github.com/kyverno/kyverno/pull/1085).
- Added autogen for patch strategic merge [(#1104)](https://github.com/kyverno/kyverno/pull/1104).
- Fix conditional anchor preprocessing for patch strategic merge [(#1090)](https://github.com/kyverno/kyverno/pull/1090).
- Set mutating webhhok reinvocationPolicy to IfNeeded [(#1097)](https://github.com/kyverno/kyverno/pull/1097).
- Fix support cronJob for auto-gen [(#1089)](https://github.com/kyverno/kyverno/pull/1089).
- Supporting CRD validation in CLI [(#1080)](https://github.com/kyverno/kyverno/pull/1080).
- Added invalid field validation for policy [(#1094)]
- 810 support cronJob for auto-gen [(#1089)](https://github.com/kyverno/kyverno/pull/1089).
- Allowing only few variables in the policies [(#1063)](https://github.com/kyverno/kyverno/pull/1063).
- Events take several minutes to show on the resource [(#1083)](https://github.com/kyverno/kyverno/pull/1083).
- Generate policy does not work on namespace update [(#1085)](https://github.com/kyverno/kyverno/pull/1085).
- Added `set` and `values_file` flag in kyverno CLI to pass variable values. [(#1030)](https://github.com/kyverno/kyverno/pull/1030).
- Added validation for openapi_v3 [(#1095)](https://github.com/kyverno/kyverno/pull/1095).
- Replace Policy CRD AnyValue fields with empty dict [(#1086)](https://github.com/kyverno/kyverno/pull/1086).
- Set mutating webhhok reinvocationPolicy to IfNeeded [(#1097)](https://github.com/kyverno/kyverno/pull/1097).
- Add watch permission of namespace policy to clusterrole kyverno:customresources [(#1084)](https://github.com/kyverno/kyverno/pull/1084).
- Added autogen for patch strategic merge [(#1104)](https://github.com/kyverno/kyverno/pull/1104)
- Fix rResolved conditional anchor issue and added validation to pattern labels [(#1060)](https://github.com/kyverno/kyverno/pull/1060).
  
## Kyverno v1.1.10 
### Bug Fixes
- Kyverno-cli and helm release step added in workslow [(#1043)](https://github.com/kyverno/kyverno/pull/1043).
- Update mutation jsonPatch doc [(#1049)](https://github.com/kyverno/kyverno/pull/1049).
- Git action added in goreleaser [(#1078)](https://github.com/kyverno/kyverno/pull/1078).
- Not checking for cluster resources for CLI in policy validate [(#1076)](https://github.com/kyverno/kyverno/pull/1076).
- Return early in CLI if generated patches from policy mutation is nil [(#1072)](https://github.com/kyverno/kyverno/pull/1072).
- FilterK8Resources is not correctly configured using ConfigMap [(#1059)](https://github.com/kyverno/kyverno/pull/1059).
- Default exclude group role added [(#1052)](https://github.com/kyverno/kyverno/pull/1052).
- Replace CRD AnyValue fields with empty dict [(#1047)](https://github.com/kyverno/kyverno/pull/1047).
- Fix cli docker images added [(#1073)](https://github.com/kyverno/kyverno/pull/1073)
- Fix to automate release [(#1044)](https://github.com/kyverno/kyverno/pull/1044).
- Update the doc on how excluded userInfo flags [(#1035)](https://github.com/kyverno/kyverno/pull/1035).
- Fix improves the mutation webhook logic.[(#1057)](https://github.com/kyverno/kyverno/pull/1057).
- Supporting annotations in match/exclude [(#1045)](https://github.com/kyverno/kyverno/pull/1045).
- Setting validationFailureAction to enforce is going to enforce it for every Policy [(#601)](https://github.com/kyverno/kyverno/pull/601).
- Added helm chart icon [(#1077)](https://github.com/kyverno/kyverno/pull/1077).
- Fix adds validateFailureAction to all [(policies #1068)](https://github.com/kyverno/kyverno/pull/1068).
- Supporting annotations in match/exclude [(#1045)](https://github.com/kyverno/kyverno/pull/1045).
## Kyverno v1.1.9 
### Changes 
- Feature/api version 852 [(#1028)](https://github.com/kyverno/kyverno/pull/1028)
- Feature/e2e 575 [(#1018)](https://github.com/kyverno/kyverno/pull/1018)
- Feature/print mutated policy [(#1014)](https://github.com/kyverno/kyverno/pull/1014).
### Bug Fixes
- added api docs generator and docs html file [(#1009)](https://github.com/kyverno/kyverno/pull/1009).
- Configrable rules added [(#1017)](https://github.com/kyverno/kyverno/pull/1017).
- Default exclude group role added [(#1052)](https://github.com/kyverno/kyverno/pull/1052).
- `filterK8Resources` is not correctly configured using ConfigMap [(#1059)](https://github.com/kyverno/kyverno/pull/1059).
- Not checking for cluster resources for CLI in policy validate [(#1076)](https://github.com/kyverno/kyverno/pull/1076).
- Fix replaces CRD AnyValue fields with empty dict [(#1047)](https://github.com/kyverno/kyverno/pull/1047).
- cli docker images added [(#1073)](https://github.com/kyverno/kyverno/pull/1073)
- Fix automating release [(#1044)](https://github.com/kyverno/kyverno/pull/1044)
- Fix Updated the doc on how excluded userInfo flags [(#1035)](https://github.com/kyverno/kyverno/pull/1035).
- Improvements in webhook [(#1057)](https://github.com/kyverno/kyverno/pull/1057).
- Supporting annotations in match/exclude [(#1045)](https://github.com/kyverno/kyverno/pull/1045).
- Fix updates mutation jsonPatch doc [(#1049)](https://github.com/kyverno/kyverno/pull/1049).
- Fix mutation patch bytes [(#563)](https://github.com/kyverno/kyverno/pull/563).
- Setting validationFailureAction to enforce is going to enforce it for every Policy [(#601)](https://github.com/kyverno/kyverno/pull/601).
- Feature/namespaced policy 280 [(#1058)](https://github.com/kyverno/kyverno/pull/1058).
- Generate request is not cleaned up after delete the generate policy [(#1036)](https://github.com/kyverno/kyverno/pull/1036).
## Kyverno v1.1.8 
### Bug Fixes
- Fix removed mutated policy [(#1010)](https://github.com/kyverno/kyverno/pull/1010).
- krew yaml fixes [(#1000)](https://github.com/kyverno/kyverno/pull/1000).
- Update selecting resource doc [(#1005)](https://github.com/kyverno/kyverno/pull/1005).
- Fixed deployment name in config [(#1004)](https://github.com/kyverno/kyverno/pull/1004).
- Policy name added in labels [(#1001)](https://github.com/kyverno/kyverno/pull/1001).
- Feature/CLI saving mutate results [(#1007)](https://github.com/kyverno/kyverno/pull/1007).
- Events fix [(#1006)](https://github.com/kyverno/kyverno/releases?after=v1.2.0).
- Fix added api docs generator and docs html file [(#1009)](https://github.com/kyverno/kyverno/pull/1009).


## Kyverno v1.1.7 
### Changes
- Feature/new operators [(#947)](https://github.com/kyverno/kyverno/pull/947).
- Added goreleaser for manging lifecycle of kyverno plugin [(#851)](https://github.com/kyverno/kyverno/pull/851).
### Bug Fixes
- Fix delete synchronized resources [(#997)](https://github.com/kyverno/kyverno/pull/997).
- Print mutated policy as yaml [(#995)](https://github.com/kyverno/kyverno/pull/995).
- Fix added Synchronize flag in Generate Request [(#980)](https://github.com/kyverno/kyverno/pull/980).
- Generate Policy from data is not behaving as expected [(#977)](https://github.com/kyverno/kyverno/pull/977).
- Resolve Kyverno panic when sync the generate request [(#975)](https://github.com/kyverno/kyverno/pull/975).
- Add policy cache based on policyType [(#960)](https://github.com/kyverno/kyverno/pull/960).
- Skip inserting auto-gen annotation into podController on UPDATE admission request [(#953)](https://github.com/kyverno/kyverno/pull/953).
- Update logging, naming, and event retry [(#959)](https://github.com/kyverno/kyverno/pull/959).
- Fix temp patch in client-go [(#950)](https://github.com/kyverno/kyverno/pull/950).
- Avoid generating violation on pre-exist pod [(#952)](https://github.com/kyverno/kyverno/pull/952).
- Update docs for add capabilities [(#957)](https://github.com/kyverno/kyverno/pull/957).
- Fix reading kyverno svc from environment variable [(#962)](https://github.com/kyverno/kyverno/pull/962).
- kyverno CLI accessable through krew [(#941)](https://github.com/kyverno/kyverno/pull/941).
- Synchronize data for generated resources [(#933)](https://github.com/kyverno/kyverno/pull/933).
## Kyverno v1.1.6 
### Changes
- Added goreleaser for manging lifecycle of kyverno plugin [(#851)](https://github.com/kyverno/kyverno/pull/851).
- Add checks for k8s version when Kyverno starts [(#831)](https://github.com/kyverno/kyverno/pull/831)
- Change annotation for auto-generate pod controllers policy [(#849)](https://github.com/kyverno/kyverno/pull/849)
### Bug Fixes
- fix resource schema not found error & fix violation updates when there's no change[(#895)](https://github.com/kyverno/kyverno/pull/895)
- Note added for kubernetes version in README [(#889)](https://github.com/kyverno/kyverno/pull/889).
- Handling Multi YAML (Policies and Resources) [(#890)](https://github.com/kyverno/kyverno/pull/890).
- helm release workflow added [(#881)](https://github.com/kyverno/kyverno/pull/881)
- auto-gen annotation is not inserted connrectly [(#870)](https://github.com/kyverno/kyverno/issues/869).
- Added cpu & memory resource requests and limits [(#868)](https://github.com/kyverno/kyverno/pull/868).
- Added readiness and liveness prob [(#874)](https://github.com/kyverno/kyverno/pull/874)
- Bug [(#844)](https://github.com/kyverno/kyverno/pull/844).
- helm docs added for helm repository [(#901)](https://github.com/kyverno/kyverno/pull/901)
- Fix parse CRD error: added CRD 1.16+ spec [(#854)](https://github.com/kyverno/kyverno/pull/854).
- skip adding crd if no schema is defined [(#862)](https://github.com/kyverno/kyverno/pull/862).
- Add Helm chart for Kyverno - [(#839)](https://github.com/kyverno/kyverno/pull/839).
- Annotation inserted to podTemplate by auto-gen should reflect the policy name [(#850)](https://github.com/kyverno/kyverno/pull/850).
- Fix duplicate pv create on both pod and pod-controller [(#853)](https://github.com/kyverno/kyverno/pull/853).
- Policy status is not being updated [(#809)](https://github.com/kyverno/kyverno/pull/809).
- Set kind in generate [(#846)](https://github.com/kyverno/kyverno/pull/846)
- remove cpu limit in BP require_pod_requests_limits.yaml [(#807)](https://github.com/kyverno/kyverno/pull/807)
- Fix removed unnecessary comments and reduce cache resync intervals[(#855)](https://github.com/kyverno/kyverno/pull/855)
- CRD sync panics on kubernetes versions 1.16 and below [(#785)](https://github.com/kyverno/kyverno/pull/785)
- Removing unneeded annotations [(#803)](https://github.com/kyverno/kyverno/pull/803)
- Validate conflicting match and exclude [(#758)](https://github.com/kyverno/kyverno/pull/758)
- golangci-lint changes [(#761)](https://github.com/kyverno/kyverno/pull/761)
- Validate conflicting match and exclude [(#758)](https://github.com/kyverno/kyverno/pull/758)
- Fixed policy violation updated without owner [(#880)](https://github.com/kyverno/kyverno/pull/880)
- update CLI executable name [(#910)](https://github.com/kyverno/kyverno/pull/910)
- Fix makes helm text consistent [(#916)](https://github.com/kyverno/kyverno/pull/916)
- Update helm chart docs [(#913)](https://github.com/kyverno/kyverno/pull/913).
## Kyverno v1.1.5 
### Bug Fixes
- kyverno CLI [(#737)](https://github.com/kyverno/kyverno/pull/737) 
- Fix error message for spec.background [(#661)](https://github.com/kyverno/kyverno/pull/661)
- Policy Mutation Validation [(#736)](https://github.com/kyverno/kyverno/pull/736)
- golangci-lint changes [(#761)](https://github.com/kyverno/kyverno/pull/761).
- Fix Access check & logging framework refactor & update code-gen version [(#750)](https://github.com/kyverno/kyverno/pull/750).
- Validate policy schema [(#764)](https://github.com/kyverno/kyverno/pull/764)
- Adding log level in "loading variable " [(#648)](https://github.com/kyverno/kyverno/pull/648)
- anyPattern error improvements [(#738)](https://github.com/kyverno/kyverno/pull/738)
- 1.1.5 doc updates [(#756)](https://github.com/kyverno/kyverno/pull/756).
- Resource field should be optional for exclude [(#757)](https://github.com/kyverno/kyverno/pull/757).
- Update clusterrole kyverno:webhook to approve csr for 1.18 cluster [(#782)](https://github.com/kyverno/kyverno/pull/782).
- CRD sync panics on kubernetes versions 1.16 and below [(#785)](https://github.com/kyverno/kyverno/pull/785).
- Fixed crd sync panic [(#784)](https://github.com/kyverno/kyverno/pull/784).


## Kyverno v1.1.4 
### Bug Fixes
- Add rules to disallow default namespace for pod controllers. [(#735)](https://github.com/kyverno/kyverno/pull/735).
- Support nested variable resolution [(#728)](https://github.com/kyverno/kyverno/pull/728).
- refactor events [(#713)](https://github.com/kyverno/kyverno/pull/713).
- if match/resource/kinds is empty, then policy can only deal with metadata of a resource [(#726)](https://github.com/kyverno/kyverno/pull/726).
## Kyverno v1.1.3 
### Bug Fixes
- Fix added `runValidationInMutatingWebhook` flag - v3 [(#654)](https://github.com/kyverno/kyverno/pull/654)
- Add doc on how to write policy to generate rule for pod controllers. [(#665)](https://github.com/kyverno/kyverno/pull/665).
- Fis added type in openapi schema [(#629)](https://github.com/kyverno/kyverno/pull/629).
- Cannot match or exclude clusterroles - remaining fixes [(#707)](https://github.com/kyverno/kyverno/pull/707).
- Policy Rule Exclude conditions should be processed as a logical AND instead of a logical OR [(#662)](https://github.com/kyverno/kyverno/pull/662).
- Fix updated docs [(#675)](https://github.com/kyverno/kyverno/pull/675).

## Kyverno v1.1.2 
### Bug Fixes
- Mutation failure should not block resource creation [(#633)](https://github.com/kyverno/kyverno/pull/633)
- Default failurepolicy & bug fix [(#632)](https://github.com/kyverno/kyverno/pull/632)
- Fix added missing var for PACKAGE [(#623)](https://github.com/kyverno/kyverno/pull/623).
- Support nested variable resolution [(#728)](https://github.com/kyverno/kyverno/pull/728)

## Kyverno v1.1.1 
### Changes
- Feature [(#594)](https://github.com/kyverno/kyverno/pull/594).
- Setting validationFailureAction to enforce is going to enforce it for every Policy [(#601)](https://github.com/kyverno/kyverno/pull/601).

### Bug Fixes
- Fix annotation path error if applied to pod controller [(#625)](https://github.com/kyverno/kyverno/pull/625).
- Fix added annotation to ns-creator sample policy [(#621)](https://github.com/kyverno/kyverno/pull/621).
- Pass in original resource to validation if patches from mutation is nil [(#618)](https://github.com/kyverno/kyverno/pull/618).
- Check for multiple variables in a expression & serviceAccount variables [(#610)](https://github.com/kyverno/kyverno/pull/610).
- 
## Kyverno v1.1.0 
### Changes 
- Feature [(#503)](https://github.com/kyverno/kyverno/pull/503)
### Bug Fixes
- Fix the bugs and add pre-condition checks [(#606)](https://github.com/kyverno/kyverno/pull/606).
- Fetch annotation from resource annotation map [(#602)](https://github.com/kyverno/kyverno/pull/602).
-  Fixed pod controller [(#573)](https://github.com/kyverno/kyverno/pull/573).
- Handle processing of policies in background [(#569)](https://github.com/kyverno/kyverno/pull/569).
- Support variable substitution [(#549)](https://github.com/kyverno/kyverno/pull/549).
- Fixed crd permission [(#553)](https://github.com/kyverno/kyverno/pull/553).
- Fix rename `namespacedpolicyviolation` to `policyviolation` [(#547)](https://github.com/kyverno/kyverno/pull/547).
- Refactor Policy violation owner logic [(#534)](https://github.com/kyverno/kyverno/pull/534)
- Fix removed newline from engine response strings [(#537)](https://github.com/kyverno/kyverno/pull/537).
- Policy validation userinfo [(#540)](https://github.com/kyverno/kyverno/pull/540).
- policy violation name format update [(#502)](https://github.com/kyverno/kyverno/pull/502).
- init container [(#501)](https://github.com/kyverno/kyverno/pull/501).
- Fix implemented quantity comparison [(#558)](https://github.com/kyverno/kyverno/pull/558).
- Handle json numbers resubmit [(#427)](https://github.com/kyverno/kyverno/pull/427).
- Fix test webhook [(#525)](https://github.com/kyverno/kyverno/pull/525).
- Fix Added best practice policies [(#366)](https://github.com/kyverno/kyverno/pull/366)
- Fix updated engineResponse Name [(#369)](https://github.com/kyverno/kyverno/pull/369)
- Added anchors for omitempty tag [(#584)](https://github.com/kyverno/kyverno/pull/584).
  
## Kyverno v1.0.0 
**NOTE:** It is recommended to deploy the stable release v1.1.1.
### Bug Fixes
- fix mutation patches [(#532)](https://github.com/kyverno/kyverno/pull/532)
- Explicitly set resource version of policy violation when update [(#517)](https://github.com/kyverno/kyverno/pull/517).


<!--   
## Kyverno v0.10.0 
### Bug Fixes
- 


## Kyverno v0.9.0 
### Changes
- 
### Bug Fixes
- 

## Kyverno v0.8.0 
**NOTE:** 
If Kyverno is installed before this release, it is recommended to update CRD [manifest](https://github.com/nirmata/kyverno/blob/v0.8.0/definitions/install.yaml) as policyViolation is now a separate CRD, or to re-install Kyverno using [install.yaml](https://github.com/nirmata/kyverno/blob/v0.8.0/definitions/install.yaml).
### Bug Fixes
-  -->