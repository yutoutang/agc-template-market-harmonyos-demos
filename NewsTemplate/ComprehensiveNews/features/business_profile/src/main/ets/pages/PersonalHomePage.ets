import { CommonConstants } from 'lib_common';
import { FlexLayoutPage } from 'lib_flex_layout';
import { NewsEnum, RequestListData } from 'lib_news_api';
import { emptyBuilder, NavHeaderBar } from 'lib_widget';
import { LayoutNewsDataSource } from '../common/DataSource';
import { TabBar } from '../components/TabBar';
import { UserIntro } from '../components/UserIntro';
import { UniformNews } from '../components/UniformNews';
import { PersonalPageViewModel } from '../viewmodels/PersonalHomeVM';
import { WatchButton } from '../components/WatchButton';
import { Constants } from '../common/Constants';

@Builder
export function PersonalHomePageBuilder() {
  PersonalHomePage()
}

@ComponentV2
struct PersonalHomePage {
  @Local vm: PersonalPageViewModel = new PersonalPageViewModel();

  aboutToAppear(): void {
    this.vm.init();
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          rightPartBuilder: () => {
            this.rightPartBuilder()
          },
        })
        Refresh({ refreshing: $$this.vm.loading }) {
          Scroll() {
            Column({ space: CommonConstants.SPACE_M }) {
              UserIntro({
                userInfo: this.vm.userInfo!,
                fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
                refreshProfileHomePage: () => {
                  this.vm.queryAuthorInfo()
                },
              })
              this.contentBuilder()
            }
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
          .edgeEffect(EdgeEffect.None)
          .onReachEnd(() => {
            this.vm.showInfoTop = true;
          })
          .onReachStart(() => {
            this.vm.showInfoTop = false;
          })
        }
        .layoutWeight(1)
        .accessibilityLevel('no')
        .onRefreshing(() => {
          this.vm.onRefreshing();
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .linearGradient({
      direction: GradientDirection.Bottom,
      repeating: false,
      colors: [[$r('app.color.profile_bg1'), 0.0], [$r('app.color.profile_bg2'), 1]],
    })
  }

  @Builder
  contentBuilder() {
    Column() {
      TabBar({
        selectedId: this.vm.targetIndex,
        fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
        onClickBar: (id: number) => {
          this.vm.curIndex = id;
          this.vm.targetIndex = id;
        },
      })
      Tabs({ index: this.vm.curIndex }) {
        ForEach(this.vm.dataSource, (v: LayoutNewsDataSource, index: number) => {
          TabContent() {
            if (v.totalCount() > 0) {
              this.listBuilder(v, index)
            } else {
              Column() {
                emptyBuilder({
                  fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
                })
              }
              .layoutWeight(1)
              .padding({
                bottom: 150,
              })
            }
          }
        }, (v: LayoutNewsDataSource, index: number) => index.toString())
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
      .align(Alignment.Top)
      .barHeight(0)
      .onAnimationStart((index: number, targetIndex: number) => {
        this.vm.targetIndex = targetIndex;
      })
      .onChange((index: number) => {
        this.vm.curIndex = index;
      })
    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius({ topLeft: $r('app.float.xxl_radius'), topRight: $r('app.float.xxl_radius') })
    .padding({
      left: this.vm.breakPointModel.pagePadding,
      right: this.vm.breakPointModel.pagePadding,
      bottom: this.vm.windowModel.windowBottomPadding,
    })
  }

  @Builder
  listBuilder(v: LayoutNewsDataSource, index: number) {
    WaterFlow() {
      LazyForEach(v, (item: RequestListData) => {
        FlowItem() {
          if ([NewsEnum.Article, NewsEnum.Video].includes(index)) {
            UniformNews({
              newsInfo: item.articles[0],
              fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
            })
          } else {
            FlexLayoutPage({
              setting: JSON.parse(item.navInfo.setting),
              articles: item.articles,
              extraInfo: item.extraInfo,
            })
          }
        }
        .width(CommonConstants.FULL_PERCENT)
      }, (item: RequestListData) => JSON.stringify(item))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .cachedCount(1)
    .columnsTemplate(this.vm.getColumnsTemplate())
    .columnsGap(CommonConstants.SPACE_XXL)
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST,
    })
  }

  @Builder
  rightPartBuilder() {
    Row({ space: CommonConstants.SPACE_XS }) {
      Row() {
        Image(this.vm.userInfo?.authorIcon)
          .width(Constants.SMALL_USER_ICON_W)
          .aspectRatio(1)
          .borderRadius(CommonConstants.HALF_PERCENT)
          .clip(true)
          .margin({
            left: CommonConstants.PADDING_S,
          })
        Text(this.vm.userInfo?.authorNickName)
          .fontSize($r('sys.float.Subtitle_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: `calc(100% - ${this.vm.authorNameMaxWidth}vp)` })
          .margin({
            left: CommonConstants.PADDING_M,
          })
        Row() {
          WatchButton({
            author: this.vm.userInfo!,
          })
        }
        .margin({
          left: CommonConstants.PADDING_L,
        })
        .visibility(this.vm.isMyself ? Visibility.Hidden : Visibility.Visible)
      }
      .layoutWeight(1)
      .visibility(this.vm.showInfoTop ? Visibility.Visible : Visibility.Hidden)

      Button() {
        SymbolGlyph($r('sys.symbol.envelope'))
          .fontColor([$r('sys.color.font_primary')])
          .fontWeight(FontWeight.Normal)
          .fontSize(24)
      }
      .attributeModifier(this.vm.buttonModifier)
      .accessibilityText('私信')
      .visibility(this.vm.isMyself ? Visibility.None : Visibility.Visible)
      .onClick(() => {
        this.vm.jumpChatPage();
      })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
  }
}