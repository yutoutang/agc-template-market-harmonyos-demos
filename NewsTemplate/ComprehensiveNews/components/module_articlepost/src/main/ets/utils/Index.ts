export function callTarget<T>(func: () => void, target: any, ...args): T {
  return func.call(target, ...args) as T
}

export function invokeTo(target: object, func: () => void, ...args: any[]): object {
  return func.call(target, ...args)
}

export function bindTo(func: () => void, target: any):() => void {
  return func?.bind(target) ?? func
}

export function bindWith(source: object, target: object, map: Record<string, string>):() => void {
  if (!source || !target || !map) {
    return
  }
  let keys = Object.keys(map)
  if (keys?.length) {
    let originalMap: Map<string, () => void> = new Map()
    keys.forEach(key => {
      let value = map[key]
      if (key && value && typeof source[key] === 'function' && typeof target[value] === 'function') {
        originalMap[value] = target[value]
        target[value] = source[key].bind(source)
      }
    })
    originalMap.forEach((value, key) => {
      target[key] = value
    })
  }
}