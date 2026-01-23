import { AppStorageV2, window } from '@kit.ArkUI';

import {
  TopBar,
  UserInfo,
  MyScrollModifier, RouterModule, RouterMap,
} from 'commonlib'


@ComponentV2
export struct FeedbackListPage {
  @Local bottomHeight: number = 0;
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier()

  aboutToAppear(): void {
    try {
      window.getLastWindow(this.getUIContext().getHostContext(), (_err, data) => {
        const avoidAreaBottom = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.bottomHeight = avoidAreaBottom.bottomRect.height;
      })
    } catch (e) {
      console.error(`Failed to get last window. error: ${JSON.stringify(e)}`)
    }
  }

  build() {
    NavDestination(){
      Column() {
        Column() {
          TopBar({ title: $r('app.string.opinion_and_feedback') })

          Column() {
            Row() {
              Text('反馈问题')
                .fontSize(16)
              Image($r('app.media.forward'))
                .width(13)
                .height(13)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              RouterModule.push({ url: RouterMap.FEEDBACK_PAGE })
            })
          }
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .padding(12)
          .borderRadius(16)
          .margin({ left: 8, right: 8 ,top: 16, bottom: 12})
          .alignItems(HorizontalAlign.Start)

          Column() {
            Row() {
              Text('反馈记录')
                .fontSize(16)
              Image($r('app.media.forward'))
                .width(13)
                .height(13)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              RouterModule.push({ url: RouterMap.FEEDBACK_RECORDS_PAGE })
            })
          }
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .padding(12)
          .borderRadius(16)
          .margin({ left: 8, right: 8 })
          .alignItems(HorizontalAlign.Start)

        }.alignItems(HorizontalAlign.Start)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height('100%')
      .padding({ left: $r('app.float.vp_8'), right: $r('app.float.vp_8'), bottom: $r('app.float.vp_50') })
      .alignItems(HorizontalAlign.Start)
    }.backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true);
  }
}



@Builder
export function FeedbackListPageBuilder() {
  FeedbackListPage()
}
