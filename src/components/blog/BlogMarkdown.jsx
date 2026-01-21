import PropTypes from 'prop-types'
import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'

export const BlogMarkdown = ({ content }) => {
  return (
    <div className="prose prose-lg max-w-none blog-content">
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        components={{
          // Custom image component to handle relative paths
          img: ({ node, ...props }) => {
            return <img {...props} alt={props.alt || ''} />
          },
        }}
      >
        {content}
      </ReactMarkdown>
    </div>
  )
}

BlogMarkdown.propTypes = {
  content: PropTypes.string.isRequired,
}
