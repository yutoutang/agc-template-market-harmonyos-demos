import { AppStorageV2 } from '@kit.ArkUI';
import { MediaViewModel } from '../viewmodel/MediaViewModel';
import { ControlStateModel } from '../model/ControlStateModel';

@ComponentV2
export struct ControlAreaComponent {
  @Local controlState: ControlStateModel =
    AppStorageV2.connect<ControlStateModel>(ControlStateModel, () => new ControlStateModel())!;

  build() {
    Column() {
      Row() {
        Text(this.controlState.currentTime)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(10)
          .lineHeight(13)
        Slider({
          min: 0,
          max: this.controlState.progressMax,
          style: SliderStyle.OutSet,
          step: 1,
          value: this.controlState.progress,
        })
          .width('70%')
          .blockColor($r('sys.color.comp_background_primary_contrary'))
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .trackColor($r('sys.color.comp_background_secondary'))
          .onChange((value: number, mode: SliderChangeMode) => {
            if (mode === SliderChangeMode.End || mode === SliderChangeMode.Begin) {
              MediaViewModel.getInstance().seek(value);
            }
            this.controlState.pageShowTime = 0;
          })
          .height(16)
          .margin(16)
          .hitTestBehavior(HitTestMode.Block)
        Text(this.controlState.totalTime)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(10)
          .lineHeight(13)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({
        top: 24,
        bottom: 16,
      })

      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.backward_end_fill'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_secondary')])
        }
        .onClick(() => {
          MediaViewModel.getInstance().playPrevious();
          this.controlState.pageShowTime = 0;
        })
        .padding(12)
        .borderRadius('50%')
        .backgroundColor($r('sys.color.comp_background_tertiary'))

        Row() {
          LoadingProgress()
            .color($r('sys.color.icon_on_primary'))
            .width(24)
            .height(24)
            .visibility(MediaViewModel.getInstance().loadAudio ? Visibility.Visible : Visibility.None)
          SymbolGlyph(MediaViewModel.getInstance().isPlaying ? $r('sys.symbol.pause_fill') :
            $r('sys.symbol.play_fill'))
            .fontSize(24)
            .fontColor([$r('sys.color.font_on_primary')])
            .visibility(MediaViewModel.getInstance().loadAudio ? Visibility.None : Visibility.Visible)
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .borderRadius('50%')
        .backgroundColor('#5C79D9')
        .onClick(() => {
          if (this.controlState.isPlay) {
            MediaViewModel.getInstance().pause();
          } else {
            if (MediaViewModel.getInstance().getFirst()) {
              MediaViewModel.getInstance().loadAssent(0);
            } else {
              MediaViewModel.getInstance().play();
            }
          }
          this.controlState.pageShowTime = 0;
        })

        Row() {
          SymbolGlyph($r('sys.symbol.forward_end_fill'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_secondary')])
        }
        .onClick(() => {
          MediaViewModel.getInstance().playNext()
          this.controlState.pageShowTime = 0;
        })
        .padding(12)
        .borderRadius('50%')
        .backgroundColor($r('sys.color.comp_background_tertiary'))

      }
      .width(212)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(6)
      .borderRadius(36)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
    }
    .padding({ left: 16, right: 16 })
  }
}