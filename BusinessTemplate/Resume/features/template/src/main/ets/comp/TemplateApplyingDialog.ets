/**
 * 模板应用中对话框
 * 显示模板应用进度,完成后跳转到预览页面或简历页面
 */

import { phoneRouterControl } from 'oh_router'
import { TemplateModel } from '../viewsmodel/TemplateModel'
import { TemplatePreviewPageBuilder } from '../views/TemplatePreviewPage'
import { ResumePageBuilder } from 'resume'

@CustomDialog
export struct TemplateApplyingDialog {
  @Prop jumpTarget: string = 'preview'
  @State progress: number = 0
  controller: CustomDialogController

  aboutToAppear() {
    this.progress = 0
    this.tick()
  }

  private tick() {
    setTimeout(() => {
      let next = this.progress + 1
      if (next > 100) {
        next = 100
      }
      this.progress = next
      if (this.progress >= 100) {
        this.controller.close()
        if (this.jumpTarget === 'resume') {
          phoneRouterControl.jumpPage({ pageName: 'ResumePage', builder: wrapBuilder(ResumePageBuilder) })
        } else {
          TemplateModel.instance.setApplied(true)
          phoneRouterControl.jumpPage({ pageName: 'TemplatePreviewPage', builder: wrapBuilder(TemplatePreviewPageBuilder) })
        }
      } else {
        this.tick()
      }
    }, 10)
  }

  build() {
    Column() {
      Column() {
        Text('正在使用模板')
          .fontSize(20)
          .fontWeight(400)
          .fontColor($r('sys.color.black'))
          .lineHeight(28)
        Text('简历模板应用中，请耐心等待!')
          .fontSize(16)
          .fontWeight(400)
          .fontColor('#e6000000')
          .lineHeight(21)
          .margin({ top: 8 })
        Row() {
          Text('加载中...')
            .fontSize(14)
            .fontWeight(400)
            .fontColor($r('sys.color.black'))
            .lineHeight(19)
            .margin({ top: 8 })

          Text(this.progress + '%')
            .fontSize(12)
            .fontColor('#666666')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Stack({ alignContent: Alignment.Start }) {
          Row()
            .height(4)
            .width('100%')
            .backgroundColor('#E5E7E9')
            .borderRadius(2)
          Row()
            .height(4)
            .width(this.progress + '%')
            .backgroundColor('#0A59F7')
            .borderRadius(2)
            .align(Alignment.Start)
        }
        .margin({ top: 12 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: 16
      })
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(32)
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 16 })
  }
}
