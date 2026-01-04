import {
  BreakpointModel,
  BreakpointNameEnum,
  CommonConstants,
  LinearColumnModifier,
  Logger,
  RouterMap,
  RouterUtils
} from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { FlexLayoutModel } from '../viewmodels/FlexLayoutModel';
import { HomeViewModel } from '../viewmodels/HomeViewModel';
import { AppStorageV2 } from '@kit.ArkUI';
import { HotComponent } from '../components/HotComponent';
import { TvComponent } from '../components/TvComponent';
import { MovieComponent } from '../components/MovieComponent';
import { ChildComponent } from '../components/ChildComponent';
import { TabInfo } from '../model/TabInfoModel';
import { VideoModel } from 'lib_video_api';

@Builder
export function HomePageBuilder() {
  HomePage()
}

const TAG = 'HomePage'

@ComponentV2
struct HomePage {
  @Local homeViewModel: HomeViewModel = new HomeViewModel();
  @Local modifier: LinearColumnModifier = new LinearColumnModifier($r('app.color.home_linear'));
  @Local vm: FlexLayoutModel = new FlexLayoutModel();
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local titleBgValue: ResourceColor = 'rgba(255, 255, 255, 0)'
  @Local scrollLength: number = 0
  @Local selectedItemHeight: number = 8

  aboutToAppear(): void {
    this.vm.init(0)
  }

  build() {
    NavDestination() {
      Column() {
        Stack() {
          Column() {
            Refresh({ refreshing: this.vm.isRefreshing }) {
              Scroll() {
                Column() {
                  if (this.vm.isRefreshing) {
                    Row() {
                      Text(this.vm.refreshText)
                        .fontSize(14)
                        .margin({ left: 8 })
                        .fontColor('#E6000000')
                    }
                    .alignItems(VerticalAlign.Center)
                    .justifyContent(FlexAlign.Center)
                    .width('100%')

                  } else {
                    Text(this.vm.refreshText)
                      .fontSize(14)
                      .fontColor('#99000000')// 浅色文本，避免突兀
                      .width('100%')
                      .textAlign(TextAlign.Center)
                  }
                  Stack({ alignContent: Alignment.Top }) {
                    Swiper() {
                      ForEach(this.vm.swiperList.slice(0, 5), (swiper: VideoModel) => {
                        Column() {
                          Stack() {
                            Image(swiper.coverUrl)
                              .width('100%')
                              .aspectRatio(this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM ? 1 : 1.5)
                              .onClick(() => {
                                const param: Record<string, Object> = {
                                  'videoId': swiper.videoId
                                }
                                RouterUtils.pushPathByName(RouterMap.PLAY_PAGE, param);
                              })
                            Row() {
                            }
                            .linearGradient({
                              direction: GradientDirection.Bottom,
                              repeating: true,
                              colors: [['#90FFFFFF', 0], ['#00FFFFFF', 1]]
                            })
                            .width('100%')
                            .height(this.vm.windowModel.windowTopPadding * 2.5)
                          }.align(Alignment.Top)

                          Row({ space: this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM ? 5 : 8 }) {
                            Text(swiper.videoType)
                              .fontColor(Color.White)
                              .padding({
                                left: 3,
                                right: 3,
                              })
                              .fontSize(this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM ? 8 : 11)
                              .lineHeight(this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM ? 12 : 17)
                              .backgroundColor('#33FFFFFF')
                              .border({ width: 1, color: '#1AFFFFFF', radius: 3 })
                            Text(swiper.title)
                              .fontColor(Color.White)
                              .fontSize(this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM ? 12 : 17)
                              .lineHeight(this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM ? 12 : 17)
                            Text(':')
                              .fontColor(Color.White)
                              .fontSize(this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM ? 12 : 17)
                              .lineHeight(this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM ? 12 : 17)
                            Text(swiper.subTitle)
                              .fontColor(Color.White)
                              .fontSize(this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM ? 12 : 17)
                              .lineHeight(this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM ? 12 : 17)
                          }
                          .width('100%')
                          .justifyContent(FlexAlign.Start)
                          .position({
                            left: 20,
                            bottom: 26
                          })
                        }
                      }, (swiper: VideoModel) => JSON.stringify(swiper))
                    }
                    .autoPlay(true)
                    .interval(3000)
                    .loop(true)
                    .width('100%')
                    .onChange((index: number) => {
                      this.vm.swiperIndex = index;
                    })
                    .indicator(new DotIndicator()
                      .itemWidth((px2vp(this.vm.windowModel.windowWidth) - 20 * 2 - 4 * 8) / 5)
                      .itemHeight(this.selectedItemHeight / 4)
                      .selectedItemWidth((px2vp(this.vm.windowModel.windowWidth) - 20 * 2 - 4 * 8) / 5)
                      .selectedItemHeight(this.selectedItemHeight / 4))

                    this.rightHeadPartBuilder()
                  }

                  Row() {
                    this.contentBuilder()
                  }

                  Column() {
                    if (this.homeViewModel.settingInfo.teenagersSwitch) {
                      ChildComponent()
                    } else {
                      if (this.vm.currentIndex === 0) {
                        HotComponent().padding({
                          left: CommonConstants.PADDING_PAGE,
                          right: CommonConstants.PADDING_PAGE,
                        })
                      } else if (this.vm.currentIndex === 1) {
                        TvComponent().padding({
                          left: CommonConstants.PADDING_PAGE,
                          right: CommonConstants.PADDING_PAGE,
                        })
                      } else if (this.vm.currentIndex === 2) {
                        MovieComponent().padding({
                          left: CommonConstants.PADDING_PAGE,
                          right: CommonConstants.PADDING_PAGE,
                        })
                      } else if (this.vm.currentIndex === 3) {
                        ChildComponent()
                      }
                    }

                  }
                }.alignItems(HorizontalAlign.Start)
              }
              .scrollBar(BarState.Off)
              .align(Alignment.Top)
              .edgeEffect(EdgeEffect.Spring)
              .width('100%')
              .height('100%')
              .onDidScroll((xOffset: number, yOffset: number, scrollState: ScrollState) => {
                Logger.info(TAG, xOffset + JSON.stringify(scrollState))
                this.scrollLength += yOffset
                let opacity: number = 1
                if (this.scrollLength / this.vm.windowModel.windowTopPadding < 1) {
                  opacity = this.scrollLength / this.vm.windowModel.windowTopPadding
                }
                this.titleBgValue = `rgba(255, 255, 255, ${opacity})`
              })
            }
            .onRefreshing(() => {
              this.vm.refreshData()
            })
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)

          Row() {
          }
          .width('100%')
          .height(this.vm.windowModel.windowTopPadding)
          .backgroundColor(this.titleBgValue)
        }
        .align(Alignment.Top)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('sys.color.background_primary'))
      .attributeModifier(this.modifier)
    }
    .hideTitleBar(true)
  }

  @Builder
  rightHeadPartBuilder() {
    Column({ space: 8 }) {
      NavHeaderBar({
        title: '首页',
        isSubTitle: false,
        titleColor: Color.White
      })
      Row({ space: CommonConstants.SPACE_S }) {
        Row({ space: 8 }) {
          Image($r('app.media.icon_input_search')).width(16).height(16)
          Text(this.vm.placeValue).fontColor('#B3FFFFFF')
        }
        .width('100%')
        .height(40)
        .backdropBlur(30)
        .borderRadius(20)
        .backgroundColor('#33FFFFFF')
        .padding({ left: 12 })
        .onClick(() => {
          RouterUtils.pushPathByName(RouterMap.NEWS_SEARCH)
        })
      }.padding({ left: 16, right: 16 })
    }
  } //font_emphasize

  @Builder
  contentBuilder() {
    List({ space: 8 }) {
      // 青少年模式下只显示少儿内容（索引为3）
      if (this.homeViewModel.settingInfo.teenagersSwitch) {
        ForEach(this.vm.tabList.filter((item: TabInfo, index: number) => index === 3),
          (item: TabInfo) => {
            ListItem() {
              Row({ space: 8 }) {
                Image(item.selectIcon).width(16).height(16)
                Text(item.text)
                  .fontSize(14)
                  .lineHeight(16)
                  .fontColor('#FFFFFFFF')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .textAlign(TextAlign.Center)
              }
              .borderRadius(21)
              .padding({
                left: 16,
                right: 16,
                top: 8,
                bottom: 8
              })
              .backgroundColor('#FFFD603E')
              .onClick(() => {
                this.vm.currentIndex = 3;
                this.vm.currentIndexChange(this.vm.currentIndex)
              })
            }
          }, (item: TabInfo) => JSON.stringify(item))
      } else {
        // 正常模式下显示所有tab
        ForEach(this.vm.tabList, (item: TabInfo, index: number) => {
          ListItem() {
            Row({ space: 8 }) {
              Image(this.vm.currentIndex === index ? item.selectIcon : item.icon)
                .width(16)
                .height(16)
              Text(item.text)
                .fontSize(14)
                .lineHeight(16)
                .fontColor(this.vm.currentIndex === index ? '#FFFFFFFF' : '#E6000000')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .textAlign(TextAlign.Center)
            }
            .borderRadius(21)
            .padding({
              left: 16,
              right: 16,
              top: 8,
              bottom: 8
            })
            .backgroundColor(this.vm.currentIndex === index ? '#FFFD603E' : '#0D000000')
            .onClick(() => {
              if (index === 4) {
                RouterUtils.pushPathByName(RouterMap.ALL_PAGE);
              } else {
                this.vm.currentIndex = index;
                this.vm.currentIndexChange(this.vm.currentIndex)
              }
            })
          }
        }, (item: TabInfo) => JSON.stringify(item))
      }
    }
    .listDirection(Axis.Horizontal)
    .padding({
      left: 8,
      right: 8,
      top: 14,
      bottom: 0
    })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }
}