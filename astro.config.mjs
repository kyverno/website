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
import starlightBlog from 'starlight-blog'

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
      components: {
        PageSidebar: './src/components/PageSidebar.astro',
        ThemeSelect: './src/components/ThemeSelect.astro',
      },
      editLink: {
        baseUrl: 'https://github.com/kyverno/website/edit/main/',
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
        {
          icon: 'laptop',
          label: 'Support',
          href: '/support',
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
          collapsed: true,
        },
        {
          label: 'Setup',
          autogenerate: { directory: 'docs/installation' },
          collapsed: true,
        },
        {
          label: 'Policy Types',
          items: [
            'docs/policy-types/overview',
            'docs/policy-types/validating-policy',
            'docs/policy-types/mutating-policy',
            'docs/policy-types/generating-policy',
            'docs/policy-types/deleting-policy',
            'docs/policy-types/image-validating-policy',
            'docs/policy-types/cel-libraries',
            {
              label: 'ClusterPolicy',
              items: [
                'docs/policy-types/cluster-policy/overview',
                'docs/policy-types/cluster-policy/policy-settings',
                'docs/policy-types/cluster-policy/match-exclude',
                'docs/policy-types/cluster-policy/validate',
                'docs/policy-types/cluster-policy/mutate',
                'docs/policy-types/cluster-policy/generate',
                {
                  label: 'Verify Image Rules',
                  collapsed: true,
                  autogenerate: {
                    directory: 'docs/policy-types/cluster-policy/verify-images',
                  },
                },
                'docs/policy-types/cluster-policy/autogen',
                'docs/policy-types/cluster-policy/variables',
                'docs/policy-types/cluster-policy/jmespath',
                'docs/policy-types/cluster-policy/preconditions',
                'docs/policy-types/cluster-policy/external-data-sources',
              ],
              collapsed: true,
              badge: {
                text: 'Deprecated',
                variant: 'caution',
              },
            },
            'docs/policy-types/cleanup-policy',
          ],
          collapsed: false,
        },
        {
          label: 'Guides',
          collapsed: true,
          items: [
            'docs/guides/applying-policies',
            'docs/guides/testing-policies',
            'docs/guides/exceptions',
            'docs/guides/reports',
            'docs/guides/monitoring',
            'docs/guides/tracing',
            'docs/guides/high-availability',
            'docs/guides/security',
            'docs/guides/troubleshooting',
            {
              label: 'Migrating to CEL Policies',
              link: 'docs/migration/traditional-to-cel',
            },
            'docs/guides/admission-controllers',
            'docs/guides/pod-security',
            'docs/guides/gatekeeper',
          ],
        },
        {
          label: 'Reference',
          items: [
            {
              label: 'Resource Definitions',
              slug: 'docs/crds',
            },
            'docs/reference/metrics',
            {
              label: 'Kyverno CLI',
              collapsed: true,
              autogenerate: { directory: 'docs/kyverno-cli' },
            },
          ],
        },
        {
          label: 'Sub-Projects',
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
          label: 'Community',
          slug: 'community',
        },
      ],
      plugins: [
        starlightImageZoom(),
        // starlightAutoSidebar(),
        starlightBlog({
          metrics: {
            readingTime: true,
            words: 'total',
          },
          navigation: 'header-end',
        }),
        ...checkLinksPlugin,
      ],
    }),
    react(),
    markdoc(),
  ],
  vite: {
    // @ts-expect-error - Vite plugin type mismatch between Astro's Vite and root Vite versions
    plugins: [tailwindcss()],
  },
})
