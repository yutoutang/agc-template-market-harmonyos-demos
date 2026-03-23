import { BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  Constants, NavHeaderBar, TCRouter, UserInfoModel, UserInfoUtil } from 'common';
import { CenterToolCard } from '../comp/CenterToolCard';
import { MyBalanceCard } from '../comp/MyBalanceCard';
import { MyInfoCard } from '../comp/MyInfoCard';
import { ActivityCard } from '../comp/ActivityCard';
import { AccountCard } from '../comp/AccountCard';
import { ServiceCard } from '../comp/ServiceCard';

@Builder
export function PersonPageBuilder() {
  PersonPage();
}

@ComponentV2
export struct PersonPage {
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Provider('index') index: number = 0;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  build() {
    // NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          this.headBarView()
          Scroll() {
            Column({ space: 12 }) {
              if (this.curBreakpoint.value === BreakpointTypeEnum.SM){
                MyInfoCard();
                AccountCard();
                ActivityCard();
                ServiceCard();
              } else {
                Row({space:12}){
                  MyInfoCard()
                    .layoutWeight(1)
                  AccountCard()
                    .layoutWeight(1)
                }
                .width('100%')
                ActivityCard();
                ServiceCard();
              }

            }
          }.layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top).edgeEffect(EdgeEffect.Spring);

        }
        .alignItems(HorizontalAlign.Start)
        .width(Constants.FULL_SIZE)
        .padding({
          left: 16,
          right: 16,
        })
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.background_secondary'))
    // }.hideTitleBar(true)
  }

  @Builder
  headBarView() {
    Column() {
      Row() {
        Text($r('app.string.person'))
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Title_M'))
          .fontWeight(FontWeight.Medium)
        Row() {
          SymbolGlyph($r('sys.symbol.message'))
            .fontSize($r('sys.float.Title_M'))
            .fontColor([$r('sys.color.icon_primary')])
            .margin({ right: 8 })
            .width(40)
            .height(40)
            .borderRadius(1000)
            .padding(8)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              TCRouter.push(Constants.MESSAGE_PAGE_ROUTE);
            });

          SymbolGlyph($r('sys.symbol.gearshape'))
            .fontSize($r('sys.float.Title_M'))
            .fontColor([$r('sys.color.icon_primary')])
            .width(40)
            .height(40)
            .borderRadius(1000)
            .padding(8)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              TCRouter.push(Constants.SETTING_ROUTE);
            })
        }
      }
      .height(36)
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: 8 + this.windowTopHeight,
      bottom: 8
    })
    .width(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}