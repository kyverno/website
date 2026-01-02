import { component, defineMarkdocConfig } from '@astrojs/markdoc/config'

import starlightMarkdoc from '@astrojs/starlight-markdoc'

export default defineMarkdocConfig({
  extends: [starlightMarkdoc()],
  tags: {
    'feature-state': {
      render: component('./src/components/FeatureState.astro'),
      selfClosing: true,
      attributes: {
        state: { type: String, required: false },
        version: { type: String, required: false },
      },
    },
  },
})
