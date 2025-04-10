+++
title = "Kyverno"
linkTitle = "Kyverno"
+++

{{< blocks/cover title="Kyverno" image_anchor="top" height="full" color="dark" >}}

# Policy as Code, Simplified! { class="text-center" }

<div class="mt-5 mx-auto">
	<a class="btn btn-lg btn-primary mr-3 mb-4" href="#about-kyverno">
		Learn More <i class="fa fa-chalkboard-teacher ml-2"></i>
	</a>
	&nbsp;
	<a class="btn btn-lg btn-secondary mr-3 mb-4" href="docs/introduction/#quick-start-guides">
		Get Started <i class="fa fa-arrow-alt-circle-right ml-2 "></i>
	</a>
	<a class="btn btn-link text-info" href="#about-kyverno" aria-label="Read more">
		<i class="fa fa-chevron-circle-down" style="font-size: 400%"></i>
	</a>
</div>
{{< /blocks/cover >}}

{{% blocks/lead color="light" %}}
<br/>

# About Kyverno { class="text-center" }

<br/>
<br/>

<h2>
The Kyverno project provides a comprehensive set of tools to manage the complete Policy-as-Code (PaC) lifecycle for Kubernetes and other cloud native environments
</h2>
<br/>

<p style="line-height:1.5">

Kyverno policies are declarative YAML resources and <b>no new language</b> is required. Kyverno enables use of familiar tools such as <code style="font-size: 1.35rem">kubectl</code>, <code style="font-size: 1.35rem">git</code>, and <code style="font-size: 1.35rem">kustomize</code> to manage policies. Kyverno supports JMESPath and the Common Expressions Language (CEL) for efficient handling of complex logic.

In Kubernetes environments, Kyverno policies can <b>validate, mutate, generate, and cleanup</b> any Kubernetes resource, including custom resources. To help secure the software supply chain Kyverno policies can <b>verify OCI container image signatures and artifacts</b>. Kyverno policy reports and policy exceptions are also Kubernetes API resources.

The **Kyverno CLI** can be used to apply and test policies off-cluster e.g., as part of an IaC and CI/CD pipelines.

**Kyverno Policy Reporter** provides report management with a graphical web-based user interface.

**Kyverno JSON** allows applying Kyverno policies in non-Kubernetes environments and on any JSON payload.

**Kyverno Chainsaw** provides declarative end-to-end testing for policies.

</p>

<div class="mt-5 mx-auto">
	<a class="btn btn-lg btn-primary mr-3 mb-4" href="docs/introduction/">
		Documentation <i class="fa fa-book ml-2"></i>
	</a>
	&nbsp;
	<a class="btn btn-lg btn-secondary mr-3 mb-4" href="/policies/">
		Sample Policies <i class="fa fa-shield-alt ml-2 "></i>
  	</a>	
</div>

{{% /blocks/lead %}}

{{% blocks/lead color="gray" %}}

<br/>

# Join our community { class="text-center" }

<br/>

### Interested in learning and contributing?

<p class="mt-5 mx-auto">
	Sign up on our <a href="https://groups.google.com/g/kyverno" target="_blank">mailing list</a> 
	or the <a href="https://slack.k8s.io/#kyverno" target="_blank">Kyverno channel on Kubernetes Slack</a> for discussions, and join 
	our next community meeting. Check out the <a href="/community/" target="_blank">community page</a> for more details. 
</p>

[![Go Report Card](https://goreportcard.com/badge/github.com/kyverno/kyverno)](https://goreportcard.com/report/github.com/kyverno/kyverno)
[![License: Apache-2.0](https://img.shields.io/github/license/kyverno/kyverno?color=blue)](https://github.com/kyverno/kyverno/)
[![GitHub Repo stars](https://img.shields.io/github/stars/kyverno/kyverno)](https://github.com/kyverno/kyverno/stargazers)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/5327/badge)](https://bestpractices.coreinfrastructure.org/projects/5327)

{{% /blocks/lead %}}

{{% blocks/lead color="dark" %}}

## Kyverno is a CNCF Incubating Project { class="text-center mb-4" }

<a href="https://www.cncf.io" target="blank">
	<img class="cncf-logo img-fluid" src="/images/logo_cloudnative.png" alt="Cloud Native Computing Foundation logo">
</a>

<br/>
<br/>
<br/>
<br/>

<div class="mt-8 mx-auto">
	<small class="text-white">The Linux Foundation® (TLF) has registered trademarks and uses trademarks. For a list of TLF trademarks, see <a href="https://www.linuxfoundation.org/trademark-usage/">Trademark Usage</a>.</small>
</div>

{{% /blocks/lead %}}
