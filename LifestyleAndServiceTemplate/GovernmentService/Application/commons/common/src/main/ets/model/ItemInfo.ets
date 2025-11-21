import { Type } from '@kit.ArkUI'

export class ItemInfo {
  pic: string = ''
  name: string = ''
}

@ObservedV2
export class MineItemList {
  @Type(ItemInfo)
  @Trace itemInfoList:ItemInfo[] = []
}

export interface SwiperInfo {
  title: string
  footer: string
  thumbnailsJson: Array<string>
}