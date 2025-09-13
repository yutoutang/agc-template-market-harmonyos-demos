import { PublishPostComp } from '../components/PublishPostComp';
import { PostImgVideoItem } from '../constants/Constants';

@Entry
@ComponentV2
struct Sample1 {
  @Local body: string = '';
  @Local mediaList: PostImgVideoItem[] = [];

  build() {
    NavDestination() {
      this.titleBuilder()

      Column() {
        PublishPostComp({
          fontRatio: 1,
          onChange: (body: string, mediaList: PostImgVideoItem[]) => {
            this.body = body;
            this.mediaList = mediaList;
          },
        })
      }
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .padding(16)
  }

  @Builder
  titleBuilder() {
    Row() {
      Text('发帖页面')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
      Blank()
      Button('发布')
        .width(72)
        .height(40)
        .fontSize($r('sys.float.Body_L'))
        .fontColor(this.enablePublish ? $r('sys.color.font_on_primary') : $r('sys.color.font_tertiary'))
        .backgroundColor(this.enablePublish ? '#5C79D9' :
        $r('sys.color.comp_background_secondary'))
        .enabled(this.enablePublish)
        .onClick(() => {
          this.getUIContext().getPromptAction().showToast({
            message: '点击了发布按钮',
          })
        })
    }
    .width('100%')
    .height(56)
  }

  @Computed
  get enablePublish() {
    if (this.body) {
      return true;
    }
    if (this.mediaList.length) {
      return true;
    }
    return false;
  }
}