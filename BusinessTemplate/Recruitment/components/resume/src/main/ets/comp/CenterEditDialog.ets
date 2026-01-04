@Builder
export function CenterEditDialogPageBuilder() {
  CenterEditDialogPage()
}

export interface CenterEditDialogParams {
  title: string
  placeholder: string
  value: string
  onCancel: () => void
  onConfirm: (value: string) => void
}

@ComponentV2
export struct CenterEditDialogPage {
  @Local routerModule: NavPathStack = new NavPathStack()
  @Local title: string = ''
  @Local placeholder: string = ''
  @Local value: string = ''
  @Local onCancel: () => void = () => {
  }
  @Local onConfirm: (value: string) => void = (_: string) => {
  }
  @Local temp: string = ''

  aboutToAppear(): void {
    this.temp = this.value
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Text(this.title)
            .width('100%')
            .textAlign(TextAlign.Start)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          TextInput({ text: $$this.temp, placeholder: this.placeholder })
            .padding({
              left: '0vp',
              right: '0vp',
              top: '8vp',
              bottom: '8vp'
            })
            .fontSize(16)
            .fontColor($r('sys.color.font_primary'))
            .backgroundColor($r('sys.color.background_primary'))
            .constraintSize({ minHeight: 48 })
            .margin({ top: 16 })
          Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
          Row() {
            Button('取消')
              .width('44%')
              .height(40)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_tertiary'))
              .backgroundColor('#00000000')
              .onClick(() => {
                this.onCancel();
                this.routerModule.pop()
              })
            Text('|')
              .fontColor($r('sys.color.comp_divider'))
            Button('确定')
              .width('44%')
              .height(40)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_emphasize'))
              .backgroundColor('#00000000')
              .onClick(() => {
                this.onConfirm(this.temp);
                this.routerModule.pop()
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: 12 })
        }
        .width('90%')
        .margin({ left: 16, right: 16 })
        .padding({
          left: 16,
          right: 16,
          top: 16,
          bottom: 16
        })
        .borderRadius(20)
        .backgroundColor($r('sys.color.background_primary'))
        .transition(TransitionEffect.OPACITY.animation({ duration: 10, curve: Curve.EaseOut }))
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .backgroundColor('rgba(0, 0, 0, 0.5)')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .hideTitleBar(true)
    .mode(NavDestinationMode.DIALOG)
    .onReady((context) => {
      this.routerModule = context.pathStack
      if (context.pathInfo.param) {
        const p = context.pathInfo.param as CenterEditDialogParams
        this.title = p.title
        this.placeholder = p.placeholder
        this.value = p.value
        this.temp = p.value
        this.onCancel = p.onCancel
        this.onConfirm = p.onConfirm
      }
    })
  }
}
