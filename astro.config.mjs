// @ts-check
import { defineConfig } from 'astro/config'
import netlify from '@astrojs/netlify'
import starlight from '@astrojs/starlight'
import starlightThemeRapide from 'starlight-theme-rapide'
import react from '@astrojs/react';
import tailwindcss from "@tailwindcss/vite";


// https://astro.build/config
export default defineConfig({
  integrations: [starlight({
    plugins: [starlightThemeRapide()],
    title: 'Kyverno',
    // customCss: ['./src/styles/global.css'],
    social: [
      {
        icon: 'github',
        label: 'GitHub',
        href: 'https://github.com/kyverno/kyverno',
      },
    ],
    sidebar: [
      {
        label: 'Guides',
        items: [
          // Each item here is one entry in the navigation menu.
          { label: 'Example Guide', slug: 'guides/example' },
        ],
      },
      {
        label: 'Reference',
        autogenerate: { directory: 'reference' },
      },
    ],
  }), react()],

  adapter: netlify(),
  vite: {
    plugins: [tailwindcss()],
  },
})