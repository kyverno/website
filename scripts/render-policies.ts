#!/usr/bin/env node

import * as fs from 'fs/promises'
import * as path from 'path'
import * as yaml from 'js-yaml'

import simpleGit from 'simple-git'

interface PolicyMetadata {
  title: string
  category: string
  version: string
  subject: string
  policyType: 'validate' | 'mutate' | 'generate'
  description: string
}

interface PolicyYaml {
  apiVersion: string
  kind: string
  metadata: {
    name: string
    annotations?: Record<string, string>
  }
  spec: {
    validationFailureAction?: string
    rules: Array<{
      validate?: unknown
      mutate?: unknown
      generate?: unknown
    }>
  }
}

/**
 * Determines the policy type from the spec rules
 */
function getPolicyType(
  spec: PolicyYaml['spec'],
): 'validate' | 'mutate' | 'generate' {
  if (!spec.rules || spec.rules.length === 0) {
    return 'validate'
  }

  const firstRule = spec.rules[0]
  if (firstRule.generate) {
    return 'generate'
  }
  if (firstRule.mutate) {
    return 'mutate'
  }
  return 'validate'
}

/**
 * Extracts metadata from policy YAML annotations
 */
function extractMetadata(policy: PolicyYaml, filePath: string): PolicyMetadata {
  const annotations = policy.metadata.annotations || {}

  const title = annotations['policies.kyverno.io/title'] || policy.metadata.name
  const category = annotations['policies.kyverno.io/category'] || 'Other'
  const version = annotations['policies.kyverno.io/minversion'] || '1.0.0'
  const subject = annotations['policies.kyverno.io/subject'] || ''
  const description = annotations['policies.kyverno.io/description'] || ''
  const policyType = getPolicyType(policy.spec)

  return {
    title,
    category,
    version,
    subject,
    policyType,
    description,
  }
}

/**
 * Generates markdown content from policy YAML
 */
function generateMarkdown(
  policy: PolicyYaml,
  metadata: PolicyMetadata,
  repoUrl: string,
  relativePath: string,
): string {
  const yamlContent = yaml.dump(policy, { lineWidth: -1, quotingType: '"' })

  // Extract the path from the repo URL (e.g., "main" from "https://github.com/kyverno/policies/main")
  const repoPath = repoUrl.split('/').slice(-1)[0] || 'main'
  const repoBase = repoUrl.replace(`/${repoPath}`, '')
  const rawUrl = `${repoBase}/raw/${repoPath}/${relativePath}`

  // Format the relative path for display (remove leading slash if present)
  const displayPath = relativePath.startsWith('/')
    ? relativePath
    : `/${relativePath}`

  const frontmatter = `---
title: '${metadata.title.replace(/'/g, "''")}'
category: ${metadata.category}
version: ${metadata.version}
subject: ${metadata.subject}
policyType: '${metadata.policyType}'
description: >
  ${metadata.description.split('\n').join('\n  ')}
---

## Policy Definition

<a href="${rawUrl}" target="-blank">${displayPath}</a>

\`\`\`yaml
${yamlContent}\`\`\`
`

  return frontmatter
}

/**
 * Finds all YAML policy files in a directory recursively
 */
async function findPolicyFiles(dir: string): Promise<string[]> {
  const files: string[] = []

  async function walk(currentDir: string) {
    const entries = await fs.readdir(currentDir, { withFileTypes: true })

    for (const entry of entries) {
      const fullPath = path.join(currentDir, entry.name)

      if (entry.isDirectory()) {
        await walk(fullPath)
      } else if (
        (entry.isFile() && entry.name.endsWith('.yaml')) ||
        entry.name.endsWith('.yml')
      ) {
        files.push(fullPath)
      }
    }
  }

  await walk(dir)
  return files
}

/**
 * Processes a single policy file and generates markdown
 */
async function processPolicyFile(
  filePath: string,
  repoDir: string,
  outputDir: string,
  repoUrl: string,
): Promise<void> {
  try {
    const content = await fs.readFile(filePath, 'utf-8')
    const policy = yaml.load(content) as PolicyYaml

    // Skip if not a Kyverno policy
    if (
      !policy.apiVersion?.includes('kyverno.io') ||
      !policy.kind?.includes('Policy')
    ) {
      return
    }

    const metadata = extractMetadata(policy, filePath)

    // Calculate relative path from repo root (for GitHub link)
    const relativePath = path.relative(repoDir, filePath).replace(/\\/g, '/')

    // Preserve directory structure from source repository
    // Remove the filename and get the directory path
    const relativeDir = path.dirname(path.relative(repoDir, filePath))
    const policyName = policy.metadata.name
    const fileName = path.basename(filePath, path.extname(filePath))

    // Output path preserves the source directory structure
    const outputPath = relativeDir
      ? path.join(outputDir, relativeDir, `${fileName}.md`)
      : path.join(outputDir, `${fileName}.md`)

    // Create output directory
    await fs.mkdir(path.dirname(outputPath), { recursive: true })

    // Generate markdown
    const markdown = generateMarkdown(policy, metadata, repoUrl, relativePath)

    // Write markdown file
    await fs.writeFile(outputPath, markdown, 'utf-8')

    console.log(`Generated: ${outputPath}`)
  } catch (error) {
    console.error(`Error processing ${filePath}:`, error)
  }
}

/**
 * Main function to render policies
 */
async function main() {
  const args = process.argv.slice(2)

  if (args.length < 2) {
    console.error('Usage: render.ts <repo-url> <output-dir>')
    console.error(
      'Example: render.ts https://github.com/kyverno/policies/main ../src/content/docs/policies/',
    )
    process.exit(1)
  }

  const repoUrl = args[0]
  const outputDir = path.resolve(args[1])

  // Extract repo info from URL
  // Format: https://github.com/owner/repo/branch
  const urlMatch = repoUrl.match(
    /https:\/\/github\.com\/([^\/]+)\/([^\/]+)\/(.+)/,
  )
  if (!urlMatch) {
    console.error(
      'Invalid repository URL format. Expected: https://github.com/owner/repo/branch',
    )
    process.exit(1)
  }

  const [, owner, repo, branch] = urlMatch
  const repoFullName = `${owner}/${repo}`

  // Create temporary directory for cloning
  const tempDir = path.join(process.cwd(), '.temp-policies')

  try {
    console.log(`Cloning ${repoFullName} (branch: ${branch})...`)

    // Clone repository
    const git = simpleGit()
    await git.clone(`https://github.com/${repoFullName}.git`, tempDir, [
      '--branch',
      branch,
      '--depth',
      '1',
    ])

    console.log('Finding policy files...')
    const policyFiles = await findPolicyFiles(tempDir)

    console.log(`Found ${policyFiles.length} policy files`)

    // Ensure output directory exists
    await fs.mkdir(outputDir, { recursive: true })

    // Clean output directory (but keep _index.md, search.md, and other special files)
    const existingItems = await fs.readdir(outputDir).catch(() => [])
    for (const item of existingItems) {
      const itemPath = path.join(outputDir, item)
      const stat = await fs.stat(itemPath).catch(() => null)
      if (stat?.isDirectory()) {
        // Remove directories that will be regenerated
        await fs.rm(itemPath, { recursive: true, force: true })
      } else if (
        stat?.isFile() &&
        item !== '_index.md' &&
        item !== 'search.md' &&
        !item.endsWith('.mdoc')
      ) {
        // Keep special markdown files but remove generated ones
        // We'll regenerate all .md files except _index.md and search.md
      }
    }

    // Process each policy file
    for (const filePath of policyFiles) {
      await processPolicyFile(filePath, tempDir, outputDir, repoUrl)
    }

    console.log('Policy rendering complete!')
  } catch (error) {
    console.error('Error:', error)
    process.exit(1)
  } finally {
    // Clean up temporary directory
    await fs.rm(tempDir, { recursive: true, force: true }).catch(() => {
      // Ignore cleanup errors
    })
  }
}

// Run main function
main().catch(console.error)
