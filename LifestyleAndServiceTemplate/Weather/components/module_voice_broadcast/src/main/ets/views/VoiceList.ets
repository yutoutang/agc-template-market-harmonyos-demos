import { VoiceListItem } from '../components/VoiceListItem';
import { VoicePackage } from '../types/Types';
import { BroadCastUtil } from '../utils/BroadcastUtil';

@ComponentV2
export struct VoiceList {
  @Param space: string | number = 7;
  @Local list: VoicePackage[] = [];

  aboutToAppear(): void {
    BroadCastUtil.getVoiceList().then(res => this.list = res);
  }

  build() {
    if (this.list.length) {
      List({ space: this.space }) {
        ForEach(this.list, (voice: VoicePackage) => {
          VoiceListItem({
            voice: voice,
            callback: () => {
              BroadCastUtil.getVoiceList().then(res => this.list = res);
            },
          })
        }, (voice: VoicePackage, index) => JSON.stringify(voice) + '_' + index)
      }
      .width('100%')
    } else {
      Text('暂无语音包')
        .margin({ top: 300 })
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
    }
  }
}