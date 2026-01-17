import { ValueType } from '@kit.ArkData';
import { RouterMap } from 'lib_common';
import { AvModel } from 'lib_news_api';
import { NavHeaderBar, Share } from 'lib_widget';
import { MediaController, AudioPlayer, AudioPlayerState, SubUtils, AudioConstants } from 'module_audioplayer';
import { AudioMightLike } from '../components/AudioMightLike';
import { AudioUtils } from '../utils/AudioAdaptationUtils';
import { AudioVM } from '../viewmodel/AudioViewModel';
import { VideoPipViewModel } from '../viewmodel/VideoPipViewModel';


@Builder
export function AudioPlayingDetailsBuilder() {
  AudioPlayingDetails()
}

@ComponentV2
export struct AudioPlayingDetails {
  @Local curPlayAudioInfo: AvModel = new AvModel()
  @Local audioIndex: number = 0
  @Local audioVM: AudioVM = new AudioVM()
  @Local videoPipModel: VideoPipViewModel = new VideoPipViewModel()
  @Local canRedirect: boolean = true

  @Builder
  shareBuilder() {
    Share({
      shareData: {
        type: this.curPlayAudioInfo.type,
        recordId: this.curPlayAudioInfo.id,
        title: this.curPlayAudioInfo.title,
        createTime: new Date().getTime(),
        coverUrl: this.curPlayAudioInfo.coverUrl,
      },
    })
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: `正在直播：${this.curPlayAudioInfo.title}`,
          rightPartBuilder: () => {
            this.shareBuilder()
          },
        })
        List({ space: 24 }) {
          ListItem() {
            AudioPlayer({
              audioIndex: this.audioIndex,
              hasOperation: true,
              fontSizeRatio: this.audioVM.settingInfo.fontSizeRatio,
              canRedirect: this.canRedirect,
              onAudioStateChange: (state: AudioPlayerState) => {
                if (state === AudioPlayerState.PLAY) {
                  this.videoPipModel.stopPip()
                }
              },
            })
          }

          ListItem() {
            AudioMightLike()
          }
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
    }
    .hideTitleBar(true)
    .onReady((content) => {
      let params =
        content.pathStack.getParamByName(RouterMap.AUDIO_PLAYING_DETAILS)[0] as Record<string, AvModel | ValueType>
      this.audioIndex = params.audioIndex as number
      this.curPlayAudioInfo = params.curPlayAudioInfo as AvModel
      this.canRedirect = params.canRedirect as boolean
      if (!MediaController
        .isSameCurrentPlayWithIndex(this.curPlayAudioInfo.id, this.curPlayAudioInfo.section[this.audioIndex].id)) {
        MediaController.setAudioList(AudioUtils.adaptation(this.curPlayAudioInfo))
        MediaController.loadAssent(this.audioIndex);
        MediaController.setAlbumId(this.curPlayAudioInfo.id);
      }
    })
  }
}