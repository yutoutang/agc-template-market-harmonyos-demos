export const transformLayout =
  (style: Record<string, string | number>) => {
    let result: Record<string, string | number> = {}
    if (!style) {
      return result
    }
    Object.keys(style).forEach(key => {
      switch (key) {
        case 'padding-left':
          result.paddingLeft = style[key]
          break;
        case 'padding-right':
          result.paddingRight = style[key]
          break
        case 'padding-top':
          result.paddingTop = style[key]
          break
        case 'padding-bottom':
          result.paddingBottom = style[key]
          break
        case 'margin-top':
          result.marginTop = style[key]
          break
        case 'border-radius':
          result.borderRadius = style[key]
          break
      }
    })
    return result
  }

