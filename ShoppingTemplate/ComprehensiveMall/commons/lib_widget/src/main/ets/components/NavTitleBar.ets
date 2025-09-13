import { routerStack } from 'lib_foundation';

@ComponentV2
export struct NavTitleBar {
  @Param
  title: string = ''
  @Param
  titleColor: ResourceColor = $r('app.color.font_color_level1')
  @Param
  showSearchIcon: boolean = false
  @Param
  showBackBtn: boolean = false
  @Param
  bgColor: ResourceColor = $r('app.color.background_color_transparent');
  @Event
  onBack: () => void = () => {
    routerStack.pop()
  };
  @Event
  onSearchClick: () => void
  @BuilderParam
  rightPartBuilder: () => void = this.emptyBuilder

  @Computed
  get isSubTitle() {
    return routerStack.size() > 1 || this.showBackBtn
  }

  build() {
    Column() {
      Row() {
        if (this.isSubTitle || this.showBackBtn) {
          Image($r('app.media.ic_back'))
            .width($r('app.float.head_icon_width'))
            .height($r('app.float.head_icon_width'))
            .aspectRatio(1)
            .draggable(false)
            .margin({ right: $r('app.float.space_s') })
            .borderRadius($r('app.float.border_radius_capsule'))
            .stateStyles({
              normal: { .backgroundColor($r('app.color.background_color_transparent'))
              },
              pressed: { .backgroundColor($r('sys.color.interactive_pressed'))
              },
            })
            .onClick(() => {
              this.onBack();
            })
        }
        if (this.title) {
          Text(this.title)
            .fontSize(this.isSubTitle ? $r('sys.float.Title_S') : $r('sys.float.Title_M'))
            .fontColor(this.titleColor)
            .fontWeight(FontWeight.Bold)
        }
        if (this.rightPartBuilder) {
          this.rightPartBuilder()
        } else if (this.showSearchIcon) {
          Row() {
            Image($r('app.media.ic_search_filled'))
              .width(40)
              .height(40)
              .onClick(() => {
                this.onSearchClick?.()
              })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.End)
        }
      }
      .height($r('app.float.nav_header_height'))
      .width('100%')
    }
    .padding({
      left: $r('app.float.space_l'),
      right: $r('app.float.space_l'),
    })
    .width('100%')
    .backgroundColor(this.bgColor)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  emptyBuilder() {

  }
}