import { SafePageVM } from '../viewmodels/SafePageVM';

@Builder
export function SafePageBuilder() {
  SafePage()
}
@ComponentV2
struct SafePage {
  vm: SafePageVM = new SafePageVM();

  build() {
    NavDestination() {
      Column() {
        Image($r('app.media.logo'))
          .width(72)
          .draggable(false)
          .margin({ top: 136 })
        Text('公交出行')
          .fontSize($r('sys.float.Title_L'))
          .fontWeight(FontWeight.Medium)
          .margin({
            bottom: 2,
            top: 2
          })
        Text('业务描述')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
        Blank()
        Column() {
          Image($r('app.media.ic_security'))
            .width($r('app.string.medium_img_width'))
            .draggable(false)
          Text() {
            Span('本应用需联网，调用XX、XX权限，获取XX信息，以为您提供XX服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅')
              .fontColor($r('sys.color.font_secondary'))
            Span('XX业务与隐私的声明、权限使用说明')
              .fontColor($r('app.color.home_tab_active_color'))
              .onClick(() => {
                this.vm.privacyClick();
              })
            Span('。')
              .fontColor($r('sys.color.font_secondary'))
          }
          .fontSize($r('sys.float.Caption_M'))
          .margin({
            bottom: 6,
            top: 6
          })

          Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_secondary'))
            .margin({
              bottom: 6
            })
          Row({ space: 10 }) {
            Button('取消')
              .fontColor($r('app.color.system_color_green'))
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .height(40)
              .layoutWeight(1)
              .onClick(() => {
                this.vm.cancelBtnClick();
              })
            Button('同意')
              .backgroundColor($r('app.color.system_color_green'))
              .height(40)
              .layoutWeight(1)
              .onClick(() => {
                this.vm.agreeBtnClick();
              })
          }
        }
      }
      .width('100%')
      .height('100%')
      .padding(20)
    }
    .hideTitleBar(true)
  }
}
