#!/usr/bin/env bash

rm -rf ./src/content/docs/docs/kyverno-cli/reference/kyverno*.md
docker run --user root -v ${PWD}:/work --rm ghcr.io/kyverno/kyverno-cli docs	\
  --autogenTag=false															\
  --website																	\
  --noDate																	\
  --markdownLinks																\
  --output "/work/src/content/docs/docs/kyverno-cli/reference"

# Function to run sed in-place (handles macOS vs Linux differences)
sed_in_place() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i'' "$@"
  else
    sed -i "$@"
  fi
}

# Update all markdown links to absolute /docs/... paths in the generated MD files
find ./src/content/docs/docs/kyverno-cli/reference/ -name '*.md' | while read -r file; do
  # Remove .md extension from absolute /docs/ links
  sed_in_place 's|](/docs/\([^)]*\)\.md)|](/docs/\1)|g' "$file"
  
  # Convert relative links ](../... to absolute ](/docs/kyverno-cli/reference/...
  sed_in_place 's|](\.\./\([^)]*\))|](/docs/kyverno-cli/reference/\1)|g' "$file"
  
  # Convert relative links ](./docs/... or ](docs/... to absolute ](/docs/...
  sed_in_place 's|](\./docs/\([^)]*\)\.md)|](/docs/\1)|g' "$file"
  sed_in_place 's|](\./docs/\([^)]*\))|](/docs/\1)|g' "$file"
  sed_in_place 's|](docs/\([^)]*\)\.md)|](/docs/\1)|g' "$file"
  sed_in_place 's|](docs/\([^)]*\))|](/docs/\1)|g' "$file"
  
  # Convert local file references (e.g., ](kyverno.md) to absolute paths
  # Match any relative markdown link that doesn't start with /, ./, ../, or http
  # This catches patterns like ](kyverno.md), ](kyverno_apply.md), etc.
  # Pattern: ](filename.md) where filename starts with a word character and doesn't contain ://
  sed_in_place 's|](\([a-zA-Z0-9_][^:)]*\)\.md)|](/docs/kyverno-cli/reference/\1)|g' "$file"
  
  # Convert external https://kyverno.io/docs/... links to relative /docs/... links
  # Convert https://kyverno.io/docs/kyverno-cli/usage/apply/ to /docs/kyverno-cli/reference/kyverno_apply
  sed_in_place 's|https://kyverno.io/docs/kyverno-cli/usage/apply/|/docs/kyverno-cli/reference/kyverno_apply|g' "$file"
  sed_in_place 's|https://kyverno.io/docs/kyverno-cli/usage/jp/|/docs/kyverno-cli/reference/kyverno_jp|g' "$file"
  sed_in_place 's|https://kyverno.io/docs/kyverno-cli/usage/test/|/docs/kyverno-cli/reference/kyverno_test|g' "$file"
  # Convert https://kyverno.io/docs/kyverno-cli (with optional hash) to /docs/subprojects/kyverno-cli
  # Use extended regex (-E) for the optional group
  sed_in_place -E 's|https://kyverno.io/docs/kyverno-cli(#.*)?|/docs/subprojects/kyverno-cli\1|g' "$file"
  
  # Remove "For more information visit..." lines
  sed_in_place '/^[[:space:]]*For more information visit/d' "$file"
done