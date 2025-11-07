export class PhotoFrameModel {
  image?: Resource
  background?: Resource

  constructor( background: Resource, image: Resource) {
    this.image = image
    this.background = background
  }
}