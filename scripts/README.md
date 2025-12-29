# Development Scripts

This directory contains development scripts and tools for generating content and maintaining the website.

## Scripts Overview

- **`render-policies.ts`** - TypeScript tool for generating policy documentation from GitHub repositories
- **`codegen-cli-docs.sh`** - Bash script for generating CLI documentation from Docker images

## Policy Render Tool (`render-policies.ts`)

This TypeScript tool fetches Kyverno policies from a GitHub repository and generates markdown documentation files for the website.

### Usage

**Via npm script (recommended):**

```bash
npm run codegen:policies
```

**With custom arguments:**

```bash
npm run codegen:policies -- <repo-url> <output-dir>
```

**Example:**

```bash
npm run codegen:policies -- https://github.com/kyverno/policies/main ./src/content/policies/
```

**Direct execution:**

```bash
tsx scripts/render-policies.ts https://github.com/kyverno/policies/main ./src/content/policies/
```

### How it works

1. Clones the specified GitHub repository (shallow clone, single branch)
2. Recursively finds all YAML policy files (`.yaml` or `.yml`)
3. Extracts metadata from policy annotations:
   - `policies.kyverno.io/title`
   - `policies.kyverno.io/category`
   - `policies.kyverno.io/minversion`
   - `policies.kyverno.io/subject`
   - `policies.kyverno.io/description`
4. Determines policy type (`validate`, `mutate`, or `generate`) from the spec
5. Generates markdown files with frontmatter and full YAML content
6. Preserves the directory structure from the source repository

### Output Format

Each generated markdown file includes:

- Frontmatter with policy metadata (title, category, version, subject, policyType, description)
- A link to the raw YAML file on GitHub
- The complete policy YAML in a code block

### Dependencies

- `js-yaml` - YAML parsing
- `simple-git` - Git operations
- `tsx` - TypeScript execution

### Requirements

- Node.js v24 or higher
- Git (for cloning repositories)

---

## CLI Documentation Generator (`codegen-cli-docs.sh`)

This bash script generates CLI documentation by running the kyverno-cli Docker container and extracting documentation.

### Usage

**Via npm script (recommended):**

```bash
npm run codegen:cli-docs
```

**Direct execution:**

```bash
./scripts/codegen-cli-docs.sh
```

### How it works

1. Removes existing CLI documentation files from `src/content/docs/docs/kyverno-cli/reference/`
2. Runs the `ghcr.io/kyverno/kyverno-cli` Docker container
3. Generates markdown documentation files with the following options:
   - `--autogenTag=false` - Disables auto-generated tags
   - `--website` - Formats output for website
   - `--noDate` - Omits dates from generated files
   - `--markdownLinks` - Uses markdown link format
4. Outputs files to `src/content/docs/docs/kyverno-cli/reference/`

### Requirements

- Docker installed and running
- Access to pull `ghcr.io/kyverno/kyverno-cli` image

---

## Running All Code Generation

To regenerate all generated content:

```bash
npm run codegen:policies
npm run codegen:cli-docs
```

Or run both in sequence:

```bash
npm run codegen:policies && npm run codegen:cli-docs
```

## See Also

For more information about code generation, see [DEVELOPMENT.md](../DEVELOPMENT.md#code-generation).
