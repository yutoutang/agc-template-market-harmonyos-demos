/**
 * 对象代理
 */
export declare class JavaScriptProxy {
  object: object
  name: string
  methodList: Array<string>
  asyncMethodList?: Array<string>
  permission?: string
}