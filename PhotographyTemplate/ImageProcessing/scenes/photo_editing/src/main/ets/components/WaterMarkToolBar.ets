import { componentSnapshot } from '@kit.ArkUI';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';


@ComponentV2
export struct WaterMarkToolBar {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;

  build() {
    Column({ space: 16 }) {
      Row() {
        Image($r('app.media.xmark'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.vm.barIndex = -1;
          });

        Image($r('app.media.checkMark'))
          .width(24)
          .height(24)
          .onClick(async () => {
            this.vm.waterMarkPixelMap = componentSnapshot.getSync(this.vm.waterMarkId);
            this.vm.saveWaterMark(this.getUIContext());
          });
      }
      .height(24)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);

      Column({ space: 4 }) {
        Image($r('app.media.no_sign')).width(24);
        Text('还原').fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'));
      }.onClick(() => {
        this.vm.barIndex = -1;
      });

    }
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 14,
    })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius({ topLeft: 16, topRight: 16 })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
  }
}