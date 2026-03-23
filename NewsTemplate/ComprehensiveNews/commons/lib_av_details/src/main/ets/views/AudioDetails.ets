import { common } from '@kit.AbilityKit';
import { ValueType } from '@kit.ArkData';
import { MembershipUtils } from 'lib_account';
import { RouterMap, RouterUtils } from 'lib_common';
import { AvModel, AvSection, HomeServiceApi } from 'lib_news_api';
import { NavHeaderBar, Share } from 'lib_widget';
import { AudioConstants, AudioService } from 'module_audioplayer';
import { CardLongTakeDelegate, LongTakeAnimationProperties } from 'module_transition';
import { AudioIntroduce } from '../components/AudioIntroduce';
import { AudioListSelect } from '../components/AudioListSelect';
import { AudioVM } from '../viewmodel/AudioViewModel';
import { AvViewModel } from '../viewmodel/AvViewModel';

@Builder
export function AudioDetailsBuilder() {
  AudioDetails()
}

@ComponentV2
export struct AudioDetails {
  @Local curAudioInfo: AvModel = new AvModel()
  @Local longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  audioVM: AudioVM = new AudioVM()
  avViewModel: AvViewModel = new AvViewModel()
  @Local subWindow: boolean = false
  @Local isCreateSubWindow: boolean = true

  @Builder
  shareBuilder() {
    Share({
      shareData: {
        type: this.curAudioInfo.type,
        recordId: this.curAudioInfo.id,
        title: this.curAudioInfo.title,
        createTime: new Date().getTime(),
        coverUrl: this.curAudioInfo.coverUrl,
      },
    })
  }

  backIntercept() {
    if (this.audioVM.settingInfo.network.enableAudioSub) {
      if (!this.audioVM.isVideoTab() && this.isCreateSubWindow) {
        AudioService.createSubWindow(this.getUIContext())
      }
    }
    RouterUtils.pop(this.curAudioInfo)
  }

  @Builder
  ContentBuilder() {
    Column() {
      NavHeaderBar({
        title: this.curAudioInfo.title,
        rightPartBuilder: () => {
          this.shareBuilder()
        },
        onBack: () => {
          this.backIntercept()
        },
      })
      AudioIntroduce({
        curAudioInfo: this.curAudioInfo,
        fontSizeRatio: this.audioVM.settingInfo.fontSizeRatio,
        onSubscribe: (curAudioInfo: AvModel) => {
          this.avViewModel.followOperation(curAudioInfo)
        },
      })

      Row().width('100%').height(8).background($r('sys.color.background_secondary'))

      AudioListSelect({
        curAudioInfo: this.curAudioInfo,
        isCurrentPlay: this.audioVM.isCurrentPlay,
        onAudioCard: async (item: AvSection, index: number) => {
          if (item.needVip && (!this.audioVM.userInfoModel.isLogin || !this.audioVM.userInfoModel.isMembership)) {
            MembershipUtils.openSheet();
            return;
          }

          await this.audioVM.destroyOtherSession();
          const params: Record<string, AvModel | ValueType> = {
            'audioIndex': index,
            'canRedirect': false,
            'curPlayAudioInfo': this.curAudioInfo,
          }
          RouterUtils.pushPathByName(RouterMap.AUDIO_PLAYING_DETAILS, params)
        },
      })
    }
    .backgroundColor($r('sys.color.background_primary'))
  }

  build() {
    NavDestination() {
      if (this.longTakeSession) {
        CardLongTakeDelegate({
          longTakeSession: this.longTakeSession,
          contentBuilder: (): void => {
            this.ContentBuilder()
          },
        })
      } else {
        this.ContentBuilder()
      }
    }
    .hideTitleBar(true)
    .backgroundColor(this.longTakeSession.navDestinationBgColor)
    .onSizeChange((_oldValue: SizeOptions, newValue: SizeOptions) => {
      this.longTakeSession.setNewSize(newValue);
    })
    .onReady(async (context) => {
      let paramsList = context.pathStack.getParamByName(RouterMap.AUDIO_DETAILS) as Record<string, Object>[]
      let params =
        paramsList[paramsList.length-1]
      if (!params.avId) {
        return
      }
      if (params.subWindow) {
        this.subWindow = params.subWindow as boolean
        AudioService.destroySubWindow(AudioConstants.AUDIO_SUB_NAME)
      }
      this.isCreateSubWindow = params.isCreateSubWindow as boolean
      this.avViewModel.registerCustomTransition(context, this.longTakeSession)
      let curAudioInfo = await HomeServiceApi.queryHomeBroadcastById(params.avId as string) as AvModel
      this.curAudioInfo = new AvModel(curAudioInfo)
      this.audioVM.setCurAudioInfo(this.curAudioInfo)
      // 扫一扫 订阅入口需要单独初始化audio
      this.audioVM.initAudioPlayer()
    })
    .onBackPressed(() => {
      this.backIntercept()
      return true
    })
    .onShown(() => {
      this.audioVM.enableContinue(this.getUIContext().getHostContext() as common.UIAbilityContext);
      AudioService.destroySubWindow(AudioConstants.AUDIO_SUB_NAME)
    })
  }
}