#!/usr/bin/env node
/**
 * Script to migrate blog posts from flat structure to date-based structure
 *
 * Before: src/content/blog/announcing-kyverno-release-1.14/index.md
 * After:  src/content/blog/2025/04/25/announcing-kyverno-release-1.14/index.md
 */

import { readFileSync, readdirSync, statSync, mkdirSync, renameSync } from 'fs'
import { join, dirname } from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const blogDir = join(__dirname, '..', 'src', 'content', 'blog')

// Helper to format date as YYYY/MM/DD
function formatDatePath(date) {
  const d = new Date(date)
  const year = d.getFullYear()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${year}/${month}/${day}`
}

// Read all blog post folders
const folders = readdirSync(blogDir, { withFileTypes: true })
  .filter((dirent) => dirent.isDirectory())
  .map((dirent) => dirent.name)

console.log(`Found ${folders.length} blog post folders to migrate\n`)

let migrated = 0
let skipped = 0
let errors = 0

for (const folder of folders) {
  const folderPath = join(blogDir, folder)
  const indexPath = join(folderPath, 'index.md')

  try {
    // Check if index.md exists
    if (!statSync(indexPath).isFile()) {
      console.log(`⚠️  Skipping ${folder}: no index.md found`)
      skipped++
      continue
    }

    // Read the frontmatter to get the date
    const content = readFileSync(indexPath, 'utf-8')
    const frontmatterMatch = content.match(/^---\n([\s\S]*?)\n---/)

    if (!frontmatterMatch) {
      console.log(`⚠️  Skipping ${folder}: no frontmatter found`)
      skipped++
      continue
    }

    const frontmatter = frontmatterMatch[1]
    const dateMatch = frontmatter.match(/^date:\s*(.+)$/m)

    if (!dateMatch) {
      console.log(`⚠️  Skipping ${folder}: no date in frontmatter`)
      skipped++
      continue
    }

    const date = dateMatch[1].trim()
    const datePath = formatDatePath(date)
    const newFolderPath = join(blogDir, datePath, folder)

    // Create the date directory structure
    const dateDir = join(blogDir, datePath)
    mkdirSync(dateDir, { recursive: true })

    // Move the entire folder
    renameSync(folderPath, newFolderPath)

    console.log(`✅ Migrated ${folder} -> ${datePath}/${folder}`)
    migrated++
  } catch (error) {
    console.error(`❌ Error migrating ${folder}:`, error.message)
    errors++
  }
}

console.log(`\n📊 Migration Summary:`)
console.log(`   ✅ Migrated: ${migrated}`)
console.log(`   ⚠️  Skipped: ${skipped}`)
console.log(`   ❌ Errors: ${errors}`)
