// @ts-check
import { defineConfig } from 'astro/config'
import netlify from '@astrojs/netlify'
import starlight from '@astrojs/starlight'
import react from '@astrojs/react';
import tailwindcss from "@tailwindcss/vite";


// https://astro.build/config
export default defineConfig({
  integrations: [starlight({
    title: 'Kyverno',
    social: [
      {
        icon: 'github',
        label: 'GitHub',
        href: 'https://github.com/kyverno/kyverno',
      },
    ],
    sidebar: [
      // Autogenerate sidebar from the root: '/docs/docs'
      // {
      // 	label: 'Docs',
      // 	collapsed: false,
      // 	autogenerate: { directory: 'docs', collapsed: true, attrs: { style: 'text-transform: capitalize' }},
      // },
      {
        label: 'Introduction',
        autogenerate: { directory: 'docs/introduction' },
      },
      {
        label: 'Installation',
        autogenerate: { directory: 'docs/installation' },
      },
      {
        label: 'Applying Policies',
        collapsed: true,
        autogenerate: { directory: 'docs/applying-policies' },
      },
      {
        label: 'CRDs',
        collapsed: true,
        autogenerate: { directory: 'docs/CRDs' },
      },
      {
        label: 'Exceptions',
        collapsed: true,
        autogenerate: { directory: 'docs/exceptions' },
      },
      {
        label: 'High Availability',
        collapsed: true,
        autogenerate: { directory: 'docs/high-availability' },
      },
      {
        label: 'Kyverno Chainsaw',
        collapsed: true,
        autogenerate: { directory: 'docs/kyverno-chainsaw' },
      },
      {
        label: 'Kyverno CLI',
        collapsed: true,
        autogenerate: { directory: 'docs/kyverno-cli' },
      },
      {
        label: 'Kyverno JSON',
        collapsed: true,
        autogenerate: { directory: 'docs/kyverno-json' },
      },
      {
        label: 'Kyverno Policy Reporter',
        collapsed: true,
        autogenerate: { directory: 'docs/kyverno-policy-reporter' },
      },
      {
        label: 'Monitoring',
        collapsed: true,
        autogenerate: { directory: 'docs/monitoring' },
      },
      {
        label: 'Policy Reports',
        collapsed: true,
        autogenerate: { directory: 'docs/policy-reports' },
      },
      {
        label: 'Policy-Types',
        collapsed: true,
        autogenerate: { directory: 'docs/policy-types' },
      },
      {
        label: 'Releases',
        collapsed: true,
        autogenerate: { directory: 'docs/releases' },
      },
      {
        label: 'Security',
        collapsed: true,
        autogenerate: { directory: 'docs/security' },
      },
      {
        label: 'Testing-Policies',
        collapsed: true,
        autogenerate: { directory: 'docs/testing-policies' },
      },
      {
        label: 'Tracing',
        collapsed: true,
        autogenerate: { directory: 'docs/tracing' },
      },
      {
        label: 'Troubleshooting',
        autogenerate: { directory: 'docs/troubleshooting' },
      },
    ],
  }), react()],

  adapter: netlify(),
  vite: {
    plugins: [tailwindcss()],
  },
})