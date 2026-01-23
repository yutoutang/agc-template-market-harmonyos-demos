import { CanvasTextItem } from './BeautificationParam';
import ImageModel from './ImageModel';


export class DrawPathPointModel {
  x: number = 0;
  y: number = 0;
}



export interface TextEditDialogParams {
  cloneText: string
  canvasItemStack: CanvasTextItem
  close: Function
}

export class DisPlaySize {
  width: number = 0;
  height: number = 0;
}

@ObservedV2
export class ImageVM {
  @Trace id: string = ''
  @Trace src: string = ''
  @Trace x: number = 0
  @Trace y: number = 0
  @Trace width: number = 100
  @Trace height: number = 100
  @Trace scale: number = 1
  @Trace rotate: number = 0

  updateFromModel(model: ImageModel) {
    this.id = model.id
    this.src = model.src
    this.x = model.x
    this.y = model.y
    this.width = model.width
    this.height = model.height
    this.scale = model.scale
    this.rotate = model.rotate
  }
}



@ObservedV2
export class FilterEdit {
  @Trace isEdit: boolean = true;
}




export interface MosaicInfo{
  icon:ResourceStr,
  mosaicSource:string,
  isVip:boolean
}
