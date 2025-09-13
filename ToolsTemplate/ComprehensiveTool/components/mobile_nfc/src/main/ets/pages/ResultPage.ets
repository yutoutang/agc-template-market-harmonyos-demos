import { ResultInfo, ResultModel } from '../model/Index';
import { getNavPathStack } from '../common/Route';
import { RESULT_INFO_MAP } from '../common/nfc/Common';

@Builder
export function ResultPageBuilder() {
  ResultPage();
}

@ComponentV2
struct ResultPage {
  @Local data: ResultModel = new ResultModel();
  @Local resultInfo: ResultInfo = new ResultInfo();

  aboutToAppear(): void {
    this.resultInfo = RESULT_INFO_MAP.get(this.data?.rtype) ?? new ResultInfo();
    if (this.data.msg) {
      this.resultInfo.hintInfo = this.data.msg;
    }
  }

  build() {
    NavDestination() {
      Column() {
        Image($r('app.media.ic_read_error')).fitOriginalSize(true).margin({ top: 76 });
        Text(this.resultInfo.hintInfo)
          .fontColor($r('sys.color.font_secondary')).fontSize(14).margin({ top: 12, bottom: 160 });

        Button('重试')
          .width('100%')
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor($r('sys.color.background_emphasize'))
          .height(40)
          .onClick(() => {
            if (this.resultInfo.retry) {
              getNavPathStack().pushPathByName('ActionPage', this.data.actionModel);
            } else {
              getNavPathStack().pop();
            }
          });
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .height('100%')
      .padding(16);
    }.hideTitleBar(true).onReady((ctx) => {
      this.data = ctx.pathInfo.param as ResultModel;
    });
  }
}
