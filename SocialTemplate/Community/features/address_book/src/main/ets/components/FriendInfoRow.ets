import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from 'common';

// 好友信息row
@ComponentV2
export struct FriendInfoRow {
  @Param @Require imgSrc: ResourceStr;
  @Param @Require title: ResourceStr;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    Row() {
      Image(this.imgSrc)
        .objectFit(ImageFit.Fill)
        .width($r('app.float.vp_48'))
        .aspectRatio(1)
        .borderRadius($r('sys.float.corner_radius_level6'))

      Blank().width($r('app.float.vp_12'));

      Text(this.title)
        .textAlign(TextAlign.Start)
        .fontSize($r('sys.float.Body_M'))
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Medium)
        .height('100%')
        .layoutWeight(1)
    }
    .backgroundColor(Color.White)
    .width('100%')
    .height($r('app.float.vp_64'))
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .padding({ left: this.breakPointModel.pagePadding, right: this.breakPointModel.pagePadding })
  }
}