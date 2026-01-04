import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonConstants, Logger, RouterMap, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { mineGridList } from '../constants/Constants';
import {
  AntiFraudList,
  loanList,
  MineGridItem,
  QuestionInfo,
  questionList,
  TabInfo,
  tabInfoList
} from '../types/Types';
import { ContactViewModel } from '../viewmodels/ContactVM';


const TAG: string = '[ContactPageCallDialog]'

@Builder
export function ContactPageBuilder() {
  ContactPage()
}

@ComponentV2
struct ContactPage {
  @Local vm: ContactViewModel = new ContactViewModel();
  @Local showSheet: boolean = false

  aboutToAppear(): void {
    this.vm.init()
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '联系我们',
      })
      Scroll() {

        Column({ space: CommonConstants.SPACE_M }) {

          this.gridCard()
          this.tabsCard()
        }
      }
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .padding({
        left: CommonConstants.PADDING_PAGE,
        right: CommonConstants.PADDING_PAGE,
        top: CommonConstants.SPACE_M
      })
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .bindSheet($$this.showSheet, this.callDialogBuilder(this.vm.onLinePhone ?? ''), {
      title: { title: '联系客服' },
      height: 280,
      dragBar: true,
      backgroundColor: $r('app.color.background_color_grey'),
      preferType: SheetType.CENTER
    })
    .padding({ bottom: CommonConstants.SPACE_XL })
  }

  @Builder
  gridCard() {
    Column() {
      Grid() {
        ForEach(mineGridList, (v: MineGridItem) => {
          GridItem() {
            Column({ space: 8 }) {
              Image(v.icon)
                .width(32)
                .height(32)
                .draggable(false)
              Text(v.label)
                .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                .fontColor($r('sys.color.font_primary'))
            }
            .height(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(HorizontalAlign.Center)
            .padding({
              top: CommonConstants.PADDING_S,
              bottom: CommonConstants.PADDING_S,
              left: CommonConstants.PADDING_XS,
              right: CommonConstants.PADDING_XS,
            })
          }
          .borderRadius($r('app.float.large_radius'))
          .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles,
          })
          .padding({
            top: CommonConstants.PADDING_S,
            bottom: CommonConstants.PADDING_S,
            left: CommonConstants.PADDING_XS,
            right: CommonConstants.PADDING_XS,
          })
          .onClick(() => {
            if (v.label === '电话客服') {
              this.showSheet = true;
            } else {
              this.vm.gridClick(v);
            }
          })
        }, (v: MineGridItem) => v.label as string)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(88)
      .columnsTemplate('1fr 1fr 1fr 1fr')
    }
    .padding({
      top: CommonConstants.PADDING_XS,
      bottom: CommonConstants.PADDING_XS,
      left: CommonConstants.PADDING_XS,
      right: CommonConstants.PADDING_XS,
    })
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius($r('app.float.large_radius'))
  }

  @Builder
  tabsCard() {
    Column() {
      Tabs({ index: this.vm.currentIndex }) {
        ForEach(tabInfoList, (tab: TabInfo, index: number) => {
          TabContent() {
            if (this.vm.currentIndex === 0) {
              // 第一个标签（如“常见问题”）的内容组件
              this.questionBuilder(questionList)
            } else if (this.vm.currentIndex === 1) {
              this.questionBuilder(loanList)
            } else {
              this.questionBuilder(AntiFraudList)
            }
          }
          .tabBar(this.tabBarItemBuilder(tab, index))
        }, (tab: TabInfo) => tab.id)
      }
      .onChange((index: number) => {
        this.vm.currentIndex = index;
        this.vm.currentIndexChange(this.vm.currentIndex)
      })
      .barHeight(48)
      .vertical(false)
      .height('auto')
    }
    .padding({
      top: CommonConstants.PADDING_XS,
      bottom: CommonConstants.PADDING_XS,
      left: CommonConstants.PADDING_XS,
      right: CommonConstants.PADDING_XS,
    })
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius($r('app.float.large_radius'))
  }

  @Builder
  questionBuilder(list: QuestionInfo[]) {
    Column() {
      List({ space: CommonConstants.PADDING_XS }) {
        ForEach(list, (question: QuestionInfo, index: number) => {
          ListItem() {
            Row({ space: 4 }) {
              Text(`${index + 1}`)
                .fontSize(16)
                .fontColor($r('sys.color.font_tertiary'))
                .lineHeight(19)
                .padding({
                  left: CommonConstants.PADDING_XSS,
                  right: CommonConstants.PADDING_XSS,
                  top: CommonConstants.PADDING_XXS,
                  bottom: CommonConstants.PADDING_XXS
                })
              Text(question.text)
                .fontSize(16)
                .fontColor($r('sys.color.font_primary'))
                .lineHeight(19)
            }
            .padding({ top: CommonConstants.PADDING_S, bottom: CommonConstants.PADDING_S })
            .onClick(() => {
              //   跳转到详情页
              const param: Record<string, Object> = {
                'question': question
              }
              RouterUtils.pushPathByName(RouterMap.PROBLEM_DETAILS, param);
            })
          }

        }, (question: string) => question)
      }
      .width('100%')
      .height('auto')
      .padding({ left: CommonConstants.PADDING_M, right: CommonConstants.PADDING_M })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .nestedScroll({
        scrollForward: NestedScrollMode.SELF_FIRST,
        scrollBackward: NestedScrollMode.PARENT_FIRST
      })
    }
  }

  @Builder
  tabBarItemBuilder(tab: TabInfo, tabIndex: number) {
    Column({ space: 4 }) {
      Text(tab.text)
        .fontSize(14)
        .lineHeight(16)
        .fontWeight(this.vm.currentIndex === tabIndex ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.vm.currentIndex === tabIndex ? '#FF317AF7' : '#99000000')
      Blank()
        .height(1)
        .width(28)
        .borderRadius(1)
        .backgroundColor(this.vm.currentIndex === tabIndex ? '#FF317AF7' : Color.Transparent)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.interactive_pressed'))
  }

  @Builder
  callDialogBuilder(phone: string) {
    Column() {
      Text(phone)
        .fontColor($r('app.color.font_color_level1'))
        .fontSize($r('app.string.font_size_20'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: $r('app.string.space_m') });

      Button() {
        Row() {
          Image($r('sys.media.ohos_ic_public_phone'))
            .fillColor($r('sys.color.white'))
            .width(16)
            .height(16)
            .margin({ right: $r('app.string.space_m') });
          Text('一键拨号')
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium);
        };
      }
      .width($r('app.string.size_percent_100'))
      .height(40)
      .backgroundColor($r('app.color.theme_color'))
      .margin({ bottom: $r('app.string.space_m') })
      .onClick(() => {
        try {
          if (!phone) {
            this.toast('号码传入错误')
          }
          if (canIUse('SystemCapability.Applications.Contacts')) {
            call.makeCall(phone, (error: BusinessError) => {
              if (error) {
                Logger.error(TAG, 'make call fail, error is: ' + JSON.stringify(error));
              } else {
                Logger.info(TAG, 'make call success.');
              }
            });
          } else {
            this.toast('当前设备暂不支持一键拨号')
          }
        } catch (error) {
          Logger.error(TAG, 'make call error: ' + JSON.stringify(error));
        }
      });

      Button('取消')
        .backgroundColor($r('app.color.background_color_grey'))
        .fontColor($r('sys.color.font_tertiary'))
        .fontWeight(FontWeight.Medium)
        .height(40)
        .width($r('app.string.size_percent_100'))
        .onClick(() => {
          this.showSheet = false
        });

    }
    .backgroundColor($r('app.color.background_color_white'))
    .padding($r('app.string.space_l'))
    .margin($r('app.string.space_l'))
    .borderRadius($r('app.string.border_radius_16'))
    .backgroundColor($r('app.color.background_color_white'))
  }

  toast(message: string) {
    try {
      this.getUIContext().getPromptAction().showToast({ message })
    } catch (err) {
      Logger.error(TAG, 'show toast failed.error: ' + JSON.stringify(err))
    }
  }
}
