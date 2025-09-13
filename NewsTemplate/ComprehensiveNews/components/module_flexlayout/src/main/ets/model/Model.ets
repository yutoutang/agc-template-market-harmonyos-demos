import { NodeControllerFactory } from '../factory/NativeNodeFactory'

export class LayoutSetting {
  type: string = ''
  style: Record<string, string | number> = {}
  showType: string = ''
  children: LayoutSetting[] = []
}

export class FrameNodeParams {
  viewLayout: LayoutSetting
  articles: JSONObject[]
  extraInfo?: Record<string, number | string | boolean | Record<string, string | boolean>[]>
  style: Record<string, string | number>
  nodeControllerFactory?: NodeControllerFactory

  constructor(viewLayout: LayoutSetting, articles: JSONObject[], style: Record<string, string | number>,
    extraInfo?: Record<string, number | string | boolean | Record<string, string | boolean>[]>,
    nodeControllerFactory?: NodeControllerFactory) {
    this.viewLayout = viewLayout
    this.articles = articles
    this.style = style
    this.extraInfo = extraInfo
    this.nodeControllerFactory = nodeControllerFactory
  }
}


export class LayoutParams {
  nativeCardData: JSONObject
  currentIndex: number = 0
  extraInfo: Record<string, string | boolean | Record<string, string | boolean>[] | JSONObject[]> = {}
  layout: LayoutSetting = new LayoutSetting()

  constructor(nativeCardData: JSONObject, currentIndex: number,
    extraInfo: Record<string, string | boolean | Record<string, string | boolean>[]>, layout: LayoutSetting) {
    this.nativeCardData = nativeCardData
    this.currentIndex = currentIndex
    this.extraInfo = extraInfo
    this.layout = layout
  }
}

/**
 * 断点名称
 */
export enum BreakpointNameEnum {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
  XL = 'xl',
}

/**
 * 栅格断点
 */
@ObservedV2
export class BreakpointModel {
  @Trace currentBreakpoint: BreakpointNameEnum = BreakpointNameEnum.SM;
}

export type JSONObject = ESObject;