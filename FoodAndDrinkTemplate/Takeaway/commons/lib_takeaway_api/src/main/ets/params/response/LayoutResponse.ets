import { StoreResponse } from './StoreResponse'

@ObservedV2
export class RequestStoreListData {
  @Trace articles: StoreResponse[] = []
}

export class LayoutSetting {
  type: string = ''
  style: Record<string, string | number> = {}
  showType: string = ''
  children: LayoutSetting[] = []
}

export class LayoutStyle {
  backgroundColor: string = ''
  borderRadius: number = 0
  space: number = 0
  paddingLeft: number | string = 0
  paddingRight: number | string = 0
  paddingBottom: number | string = 0
  paddingTop: number | string = 0
}
