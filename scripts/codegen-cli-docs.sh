#!/usr/bin/env bash
set -euo pipefail

# Determine the kyverno-cli image tag:
# - If positional arg is provided: use it directly as the distant repo tag (no transformation)
# - Otherwise (auto mode): derive from WEBSITE_BRANCH or current git branch, then map:
#   - release-x-y or release-x-y-z  -> release-x.y
#   - anything else                 -> latest
if [[ -n "${1:-}" ]]; then
  CLI_REF="$1"
  echo "Using kyverno-cli image tag: ${CLI_REF} (from positional argument)"
else
  branch_name="${WEBSITE_BRANCH:-}"
  if [[ -z "${branch_name}" ]]; then
    if git rev-parse --abbrev-ref HEAD >/dev/null 2>&1; then
      branch_name="$(git rev-parse --abbrev-ref HEAD)"
    else
      branch_name="main"
    fi
  fi

  if [[ "$branch_name" =~ ^release-([0-9]+)-([0-9]+)(-[0-9]+)?$ ]]; then
    CLI_REF="release-${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
  else
    CLI_REF="latest"
  fi

  echo "Using website branch: ${branch_name}"
  echo "Using kyverno-cli image tag: ${CLI_REF}"
fi
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