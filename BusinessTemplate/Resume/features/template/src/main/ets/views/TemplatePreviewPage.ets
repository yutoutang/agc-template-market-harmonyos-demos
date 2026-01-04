/**
 * 模板预览页面
 * 使用WebView展示应用模板后的简历预览效果
 */

import { getNWeb, GlobalContext } from 'common'
import { phoneRouterControl } from 'oh_router'
import { TemplateModel } from '../viewsmodel/TemplateModel'
import { ResumeSnapshotUtil } from 'resume'
import { componentSnapshot } from '@kit.ArkUI'
import { image } from '@kit.ImageKit'
import { util } from '@kit.ArkTS'
import { BusinessError } from '@kit.BasicServicesKit'

@Builder
export function TemplatePreviewPageBuilder() {
  TemplatePreviewPage()
}

@ComponentV2
export struct TemplatePreviewPage {
  @Local vm: TemplateModel = TemplateModel.instance
  @Local isSaving: boolean = false
  private isNavigating: boolean = false

  aboutToAppear(): void {
    const style = this.vm.selectedTemplate?.filterTags?.style || ''
    if (style === '简约') {
      this.vm.webUrl = $rawfile('simple.html')
    } else {
      this.vm.webUrl = $rawfile('huge.html')
    }
  }

  // 生成预览图的 Base64 字符串
  private async capturePreviewImage(): Promise<string | undefined> {
    try {
      const pixelMap = await componentSnapshot.get('previewContainer')
      if (!pixelMap) {
        return undefined
      }

      // 将 PixelMap 转换为 Base64
      const imagePackerApi = image.createImagePacker()
      const packOpts: image.PackingOption = {
        format: 'image/jpeg',
        quality: 80
      }
      const arrayBuffer = await imagePackerApi.packing(pixelMap, packOpts)
      const uint8Array = new Uint8Array(arrayBuffer)
      const base64Helper = new util.Base64Helper()
      const base64String = base64Helper.encodeToStringSync(uint8Array)

      pixelMap.release()
      return base64String
    } catch (error) {
      const e = error as BusinessError
      return undefined
    }
  }

  @Builder
  topBar() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.chevron_backward')).fontSize(24).fontColor([Color.Black])
      }
      .width(40)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .border({ width: 1, color: '#E5E7E9' })
      .onClick(() => phoneRouterControl.popPage())

      Text('使用预览')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ left: 8 })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#F3F4F5')
  }

  build() {
    NavDestination() {
      Column() {
        this.topBar()

        Scroll() {
          Column() {
            NodeContainer(getNWeb('template'))
              .height('100%')
              .width('100%')
          }
          .width('100%')
          .id('previewContainer')
        }
        .padding({
          top: 6
        })
        .backgroundColor('#F5F5F5')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

        Row() {
          Button({ type: ButtonType.Capsule }) {
            Text(this.isSaving ? '保存中...' : '保存').fontSize(16).fontColor($r('sys.color.comp_background_list_card'))
          }
          .height(44)
          .layoutWeight(1)
          .backgroundColor('#0A59F7')
          .borderRadius(22)
          .enabled(!this.isSaving)
          .onClick(async () => {
            // 防止重复点击
            if (this.isSaving) {
              return
            }

            // 检查是否选择了模板
            if (!this.vm.selectedTemplate) {
              GlobalContext.getUIContext().getPromptAction().showToast({ message: '请选择模板后再保存' })
              return
            }

            // 检查是否已使用模板
            if (!this.vm.applied) {
              GlobalContext.getUIContext().getPromptAction().showToast({ message: '请先使用模板后再保存' })
              return
            }

            this.isSaving = true

            // 生成预览图
            const previewImage = await this.capturePreviewImage()

            // 使用 ResumeSnapshotUtil.saveResume 进行统一保存
            // 这会包含完整性校验(validateRequiredFields)和快照生成(createResumeSnapshot)
            const tplName = this.vm.selectedTemplate.name
            const coverColor = this.vm.selectedTemplate.coverColor
            const templateStyle = this.vm.selectedTemplate.filterTags?.style || tplName
            const filterTags = this.vm.selectedTemplate.filterTags

            const success = ResumeSnapshotUtil.saveResume(
              tplName,
              coverColor,
              templateStyle,
              filterTags,
              previewImage
            )

            if (success) {
              // 保存成功，防止重复导航
              if (this.isNavigating) {
                return
              }
              this.isNavigating = true
              // 延迟关闭页面
              setTimeout(() => {
                phoneRouterControl.popPage()
              }, 500)
            } else {
              this.isSaving = false
            }
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .height('100%')
    }
    .onReady((_ctx: NavDestinationContext) => {
    })
    .onBackPressed(() => {
      phoneRouterControl.popPage();
      return true
    })
    .hideTitleBar(true)
  }
}
