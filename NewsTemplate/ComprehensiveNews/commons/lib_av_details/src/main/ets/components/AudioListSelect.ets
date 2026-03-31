import { AvModel, AvSection } from 'lib_news_api';
import { MediaController } from 'module_audioplayer';
import { secondToTime } from 'module_swipeplayer';
import { AudioUtils } from '../utils/AudioAdaptationUtils';
import { AudioVM } from '../viewmodel/AudioViewModel';
import { VipBadge } from './VipBadge';

@ComponentV2
export struct AudioListSelect {
  @Param curAudioInfo: AvModel = new AvModel()
  @Param isCurrentPlay: boolean = false
  @Event onAudioCard: (item: AvSection, index: number) => void = () => {
  }
  @Local sortFlag: boolean = false
  audioVM: AudioVM = new AudioVM()

  formatDuration(duration: number) {
    const durationTime = duration / 1000
    return secondToTime(Math.floor(durationTime));
  }

  @Builder
  selectHeader() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Text('选集列表')
        .fontWeight(FontWeight.Bold)
        .fontSize(18 * this.audioVM.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
      SymbolGlyph($r('sys.symbol.text_and_arrow_up_and_down'))
        .fontColor([$r('sys.color.font_primary')])
        .fontSize(24 * this.audioVM.settingInfo.fontSizeRatio)
        .onClick(() => {
          this.audioVM.audioListSort(this.curAudioInfo, this.sortFlag)
          this.sortFlag = !this.sortFlag
          MediaController.setAudioList(AudioUtils.adaptation(this.curAudioInfo))
          MediaController.updateCurrentAudioIndex();
        })
    }
  }

  @Builder
  sectionCard(item: AvSection, index: number) {
    Column({ space: 4 }) {
      Row() {
        if (item.needVip) {
          VipBadge()
        } else {
          Text('免费')
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Regular)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .borderRadius(4)
            .width(28)
            .height(16)
            .textAlign(TextAlign.Center)
        }
        Text(item.title)
          .fontWeight(FontWeight.Medium)
          .fontSize(14 * this.audioVM.settingInfo.fontSizeRatio)
          .fontColor(this.isCurrentPlay &&
            item.id === MediaController.playingId ? '#5C79D9' :
            $r('sys.color.font_primary'))
          .margin({
            left: item.needVip ? 8 : 4,
          })
      }

      Row({ space: 12 }) {
        Row({ space: 4 }) {
          SymbolGlyph($r('sys.symbol.time_inerval'))
            .fontColor([$r('sys.color.font_secondary')])
            .fontSize(12 * this.audioVM.settingInfo.fontSizeRatio)
          Text(this.formatDuration(item.duration))
            .fontSize(12 * this.audioVM.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_tertiary'))
        }

        Text(item.updateTime)
          .fontSize(12 * this.audioVM.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_tertiary'))
      }
    }
    .width('100%')
    .onClick(() => {
      this.onAudioCard(item, index)
    })
    .alignItems(HorizontalAlign.Start)
    .padding({ top: 8, bottom: 8 })
  }

  build() {
    Column({ space: 16 }) {
      this.selectHeader()
      List({ space: 16 }) {
        ForEach(this.curAudioInfo.section, (item: AvSection, index: number) => {
          ListItem() {
            this.sectionCard(item, index)
          }
        }, (item: AvSection) => item.title + item.id)
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .divider({
        strokeWidth: 1,
        color: $r('sys.color.comp_divider'),
      })
    }
    .padding(16)
    .layoutWeight(1)
  }
}