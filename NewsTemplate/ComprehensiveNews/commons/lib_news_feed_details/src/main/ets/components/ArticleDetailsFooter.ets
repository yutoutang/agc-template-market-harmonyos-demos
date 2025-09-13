import { PersistenceV2 } from '@kit.ArkUI'
import dayjs from 'dayjs'
import { SettingModel } from 'lib_common'
import { WxShareViewModel } from 'module_share'
import { handlerCoverImage } from '../utils/Utils'
import NewsFeedVM from '../viewmodel/NewsFeedVM'

@ComponentV2
export struct ArticleDetailsFooter {
  @Local newsFeedVM: NewsFeedVM = NewsFeedVM.instance
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!

  @Computed
  get getDarkLike() {
    return this.settingInfo.darkSwitch ? $r('app.media.details_like_dark'): $r('app.media.details_like')
  }

  @Builder
  shareBuilder() {
    Row() {
      Image($r('app.media.wechat'))
        .width(16 * this.settingInfo.fontSizeRatio)
        .height(14 * this.settingInfo.fontSizeRatio)
        .margin({ right: 5 })
        .fillColor($r('sys.color.font_primary'))
      Text('微信')
        .fontSize(14 * this.settingInfo.fontSizeRatio)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .borderRadius(21)
    .justifyContent(FlexAlign.Center)
    .padding({ top: 8, bottom: 8 })
    .width('48%')
    .margin({ left: 5 })
  }

  build() {
    Column() {
      Flex() {
        Row() {
          Image(this.newsFeedVM.articleDetails.isLiked ? $r('app.media.details_like_active') :
          this.getDarkLike)
            .width(16 * this.settingInfo.fontSizeRatio)
            .height(14 * this.settingInfo.fontSizeRatio)
            .margin({ right: 5 })
          Text(this.newsFeedVM.articleDetails.likeCount.toString())
            .fontSize(14 * this.settingInfo.fontSizeRatio)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'))
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .padding({ top: 8, bottom: 8 })
        .justifyContent(FlexAlign.Center)
        .borderRadius(21)
        .flexGrow(1)
        .margin({ right: 5 })
        .accessibilityText('点赞' + this.newsFeedVM.articleDetails.likeCount.toString())
        .onClick(() => {
          this.newsFeedVM.newsLike()
        })

        Row() {
          Image($r('app.media.wechat'))
            .width(18 * this.settingInfo.fontSizeRatio)
            .height(15 * this.settingInfo.fontSizeRatio)
            .margin({ right: 5 })
            .fillColor($r('sys.color.font_primary'))
          Text('微信')
            .fontSize(14 * this.settingInfo.fontSizeRatio)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'))
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius(21)
        .justifyContent(FlexAlign.Center)
        .padding({ top: 8, bottom: 8 })
        .width('48%')
        .margin({ left: 5 })
        .accessibilityText('分享到微信')
        .onClick(() => {
          WxShareViewModel.instance.newsWebShare({
            id: this.newsFeedVM.articleDetails.id,
            type: this.newsFeedVM.articleDetails.type,
            title: this.newsFeedVM.articleDetails.title,
            articleFrom: this.newsFeedVM.articleDetails.articleFrom,
            createTime: dayjs(this.newsFeedVM.articleDetails.createTime).format('YYYY-MM-DD HH:mm'),
            coverUrl: handlerCoverImage(this.newsFeedVM.articleDetails),
            isVideo: !!this.newsFeedVM.articleDetails.postImgList?.[0]?.surfaceUrl,
          })
        })
      }
    }
    .margin({ bottom: 16,top:16 })
  }
}
