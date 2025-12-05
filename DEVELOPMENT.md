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
│       ├── images/        # Image assets
│       └── product-icons/ # Product/company icons
├── src/
│   ├── components/        # React components (JSX)
│   ├── constants/         # Constants and configuration data
│   ├── content/           # Content files (Markdown/MDX)
│   │   └── docs/          # Documentation content
│   │       ├── blog/      # Blog posts
│   │       ├── docs/      # Documentation pages
│   │       └── policies/  # Policy examples (generated)
│   ├── layouts/           # Astro layout components
│   ├── pages/             # Astro pages (file-based routing)
│   ├── sections/          # Page section components
│   ├── styles/            # Global CSS styles
│   └── content.config.ts  # Content collection configuration
├── render/                # Policy rendering tool (Go)
├── astro.config.mjs       # Astro configuration
├── package.json           # Dependencies and scripts
├── tsconfig.json          # TypeScript configuration
└── Makefile              # Code generation tasks
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

### Code Generation

The project uses a Makefile for generating content:

- `make codegen` - Rebuild all generated code and docs (policies and CLI docs)
- `make codegen-policies` - Generate policy markdown files from the kyverno/policies repository
- `make codegen-cli-docs` - Generate CLI documentation from the kyverno-cli Docker image
- `make verify-codegen` - Verify that all generated code is up to date
- `make help` - Show all available Makefile commands

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

#### Blog Posts

Blog posts are located in `src/content/docs/blog/` and organized by category (e.g., `general/`, `releases/`).

#### Policies

Policy examples are generated from the [kyverno/policies](https://github.com/kyverno/policies) repository. To regenerate them:

```bash
make codegen-policies
```

This requires Go to be installed and will pull the latest policies from the upstream repository.

### Working with Components

#### React Components

React components are located in `src/components/` and `src/sections/`. They use JSX syntax and can be imported in Astro files:

```astro
---
import MyComponent from '../components/MyComponent.jsx';
---

<MyComponent />
```

#### Styling

The project uses Tailwind CSS for styling. You can use Tailwind utility classes directly in components. Global styles are in `src/styles/`.

### Code Generation

#### Generating Policies

Policies are automatically generated from the kyverno/policies repository. To regenerate:

```bash
make codegen-policies
```

This requires:
- Go installed
- Access to the kyverno/policies repository

#### Generating CLI Documentation

CLI documentation is generated from the kyverno-cli Docker image:

```bash
make codegen-cli-docs
```

This requires Docker to be installed and running.

## Testing Your Changes

1. **Visual Testing**: Use the development server to visually inspect your changes
2. **Build Testing**: Run `npm run build` to ensure the site builds without errors
3. **Format Checking**: Run `npm run format:check` to ensure code is properly formatted
4. **Code Generation**: Run `make verify-codegen` to ensure generated content is up to date

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

