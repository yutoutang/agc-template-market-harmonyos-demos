import {
  CommonConstants, CommonHeader, WindowUtil,
} from 'lib_foundation';
import { VoiceList } from 'module_voice_broadcast';

@ComponentV2
export struct BroadcastPage {
  build() {
    NavDestination() {
      CommonHeader({ title: '语音播报', bgColor: $r('sys.color.background_primary') })
        .margin({ bottom: CommonConstants.SPACE_8 })
      
      VoiceList()
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ bottom: WindowUtil.getAvoidArea().bottom })
  }
}


@Builder
export function broadcastPageBuilder() {
  BroadcastPage()
}