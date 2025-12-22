// @ts-check
import { defineConfig } from 'astro/config'
import markdoc from '@astrojs/markdoc'
import netlify from '@astrojs/netlify'
import react from '@astrojs/react'
import starlight from '@astrojs/starlight'
import starlightImageZoom from 'starlight-image-zoom'
import tailwindcss from '@tailwindcss/vite'

const isDev = import.meta.env.DEV || import.meta.env.MODE === 'development'

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
        {
          icon: 'twitter',
          label: 'Twitter',
          href: 'https://twitter.com/kyverno',
        },
        {
          icon: 'slack',
          label: 'Slack',
          href: 'https://slack.k8s.io/#kyverno',
        },
        {
          icon: 'email',
          label: 'Google groups',
          href: 'https://groups.google.com/g/kyverno',
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
          label: 'Resource Definitions',
          slug: 'docs/crds',
        },
        {
          label: 'High Availability',
          slug: 'docs/high-availability',
        },
        {
          label: 'Releases',
          slug: 'docs/releases',
        },
        {
          label: 'Troubleshooting',
          slug: 'docs/troubleshooting',
        },
        {
          label: 'Community',
          slug: 'community',
        },
      ],
      plugins: [starlightImageZoom()],
    }),
    react(),
    markdoc(),
  ],

  adapter: isDev ? undefined : netlify(),
  vite: {
    plugins: [tailwindcss()],
  },
})
