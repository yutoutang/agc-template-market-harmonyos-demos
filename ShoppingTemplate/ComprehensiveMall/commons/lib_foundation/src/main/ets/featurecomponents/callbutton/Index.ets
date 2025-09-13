import { call } from '@kit.TelephonyKit';

@ComponentV2
export struct CallButton {
  @Local
  public isOpen: boolean = false;
  @BuilderParam
  public contentBuilder: () => void = buildEmptyComponent;

  build(): void {
    Column() {
      Column() {
        this.contentBuilder();
      }
      .onClick(() => {
        this.isOpen = true;
      })
      .bindSheet(
        $$this.isOpen,
        buildMakeCallComponent(() => this.isOpen = false),
        {
          title: this.buildTitle(),
          dragBar: true,
          detents: [SheetSize.FIT_CONTENT],
        })
    }
  }

  @Builder
  buildTitle() {
    Text('联系客服')
      .fontSize(18)
      .fontColor('#E6000000')
      .fontWeight(500)
  }
}

@Builder
export function buildMakeCallComponent(handleClose?: () => void) {
  Column() {
    Column() {
      Text('012****7890')
        .fontSize(18)
        .fontColor('#E6000000')
        .lineHeight(30)
        .halfLeading(true)
      Button() {
        Row() {
          Image($r('app.media.ic_phone'))
            .height(24)
            .objectFit(ImageFit.Contain)
            .margin({ right: 5 })
          Text('一键拨号')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(600)
        }
      }
      .width('100%')
      .height(45)
      .type(ButtonType.Normal)
      .backgroundColor('#FFE64566')
      .borderRadius($r('sys.float.corner_radius_level10'))
      .onClick(() => {
        if (canIUse('SystemCapability.Applications.Contacts')) {
          call.makeCall('01234567890');
        }
        handleClose?.()
      })

      Button('取消')
        .width('100%')
        .height(45)
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor('#0D000000')
        .onClick(() => handleClose?.())
    }
    .width('100%')
    .height(170)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceEvenly)
  }
  .width('100%')
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Start)
  .padding({
    left: 16,
    right: 16,
    bottom: 32,
    top: 8,
  })
}

@Builder
function buildEmptyComponent() {
  // No need to do anything
}
