module.exports = {
  // calc(1 + 1)
  calcFunction: /(^|\s|\(|,)calc\((([^()]*(\([^()]*\))?)*)\)/,

  // rgb(0, 0, 0), hsl(0, 0%, 0%), rgba(0, 0, 0, 1), hsla(0, 0%, 0%, 1)
  colorFunction: /(^|\s|\(|,)((?:rgb|hsl)a?\(.*?\))/gi,

  // #000, #000000
  colorHex: /(^|\s|\(|,)#([0-9a-f])([0-9a-f])([0-9a-f])([0-9a-f])([0-9a-f])([0-9a-f])/gi,

  // rgba(0,0,0,0)
  colorTransparent: /(^|\s|\(|,)rgba\(0,0,0,0\)/gi,

  // 0.1
  decimalWithZeros: /(^|\s|\(|,)(-)?0*([1-9]\d*)?\.(\d*[1-9])0*/g,

  // (top: 0)
  declInParentheses: /\(([-a-zA-Z]+):(([^()]*(\([^()]*\))?)*)\)/g,

  // font-style, font-stretch, font-variant, font-feature-settings
  descriptorFontFace: /^font-(style|stretch|variant|feature-settings)$/i,

  // 0
  number: /\d/,

  // 01
  numberLeadingZeros: /(^|\s|\(|,)0+([1-9]\d*(\.\d+)?)/g,

  // margin, padding, border-color, border-radius, border-spacing, border-style, border-width
  propertyMultipleValues: /^(margin|padding|border-(color|radius|spacing|style|width))$/i,

  // "...", '...'
  quotedString: /("|')?(.*)\1/,

  // [class = "foo"], [class ~= "foo"], [class |= "foo"], [class ^= "foo"], [class $= "foo"], [class *= "foo"]
  selectorAtt: /\[\s*(.*?)(?:\s*([~|^$*]?=)\s*(("|').*\4|.*?[^\\]))?\s*\]/g,

  // :lang(ja), :nth-child(0), nth-last-child(0), nth-of-type(1n), nth-last-of-type(1n)
  selectorFunctions: /:(lang|nth-(?:last-)?(?:child|of-type))\((.*?[^\\])\)/gi,

  // :not(a)
  selectorNegationFunction: /:not\((([^()]*(\([^()]*\))?)*)\)/gi,

  // p > a, p + a, p ~ a
  selectorCombinators: /\s*(\\?[>+~])\s*/g,

  // )and, )or
  supportsConjunctions: /\)(and|or)/g,

  // u0-10ffff, u000000-10ffff
  unicodeRangeDefault: /u\+0{1,6}-10ffff/i,

  // url(a)
  urlFunction: /(^|\s|\(|,)url\((.*?[^\\])\)/gi,

  //  , (, ), ", '
  urlNeedQuote: /[\s()"']/,

  //  , \t, \r, \n
  whiteSpaces: /\s+/g,

  // 0%, 0em, 0ex, 0ch, 0rem, 0vw, 0vh, 0vmin, 0vmax, 0cm, 0mm, 0in, 0pt, 0pc, 0px
  zeroValueUnit: /(^|\s|\(|,)(0)(%|em|ex|ch|rem|vw|vh|vmin|vmax|cm|mm|in|pt|pc|px)/gi
};
