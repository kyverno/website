#!/usr/bin/env bash

rm -rf ./src/content/docs/docs/kyverno-cli/reference/kyverno*.md
docker run --user root -v ${PWD}:/work --rm ghcr.io/kyverno/kyverno-cli docs	\
  --autogenTag=false															\
  --website																	\
  --noDate																	\
  --markdownLinks																\
  --output "/work/src/content/docs/docs/kyverno-cli/reference"

# Update all markdown links to absolute /docs/... paths in the generated MD files
find ./src/content/docs/docs/kyverno-cli/reference/ -name '*.md' | while read -r file; do
  # Remove .md extension from absolute /docs/ links
  sed -i 's|](/docs/\([^)]*\)\.md)|](/docs/\1)|g' "$file"
  
  # Convert relative links ](../... to absolute ](/docs/kyverno-cli/reference/...
  sed -i 's|](\.\./\([^)]*\))|](/docs/kyverno-cli/reference/\1)|g' "$file"
  
  # Convert relative links ](./docs/... or ](docs/... to absolute ](/docs/...
  sed -i 's|](\./docs/\([^)]*\)\.md)|](/docs/\1)|g' "$file"
  sed -i 's|](\./docs/\([^)]*\))|](/docs/\1)|g' "$file"
  sed -i 's|](docs/\([^)]*\)\.md)|](/docs/\1)|g' "$file"
  sed -i 's|](docs/\([^)]*\))|](/docs/\1)|g' "$file"
  
  # Convert local file references (e.g., ](kyverno.md) to absolute paths
  # Convert ](kyverno*.md) to ](/docs/kyverno-cli/reference/kyverno*) (without .md extension)
  sed -i 's|](\(kyverno[^)]*\)\.md)|](/docs/kyverno-cli/reference/\1)|g' "$file"
done