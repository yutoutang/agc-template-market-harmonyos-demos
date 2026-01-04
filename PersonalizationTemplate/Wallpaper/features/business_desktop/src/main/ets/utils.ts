export class CleanData {
  static stringifyTraceObj(data: object): string {
    const renameObKeys = (obj: object): object => {
      if (Array.isArray(obj)) {
        return obj.map(item => renameObKeys(item));
      } else if (typeof obj === 'object' && obj !== null) {
        return Object.keys(obj).reduce((acc, key) => {
          const newKey = key.startsWith('__ob_') ? key.slice(5) : key;
          acc[newKey] = renameObKeys(obj[key]);
          return acc;
        }, {});
      }
      return obj;
    };
    return JSON.stringify(renameObKeys(data))
  }
}