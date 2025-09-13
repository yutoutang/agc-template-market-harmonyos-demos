import { FormatCount, RouterMap, RouterUtils, SettingModel, UserInfoModel } from 'lib_common'
import { NewsResponse } from 'lib_news_api'
import { FeedCard } from 'module_newsfeed'
import { PersistenceV2 } from '@kit.ArkUI'
import { Share } from 'module_share'
import { TimeUtils } from 'lib_common'
import { InteractionViewModel } from '../viewmodels/InteractionViewModel'
import { TabItem } from '../common/Constants'

@ComponentV2
export struct InteractionFeedCard {
  @Require @Param cardInfo: NewsResponse
  @Param @Require resource: TabItem
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local interactionViewModel: InteractionViewModel = new InteractionViewModel(this.getUIContext())
  @Param index: number = 0

  aboutToAppear(): void {
    this.interactionViewModel.setAuthorId(this.cardInfo.author.authorId)
  }

  @Builder
  shareCommentBuilder() {
    Row({ space: 5 }) {
      Image($r('app.media.op_forward'))
        .width(16 * this.settingInfo.fontSizeRatio)
        .height(16 * this.settingInfo.fontSizeRatio)
        .draggable(false)
        .fillColor($r('sys.color.font_primary'))
      Text(FormatCount.formatToK(this.cardInfo.shareCount))
        .fontSize(12 * this.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_secondary'))
    }
    .accessibilityGroup(true)
    .accessibilityText('分享按钮' + FormatCount.formatToK(this.cardInfo.shareCount))
  }

  @Builder
  shareBuilder() {
    Share({
      qrCodeInfo: {
        id: this.cardInfo.id,
        type: this.cardInfo.type,
        title: this.cardInfo.title,
        articleFrom: this.cardInfo.articleFrom,
        createTime: TimeUtils.formatDate(this.cardInfo.createTime, 'YYYY-MM-DD HH:mm'),
        coverUrl: this.cardInfo.postImgList?.[0]?.picVideoUrl,
        isVideo: !!this.cardInfo.postImgList?.[0]?.surfaceUrl,
      },
      shareRenderBuilder: () => {
        this.shareCommentBuilder()
      },
    })
  }

  build() {
    Column() {
      FeedCard({
        componentId: 'interaction_news' + this.resource.label,
        feedCardInfo: this.cardInfo,
        isAll: true,
        isDark: this.settingInfo.darkSwitch,
        showUserBar: true,
        showTimeBottom: false,
        fontSizeRatio: this.settingInfo.fontSizeRatio,
        onGoUserInfo: (authorId: string) => {
          RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, authorId)
        },
        onArticle: (formType?: string) => {
          this.interactionViewModel.actionToNewsDetails(this.cardInfo, this.index, this.resource.id, formType, true)
        },
        onVideo: () => {
          this.interactionViewModel.actionToNewsDetails(this.cardInfo, this.index, this.resource.id)
        },
        shareBuilder: () => {
          this.shareBuilder()
        },
        onWatch: () => {
          this.interactionViewModel.watchOperation()
        },
        onComment: () => {
          this.interactionViewModel.actionToNewsDetails(this.cardInfo, this.index, this.resource.id, 'comment')
        },
        onLike: () => {
          this.interactionViewModel.addLike(this.cardInfo)
        },
      })
    }
  }
}