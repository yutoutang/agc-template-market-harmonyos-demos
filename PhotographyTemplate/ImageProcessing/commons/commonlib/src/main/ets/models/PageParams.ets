export interface ImageShowModel {
  imageSource: Resource
  text: string
  isVip?: boolean
  needDownload?: boolean
}



export interface BeautyParam {
  uris: string[]
  barIndex: number;
}



export interface DraftModel {
  id:string
  uri: string
  updateTime: string
}

export interface StickerShowModel extends ImageShowModel {
  tag: string[]
}

export interface ScrawShowModel {
  imageSource: Resource
  text: string
  isVip?: boolean
  color: string;
  fontSize: number;
  opacity: number;
  rotation: number;
  type: string;
  typeName: string;
  index:number;
  tag: string[]
}

export interface MosaicShowModel {
  imageSource: Resource
  text: string
  isVip?: boolean
  color: string;
  fontSize: number;
  opacity: number;
  rotation: number;
  type: string;
  typeName: string;
  index:number;
  tag: string[]
}

export interface WaterMarkShowModel {
  imageSource?: Resource|PixelMap
  waterMarkMessages?: string[]
  text: string
  isVip?: boolean
  isShowLocationSheet?: boolean
  color: string;
  fontSize: number;
  opacity: number;
  rotation: number;
  type: string;
  typeName: string;
  index:number;
  tag: string[]
}


export interface MyPosition {
  x: number;
  y: number;
  width?: number;
  height?: number;
}