#!/usr/bin/env node

import * as fs from 'fs/promises'
import * as path from 'path'
import * as yaml from 'js-yaml'

import simpleGit from 'simple-git'

// Schema constants - keep these in sync with src/content.config.ts
// These can be easily updated if the schema changes
const POLICY_CATEGORIES = [
  'verifyImages',
  'validate',
  'mutate',
  'generate',
  'cleanup',
] as const

const POLICY_SEVERITIES = ['low', 'medium', 'high'] as const

type PolicyCategory = (typeof POLICY_CATEGORIES)[number]
type PolicySeverity = (typeof POLICY_SEVERITIES)[number]

interface PolicyMetadata {
  title: string
  category: PolicyCategory
  severity: PolicySeverity
  subjects: string[]
  tags: string[]
  version?: string
  type: string // Full kind from YAML (e.g., ClusterPolicy, Policy, MutatingPolicy)
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
 * Determines the policy category from the spec rules and annotations
 * Maps policy type to schema category enum
 */
function getPolicyCategory(
  spec: PolicyYaml['spec'],
  annotations: Record<string, string>,
): PolicyCategory {
  // Check for verifyImages category (typically has image verification rules)
  const categoryAnnotation = annotations['policies.kyverno.io/category']
  if (categoryAnnotation?.toLowerCase().includes('verifyimage')) {
    return 'verifyImages'
  }

  // Check for cleanup category
  if (categoryAnnotation?.toLowerCase().includes('cleanup')) {
    return 'cleanup'
  }

  // Determine from rule types
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
 * Matches the schema defined in src/content.config.ts
 */
function extractMetadata(policy: PolicyYaml, filePath: string): PolicyMetadata {
  const annotations = policy.metadata.annotations || {}

  const title = annotations['policies.kyverno.io/title'] || policy.metadata.name
  const category = getPolicyCategory(policy.spec, annotations)

  // Extract severity, default to 'medium' if not specified
  const severityAnnotation =
    annotations['policies.kyverno.io/severity']?.toLowerCase()
  const severity: PolicySeverity =
    severityAnnotation &&
    POLICY_SEVERITIES.includes(severityAnnotation as PolicySeverity)
      ? (severityAnnotation as PolicySeverity)
      : 'medium'

  // Extract subjects (plural) from subject annotation, split by comma if multiple
  const subjectAnnotation = annotations['policies.kyverno.io/subject'] || ''
  const subjects = subjectAnnotation
    .split(',')
    .map((s) => s.trim())
    .filter((s) => s.length > 0)

  // Extract tags from annotations (if available) or default to empty array
  const tagsAnnotation = annotations['policies.kyverno.io/tags']
  const tags = tagsAnnotation
    ? tagsAnnotation
        .split(',')
        .map((t) => t.trim())
        .filter((t) => t.length > 0)
    : []

  // Version is optional
  const version = annotations['policies.kyverno.io/minversion'] || undefined

  // Extract the full kind from the policy YAML (e.g., ClusterPolicy, Policy, MutatingPolicy)
  const type = policy.kind

  return {
    title,
    category,
    severity,
    subjects,
    tags,
    version,
    type,
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

  // Format frontmatter to match schema in src/content.config.ts
  const frontmatterLines = [
    '---',
    `title: '${metadata.title.replace(/'/g, "''")}'`,
    `category: ${metadata.category}`,
    `severity: ${metadata.severity}`,
    `type: ${metadata.type}`,
    ...(metadata.subjects.length > 0
      ? [`subjects:`, ...metadata.subjects.map((s) => `  - ${s}`)]
      : ['subjects: []']),
    ...(metadata.tags.length > 0
      ? [`tags:`, ...metadata.tags.map((t) => `  - ${t}`)]
      : ['tags: []']),
  ]

  // Add version only if present (it's optional in schema)
  if (metadata.version) {
    frontmatterLines.push(`version: ${metadata.version}`)
  }

  frontmatterLines.push('---', '', '## Policy Definition', '')
  frontmatterLines.push(
    `<a href="${rawUrl}" target="-blank">${displayPath}</a>`,
    '',
  )
  frontmatterLines.push('```yaml')
  frontmatterLines.push(yamlContent)
  frontmatterLines.push('```', '')

  return frontmatterLines.join('\n')
}

/**
 * Checks if a directory or file should be excluded from processing
 */
function shouldExclude(filePath: string, baseDir: string): boolean {
  const relativePath = path.relative(baseDir, filePath)
  const pathParts = relativePath.split(path.sep)

  // Exclude test directories and files
  const excludePatterns = [
    '.chainsaw-test',
    '.test',
    'test',
    'tests',
    '__tests__',
    'examples',
    'sample',
    'samples',
  ]

  // Check if any part of the path matches exclude patterns
  for (const part of pathParts) {
    if (excludePatterns.some((pattern) => part.includes(pattern))) {
      return true
    }
  }

  return false
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

      // Skip excluded directories and files
      if (shouldExclude(fullPath, dir)) {
        continue
      }

      if (entry.isDirectory()) {
        await walk(fullPath)
      } else if (
        entry.isFile() &&
        (entry.name.endsWith('.yaml') || entry.name.endsWith('.yml'))
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

    // Handle multi-document YAML files
    // Load all documents and find the policy one
    let policy: PolicyYaml | null = null

    try {
      // Try loading as single document first
      const loaded = yaml.load(content) as PolicyYaml
      if (
        loaded?.apiVersion?.includes('kyverno.io') &&
        loaded?.kind?.includes('Policy')
      ) {
        policy = loaded
      }
    } catch (error) {
      // If single document fails, try loading all documents
      try {
        const documents = yaml.loadAll(content) as PolicyYaml[]
        // Find the first document that is a Kyverno policy
        policy =
          documents.find(
            (doc) =>
              doc?.apiVersion?.includes('kyverno.io') &&
              doc?.kind?.includes('Policy'),
          ) || null
      } catch (multiDocError) {
        // If both fail, skip this file
        console.warn(`Skipping ${filePath}: Invalid YAML format`)
        return
      }
    }

    // Skip if not a Kyverno policy
    if (!policy) {
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
    // Only log errors that aren't expected skips
    if (
      error instanceof Error &&
      error.message.includes('expected a single document')
    ) {
      // This is handled above, so we can skip logging
      return
    }
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
      'Example: render.ts https://github.com/kyverno/policies/main ../src/content/policies/',
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
