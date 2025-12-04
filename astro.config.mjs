// @ts-check
import { defineConfig } from 'astro/config'
import starlight from '@astrojs/starlight'
import react from '@astrojs/react'
import tailwindcss from '@tailwindcss/vite'
import netlify from '@astrojs/netlify'

// https://astro.build/config
export default defineConfig({
  integrations: [
    starlight({
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
          label: 'Working With Policies',
          items: [
            {
              label: 'Policy Types',
              collapsed: true,
              autogenerate: { directory: 'docs/policy-types' },
            },
            {
              label: 'Applying Policies',
              collapsed: true,
              autogenerate: { directory: 'docs/applying-policies' },
            },
            {
              label: 'Testing Policies',
              collapsed: true,
              autogenerate: { directory: 'docs/testing-policies' },
            },
            {
              label: 'Monitoring',
              collapsed: true,
              autogenerate: { directory: 'docs/monitoring' },
            },
            {
              label: 'Security',
              collapsed: true,
              autogenerate: { directory: 'docs/security' },
            },
            {
              label: 'Tracing',
              collapsed: true,
              autogenerate: { directory: 'docs/tracing' },
            },
            {
              label: 'Reporting',
              collapsed: true,
              autogenerate: { directory: 'docs/policy-reports' },
            },
            {
              label: 'Policy Exceptions',
              collapsed: true,
              autogenerate: { directory: 'docs/exceptions' },
            },
          ],
          collapsed: true,
        },
        {
          label: 'Resource Definitions',
          collapsed: true,
          autogenerate: { directory: 'docs/CRDs' },
        },
        {
          label: 'High Availability',
          collapsed: true,
          autogenerate: { directory: 'docs/high-availability' },
        },
        {
          label: 'Tools',
          items: [
            {
              label: 'Kyverno CLI',
              collapsed: true,
              autogenerate: { directory: 'docs/kyverno-cli' },
            },
            {
              label: 'Kyverno JSON',
              collapsed: true,
              autogenerate: { directory: 'docs/subprojects/kyverno-json' },
            },
            {
              label: 'Kyverno Chainsaw',
              collapsed: true,
              autogenerate: { directory: 'docs/subprojects/kyverno-chainsaw' },
            },
            {
              label: 'Policy Reporter',
              collapsed: true,
              autogenerate: {
                directory: 'docs/subprojects/kyverno-policy-reporter',
              },
            },
          ],
          collapsed: true,
        },
        {
          label: 'Releases',
          collapsed: true,
          autogenerate: { directory: 'docs/releases' },
        },
        {
          label: 'Troubleshooting',
          autogenerate: { directory: 'docs/troubleshooting' },
        },
      ],
    }),
    react(),
  ],

  adapter: netlify(),
  vite: {
    plugins: [tailwindcss()],
  },
})
