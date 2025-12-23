import React, { useState } from 'react'

export default function Feedback() {
  const [messageType, setMessageType] = useState(null)

  const handleFeedback = (isHelpful) => {
    if (messageType) return
    setMessageType(isHelpful ? 'positive' : 'negative')
  }

  const containerStyle = {
    fontFamily: 'sans-serif',
    marginTop: '3rem',
    borderTop: '1px solid #444',
    paddingTop: '1.5rem',
  }

  const buttonsWrapper = {
    display: 'flex',
    flexDirection: 'row',
    alignItems: 'center',
    gap: '12px',
    marginTop: '16px',
  }

  const buttonStyle = (disabled) => ({
    width: '90px',
    height: '40px',
    backgroundColor: '#4c8fd6',
    color: '#fff',
    border: 'none',
    borderRadius: '6px',
    fontSize: '16px',
    fontWeight: '500',
    cursor: disabled ? 'default' : 'pointer',
    opacity: disabled ? 0.7 : 1,
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    margin: '0',
    padding: '0',
  })

  return (
    <div style={containerStyle}>
      <h2 style={{ fontSize: '24px', fontWeight: 'bold', margin: '0 0 8px 0' }}>
        Feedback
      </h2>

      <p style={{ margin: '0 0 16px 0' }}>Was this page helpful?</p>

      <div style={buttonsWrapper}>
        <button
          style={buttonStyle(!!messageType)}
          disabled={!!messageType}
          onClick={() => handleFeedback(true)}
        >
          Yes
        </button>

        <button
          style={buttonStyle(!!messageType)}
          disabled={!!messageType}
          onClick={() => handleFeedback(false)}
        >
          No
        </button>
      </div>

      {messageType && (
        <p style={{ marginTop: '20px' }}>
          {messageType === 'positive'
            ? 'Glad to hear it! '
            : 'Sorry to hear that. '}
          Please{' '}
          <a
            href="https://github.com/kyverno/website/issues/new/choose"
            target="_blank"
            style={{ color: '#4c8fd6', textDecoration: 'underline' }}
          >
            tell us how we can improve
          </a>
          .
        </p>
      )}
    </div>
  )
}
