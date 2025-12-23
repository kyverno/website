import { autoSidebarLoader } from 'starlight-auto-sidebar/loader'
import { autoSidebarSchema } from 'starlight-auto-sidebar/schema'
import { defineCollection } from 'astro:content'
import { docsLoader } from '@astrojs/starlight/loaders'
import { docsSchema } from '@astrojs/starlight/schema'
import { glob } from 'astro/loaders'

export const collections = {
  docs: defineCollection({ loader: docsLoader(), schema: docsSchema() }),
  policies: defineCollection({
    loader: glob({ pattern: '**/*.md', base: './src/content/docs/policies' }),
  }),
  autoSidebar: defineCollection({
    loader: autoSidebarLoader(),
    schema: autoSidebarSchema(),
  }),
}
