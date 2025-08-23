import { PreferConstant, PreferenceUtil } from '@agctemplate/utils'

@ComponentV2
export struct UserInfoRow {
  @Param leftTitle: ResourceStr = ''
  @Param subTitle: string = ''
  @Param rightContent: string = ''
  @Event rightOnClick: () => void
  @Event switchButton: (isOn: boolean) => void
  @Local isToggleOn: boolean = false
  @Param isSwitch: boolean = false

  aboutToAppear(): void {
    this.isToggleOn = PreferenceUtil.getInstance(getContext()).get(
      PreferConstant.BACKGROUND_MINI_WINDOW_PLAYBACK, false) as boolean
  }

  build() {
    Row() {
      Column({ space: 2 }) {
        Text(this.leftTitle)
          .height(21)
        if (this.subTitle) {
          Text(this.subTitle).height(19).fontWeight(400).fontSize(14).fontColor($r('sys.color.font_secondary'))
        }
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
      Text(this.rightContent)
        .height(19)
        .textAlign(TextAlign.End)
        .width(120)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (this.isSwitch) {
        Toggle({ type: ToggleType.Switch, isOn: this.isToggleOn })
          .size({ width: 36, height: 20 })
          .onChange(() => {
            this.isToggleOn = !this.isToggleOn
            if (this.switchButton) {
              this.switchButton(this.isToggleOn)
            }
          })
      } else {
        Image($r('app.media.iconRight'))
          .size({ width: 24, height: 24 })
      }
    }
    .onClick(() => {
      if (this.rightOnClick) {
        this.rightOnClick()
      }
    })
    .size({ width: '100%', height: 48 })
    .padding({ left: 12, right: 12 })
  }
}