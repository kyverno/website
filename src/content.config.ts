import { defineCollection, z } from 'astro:content'
import { glob } from 'astro/loaders'
import { docsLoader } from '@astrojs/starlight/loaders'
import { docsSchema } from '@astrojs/starlight/schema'

export const collections = {
  docs: defineCollection({ loader: docsLoader(), schema: docsSchema() }),
  policies: defineCollection({
    loader: glob({ pattern: '**/*.md', base: './src/content/docs/policies' }),
  }),

  blog: defineCollection({
    type: 'content',

    schema: z.object({
      title: z.string(),
      description: z.string(),
      date: z.coerce.date(),
      category: z.string().optional(),
      author: z.string().optional(),
      linkTitle: z.string(),
    }),
  }),
}
