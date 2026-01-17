import { Constants } from 'common';

@ComponentV2
export struct DeleteBottomCard {
  @Event delete: () => void = () => {
  };
  build() {
    Row() {
      Column({ space: 5 }) {
        Image($r('app.media.ic_public_trash'))
          .height(24)
          .width(24)
          .margin({ top: 5 })
        Row() {
          Text($r('app.string.delete'))
        }
      }
      .onClick(() => {
        this.getUIContext().getPromptAction().showDialog({
          title: $r('app.string.delete_book_flag'),
          message: $r('app.string.q_delete_book_flag'),
          buttons: [
            {
              text: $r('app.string.cancel'),
              color: $r('app.color.button_color')
            },
            {
              text: $r('app.string.delete'),
              color: $r('app.color.button_color')
            }
          ]
        }, (err, data) => {
          if(data.index === 1){
            this.delete();
            this.getUIContext().getPromptAction().showToast({ message: $r('app.string.delete_book_success') })
          }
        })
      })
      .height(70)
    } .height(70)
    .width(Constants.FULL_SIZE)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Center)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}