import { defineCollection } from 'astro:content'
import { glob } from 'astro/loaders'
import { docsLoader } from '@astrojs/starlight/loaders'
import { docsSchema } from '@astrojs/starlight/schema'

export const collections = {
  docs: defineCollection({ loader: docsLoader(), schema: docsSchema() }),
  policies: defineCollection({
    loader: glob({ pattern: '**/*.md', base: './src/content/docs/policies' }),
  }),
}
