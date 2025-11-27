// @ts-check
import { defineConfig } from 'astro/config'
import netlify from '@astrojs/netlify'
import starlight from '@astrojs/starlight'
import starlightThemeRapide from 'starlight-theme-rapide'
import react from '@astrojs/react';
import tailwindcss from "@tailwindcss/vite";
import starlightUtils from "@lorenzo_lewis/starlight-utils";



// https://astro.build/config
export default defineConfig({
  integrations: [starlight({
    title: 'Kyverno',
    logo: {
      light: './src/docs-assets/kyverno-logo.svg',
      dark: './src/docs-assets/kyverno-logo.svg'
      },
    social: [
      {
        icon: 'github',
        label: 'GitHub',
        href: 'https://github.com/kyverno/kyverno',
      },
      {
        icon: 'slack',
        label: 'Slack',
        href: 'https://communityinviter.com/apps/kubernetes/community#kyverno',
      }
    ],
    editLink: {
        baseUrl: 'https://github.com/kyverno/kyverno/',
      },
    sidebar: [
      {
        label: 'Getting Started',
        items: [
          // Each item here is one entry in the navigation menu.
          { label: 'Introduction', slug: 'getting-started/introduction' },
          { label: 'Quickstart', slug: 'getting-started/quickstart' },
          { label: 'Installation', slug: 'getting-started/installation' },
        ],
      },
      {
        label: 'Policy Types',
        collapsed: false,
        autogenerate: { directory: 'policy-types', collapsed: true },
      },
    ],
  }), react()],

  adapter: netlify(),
  vite: {
    plugins: [tailwindcss()],
  },
})