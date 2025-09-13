import { call } from '@kit.TelephonyKit';
import { promptAction } from '@kit.ArkUI';
import { Constant, HotlineInfo } from 'module_base';

@ComponentV2
export struct Hotline {
  @Param @Require hotlines: HotlineInfo[];

  build() {
    Column({ space: 12 }) {
      ForEach(this.hotlines, (item: HotlineInfo) => {
        Row() {
          Column({ space: 2 }) {
            Text(item.phone).fontColor('#64BB5C');
            Text(item.title).fontSize(14).opacity(0.6);
          }.alignItems(HorizontalAlign.Start);
        }
        .padding({
          left: 12,
          right: 12,
          top: 24,
          bottom: 24,
        })
        .backgroundColor($r('sys.color.font_on_primary'))
        .borderRadius(8)
        .width(Constant.FULL_PERCENT)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .onClick(() => {
          call.makeCall(item.phone, (err) => {
            if (err) {
              promptAction.showToast({ message: '拨打号码失败' });
            }
          });
        });
      }, (item: HotlineInfo) => item.title.toString());
    }.padding({ left: 12, right: 12 });
  }
}