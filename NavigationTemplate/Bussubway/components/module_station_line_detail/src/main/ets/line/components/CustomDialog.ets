import { CommentEventDispatcher } from '../utils/EventDispatcher';

@CustomDialog
export struct CustomDialogExampleTwo {
  controller: CustomDialogController;
  dialogTitle: string = '';
  isArrivalReminder: boolean = false
  routeSettingPage?: () => void
  opeArrivalReminder?: (isArrivalReminder: boolean) => void

  build() {
    Column() {
      Row() {
        Text(this.dialogTitle)
          .fontSize(20)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
      }
      .height(54)

      Row() {
        Text() {
          Span('可在设置里修改提醒提前的站数或分钟数 ')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
          Span('去设置')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.brand'))
            .onClick(() => {
              CommentEventDispatcher.dispatchToInterceptLogin((isLogin: boolean) => {
                if (isLogin || isLogin === undefined) {
                  this.controller.close()
                  if (this.routeSettingPage) {
                    this.routeSettingPage()
                  }
                }
              })
            })
        }
      }
      .height(64)
      .margin({
        top: 16,
        bottom: 8
      })

      Row() {
        Row() {
          Text('取消')
            .textAlign(TextAlign.Center)
            .width('100%')
            .fontColor($r('sys.color.font_tertiary'))
            .fontSize($r('sys.float.Body_L'))

        }
        .width('50%')
        .onClick(() => {
          this.controller.close()
        })

        Divider().vertical(true)
        Row() {
          Text('确定')
            .textAlign(TextAlign.Center)
            .width('100%')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_emphasize'))
        }
        .width('50%')
        .onClick(() => {
          this.controller.close()
          if (this.opeArrivalReminder) {
            this.opeArrivalReminder(!this.isArrivalReminder)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceAround)
    }
    .height(210)
    .padding({
      top: 16,
      bottom: 16,
      left: 24,
      right: 24
    });
  }
}