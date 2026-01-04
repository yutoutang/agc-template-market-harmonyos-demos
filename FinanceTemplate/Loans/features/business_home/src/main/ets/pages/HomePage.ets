import { LoginSheetUtils } from 'lib_account';
import { BreakpointNameEnum, CommonConstants, LinearColumnModifier, RouterMap, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { HomeIntroduceCard } from '../components/home/HomeIntroduceCard';
import { StepIntroduceCard } from '../components/home/StepIntroduceCard';
import { HomeViewModel } from '../viewmodels/HomeViewModel';
import { VerifyVM } from '../viewmodels/VerifyVM';

@Builder
export function HomePageBuilder() {
  HomePage()
}

@ComponentV2
struct HomePage {
  @Local homeViewModel: HomeViewModel = new HomeViewModel();
  @Local modifier: LinearColumnModifier = new LinearColumnModifier('#F1F3F5');
  @Local verifyVM: VerifyVM = new VerifyVM();

  aboutToAppear(): void {
    this.homeViewModel.getHomeInterduceData()
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '贷款',
          isSubTitle: false,
          titleColor: '#FFFFFF',
          needNoPadding: true
        })
        Scroll() {
          Column({ space: CommonConstants.SPACE_L }) {
            HomeIntroduceCard({
              moneyEDu: this.homeViewModel.moneyEDu,
              loanRate: this.verifyVM.fixedAnnualRate,
              loanPerDay: this.homeViewModel.loanPerDay,
              ClickFunc: () => {
                if (this.verifyVM.userInfoModel.isLogin) {
                  RouterUtils.pushPathByName(RouterMap.VERIFY_PAGE,
                    { 'rate': this.verifyVM.fixedAnnualRate } as Record<string, number>)
                } else {
                  LoginSheetUtils.open()
                }
              }
            })
            StepIntroduceCard()

            Image(this.verifyVM.breakPointModel.currentBreakpoint === 'sm' ? $r('app.media.learn_more_banner') :
            $r('app.media.learn_more_banner_lg'))
              .width('100%')
              .aspectRatio(this.verifyVM.breakPointModel.currentBreakpoint === 'sm' ? 2.15 / 1 : 6.29 / 1)
              .borderRadius(CommonConstants.PADDING_S)
              .onClick(() => {
                RouterUtils.pushPathByName(RouterMap.LEARN_MORE_PAGE)
              })
          }
        }
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .layoutWeight(1)
        .padding({ bottom: CommonConstants.PADDING_S })
        .edgeEffect(EdgeEffect.Spring,{alwaysEnabled:true})
      }
      .padding({
        left: this.homeViewModel.breakPointModel.currentBreakpoint === BreakpointNameEnum.MD ?
        CommonConstants.PADDING_XXL : CommonConstants.PADDING_L,
        right: this.homeViewModel.breakPointModel.currentBreakpoint === BreakpointNameEnum.MD ?
        CommonConstants.PADDING_XXL : CommonConstants.PADDING_L
      })
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .linearGradient({
        angle: 180,
        repeating: false, // 渐变颜色是否重复
        colors: [['#FF317AF7', 0.0], ['#FFF1F3F5', 0.4]]
      })
    }
    .hideTitleBar(true)
  }
}