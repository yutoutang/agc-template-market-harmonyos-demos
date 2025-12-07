import { PreferConstant, PreferenceUtil } from 'commonlib'

@ComponentV2
export struct DownLoadSheet {
  @Param shouldDismiss: () => void = () => {
  }

  build() {
    Column() {
      Row() {
        Text('资料下载')
          .width('100%')
          .height(27)
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 8 })

      Column({ space: 4 }) {
        ForEach([1], () => {
          ListItem() {
            DownItem({ shouldDismiss: this.shouldDismiss })
          }
        }, (item: number, index: number) => item + index + '')
      }
      .width('100%')
      .padding({ top: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
  }
}

@ComponentV2
struct DownItem {
  @Local isShowLoading: boolean = false
  @Local isDown: boolean = false
  @Param shouldDismiss: () => void = () => {
  }

  aboutToAppear(): void {
    this.getLoadData()
  }

  getLoadData() {
    let downloadState = PreferenceUtil.getInstance().get(PreferConstant.DOWNLOAD_KEY, '0')
    if (downloadState === '1') {
      this.isDown = true
    } else {
      this.isDown = false
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_public_pdf_file_textured'))
          .width($r('app.float.vp_48'))
          .height($r('app.float.vp_48'))
          .margin({ right: $r('app.float.vp_16') })
        Text('一级建造师精华题库')
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .layoutWeight(1)
        Row() {
          Image($r('app.media.ic_public_down'))
            .width($r('app.float.vp_16'))
            .height($r('app.float.vp_16'))
            .margin({ right: $r('app.float.vp_2') })
            .visibility(this.isDown ? Visibility.None : Visibility.Visible)
          Text(this.isDown ? '查看' : '下载')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor(this.isDown ? $r('sys.color.font_secondary') : $r('sys.color.font_primary'))
            .visibility(this.isShowLoading ? Visibility.None : Visibility.Visible)
            .onClick(() => {
              if (this.isDown) {
                this.shouldDismiss()
              } else {
                this.isShowLoading = true
                PreferenceUtil.getInstance().put(PreferConstant.DOWNLOAD_KEY, '1')
                setTimeout(() => {
                  this.isShowLoading = false
                  this.getLoadData()
                }, 2000)
              }
            })
          LoadingProgress()
            .width($r('app.float.vp_24'))
            .height($r('app.float.vp_24'))
            .visibility(this.isShowLoading ? Visibility.Visible : Visibility.None)
        }
        .width($r('app.float.vp_64'))
        .height($r('app.float.vp_28'))
        .borderRadius($r('app.float.vp_14'))
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('sys.color.background_secondary'))
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height($r('app.float.vp_72'))
    }
    .width('100%')
    .height($r('app.float.vp_116'))
    .borderRadius($r('app.float.vp_16'))
    .padding($r('app.float.vp_12'))
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Center)
  }
}