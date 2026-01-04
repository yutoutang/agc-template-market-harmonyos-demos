import { BreakpointModel } from 'common';

@ComponentV2
export struct TranslateHomeFunctionCards {
  @Param isFoldScreen: boolean = false; // 是否为折叠屏
  @Param breakpointModel: BreakpointModel = new BreakpointModel();
  @Event onVoiceInputClick: () => void = () => {
  };
  @Event onDocumentClick: () => void = () => {
  };
  @Event onCameraClick: () => void = () => {
  };

  @Builder
  functionCard(title: string, subtitle: string, imageRes: Resource, onClick: () => void) {
    Stack({ alignContent: Alignment.Center }) {
      Image(imageRes)
        .width('100%')
        .height(80)
        .objectFit(ImageFit.Fill)
        .borderRadius(16)

      Column({ space: 8 }) {
        Text(title)
          .fontSize($r('sys.float.Body_M'))
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
        Text(subtitle)
          .fontSize($r('sys.float.Caption_M'))
          .fontColor('rgba(255, 255, 255, 0.9)')
      }
      .padding(12)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
    .onClick(onClick)
  }

  build() {
    if (this.isFoldScreen) {
      // 折叠屏
      Row({ space: 12 }) {
        Column() {
          this.functionCard('文档翻译', '学习办公好帮手', $r('app.media.translation_foldable1'), this.onDocumentClick)
        }
        .layoutWeight(1)

        Column() {
          this.functionCard('语音翻译', '实时录音 边说边译', $r('app.media.translation_foldable2'),
            this.onVoiceInputClick)
        }
        .layoutWeight(1)

        Column() {
          this.functionCard('拍照翻译', '轻松翻译更省心', $r('app.media.translation_foldable3'), this.onCameraClick)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: this.breakpointModel.pagePadding, right: this.breakpointModel.pagePadding, top: 16 })
    } else {
      // 小屏
      Row({ space: 12 }) {
        Column() {
          this.functionCard('文档翻译', '学习办公好帮手', $r('app.media.translation_1'), this.onDocumentClick)
        }
        .layoutWeight(1)

        Column() {
          this.functionCard('语音翻译', '实时录音 边说边译', $r('app.media.translation_2'), this.onVoiceInputClick)
        }
        .layoutWeight(1)

        Column() {
          this.functionCard('拍照翻译', '轻松翻译更省心', $r('app.media.translation_3'), this.onCameraClick)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: this.breakpointModel.pagePadding, right: this.breakpointModel.pagePadding, top: 16 })
    }
  }
}
