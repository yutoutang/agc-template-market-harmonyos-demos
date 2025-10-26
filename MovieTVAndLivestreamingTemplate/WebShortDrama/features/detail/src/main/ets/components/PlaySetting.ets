import { SpeedSegmentButton } from './SpeedSegmentButton'
import { getString } from '@agctemplate/resources';
import { BulletVM } from '../viewmodels/BulletVM';
import { Preferences } from '../viewdata/Preferences'

@Preview
@ComponentV2
export struct PlaySetting {

  @Param @Require bulletVM: BulletVM
  @Param isShowBullet: boolean = true
  @Event onSpeedSet: Function = (speed: number) => {}
  @Event onBulletSet: Function = (isOn: boolean) => {}
  @Event onClear: Function = (isOn: boolean) => {}
  @Event openBulletSetting: () => void

  build() {
    Column({ space: 12 }) {
      Row() {
        Row() {
          Text(getString('app.string.play_speed_setting'))
            .textStyle(14, FontWeight.Regular)
            .width(56)
            .height(19)
          Column() {
            SpeedSegmentButton({ onSpeedSet: this.onSpeedSet })
              .width(270)
          }
          .margin({ left:12 })
          .height('100%')
        }
        .width('100%')
        .height(36)
      }
      .width('100%')
      .height(48)

      // clear screen
      Row() {
        Text(getString('app.string.clear_screen_switch'))
          .textStyle()
        Toggle({ type: ToggleType.Switch, isOn: Preferences.readData('showControl') })
          .width(36)
          .height(20)
          .selectedColor('#F17F31')
          .onChange((isOn: boolean) => {
            this.onClear(isOn)
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height(48)

      // danmu
      Row() {
        Text(getString('app.string.danmaku_switch'))
          .textStyle()
        Toggle({ type: ToggleType.Switch, isOn: Preferences.readData('isShowBullet') })
          .width(36)
          .height(20)
          .selectedColor('#F17F31')
          .onChange((isOn: boolean) => {
            this.onBulletSet(isOn)
            if(isOn) {
              this.bulletVM.startBullet()
            }else {
              this.bulletVM.closeBullet()
            }
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height(48)

      // set danmu
      Row() {
        Text(getString('app.string.danmaku_setting'))
          .textStyle()

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .scale({ x:2, y:2 })
          .fontColor(['#3000'])
          .onClick(() => {
            this.openBulletSetting()
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height(48)
    }
    .width('100%')
    .height(252)
  }
}

@Extend(Text) function textStyle(size: number = 16, weight: FontWeight = FontWeight.Medium){
  .fontSize(size)
  .fontWeight(weight)
  .fontColor('#e6000000')
}