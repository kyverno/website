import React from 'react';
import PropTypes from 'prop-types';

export const HeaderContent = ({
  headingText, 
  paragraphText, 
  variant = 'default',  
  headerLevel,
  colors = ['white', 'blue', 'orange' ],
  ...restProps
}) => {

  const HeaderTag = headerLevel;

  const getVariantClasses = (type) => {
    switch(variant) {
      case 'level1':
        return type === 'header'? `w-full text-5xl px-2 sm:text-[52px] md:text-6xl font-bold tracking-wide text-primary-100 
                capitalize leading-12 sm:leading-16` : 'text-[1.2rem] sm:text-lg max-w-80 sm:max-w-150 leading-6 text-white/80';
          
      case 'level2': 
        return type === 'header'? "text-4xl font-bold tracking-wide capitalize text-center"
                        : 'text-[1rem] sm:text-lg max-w-80 sm:max-w-150 leading-6 text-white/80';

      case 'level3': 
        return type === 'header'? "text-3xl sm:text-3xl font-bold tracking-wide capitalize text-center"
                        : 'text-[0.8rem] sm:text-lg max-w-80 sm:max-w-150 leading-6 text-white/80';
                        
     }
  }

  const processHeading = (text) => {
    const words = text.split(' ');
    return words.map((word, index) => (
      <span key={index} style={{ color: index % 2 !== 0 ? colors[0] : colors[1] }}>
        {word}{' '}
      </span>
    ));
  };

  return (
        <div className={`section-heading ${variant}`}>
          <HeaderTag className={`header-style ${getVariantClasses('header')}`}>
            {processHeading(headingText)}
          </HeaderTag>
          <p className={`paragraph-style ${getVariantClasses('paragraph')}`}>
            {paragraphText}
          </p>
      </div>

  )
}


HeaderContent.propTypes = {
  headerText: PropTypes.string.isRequired,
  paragraphText: PropTypes.string.isRequired,
  headerLevel: PropTypes.oneOf['h1', 'h2', 'h3', 'h4', 'h5', 'h6'],
  variant: PropTypes.oneOf(['default', 'primary', 'secondary', 'highlight'])
}