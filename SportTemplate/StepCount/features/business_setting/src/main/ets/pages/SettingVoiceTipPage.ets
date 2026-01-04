import { CommonConstants, RunningVoiceSetting } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingCard } from '../components/SettingCard';
import { SettingItem } from '../types/Types';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function SettingVoiceTipPageBuilder() {
  SettingVoiceTipPage()
}

/**
 * 语音提示设置页面
 */
@ComponentV2
struct SettingVoiceTipPage {
  stack: NavPathStack = new NavPathStack();
  @Local localItem: SettingItem = new SettingItem();
  @Local runningVoiceSetting: RunningVoiceSetting =
    AppStorageV2.connect(RunningVoiceSetting, 'runningVoiceSetting', () => new RunningVoiceSetting())!

  aboutToAppear(): void {
    this.localItem.label = $r('app.string.voice_broadcast')
    this.localItem.typeSwitch = true
    this.localItem.switchV = this.getRunningVoiceSetting()
    this.localItem.onClick = (isOn: ESObject) => {
      this.setRunningVoiceSetting(isOn as boolean)
      this.localItem.switchV = isOn
    }
  }

  // 修改语音播报
  setRunningVoiceSetting(val: boolean) {
    this.runningVoiceSetting.clockBaseVoiceOn = val
  }

  getRunningVoiceSetting() {
    return this.runningVoiceSetting.clockBaseVoiceOn
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: $r('app.string.voice_settings')
        })
        Column() {
          SettingCard({ list: [this.localItem] })

          Text($r('app.string.voice_settings_description'))
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 16 })
        }
        .alignItems(HorizontalAlign.Start)
        .padding({
          left: CommonConstants.PADDING_PAGE,
          right: CommonConstants.PADDING_PAGE,
          top: CommonConstants.PADDING_M,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor('#F1F3F5')
    }
    .hideTitleBar(true)
    .onReady((context) => {
      this.stack = context.pathStack;
    })
  }
}