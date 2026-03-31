import { call } from '@kit.TelephonyKit';
import { baseActionSheet } from 'base_common';
import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum, Constants, TCRouter } from 'common'

@ComponentV2
export struct ServiceCard {
  @Consumer('tabController') tabsController: TabsController = new TabsController();
  @Consumer('currentIndexTab') currentIndexTab: number = 0;
  @Consumer('isHistory') isHistory: boolean = false;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint

  build() {
    Column() {
      Row() {
        Text('常用服务')
          .height(24)
          .width(72)
          .fontSize(18)
          .fontWeight(500)
          .width(Constants.FULL_SIZE)
          .textAlign(TextAlign.Start)
      }
      .padding({ bottom: 12 })
      .width(Constants.FULL_SIZE)

      Column({ space: 8 }) {
        if (this.curBreakpoint.value === BreakpointTypeEnum.SM) {
          this.serviceButtonView('app.media.ic_reading_history', 'app.string.reading_history', true, () => {
            this.currentIndexTab = 0;
            this.tabsController.changeIndex(0)
            this.isHistory = true
          })
          this.serviceButtonView('app.media.ic_public_office_brush', 'app.string.my_evaluation', true, () => {
            TCRouter.push(Constants.MY_EVALUATION_ROUTE);
          })
          this.serviceButtonView('app.media.ic_reading_preference', 'app.string.reading_preference', true, () => {
            TCRouter.push(Constants.PREFERENCE_ROUTE);
          })
          this.serviceButtonView('app.media.ic_contact', 'app.string.contact', true, () => {
            baseActionSheet.show({
              id: 'PhoneSheetBuilder',
              title: { title: '联系客服' },
              height: SheetSize.FIT_CONTENT,
              preferType: SheetType.CENTER,
              backgroundColor: $r('sys.color.ohos_id_color_toolbar_bg'),
              customContent: () => {
                this.PhoneSheetBuilder()
              },
            })
          })
        } else {
          Row({ space: 12 }) {
            this.serviceButtonView('app.media.ic_reading_history', 'app.string.reading_history', false, () => {
              this.currentIndexTab = 0;
              this.tabsController.changeIndex(0)
              this.isHistory = true
            })
            this.serviceButtonView('app.media.ic_public_office_brush', 'app.string.my_evaluation', false, () => {
              TCRouter.push(Constants.MY_EVALUATION_ROUTE);
            })
          }
          .width('100%')

          Row({ space: 12 }) {
            this.serviceButtonView('app.media.ic_reading_preference', 'app.string.reading_preference', false, () => {
              TCRouter.push(Constants.PREFERENCE_ROUTE);
            })
            this.serviceButtonView('app.media.ic_contact', 'app.string.contact', false, () => {
              baseActionSheet.show({
                id: 'PhoneSheetBuilder',
                title: { title: '联系客服' },
                height: SheetSize.FIT_CONTENT,
                preferType: SheetType.CENTER,
                backgroundColor: $r('sys.color.ohos_id_color_toolbar_bg'),
                customContent: () => {
                  this.PhoneSheetBuilder()
                },
              })
            })
          }
        }
        this.serviceButtonView('app.media.ic_issue_and_feedback','app.string.issue_and_feedback',true,() => {
          TCRouter.push(Constants.ISSUE_AND_FEEDBACK_ROUTE);
        })
      }
    }
  }

  @Builder
  serviceButtonView(iconUrl: string, serviceText: string, isSM: boolean, onCall?: () => void) {
    Row() {
      Image($r(iconUrl))
        .height(24)
        .width(24)
        .fillColor([$r('sys.color.icon_primary')])
        .objectFit(ImageFit.Contain)
        .margin({
          right: 12
        })

      Text($r(serviceText))
        .fontColor($r('sys.color.font_primary'))
    }
    .layoutWeight(isSM ? 0 : 1)
    .height(47)
    .width(isSM ? Constants.FULL_SIZE : 'auto')
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding({
      left: 12,
      right: 12
    })
    .onClick(() => {
      onCall?.()
    })
  }

  @Builder
  PhoneSheetBuilder() {
    Column({ space: 12 }) {
      Text('000000')
        .fontSize(18)
        .fontWeight('medium')
      Column({ space: 12 }){
        Row({ space: 8 }) {
          Text('一键拨号')
            .fontSize(16)
            .fontWeight('medium')
            .fontColor($r('app.color.pure_white'))
        }
        .padding({ top: 10, bottom: 10 })
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .borderRadius(20)
        .backgroundColor('#E84026')
        .onClick(() => {
          try {
            call.makeCall('000000')
          } catch (err) {
            console.error(`makeCall fail, err->${JSON.stringify(err)}`);
          }
        })

        Row() {
          Text('取消')
            .fontSize(16)
            .fontWeight('medium')
            .fontColor('#ffffff')
        }
        .padding({ top: 10, bottom: 10 })
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .borderRadius(20)
        .backgroundColor(Color.Gray)
        .onClick(() => {
          baseActionSheet.close('PhoneSheetBuilder')
        })
      }
    }
    .height(180)
    .justifyContent(FlexAlign.SpaceBetween)
    .width('90%')
    .padding({
      left: 12,
      right: 12,
      bottom: 16,
      top: 16
    })
    .margin({ bottom: 40, left: 16, right: 16 })
    .backgroundColor($r('sys.color.ohos_id_color_toolbar_bg'))
    .borderRadius(16)
  }
}