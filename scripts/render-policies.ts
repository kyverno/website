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
  description?: string // Policy description from annotations
  isNew?: boolean // Flag to mark new policies (based on creation date)
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
    // For Policy/ClusterPolicy
    rules?: Array<{
      validate?: unknown
      mutate?: unknown
      generate?: unknown
      verifyImages?: unknown
      cleanup?: unknown
    }>
    // For MutatingPolicy
    mutations?: unknown
    // For ValidatingPolicy
    validations?: unknown
    // For ImageValidatingPolicy
    attestors?: unknown
    matchImageReferences?: unknown
  }
}

/**
 * Determines the policy category from the spec rules and annotations
 * Maps policy type to schema category enum based on Kyverno engine features
 *
 * For new policy types, we can leverage the kind directly since it indicates the category:
 * - ImageValidatingPolicy → verifyImages
 * - MutatingPolicy → mutate
 * - ValidatingPolicy → validate
 * - GeneratingPolicy → generate
 * - CleanupPolicy/ClusterCleanupPolicy → cleanup
 * - DeletingPolicy → cleanup (deletion is a form of cleanup)
 *
 * For Policy/ClusterPolicy, we need to inspect the spec.rules array to determine
 * which engine features are used (verifyImages, cleanup, generate, mutate, validate).
 *
 * Priority order: verifyImages > cleanup > generate > mutate > validate
 */
function getPolicyCategory(
  policy: PolicyYaml,
  spec: PolicyYaml['spec'],
  annotations: Record<string, string>,
): PolicyCategory {
  const kind = policy.kind

  // For new policy types, the kind directly indicates the category
  // Unlike Policy/ClusterPolicy, we don't need to inspect the spec
  switch (kind) {
    case 'ImageValidatingPolicy':
      return 'verifyImages'
    case 'MutatingPolicy':
      return 'mutate'
    case 'ValidatingPolicy':
      return 'validate'
    case 'GeneratingPolicy':
      return 'generate'
    case 'CleanupPolicy':
    case 'ClusterCleanupPolicy':
      return 'cleanup'
    case 'DeletingPolicy':
      return 'cleanup' // Deletion is a form of cleanup
  }

  // For Policy/ClusterPolicy, inspect spec.rules to determine category
  if (spec.rules && spec.rules.length > 0) {
    // Check all rules to find the primary engine feature
    // Priority order: verifyImages > cleanup > generate > mutate > validate
    let hasValidate = false

    for (const rule of spec.rules) {
      if (rule.verifyImages) {
        return 'verifyImages'
      }
      if (rule.cleanup) {
        return 'cleanup'
      }
      if (rule.generate) {
        return 'generate'
      }
      if (rule.mutate) {
        return 'mutate'
      }
      if (rule.validate) {
        hasValidate = true
      }
    }

    // If we found validate rules but no higher priority features, return validate
    if (hasValidate) {
      return 'validate'
    }
  }

  // Fallback: Check category annotation if rules don't provide clear indication
  const categoryAnnotation = annotations['policies.kyverno.io/category']
  if (categoryAnnotation) {
    const lowerAnnotation = categoryAnnotation.toLowerCase()
    if (lowerAnnotation.includes('verifyimage')) {
      return 'verifyImages'
    }
    if (lowerAnnotation.includes('cleanup')) {
      return 'cleanup'
    }
  }

  // Default to validate if no rules or unclear
  return 'validate'
}

/**
 * Extracts metadata from policy YAML annotations
 * Matches the schema defined in src/content.config.ts
 */
function extractMetadata(policy: PolicyYaml, filePath: string): PolicyMetadata {
  const annotations = policy.metadata.annotations || {}

  const title = annotations['policies.kyverno.io/title'] || policy.metadata.name
  const category = getPolicyCategory(policy, policy.spec, annotations)

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
  const tagsFromAnnotation = tagsAnnotation
    ? tagsAnnotation
        .split(',')
        .map((t) => t.trim())
        .filter((t) => t.length > 0)
    : []

  // Extract category from annotations and add to tags
  const categoryAnnotation = annotations['policies.kyverno.io/category']
  const categoryTags = categoryAnnotation
    ? categoryAnnotation
        .split(',')
        .map((c) => c.trim())
        .filter((c) => c.length > 0)
    : []

  // Combine tags and category tags, removing duplicates
  const allTags = [...tagsFromAnnotation, ...categoryTags]
  const tags = Array.from(new Set(allTags)) // Remove duplicates

  // Version is optional
  const version = annotations['policies.kyverno.io/minversion'] || undefined

  // Extract description from annotations
  const description =
    annotations['policies.kyverno.io/description'] || undefined

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

  // Add description if present
  if (metadata.description) {
    // Escape single quotes in description for YAML
    const escapedDescription = metadata.description.replace(/'/g, "''")
    frontmatterLines.push(`description: '${escapedDescription}'`)
  }

  // Add isNew flag if present
  if (metadata.isNew) {
    frontmatterLines.push(`isNew: true`)
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
 * Gets the creation date of a file from git to determine if it's "new"
 * Policies created in the last 90 days are considered "new"
 * Uses git log --reverse to get the first commit (file creation) instead of the latest
 */
async function getFileCreationDate(
  filePath: string,
  repoDir: string,
  git: ReturnType<typeof simpleGit>,
): Promise<Date | null> {
  try {
    const relativePath = path.relative(repoDir, filePath).replace(/\\/g, '/')
    // Use git log --reverse to get the first commit (when file was created)
    // This requires history, so we need to ensure the clone has enough depth
    const result = await git.raw([
      'log',
      '--reverse',
      '--format=%ai',
      '--',
      relativePath,
    ])

    if (result && result.trim()) {
      // Get the first line (first commit date)
      const firstLine = result.trim().split('\n')[0]
      if (firstLine) {
        return new Date(firstLine)
      }
    }
  } catch (error) {
    // If git log fails, return null (file might not be tracked or repo might be shallow)
    // With shallow clone, we won't have history to determine creation date
  }
  return null
}

/**
 * Processes a single policy file and generates markdown
 */
async function processPolicyFile(
  filePath: string,
  repoDir: string,
  outputDir: string,
  repoUrl: string,
  git: ReturnType<typeof simpleGit>,
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

    // Check if policy is "new" (created in last 90 days)
    try {
      const creationDate = await getFileCreationDate(filePath, repoDir, git)
      if (creationDate) {
        const daysSinceCreation =
          (Date.now() - creationDate.getTime()) / (1000 * 60 * 60 * 24)
        if (daysSinceCreation <= 90) {
          metadata.isNew = true
        }
      }
    } catch (error) {
      // If git log fails, continue without isNew flag
    }

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

    // Clone repository with enough depth to get file creation dates
    // Using depth 1000 to get sufficient history for determining "new" policies
    const git = simpleGit()
    await git.clone(`https://github.com/${repoFullName}.git`, tempDir, [
      '--branch',
      branch,
      '--depth',
      '1000', // Increased from 1 to get enough history for file creation dates
    ])

    // Initialize git instance for the cloned repo
    const repoGit = simpleGit(tempDir)

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
      await processPolicyFile(filePath, tempDir, outputDir, repoUrl, repoGit)
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
