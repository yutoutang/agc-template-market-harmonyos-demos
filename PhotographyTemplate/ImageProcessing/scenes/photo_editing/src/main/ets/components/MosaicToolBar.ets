import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';
import { Constants } from '../constant/Constants';
import { MosaicInfo } from '../model/Index';
import { UserInfoRouter } from 'mine';

@ComponentV2
export struct MosaicToolBar {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;
  userInfoRouter: UserInfoRouter = UserInfoRouter.instance;

  build() {
    Column({ space: 16 }) {
      Row() {
        Image($r('app.media.xmark'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.vm.barIndex = -1;
            this.vm.clearPath();
          });

        Image($r('app.media.checkMark'))
          .width(24)
          .height(24)
          .onClick(() => {
            if (this.vm.hasDrawVip && !this.userInfoRouter.isVip) {
              this.vm.showRemind = true;
              this.getUIContext().getPromptAction().showToast({ message: '成为vip享受很多精彩资源！' });
            } else {
              this.vm.barIndex = -1;
              this.vm.isVipMosaic = false;
              this.vm.hasDrawVip = false;
              this.vm.saveMosaic();
            }

          });
      }
      .height(24)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);

      Grid() {
        GridItem() {
          Image($r('app.media.origin_icon'));
        }.constraintSize({ maxWidth: 67 })
        .onClick(() => {
          this.vm.clearPath();
        });

        ForEach(Constants.mosaicList, (item: MosaicInfo, index) => {
          GridItem() {
            Stack() {
              Image(item.icon);
              if (this.vm.mosaicIndex === index) {
                Column() {
                  Image($r('app.media.checkmark_circle')).width(24);
                }
                .width('100%')
                .height(68)
                .justifyContent(FlexAlign.Center)
                .backgroundColor('rgba(0, 0, 0, 0.3)')
                .borderRadius(8);
              }
            };
          }.constraintSize({ maxWidth: 68, maxHeight: 68 }).onClick(() => {
            this.vm.isVipMosaic = item.isVip;
            this.vm.mosaicSource = item.mosaicSource;
            this.vm.mosaicIndex = index;
            this.vm.createPattern();
            if (this.userInfoRouter.isVip || !item.isVip && !this.vm.hasDrawVip) {
              this.vm.showRemind = false;
            } else {
              this.vm.showRemind = true;
            }
          });
        }, (item: MosaicInfo, index) => item.mosaicSource);
      }.constraintSize({ maxHeight: 68 })
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(16)
      .columnsGap(20);

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