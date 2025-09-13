import { CouponCard, CouponItem } from 'base_ui';
import { Constants, HomePageRouter, NavHeaderBar, RouterModule, TabBarType, WindowModel } from 'common/Index';
import * as API from '../api/Index';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function MyCouponsPageBuilder() {
  MyCouponsPage()
}

@ComponentV2
struct MyCouponsPage {
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Local currentIndex: number = 0
  @Local myCouponsAll: CouponItem[] = []
  @Local myCouponsUsable: CouponItem[] = []
  @Local myCouponsExpired: CouponItem[] = []
  @Local myCouponsUsed: CouponItem[] = []

  aboutToAppear() {
    this.getMyCoupon()
  }

  getMyCoupon() {
    API.getMyCoupons().then((res) => {
      res.forEach((item: CouponItem) => {
        this.myCouponsAll.push(item)
        if (item.offsetInfo) {
          this.myCouponsUsed.push(item)
        } else if (new Date(`${item.endTime} 23:59:59`).getTime() > new Date().getTime()) {
          this.myCouponsUsable.push(item)
        } else {
          this.myCouponsExpired.push(item)
        }
      })
    })
  }

  @Styles
  listStyle(){
    .align(Alignment.Top).height(Constants.FULL_SIZE).padding({
      top: 8,
      left: 12,
      right: 12,
      bottom: 8,
    })
  }

  @Builder
  tabBuilder(index: number, name: Resource) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? $r('sys.color.multi_color_09') : $r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
      if (this.currentIndex === index) {
        Row()
          .width(42)
          .height(0)
          .borderWidth({ bottom: 2 })
          .borderColor($r('sys.color.multi_color_09'))
          .margin({ top: 4 })
      }
    }
    .width(Constants.FULL_SIZE)
    .height(50)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: $r('app.string.my_coupon') })
      Scroll() {
        Tabs({ index: this.currentIndex }) {
          TabContent() {
            List({ space: 8 }) {
              ForEach(this.myCouponsAll, (item: CouponItem) => {
                ListItem() {
                  CouponCard({
                    coupon: item, useNow: () => {
                      RouterModule.pop({ index: TabBarType.HOMEPAGE } as HomePageRouter)
                    },
                  })
                }
              }, (item: CouponItem) => JSON.stringify(item))
            }.listStyle().scrollBar(BarState.Off)
          }.tabBar(this.tabBuilder(0, $r('app.string.all')))

          TabContent() {
            List({ space: 8 }) {
              ForEach(this.myCouponsUsable, (item: CouponItem) => {
                ListItem() {
                  CouponCard({
                    coupon: item, useNow: () => {
                      RouterModule.pop({ index: TabBarType.HOMEPAGE } as HomePageRouter)
                    },
                  })
                }
              }, (item: CouponItem) => JSON.stringify(item))
            }.listStyle().scrollBar(BarState.Off)
          }.tabBar(this.tabBuilder(1, $r('app.string.available')))

          TabContent() {
            List({ space: 8 }) {
              ForEach(this.myCouponsExpired, (item: CouponItem) => {
                ListItem() {
                  CouponCard({ coupon: item })
                }
              }, (item: CouponItem) => JSON.stringify(item))
            }.listStyle().scrollBar(BarState.Off)
          }.tabBar(this.tabBuilder(2, $r('app.string.expired')))

          TabContent() {
            List({ space: 8 }) {
              ForEach(this.myCouponsUsed, (item: CouponItem) => {
                ListItem() {
                  CouponCard({ coupon: item })
                }
              }, (item: CouponItem) => JSON.stringify(item))
            }.listStyle().scrollBar(BarState.Off)
          }.tabBar(this.tabBuilder(3, $r('app.string.coupon_used')))
        }
        .width(Constants.FULL_SIZE)
        .barHeight(50)
        .layoutWeight(1)
        .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
          this.currentIndex = targetIndex
        })
        .onChange((index) => {
          this.currentIndex = index;
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .backgroundColor('#F2F1F3F5')
      .margin({ bottom: this.windowModel.getWindowBottomHeight() })
    }.hideTitleBar(true)
  }
}
