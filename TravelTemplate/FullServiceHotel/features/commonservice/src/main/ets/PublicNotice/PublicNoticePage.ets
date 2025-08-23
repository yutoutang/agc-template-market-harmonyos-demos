import { FormatUtil, RouterMap, RouterModule } from 'commonlib';
import { ContentItem, GetNoticeDetailResp, https } from 'network';
import { NoticeType } from './commons/Enums';

@Builder
export function publicNoticePageBuilder() {
  PublicNoticePage()
}

@ComponentV2
export struct PublicNoticePage {
  @Local notice: GetNoticeDetailResp | null = null;

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (this.notice) {
            Column() {
              Text(this.notice.noticeTitle)
                .fontSize($r('app.string.font_size_18'))
                .fontWeight(500)
                .textAlign(TextAlign.Start)
                .margin({ bottom: $r('app.string.margin_s') })
              Text(this.notice.publishTime)
                .fontSize($r('app.string.font_size_12'))
                .fontColor($r('app.color.icon_color_level2'))
            }
            .padding($r('app.string.padding_s'))
            .alignItems(HorizontalAlign.Start)

            if (this.notice.contentList) {
              Column() {
                ForEach(this.notice.contentList, (item: ContentItem) => {
                  if (this.notice?.noticeType === NoticeType.STRING) {
                    Text(item.content)
                      .width('100%')
                      .fontSize($r('app.string.font_size_16'))
                      .lineHeight('48lpx')
                  } else if (this.notice?.noticeType === NoticeType.PICTURE) {
                    Image(FormatUtil.getImgResource(item.image))
                      .width('100%')
                  }
                }, (item: ContentItem) => JSON.stringify(item))
              }
              .backgroundColor($r('app.color.background_color_white'))
              .borderRadius($r('app.string.border_radius_16'))
              .padding($r('app.string.padding_s'))
            }
          }

        }
        .alignItems(HorizontalAlign.Start)
        .padding($r('app.string.padding_s'))
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .title('公告详情')
    .onReady(() => {
      let params: number | undefined = RouterModule.getNavParam({
        url: RouterMap.HOME_PUBLIC_NOTICE,
      });
      if (params) {
        https.getNoticeDetail(params).then((res) => {
          if (res.code === 0) {
            this.notice = res.data;
          }
        });
      }
    })
  }
}
