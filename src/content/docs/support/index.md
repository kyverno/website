---
title: Support
linkTitle: Support
description: Commercial Products and Services for Kyverno
toc: false
---

## Products

<div class="support-cards-grid grid grid-cols-1 md:grid-cols-3 gap-6 my-8">
  <a href="https://github.com/giantswarm/security-pack" class="support-card group block rounded-2xl border-2 p-6 transition-all duration-300"  
  target="_blank">
    <div class="flex flex-col space-y-4">
      <h3 class="text-2xl font-bold text-black group-hover:text-black transition-colors">Giant Swarm</h3>
      <p class="text-base text-black/90 leading-relaxed">
      Managed Kubernetes platform. Kyverno is part of the Giant Swarm Security Pack.
      </p>
    </div>
  </a>
  
  <a href="https://nirmata.com/" class="support-card group block rounded-2xl border-2 p-6 transition-all duration-300"  target="_blank">
    <div class="flex flex-col space-y-4">
      <h3 class="text-2xl font-bold text-black group-hover:text-black transition-colors">Nirmata</h3>
      <p class="text-base text-black/90 leading-relaxed">Enterprise-grade policy and governance from the creators of Kyverno.</p>
    </div>
  </a>
</div>

## Services

<div class="support-cards-grid grid grid-cols-1 md:grid-cols-3 gap-6 my-8"  target="_blank">
  <a href="https://www.blakyaks.com/partners" class="support-card group block rounded-2xl border-2 p-6 transition-all duration-300">
    <div class="flex flex-col space-y-4">
      <h3 class="text-2xl font-bold text-black group-hover:text-black transition-colors">Blakyaks</h3>
      <p class="text-base text-black/90 leading-relaxed">
      Consulting services to design and deploy Kyverno policies.
      </p>
    </div>
  </a>
  
  <a href="https://www.infracloud.io/kyverno-consulting-support/" class="support-card group block rounded-2xl border-2 p-6 transition-all duration-300"  target="_blank">
    <div class="flex flex-col space-y-4">
      <h3 class="text-2xl font-bold text-black group-hover:text-black transition-colors">Infracloud</h3>
      <p class="text-base text-black/90 leading-relaxed">Kyverno Consulting and Implementation Partner.</p>
    </div>
  </a>
  
  <a href="https://learn.kodekloud.com/courses?search=kyverno" class="support-card group block rounded-2xl border-2 p-6 transition-all duration-300"  target="_blank">
    <div class="flex flex-col space-y-4">
      <h3 class="text-2xl font-bold text-black group-hover:text-black transition-colors">KodeKloud</h3>
      <p class="text-base text-black/90 leading-relaxed">Hands-on Kubernetes and DevOps Training.</p>
    </div>
  </a>
</div>

<style>
  .support-card {
    min-height: 200px;
    background-color: #69a2d3;
    border-color: #69a2d3;
    position: relative;
    overflow: hidden;
  }
  .support-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: linear-gradient(135deg, rgba(231, 126, 91, 0.1) 0%, rgba(231, 126, 91, 0) 100%);
    opacity: 0;
    transition: opacity 0.3s ease;
  }
  .support-card:hover::before {
    opacity: 1;
  }
  .support-card:hover {
    border-color: #e77e5b;
    box-shadow: 0 20px 40px -10px rgba(231, 126, 91, 0.4), 0 0 0 2px rgba(231, 126, 91, 0.2);
    transform: scale(1.02) translateY(-4px);
  }
  .support-card:active {
    transform: scale(0.98) translateY(0);
  }
  .support-card h3 {
    color: #000000 !important;
  }
  .support-cards-grid {
    container-type: inline-size;
  }
</style>
