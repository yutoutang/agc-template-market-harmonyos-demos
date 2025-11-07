import { LayoutTemplateModel } from './LayoutTemplateModel'
import PosterTemplateModel from './PosterTemplateModel'
import FreeCollageModel from './FreeCollageModel'
import ImageModel from './ImageModel'

export type CollageMode = 'fixed' | 'poster' | 'free' | 'join'

export default class CollageModel {
  mode: CollageMode = 'fixed'

  // 各模式独立管理图片
  fixedImages: ImageModel[] = []
  posterImages: ImageModel[] = []
  freeImages: ImageModel[] = []

  layout?: LayoutTemplateModel
  poster?: PosterTemplateModel
  free?: FreeCollageModel
}
