import { CommonConstants, RouterUtils } from 'lib_common'
import { NavHeaderBar } from 'lib_widget'
import { PostImgVideoItem, PublishPostComp } from 'module_post'
import { PublishPostViewModel } from '../viewmodels/PublishPostVM'

@Builder
export function PublishPostPageBuilder() {
  PublishPostPage()
}

@ComponentV2
export struct PublishPostPage {
  vm: PublishPostViewModel = new PublishPostViewModel();

  aboutToAppear(): void {
    this.vm.onKeyBoard();
  }

  aboutToDisappear(): void {
    this.vm.offKeyBoard();
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '',
        rightPartBuilder: () => {
          this.barRight()
        },
        onBack: () => {
          const customBack = this.vm.onBackPressed();
          if (!customBack) {
            RouterUtils.pop();
          }
        },
      })
      Column() {
        PublishPostComp({
          fontRatio: this.vm.settingInfo.fontSizeRatio,
          onChange: (body: string, mediaList: PostImgVideoItem[]) => {
            this.vm.body = body;
            this.vm.mediaList = mediaList;
          },
        })
      }
      .layoutWeight(1)
      .padding({
        top: CommonConstants.PADDING_M,
        bottom: this.vm.paddingBottom,
      })
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      return this.vm.onBackPressed();
    })
  }

  @Builder
  barRight() {
    Row() {
      Button('发表')
        .width(72)
        .height(40)
        .fontSize($r('sys.float.Body_L'))
        .fontColor(this.vm.enablePublish() ? $r('sys.color.font_on_primary') : $r('sys.color.font_tertiary'))
        .backgroundColor(this.vm.enablePublish() ? $r('app.color.app_theme') :
        $r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.vm.publishPost();
        })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
  }
}