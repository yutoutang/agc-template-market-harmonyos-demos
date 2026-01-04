export class FormaterUtils {
  static formatCount(count: number): string {
    if (count > 999) {
      return '999+'
    }
    return count.toString()
  }

  static formatDeplete(deplete: number): string {
    if (deplete > 9999) {
      return `${(deplete / 10000).toFixed(1)}万`
    }
    return deplete.toString()
  }
}