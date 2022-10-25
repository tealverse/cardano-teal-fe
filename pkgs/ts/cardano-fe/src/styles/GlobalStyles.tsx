import React from 'react';
import { Global } from '@emotion/react';
import tw, { css, GlobalStyles as BaseStyles } from 'twin.macro';

const customStyles = css({
  body: {
    ...tw`antialiased`,
  },
  th: {
    'text-align': 'left',
  },
});

const GlobalStyles = () => (
  <>
    <BaseStyles />
    <Global styles={customStyles} />
  </>
);

export default GlobalStyles;
