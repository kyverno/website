---
title: Kyverno
linkTitlem: Kyverno
---

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
	<p>
		<a class="btn btn-link text-info" href="#about-kyverno" aria-label="Read more">
			<i class="fa fa-chevron-circle-down" style="font-size: 400%"></i>
		</a>
	</p>
</div>

{{< /blocks/cover >}}

{{% blocks/lead color="light" %}}
<br/>

# About Kyverno { class="text-center" }

<br/>
<br/>

<h2>
Unified Policy-as-Code (PaC) for Kubernetes and cloud native environments
</h2>
<br/>

<p style="line-height:1.5">

<br/>

<div class="row">
  <div class="col-lg-4 col-md-6 mb-4">
    <div class="card h-100 border-0 shadow-sm text-center" style="transition: transform 0.2s;">
      <div class="card-body p-4">
        <div class="mb-3">
          <i class="fa fa-cube fa-3x text-primary"></i>
        </div>
        <h3 class="card-title font-weight-bold mb-3">Kubernetes Native</h3>
        <p class="card-text text-muted mb-3">Powerful extensions of Kubernetes policy types with integrated CEL support.</p>
      </div>
    </div>
  </div>
  
  <div class="col-lg-4 col-md-6 mb-4">
    <div class="card h-100 border-0 shadow-sm text-center" style="transition: transform 0.2s;">
      <div class="card-body p-4">
        <div class="mb-3">
          <i class="fa fa-globe fa-3x text-primary"></i>
        </div>
        <h3 class="card-title font-weight-bold mb-3">Works Everywhere</h3>
        <p class="card-text text-muted mb-3">Apply Kubernetes style policies to any resource and any JSON payload using the CLI or SDK.</p>
      </div>
    </div>
  </div>
  
  <div class="col-lg-4 col-md-6 mb-4">
    <div class="card h-100 border-0 shadow-sm text-center" style="transition: transform 0.2s;">
      <div class="card-body p-4">
        <div class="mb-3">
          <i class="fa fa-chart-bar fa-3x text-primary"></i>
        </div>
        <h3 class="card-title font-weight-bold mb-3">Reporting</h3>
        <p class="card-text text-muted mb-3">Integrated OpenReports compatible producers and dashboards.</p>
      </div>
    </div>
  </div>
  
  <div class="col-lg-4 col-md-6 mb-4">
    <div class="card h-100 border-0 shadow-sm text-center" style="transition: transform 0.2s;">
      <div class="card-body p-4">
        <div class="mb-3">
          <i class="fa fa-exclamation-triangle fa-3x text-primary"></i>
        </div>
        <h3 class="card-title font-weight-bold mb-3">Exceptions</h3>
        <p class="card-text text-muted mb-3">Time-bound and fine grained exception management decoupled from policies.</p>
      </div>
    </div>
  </div>
  
  <div class="col-lg-4 col-md-6 mb-4">
    <div class="card h-100 border-0 shadow-sm text-center" style="transition: transform 0.2s;">
      <div class="card-body p-4">
        <div class="mb-3">
          <i class="fa fa-terminal fa-3x text-primary"></i>
        </div>
        <h3 class="card-title font-weight-bold mb-3">Shift-Left</h3>
        <p class="card-text text-muted mb-3">Command Line Interface for integrations into CI/CD and IaC (Terraform, etc.) pipelines.</p>
      </div>
    </div>
  </div>
  
  <div class="col-lg-4 col-md-6 mb-4">
    <div class="card h-100 border-0 shadow-sm text-center" style="transition: transform 0.2s;">
      <div class="card-body p-4">
        <div class="mb-3">
          <i class="fa fa-vial fa-3x text-primary"></i>
        </div>
        <h3 class="card-title font-weight-bold mb-3">Testing</h3>
        <p class="card-text text-muted mb-3">Tooling for declarative unit tests and end-to-end behavioral tests.</p>
      </div>
    </div>
  </div>
</div>

<br/>

## Complete Policy-Based Resource Lifecycle Management { class="text-center" }

<br/>

<div class="row justify-content-center">
  <div class="col-lg-2 col-md-4 col-6 mb-4">
    <div class="text-center">
      <div class="bg-success text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 64px; height: 64px;">
        <i class="fa fa-check-circle fa-2x"></i>
      </div>
      <h6 class="font-weight-bold">Validate</h6>
    </div>
  </div>
  
  <div class="col-lg-2 col-md-4 col-6 mb-4">
    <div class="text-center">
      <div class="bg-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 64px; height: 64px;">
        <i class="fa fa-edit fa-2x"></i>
      </div>
      <h6 class="font-weight-bold">Mutate</h6>
    </div>
  </div>
  
  <div class="col-lg-2 col-md-4 col-6 mb-4">
    <div class="text-center">
      <div class="bg-info text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 64px; height: 64px;">
        <i class="fa fa-plus-circle fa-2x"></i>
      </div>
      <h6 class="font-weight-bold">Generate</h6>
    </div>
  </div>
  
  <div class="col-lg-2 col-md-4 col-6 mb-4">
    <div class="text-center">
      <div class="bg-warning text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 64px; height: 64px;">
        <i class="fa fa-trash-alt fa-2x"></i>
      </div>
      <h6 class="font-weight-bold">Cleanup</h6>
    </div>
  </div>
  
  <div class="col-lg-2 col-md-4 col-6 mb-4">
    <div class="text-center">
      <div class="bg-danger text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 64px; height: 64px;">
        <i class="fa fa-shield-alt fa-2x"></i>
      </div>
      <h6 class="font-weight-bold">Verify Images</h6>
    </div>
  </div>
</div>

<!-- Buttons -->
<br/>
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
