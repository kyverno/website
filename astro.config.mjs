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
import { viteStaticCopy } from 'vite-plugin-static-copy'

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
            'docs/guides/migration-to-cel',
            'docs/guides/applying-policies',
            'docs/guides/testing-policies',
            'docs/guides/exceptions',
            'docs/guides/reports',
            'docs/guides/monitoring',
            'docs/guides/tracing',
            'docs/guides/high-availability',
            'docs/guides/security',
            'docs/guides/troubleshooting',
            'docs/guides/admission-controllers',
            'docs/guides/pod-security',
            'docs/guides/evaluating-policy-engines',
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
              autogenerate: { directory: 'docs/kyverno-cli/reference' },
            },
          ],
        },
        {
          label: 'Sub-Projects',
          autogenerate: { directory: 'docs/subprojects' },
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
        ...checkLinksPlugin,
      ],
    }),
    react(),
    markdoc(),
  ],
  vite: {
    plugins: [
      // @ts-expect-error - Vite plugin type mismatch between Astro's Vite and root Vite versions
      tailwindcss(),
      // @ts-expect-error - Vite plugin type mismatch between Astro's Vite and root Vite versions
      viteStaticCopy({
        targets: [
          {
            src: 'src/content/blog/**/assets/*',
            dest: 'blog',
            rename: (name, ext, fullPath) => {
              // Extract the post name from the path
              // Handles both old structure (2025/04/25/post-name/assets/image.png)
              // and new structure (post-name/assets/image.png)
              // We want: post-name/assets/image.png
              const match = fullPath.match(
                /src\/content\/blog\/(?:[\d/]+\/)?([^/]+)\/assets\/(.+)$/,
              )
              if (match) {
                const postName = match[1]
                const assetPath = match[2]
                return `${postName}/assets/${assetPath}`
              }
              // Fallback: try to extract just the post name
              const fallbackMatch = fullPath.match(
                /src\/content\/blog\/(.+)\/assets\/(.+)$/,
              )
              if (fallbackMatch) {
                const pathParts = fallbackMatch[1].split('/')
                const postName = pathParts[pathParts.length - 1]
                return `${postName}/assets/${fallbackMatch[2]}`
              }
              return name + ext
            },
          },
        ],
      }),
    ],
  },
})
