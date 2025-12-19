import { MyStorage, speedArr, speeds } from '../models/SpeedData';

@ComponentV2
export struct SpeedSegmentButton {

  @Local storage: MyStorage = MyStorage.instance()
  @Event onSpeedSet: Function = (speed: number) => {}

  build() {
    Row() {
      ForEach(speeds, (item: string) => {
        Button(item)
          .width('20%')
          .height(36)
          .fontSize($r('sys.float.Body_M'))
          .padding('2px 8px 8px 2px')
          .borderRadius('18px')
          .fontColor(this.storage.selectSpeed === item ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
          .backgroundColor(this.storage.selectSpeed === item ? '#fff' : 'transparent')
          .shadow(this.storage.selectSpeed === item ? { color:'#3000', radius:3 } : { color:'transparent', radius:0 })
          .onClick(() => {
            this.storage.selectSpeed = item
            this.onSpeedSet(speedArr[speeds.indexOf(item)])
          })
      }, (speed: string) => speed)
    }
    .width('100%')
    .height(36)
    .borderRadius(18)
    .backgroundColor('#0d000000')
  }
}
