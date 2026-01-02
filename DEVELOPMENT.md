# Development Guide

This guide will help you get started with developing the Kyverno website. It covers setup, project structure, common tasks, and development workflows.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** v24 or higher ([Download](https://nodejs.org/))
- **npm** package manager
- **Git** for version control
- **Docker** (optional, for generating CLI documentation)

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/kyverno/website.git
cd website
```

If you're contributing, you should fork the repository first and clone your fork:

```bash
git clone https://github.com/YOUR-GITHUB-ID/website.git
cd website
```

### 2. Install Dependencies

We're using NPM as dependency manager

```bash
npm install
```

### 3. Start the Development Server

```bash
npm run dev
```

The development server will start at `http://localhost:4321`. The site will automatically reload when you make changes to source files.

## Project Structure

```
.
├── public/                 # Static assets (images, favicons, etc.)
│   └── assets/
│       ├── images/           # Image assets
│       └── product-icons/    # Product/company icons
├── src/
│   ├── components/           # React components (JSX)
│   ├── constants/            # Constants and configuration data
│   ├── content/              # Content files (Markdown/MDX)
│   │   └── docs/             # Documentation content
│   │       ├── blog/         # Blog posts
│   │       ├── docs/         # Documentation pages
│   │       └── policies/     # Policy examples (generated)
│   ├── layouts/              # Astro layout components
│   ├── pages/                # Astro pages (file-based routing)
│   ├── sections/             # Page section components
│   ├── styles/               # Global CSS styles
│   └── content.config.ts     # Content collection configuration
├── scripts/                  # Development scripts and tools
│   ├── render-policies.ts    # Policy rendering tool (TypeScript)
│   └── codegen-cli-docs.sh   # CLI documentation generator
├── astro.config.mjs          # Astro configuration
├── package.json              # Dependencies and scripts
└── tsconfig.json             # TypeScript configuration
```

## Available Commands

### Development

- `npm run dev` - Start the development server at `localhost:4321`
- `npm run start` - Alias for `dev` command

### Building

- `npm run build` - Build the production site to `./dist/`
- `npm run preview` - Preview the production build locally

### Code Quality

- `npm run format:check` - Check code formatting with Prettier
- `npm run format:write` - Format code with Prettier
- `npm run check:links` - Validate all internal and external links in the documentation

### Code Generation

The project uses npm scripts for generating content:

- `npm run codegen:policies` - Generate policy markdown files from the kyverno/policies repository
- `npm run codegen:cli-docs` - Generate CLI documentation from the kyverno-cli Docker image

You can also run both in sequence:

```bash
npm run codegen:policies && npm run codegen:cli-docs
```

## Technologies & Tools

This website is built with:

- **[Astro](https://astro.build/)** - Static site generator
- **[Starlight](https://starlight.astro.build/)** - Documentation theme for Astro
- **[React](https://react.dev/)** - UI library (via `@astrojs/react`)
- **[Tailwind CSS](https://tailwindcss.com/)** - Utility-first CSS framework
- **[Framer Motion](https://www.framer.com/motion/)** - Animation library
- **[Lucide React](https://lucide.dev/)** - Icon library
- **[Prettier](https://prettier.io/)** - Code formatter
- **[Husky](https://typicode.github.io/husky/)** - Git hooks

## Development Workflow

### Making Changes

1. **Create a branch** for your changes:

   ```bash
   git checkout -b your-feature-branch
   ```

2. **Make your changes** to the relevant files:
   - React components: `src/components/` or `src/sections/`
   - Content: `src/content/docs/`
   - Styles: `src/styles/`
   - Pages: `src/pages/`

3. **Preview your changes**:

   ```bash
   npm run dev
   ```

   Visit `http://localhost:4321` to see your changes.

4. **Format your code**:

   ```bash
   npm run format:write
   ```

5. **Test the production build**:
   ```bash
   npm run build
   npm run preview
   ```

### Working with Content

#### Documentation Pages

Documentation pages are written in Markdown (`.md`) or MDX (`.mdx`) and located in `src/content/docs/docs/`. The sidebar is automatically generated from the directory structure as configured in `astro.config.mjs`.

**Link Formatting Guidelines:**

- **Use absolute paths** for internal documentation links (e.g., `/docs/policy-types/cluster-policy/validate`)
- **Avoid relative links** (e.g., `../validate.md` or `./validate.md`) as they can break when pages are moved or reorganized
- **Remove file extensions** from links (use `/docs/path/to/page` instead of `/docs/path/to/page.md`)
- **Use anchor links** for specific sections (e.g., `/docs/policy-types/cluster-policy/validate#anchors`)

**Examples:**

✅ **Good:**

```markdown
[Validate Policy](/docs/policy-types/cluster-policy/validate)
[Installation Guide](/docs/installation#methods)
```

❌ **Bad:**

```markdown
[Validate Policy](../validate.md)
[Installation Guide](./installation/methods.md#methods)
```

#### Blog Posts

Blog posts are located in `src/content/docs/blog/` and organized by category (e.g., `general/`, `releases/`).

#### Policies

Policy examples are generated from the [kyverno/policies](https://github.com/kyverno/policies) repository. To regenerate them:

```bash
npm run codegen:policies
```

This will:

1. Clone the kyverno/policies repository (shallow clone, single branch)
2. Find all YAML policy files recursively
3. Extract metadata from policy annotations
4. Generate markdown files with frontmatter and full YAML content
5. Preserve the directory structure from the source repository

The generated files are placed in `src/content/policies/`. The script uses TypeScript and requires Node.js v24+.

### Working with Components

#### React Components

React components are located in `src/components/` and `src/sections/`. They use JSX syntax and can be imported in Astro files:

```astro
---
import MyComponent from '../components/MyComponent.jsx'
---

<MyComponent />
```

#### Styling

The project uses Tailwind CSS for styling. You can use Tailwind utility classes directly in components. Global styles are in `src/styles/`.

### Code Generation

The website includes automatically generated content that should be regenerated when upstream sources change.

#### Generating Policies

Policy documentation is generated from the [kyverno/policies](https://github.com/kyverno/policies) repository. The TypeScript script (`scripts/render-policies.ts`) fetches policies and converts them to markdown format.

**Usage:**

Default (uses kyverno/policies repository):

```bash
npm run codegen:policies
```

Custom repository and output directory:

```bash
npm run codegen:policies -- <repo-url> <output-dir>
```

**Example with custom arguments:**

```bash
npm run codegen:policies -- https://github.com/kyverno/policies/main ./src/content/policies/
```

**What it does:**

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

**Output format:**
Each generated markdown file includes:

- Frontmatter with policy metadata (title, category, version, subject, policyType, description)
- A link to the raw YAML file on GitHub
- The complete policy YAML in a code block

**Requirements:**

- Node.js v24 or higher
- Dependencies installed (`npm install`)
- Git (for cloning repositories)

#### Generating CLI Documentation

CLI documentation is generated from the kyverno-cli Docker image:

```bash
npm run codegen:cli-docs
```

This script:

1. Removes existing CLI documentation files
2. Runs the kyverno-cli Docker container to generate documentation
3. Outputs markdown files to `src/content/docs/docs/kyverno-cli/reference/`

**Requirements:**

- Docker installed and running
- Access to pull `ghcr.io/kyverno/kyverno-cli` image

#### Verifying Generated Content

Before committing changes, ensure generated content is up to date. You can verify by:

1. Running the codegen scripts:

   ```bash
   npm run codegen:policies
   npm run codegen:cli-docs
   ```

2. Checking git status to see if any files changed:

   ```bash
   git status
   ```

3. If files changed, commit them along with your changes

**Note:** Generated content should be committed to the repository so the website can be built without requiring codegen steps during deployment.

## Testing Your Changes

1. **Visual Testing**: Use the development server to visually inspect your changes
2. **Build Testing**: Run `npm run build` to ensure the site builds without errors
3. **Format Checking**: Run `npm run format:check` to ensure code is properly formatted
4. **Link Checking**: Run `npm run check:links` to validate all links in the documentation (both internal and external)
5. **Code Generation**: Run `npm run codegen:policies` and `npm run codegen:cli-docs` to ensure generated content is up to date, then check `git status` for any changes

### Link Validation

The `check:links` command validates all links in the documentation to ensure they are correct and accessible. This is especially important when:

- Adding new documentation pages
- Moving or renaming existing pages
- Updating links between pages
- Fixing broken links

**Usage:**

```bash
npm run check:links
```

This command will:

- Build the site with link validation enabled
- Check all internal documentation links
- Verify external links are accessible
- Report any broken or invalid links

**Note:** The link checker will fail the build if any broken links are found. Fix any reported issues before committing your changes. The link checker uses the [Starlight Links Validator](https://starlight.astro.build/guides/validation/#link-validation) plugin.

## Common Tasks

### Adding a New Component

1. Create a new file in `src/components/` (e.g., `MyComponent.jsx`)
2. Write your React component
3. Import and use it in your pages or layouts

### Adding a New Documentation Page

1. Create a new `.md` or `.mdx` file in the appropriate directory under `src/content/docs/docs/`
2. The sidebar will automatically include it based on the directory structure
3. Use frontmatter to configure the page:

```markdown
---
title: My Page Title
description: Page description
---
```

### Modifying the Sidebar

Edit `astro.config.mjs` and modify the `sidebar` configuration in the Starlight config.

### Adding Styles

- Use Tailwind utility classes directly in components
- Add global styles to `src/styles/global.css` or `src/styles/custom.css`

## Git Hooks

The project uses Husky for git hooks. The `prepare` script automatically sets up git hooks when you run `npm install`. These hooks help ensure code quality before commits.

## Deployment

The site is deployed to [Netlify](https://www.netlify.com/). The build command is `npm run build`, and the publish directory is `dist/`.

## Getting Help

- **Documentation**: See [README.md](./README.md) and [CONTRIBUTING.md](./CONTRIBUTING.md)
- **Issues**: Report issues on [GitHub Issues](https://github.com/kyverno/website/issues)
- **Community**: Join the [Kyverno Slack](https://slack.k8s.io/#kyverno) or [CNCF Slack](https://cloud-native.slack.com/#kyverno)
- **Meetings**: See [Community Meetings](https://kyverno.io/community/#meetings)

## Additional Resources

- [Astro Documentation](https://docs.astro.build/)
- [Starlight Documentation](https://starlight.astro.build/)
- [React Documentation](https://react.dev/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
