import { CommonConstants, Logger } from 'lib_common';
import { BaseMineCustomerServiceQA } from 'lib_takeaway_api/src/main/ets/database/MineCustomerServiceQAType';
import { NavHeaderBar } from 'lib_widget';
import { BaseQAComponent } from '../components/BaseQAComponent';
import { MineCustomerServiceViewModel } from '../viewmodels/MineCustomerServiceVM';
import { common } from '@kit.AbilityKit';
import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = '[MineCustomerServicePage]';

@Builder
export function MineCustomerServicePageBuilder() {
  MineCustomerServicePage()
}

@ComponentV2
struct MineCustomerServicePage {
  @Local vm: MineCustomerServiceViewModel = new MineCustomerServiceViewModel();
  @Local isShow: boolean = false
  context: common.UIAbilityContext = getContext() as common.UIAbilityContext;

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '我的客服',
        })
        Scroll() {
          Column({ space: 12 }) {
            Text('热门问题')
              .fontSize(16)
              .fontWeight(FontWeight.Bolder)
            Divider()
              .color($r('sys.color.comp_divider'))
              .strokeWidth('1px')
            List({ space: 25 }) {
              ForEach(this.vm.list, (item: BaseMineCustomerServiceQA) => {
                BaseQAComponent(item, this.vm)
              }, (item: BaseMineCustomerServiceQA, index: number) => JSON.stringify(item))
            }
            .divider({
              strokeWidth: 1,
              startMargin: 1,
              endMargin: 0,
              color: $r('app.color.qa_default_2')
            })
            .width('100%')

          }
          .alignItems(HorizontalAlign.Start)
          .borderRadius(16)
          .backgroundColor($r('app.color.background_color_white'))
          .padding({
            top: 12,
            left: 12,
            right: 16,
            bottom: 12
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.TopStart)
        .edgeEffect(EdgeEffect.Spring)
        .padding({ right: 16, left: 16, top: 8 })

        Column() {
          Button() {
            Row() {
              Text('客服热线')
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_on_primary'))
            }
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(40)
          .backgroundColor($r('app.color.qa_yellow'))
          .margin({ top: CommonConstants.PADDING_S, bottom: CommonConstants.PADDING_S })
          .enabled(true)
          .onClick(() => {
            this.isShow = true
          })
          .bindSheet($$this.isShow, this.myBuilder(this.context), {
            preferType: SheetType.CENTER,
            height: SheetSize.FIT_CONTENT,
            backgroundColor: $r('app.color.phone_background_color'),
            dragBar: true
          })
        }
        .visibility(this.vm.userInfoModel.isLogin ? Visibility.Visible : Visibility.None)
        .padding({
          left: CommonConstants.PADDING_PAGE,
          right: CommonConstants.PADDING_PAGE,
          bottom: this.vm.windowModel.windowBottomPadding,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  myBuilder(context: common.UIAbilityContext) {
    Column({ space: 22 }) {
      Text('联系客服')
        .fontSize(20)
        .fontWeight('medium')

      Column({ space: 12 }) {
        Text('123****901')
          .fontSize(18)
          .fontWeight('medium')

        Row({ space: 8 }) {
          Image($r('app.media.ic_phone'))
            .width(24)
            .height(24)
          Text('一键拨号')
            .fontColor($r('app.color.background_color_white'))
            .fontSize(16)
        }
        .padding({ top: 10, bottom: 10 })
        .width('100%')
        .borderRadius(20)
        .backgroundColor($r('app.color.qa_yellow'))
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          call.makeCall('12345678901',
            (err: BusinessError) => {
              if (err) {
                Logger.error(TAG, `makeCall fail, err->${JSON.stringify(err)}`);
              } else {
                Logger.info(TAG, 'makeCall success');
              }
            });
        })

        Row() {
          Text('取消')
            .fontColor($r('app.color.font_color_gray'))
            .fontSize(16)
        }
        .width('100%')
        .borderRadius(20)
        .padding({ top: 8, bottom: 8 })
        .backgroundColor($r('app.color.background_color_cancel'))
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.isShow = false
        })
      }
      .padding({
        top: 16,
        right: 12,
        left: 12,
        bottom: 16
      })
      .width('100%')
      .borderRadius(16)
      .backgroundColor($r('app.color.background_color_white'))
    }
    .padding({
      left: 16,
      right: 16,
      bottom: 44,
      top: 31
    })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
  }
}