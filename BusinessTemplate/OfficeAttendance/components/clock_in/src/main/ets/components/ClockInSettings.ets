import { DataManager } from '../controller/DataManagerController';

@ComponentV2
export struct ClockInSettings {
  @Local isQuickCheckIn: boolean = DataManager.isQuickCheckIn();

  build() {
    Stack() {
        Column() {
          Row() {
            Column() {
              Text($r('app.string.quick_checkin'))
                .fontColor($r('app.string.black_90'))
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .height(24)
                .margin({ top: 6 })
              Text($r('app.string.quick_checkin_desc'))
                .fontColor($r('app.string.black_60'))
                .fontSize(12)
                .fontWeight(FontWeight.Regular)
                .height(16)
                .margin({ top: 2 })
            }.alignItems(HorizontalAlign.Start)

            Toggle({ type: ToggleType.Switch, isOn: this.isQuickCheckIn })
              .onChange((isOn: boolean) => {
                DataManager.saveIsQuickCheckIn(isOn);
              })

          }.height(56).width('100%').justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
        }
        .padding({ left: 16, right: 16 })
      }.alignContent(Alignment.Bottom)
  }
}