export interface LutModel {
  id: string,
  lut: Resource,
  icon:ResourceStr,
  label:string,
  isVip: boolean
}


export interface BeautyParam {
  uris: string[]
  barIndex: number;
  filterName?: string;
  pixelMap?: PixelMap
}