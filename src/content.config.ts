import { defineCollection, z } from 'astro:content'

import { autoSidebarLoader } from 'starlight-auto-sidebar/loader'
import { autoSidebarSchema } from 'starlight-auto-sidebar/schema'
import { docsLoader } from '@astrojs/starlight/loaders'
import { docsSchema } from '@astrojs/starlight/schema'
import { glob } from 'astro/loaders'

const policiesCollection = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/policies' }),
  schema: z.object({
    title: z.string(),
    category: z.enum([
      'verifyImages',
      'validate',
      'mutate',
      'generate',
      'cleanup',
    ]),
    severity: z.enum(['low', 'medium', 'high']),
    type: z.string(), // Full kind from YAML (e.g., ClusterPolicy, Policy, MutatingPolicy)
    subjects: z.array(z.string()), // Pod, Deployment, ...
    tags: z.array(z.string()),
    version: z.string().optional(),
    description: z.string().optional(), // Policy description from annotations
    isNew: z.boolean().optional(), // Flag to mark new policies
  }),
})

const blogCollection = defineCollection({
  loader: glob({
    pattern: '**/*.md',
    base: './src/content/blog',
    generateId: (options) => {
      // Extract full path from date-based structure: e.g., "2025/04/25/announcing-kyverno-release-1.14/index.md" -> "2025/04/25/announcing-kyverno-release-1.14"
      // Remove /index.md and return the full path including date
      return options.entry.replace(/\/index\.md$/, '')
    },
  }),
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    tags: z.array(z.string()).optional(),
    excerpt: z.string().optional(),
    draft: z.boolean().optional().default(false),
    coverImage: z.string().optional(),
  }),
})

export const collections = {
  docs: defineCollection({
    loader: docsLoader(),
    schema: docsSchema(),
  }),

  blog: blogCollection,
  policies: policiesCollection,
  autoSidebar: defineCollection({
    loader: autoSidebarLoader(),
    schema: autoSidebarSchema(),
  }),
}
