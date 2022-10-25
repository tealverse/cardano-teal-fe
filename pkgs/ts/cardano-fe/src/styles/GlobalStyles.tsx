import React from 'react';
import { Global } from '@emotion/react';
import tw, { css, GlobalStyles as BaseStyles } from 'twin.macro';

const customStyles = css({
  body: {
    ...tw`antialiased`,
    color: 'white',
    boxSizing: 'border-box',
  },
  th: {
    textAlign: 'left',
    padding: '0.25rem 0.5rem',
  },
  td: {
    padding: '0.25rem 0.5rem',
  },
});

const GlobalStyles = () => (
  <>
    <BaseStyles />
    <Global styles={customStyles} />
  </>
);

export default GlobalStyles;
