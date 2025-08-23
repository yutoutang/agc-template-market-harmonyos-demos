import { Permissions } from '@kit.AbilityKit'
import { RouteEntryVM } from 'common'
import { RealTimeBus } from './realTimeBus'
import { TravelPlan } from './TravelPlan'
import { RandomCountdown } from '../components/RandomCountdown'
import { CustomSegmentButton } from '../components/CustomSegmentButton'
import { ButtonItem, ButtonOptions } from '../viewmodels/ButtonItems'

@Builder
export function BusLinePlanBuilder() {
  BusLinePlan()
}

@ComponentV2
export struct BusLinePlan {
  @Provider('busLineTimeList') busLineTimeList: Map<string, RandomCountdown> = new Map()
  permissions: Array<Permissions> = ['ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.LOCATION']
  vm: RouteEntryVM = RouteEntryVM.instance
  tabOptions: ButtonOptions =
    new ButtonOptions([{ text: '实时公交', icon: $r('app.media.bus'), selectedIcon: $r('app.media.bus_select') },
      { text: '路线规划', icon: $r('app.media.route'), selectedIcon: $r('app.media.route_select') },] as ButtonItem[])
  @Local tabSelectedIndex: number = 0
  private controller: TabsController = new TabsController()
  scroller: Scroller = new Scroller()

  @Builder
  topTitle() {
    Row() {
      Text('出行')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .height(70)
    .padding({ left: 24 })
    .justifyContent(FlexAlign.Start)
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          this.topTitle()
          Row() {
            CustomSegmentButton({
              buttonOptions: this.tabOptions,
              selectIndex: this.tabSelectedIndex,
              onSelectIndexChange: (index: number) => {
                this.tabSelectedIndex = index
              }
            })
          }
          .height('64lpx')
          .width('330lpx')
          .margin({ bottom: '24lpx' })
          .justifyContent(FlexAlign.SpaceBetween)

          Tabs({ controller: this.controller,index: this.tabSelectedIndex }) {
            TabContent() {
              RealTimeBus()
            }

            TabContent() {
              TravelPlan()
            }
          }
          .barHeight(0)
          .onChange((index: number) => {
            this.tabSelectedIndex = index
          })
          //使用onAnimationStart，动画开始执行至targetIndex时进行刷新
          .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
            if (index === targetIndex) {
              return
            }
            this.tabSelectedIndex = targetIndex
          })

          Blank()
            .layoutWeight(1)
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .backgroundColor('#F1F3F5')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .scrollBarWidth('0vp')
      .edgeEffect(EdgeEffect.Spring)
    }
    .hideTitleBar(true)
  }
}