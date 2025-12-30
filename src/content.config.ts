import { defineCollection, z } from 'astro:content'

import { autoSidebarLoader } from 'starlight-auto-sidebar/loader'
import { autoSidebarSchema } from 'starlight-auto-sidebar/schema'
import { docsLoader } from '@astrojs/starlight/loaders'
import { docsSchema } from '@astrojs/starlight/schema'
import { glob } from 'astro/loaders'

const policiesCollection = defineCollection({
  type: 'content',
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
  }),
})

export const collections = {
  docs: defineCollection({ loader: docsLoader(), schema: docsSchema() }),
  policies: policiesCollection,
  autoSidebar: defineCollection({
    loader: autoSidebarLoader(),
    schema: autoSidebarSchema(),
  }),
}
