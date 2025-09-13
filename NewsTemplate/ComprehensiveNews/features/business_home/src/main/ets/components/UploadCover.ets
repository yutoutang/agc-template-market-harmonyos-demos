import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { MediaUtils } from 'lib_common'

@ComponentV2
export struct UploadCover {
  @Param coverUri: string = ''
  @Local maxSelectNumber: number = 1
  @Event onSelected: (uri: string) => void = () => {
  }
  @Event onDeleteUri: (uri: string) => void = () => {
  }

  build() {
    Column() {
      if (this.coverUri) {
        Stack() {
          Column() {
            Image(this.coverUri)
              .objectFit(ImageFit.Fill)
          }
          .clip(true)
          .borderRadius(8)
          Image($r('app.media.ic_public_close_circle'))
            .width(24)
            .height(24)
            .fillColor($r('sys.color.font_primary'))
            .position({ right: -8, top: -8 })
            .onClick(() => {
              this.onDeleteUri(this.coverUri)
            })
        }
      } else {
        Image($r('app.media.cover_plus'))
          .fillColor($r('sys.color.font_primary'))
          .width(20)
          .height(20)
      }
    }
    .onClick(async () => {
      if (!this.coverUri) {
        const uriList = await MediaUtils.selectMedia({
          type: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
          maxLimit: 1,
        });
        this.onSelected(uriList[0])
      }
    })
    .justifyContent(FlexAlign.Center)
    .width('30%')
    .aspectRatio(1)
    .borderRadius(8)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
  }
}