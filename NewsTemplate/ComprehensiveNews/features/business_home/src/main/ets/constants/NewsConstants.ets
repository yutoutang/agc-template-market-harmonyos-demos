import { IButtonItem } from 'lib_widget'

export class Constants {
  public static readonly VIDEO_SIZE_SM_W: number = 160;
  public static readonly VIDEO_SIZE_LG_W: number = 320;
  public static readonly VIDEO_SIZE_SM_H: number = 214;
  public static readonly VIDEO_SIZE_LG_H: number = 428;
}

  export interface KindsList {
  name: string
  id: string
}

export enum NewsSelectType {
  ARTICLE = 'article',
  VIDEO = 'video',
  POST = 'post'
}

export const newsKindsList: KindsList[] = [
  {
    name: '文章',
    id: NewsSelectType.ARTICLE,
  },
  {
    name: '视频',
    id: NewsSelectType.VIDEO,
  },
  {
    name: '动态',
    id: NewsSelectType.POST,
  },
]

export interface PublishNews extends IButtonItem {
  setting: string
}

export enum NewsStyleEnum {
  IMAGE_NONE = 'none',
  IMAGE_SINGLE = 'single',
  IMAGE_THREE = 'three'
}

export const newsStyleList: PublishNews[] = [
  {
    label: '无图',
    id: NewsStyleEnum.IMAGE_NONE,
    setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
  },
  {
    label: '单图',
    id: NewsStyleEnum.IMAGE_SINGLE,
    setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
  },
  {
    label: '三图',
    id: NewsStyleEnum.IMAGE_THREE,
    setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
  },
]

export const videoSetting =
  '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}'

