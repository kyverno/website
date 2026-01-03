// @ts-check
import { defineConfig } from 'astro/config'
import markdoc from '@astrojs/markdoc'
import netlify from '@astrojs/netlify'
import react from '@astrojs/react'
import starlight from '@astrojs/starlight'
import starlightAutoSidebar from 'starlight-auto-sidebar'
import starlightImageZoom from 'starlight-image-zoom'
import starlightLinksValidator from 'starlight-links-validator'
import tailwindcss from '@tailwindcss/vite'

const checkLinksPlugin = process.env.CHECK_LINKS
  ? [
      starlightLinksValidator({
        exclude: ['/{policies,blog,docs/blog}{,/,/**/*,/**/*/}'],
        errorOnLocalLinks: false,
      }),
    ]
  : []

// https://astro.build/config
export default defineConfig({
  integrations: [
    starlight({
      title: 'Kyverno',
      customCss: ['./src/styles/global.css'],
      editLink: {
        baseUrl: 'https://github.com/kyverno/website/edit/astro/',
      },
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
              label: 'Reporting',
              collapsed: true,
              autogenerate: { directory: 'docs/policy-reports' },
            },
            'docs/applying-policies',
            'docs/testing-policies',
            'docs/exceptions',
          ],
          collapsed: true,
        },
        {
          label: 'Monitoring',
          collapsed: true,
          autogenerate: { directory: 'docs/monitoring' },
        },
        {
          label: 'Tracing',
          collapsed: true,
          autogenerate: { directory: 'docs/tracing' },
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
            {
              label: 'Backstage Plugin',
              collapsed: true,
              autogenerate: { directory: 'docs/subprojects/backstage-plugin' },
            },
            {
              label: 'Kyverno Authz',
              collapsed: true,
              autogenerate: { directory: 'docs/subprojects/kyverno-authz' },
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
          label: 'Security',
          slug: 'docs/security',
        },
        {
          label: 'Community',
          slug: 'community',
        },
        {
          label: 'Support',
          slug: 'support',
        },
      ],
      plugins: [
        starlightImageZoom(),
        starlightAutoSidebar(),
        ...checkLinksPlugin,
      ],
    }),
    react(),
    markdoc(),
  ],
  vite: {
    plugins: [tailwindcss()],
  },
})
