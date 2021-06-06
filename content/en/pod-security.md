+++
description = "Policies to secure Kubernetes Pods."
title = "Pod Security"
type = "policies"
url = "/policies/pod-security/"
+++

<br/>

These Kyverno policies are based the on [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/) definitons. To apply all pod security policies (recommended) [install Kyverno](/docs/installation/) and [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/), then run:

```sh
kustomize build https://github.com/kyverno/policies/pod-security | kubectl apply -f -
```

{{% alert title="Note" color="info" %}}
The upstream `kustomize` should be used to apply customizations in these policies, available [here](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/). In many cases the version of `kustomize` built-in to `kubectl` will not work.
{{% /alert %}}

Pod Security Standard policies are organized in two groups, **Baseline** and **Restricted**:

<br/>

## Baseline

Minimally restrictive policies to prevent known privilege escalations.

<table style="width:100%; margin-bottom: 30px; line-height: 28px;">
    <tr>
        <th>Control</th>
        <th>Policy</th>
    </tr>
    <tr>
        <td>Host Namespaces</td>
        <td>
            <a href="/policies/pod-security/baseline/disallow-host-namespaces/disallow-host-namespaces/" target="_blank">Disallow Host Namespaces</a>
        </td>
    </tr>
    <tr>
        <td>Privileged Containers</td>
        <td>
            <a href="/policies/pod-security/baseline/disallow-privileged-containers/disallow-privileged-containers/" target="_blank">Disallow Privileged Containers</a>
        </td>
    </tr>
    <tr>
        <td>Capabilities</td>
        <td>
            <a href="/policies/pod-security/baseline/disallow-adding-capabilities/disallow-adding-capabilities/" target="_blank">Disallow Adding Capabilities</a>
        </td>
    </tr>
    <tr>
        <td>HostPath Volumes</td>
        <td>
            <a href="/policies/pod-security/baseline/disallow-host-path/disallow-host-path/" target="_blank">Disallow Host Path</a>
        </td>           
    </tr>
    <tr>
        <td>Host Ports</td>
        <td>
            <a href="/policies/pod-security/baseline/disallow-host-ports/disallow-host-ports/" target="_blank">Disallow Host Ports</a>
        </td>
    </tr>
    <tr>
        <td>AppArmor <em>(optional)</em></td>
        <td>
            <a href="/policies/pod-security/baseline/restrict-apparmor-profiles/restrict-apparmor-profiles/" target="_blank">Restrict AppArmor Profiles</a>
        </td>
    </tr>
    <tr>
        <td>SELinux <em>(optional)</em></td>
        <td>
            <a href="/policies/pod-security/baseline/disallow-selinux/disallow-selinux/" target="_blank">Disallow Custom SELinux Options</a>
        </td>    
    </tr>
    <tr>
        <td>/proc Mount Type</td>
        <td>
            <a href="/policies/pod-security/baseline/disallow-proc-mount/disallow-proc-mount/" target="_blank">Require Default Proc Mount</a>
        </td>
    </tr>
    <tr>
        <td>Sysctls</td>
        <td>
            <a href="/policies/pod-security/baseline/restrict-sysctls/restrict-sysctls/" target="_blank">Restrict Sysctls</a>
        </td>           
    </tr>
</table>

Apply the Baseline Pod Security policies using:

```sh
kustomize build https://github.com/kyverno/policies/pod-security/baseline | kubectl apply -f -
```


<br/>

## Restricted

Heavily restricted policies following current Pod hardening best practices.

<table style="width:80%; margin-bottom: 30px; line-height: 28px;">
    <tr>
        <th>Control</th>
        <th>Policy</th>
    </tr>
    <tr>
        <td>Volume Types</td>
        <td>
            <a href="/policies/pod-security/restricted/restrict-volume-types/restrict-volume-types/" target="_blank">Restrict Volume Types</a>
        </td>
    </tr>
    <tr>
        <td>Privilege Escalation</td>
        <td>
            <a href="/policies/pod-security/restricted/deny-privilege-escalation/deny-privilege-escalation/" target="_blank">Deny Privilege Escalation</a>
        </td>
    </tr>
    <tr>
        <td>Running as Non-root</td>
        <td>
            <a href="/policies/pod-security/restricted/require-run-as-nonroot/require-run-as-nonroot/" target="_blank">Require Run As Non Root</a>        
        </td>
    </tr>
    <tr>
        <td>Non-root groups <em>(optional)</em></td>
        <td>
            <a href="/policies/pod-security/restricted/require-non-root-groups/require-non-root-groups/" target="_blank">Require Non Root Groups</a>
        </td>
    </tr>
    <tr>
        <td>Seccomp</td>
        <td>
            <a href="/policies/pod-security/restricted/restrict-seccomp/restrict-seccomp/" target="_blank">Restrict Seccomp</a>
        </td>        
    </tr>
</table>

Apply the Restricted Pod Security policies (included Baseline policies) using:

```sh
kustomize build https://github.com/kyverno/policies/pod-security/restricted | kubectl apply -f -
```
