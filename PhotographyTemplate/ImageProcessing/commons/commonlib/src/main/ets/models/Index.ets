import { image } from '@kit.ImageKit';

export interface AddressInfo {
  name: string,
  formatAddress: string,
  distance: number
}


// 保存图片信息
export interface ImagePixelMap {
  pixelMap: image.PixelMap;
  width: number;
  height: number;
}


