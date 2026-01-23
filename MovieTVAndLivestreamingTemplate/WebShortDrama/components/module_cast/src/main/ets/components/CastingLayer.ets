import { SimpleProgressBar } from './SimpleProgressBar';
import { promptAction } from '@kit.ArkUI';
import { CastService } from '../service/CastService';

@ComponentV2
export struct CastingLayer {
  @Param @Require castService: CastService
  @Param title: string = ''
  @Event onPlayNext: Function
  @Event onPlayPre: Function
  @Event onPlay: Function
  @Event onSeek: Function
  @Event onBack: Function

  aboutToDisappear(): void {
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Header({
          title: this.title,
          onBack: this.onBack
        })

        DeviceView({
          castService: this.castService
        })
          .margin({ top: 9 })

        SimpleProgressBar({
          castService: this.castService
        })
          .margin({ top: 24 })
          .width('100%')
          .padding({ left: 16, right: 16 })

        ControlView({
          castService: this.castService,
          onPlay: this.onPlay,
          onPlayNext: this.onPlayNext,
          onPlayPre: this.onPlayPre
        })
          .margin({ top: 59 })
        ExitCastView({
          castService: this.castService
        })
          .margin({ top: 40 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.black'))
  }
}

@ComponentV2
struct Header {
  @Param title: string = ''
  @Event onBack: Function

  build() {
    Row() {
      Image($r('app.media.dark_back'))
        .width(40)
        .aspectRatio(1)
        .margin({ right: 8 })
        .onClick(() => {
          this.getUIContext().getPromptAction().showToast({ message: '返回' })
          this.onBack?.()
        })
      Text(this.title)
        .height(40)
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize(20)
      Blank()
    }
    .justifyContent(FlexAlign.Start)
    .height(56)
    .width('100%')
    .padding({ left: 16 })
  }
}

@ComponentV2
struct ExitCastView {
  @Param @Require castService: CastService

  build() {
    Button({ type: ButtonType.Capsule }) {
      Row() {
        SymbolGlyph($r('sys.symbol.power'))
          .fontColor(['#E6FF7500'])
          .width(20)
          .height(20)
          .margin({ left: 16 })
        Text('退出投屏').fontSize(12).fontColor(0xffffff).margin({ left: 5, right: 12 })
          .margin({ left: 10, right: 16 })
      }.alignItems(VerticalAlign.Center)
    }
    .backgroundColor('#1AFFFFFF')
    .borderRadius(20)
    .height(40)
    .width(128)
    .onClick(() => {
      this.getUIContext().getPromptAction().showToast({ message: 'exit' })
      this.castService.endCasting()
    })
  }
}

@ComponentV2
struct DeviceView {
  @Param @Require castService: CastService
  @Param castResolution: string = '720P标清'

  build() {
    Column() {
      Text(`投屏设备:${this.castService.castStatusModel.currentDeviceName}`)
        .fontSize(16)
        .fontColor($r('sys.color.font_on_primary'))
        .margin({ top: 49, bottom: 16 })
      Row() {
        Row() {
          Image($r('app.media.camera'))
            .width(14)
            .height(9)

          Text(this.castResolution)
            .fontSize(14)
            .fontColor($r('sys.color.font_on_primary'))
            .margin({ left: 5 })
        }
      }
      .backgroundColor('#1AFFFFFF')
      .borderRadius(20)
      .height(28)
      .width(97)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .width(277)
    .height(167)
    .backgroundImage($r('app.media.tv_bg'))
    .backgroundImageSize(ImageSize.Contain)
  }
}

@ComponentV2
struct ControlView {
  @Param @Require castService: CastService
  @Event onPlayNext: Function
  @Event onPlayPre: Function
  @Event onPlay: Function

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.bigCircle'))
        .width(208)
        .height(208)
      Image($r('app.media.innerCircle'))
        .width(72)
        .height(72)

      Column() {
        SymbolGlyph($r('sys.symbol.speaker_plus'))
          .fontSize(32)
          .fontColor([$r('sys.color.icon_on_primary')])
          .onClick(() => {
            this.getUIContext().getPromptAction().showToast({ message: '音量+' })
            this.castService.setVolumeByOffset(1)
          })
        SymbolGlyph($r('sys.symbol.speaker_minus'))
          .fontSize(32)
          .fontColor([$r('sys.color.icon_on_primary')])
          .onClick(() => {
            this.getUIContext().getPromptAction().showToast({ message: '音量-' })
            this.castService.setVolumeByOffset(-1)
          })
      }.height('100%')
      .padding({ top: 20, bottom: 20 })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        SymbolGlyph($r('sys.symbol.backward_end_fill'))
          .fontSize(32)
          .fontColor([$r('sys.color.icon_on_primary')])
          .onClick(() => {
            this.onPlayPre?.()
          })
        SymbolGlyph($r('sys.symbol.forward_end_fill'))
          .fontSize(32)
          .fontColor([$r('sys.color.icon_on_primary')])
          .onClick(() => {
            this.onPlayNext?.()
          })
      }.width('100%')
      .padding({ left: 20, right: 20 })
      .justifyContent(FlexAlign.SpaceBetween)

      Column() {
        SymbolGlyph(this.castService.castStatusModel.isCastPlaying ? $r('sys.symbol.pause') : $r('sys.symbol.play'))
          .fontSize(40)
          .fontColor([$r('sys.color.icon_on_primary')])
      }.justifyContent(FlexAlign.Center)
      .width(40)
      .height(40)
      .onClick(() => {
        this.castService.castStatusModel.isCastPlaying ? this.castService.pause() : this.castService.play()
      })
    }.width(208)
    .height(208)
  }
}

@Preview
export struct CastingLayerPreview {
  castService: CastService = CastService.getInstance()

  build() {
    CastingLayer({
      castService: this.castService
    })
      .width('100%')
      .height('100%')
  }
}