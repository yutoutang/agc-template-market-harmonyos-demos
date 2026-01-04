/**
 * 模板详情页面
 * 展示模板的详细信息和预览效果,支持收藏和应用模板功能
 */

import { TemplateModel } from '../viewsmodel/TemplateModel'
import { createNWeb, GlobalContext, RouterMap } from 'common'
import { webview } from '@kit.ArkWeb'
import {
  PersonalInformationModel,
  SelfEvaluationModel,
  CareerObjectiveModel,
  EducationalBackgroundModel,
  ResumePageBuilder,
  FilterTags
} from 'resume'
import { phoneRouterControl } from 'oh_router'
import { PreferenceUtil } from 'common'
import { util } from '@kit.ArkTS'
import { TemplateApplyingDialog } from '../comp/TemplateApplyingDialog'
import { UIScaleView } from '@hw-agconnect/ui-scale-view'

@Builder
export function TemplateDetailPageBuilder() {
  TemplateDetailPage()
}

interface FavoriteItem {
  id: string
  name: string
  coverColor: string
  updatedAt: number
  filterTags?: FilterTags
}

@ComponentV2
export struct TemplateDetailPage {
  vm: TemplateModel = TemplateModel.instance
  @Local personalModel: PersonalInformationModel = PersonalInformationModel.instance
  @Local selfEvalModel: SelfEvaluationModel = SelfEvaluationModel.instance
  @Local careerModel: CareerObjectiveModel = CareerObjectiveModel.instance
  @Local eduModel: EducationalBackgroundModel = EducationalBackgroundModel.instance
  @Local isFavorited: boolean = false
  private uiContext: UIContext = this.getUIContext();
  applyDialogToPreview: CustomDialogController = new CustomDialogController({
    builder: TemplateApplyingDialog({ jumpTarget: 'preview' }),
    alignment: DialogAlignment.Bottom,
    customStyle: true
  })

  aboutToAppear() {
    this.vm.setApplied(false)
    const store = PreferenceUtil.getInstance(undefined, 'favorite_store')
    const raw = store.get('my_favorites_list', '[]') as string
    let list: Array<FavoriteItem> = []
    try {
      list = JSON.parse(raw as string) as Array<FavoriteItem>
    } catch (_) {
      list = []
    }
    const name = this.vm.selectedTemplate?.name || ''
    this.isFavorited = list.some((it: FavoriteItem) => it.name === name)
    this.initWebView()
  }

  private initWebView() {
    let type = '1' //1简约 2大气 3导出
    const style = this.vm.selectedTemplate?.filterTags?.style || ''
    if (style === '简约') {
      type = '1'
    } else {
      type = '2'
    }
    this.vm.webController = new webview.WebviewController()
    createNWeb('template', this.uiContext, type, TemplateModel.instance, this.vm.webController);
  }

  private getTemplateImage(): ResourceStr {
    // 根据完整的 filterTags 生成唯一标识
    const filterTags = this.vm.selectedTemplate?.filterTags
    const industry = filterTags?.industry || ''
    const position = filterTags?.position || ''
    const style = filterTags?.style || ''

    // 生成唯一标识：行业-岗位-风格
    const templateKey = `${industry}-${position}-${style}`

    // 根据唯一标识精确匹配模板图片
    if (templateKey === '互联网-人力资源专员/助理-简约') {
      return $r('app.media.ic_templateExampleOne')
    }
    if (templateKey === '电子商务-行政专员/助理-大气') {
      return $r('app.media.ic_templateExampleTwo')
    }

    // 默认返回第一个模板
    return $r('app.media.ic_templateExampleOne')
  }

  @Builder
  templateImageBuilder() {
    Image(this.getTemplateImage())
      .width('100%')
      .objectFit(ImageFit.ScaleDown)
  }

  private isRequiredResumeFilled(): boolean {
    const hasName = (this.personalModel.data.name !== '')
    const hasSelf = this.selfEvalModel.content !== ''
    const hasCareer = this.careerModel.items.length > 0
    const hasEdu = this.eduModel.items.length > 0
    return hasName && hasSelf && hasCareer && hasEdu
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Row() {
            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.chevron_backward'))
                .fontSize(24)
                .fontColor([Color.Black])
            }
            .width(40)
            .height(40)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .border({ width: 1, color: '#E5E7E9' })
            .onClick(() => phoneRouterControl.popPage())

            Text('简历模板')
              .fontSize(18)
              .margin({ left: 8 })
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
          }

          Row() {
            Image(this.isFavorited ? $r('app.media.ic_favorited') : $r('app.media.ic_notFavorited'))
              .width(20)
              .height(20)
          }
          .height(32)
          .width(32)
          .backgroundColor('#F3F4F5')
          .borderRadius(16)
          .onClick(() => {
            if (!this.vm.selectedTemplate) {
              return
            }
            const store = PreferenceUtil.getInstance(undefined, 'favorite_store')
            const raw = store.get('my_favorites_list', '[]') as string
            let list: Array<FavoriteItem> = []
            try {
              list = JSON.parse(raw as string) as Array<FavoriteItem>
            } catch (_) {
              list = []
            }
            const name = this.vm.selectedTemplate.name
            const coverColor = this.vm.selectedTemplate.coverColor
            const filterTags = this.vm.selectedTemplate.filterTags
            const idx = list.findIndex((it: FavoriteItem) => it.name === name)
            if (idx === -1) {
              list.unshift({
                id: util.generateRandomUUID(true),
                name,
                coverColor,
                updatedAt: Date.now(),
                filterTags
              } as FavoriteItem)
              this.isFavorited = true
              GlobalContext.getUIContext().getPromptAction().showToast({ message: '已加入收藏' })
            } else {
              list.splice(idx, 1)
              this.isFavorited = false
              GlobalContext.getUIContext().getPromptAction().showToast({ message: '已取消收藏' })
            }
            store.put('my_favorites_list', JSON.stringify(list))
            // 通知收藏页面刷新
            const timestamp = Date.now()
            AppStorage.setOrCreate('favoriteUpdateTimestamp', timestamp)
          })
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor('#F3F4F5')
        .padding({ left: 16, right: 16 })

        Column() {
          UIScaleView({
            customDirection: PanDirection.All,
            outContainer: false,
            customMinScale: 1,
            customMaxScale: 4,
            moveViewBuilderParam: () => {
              this.templateImageBuilder()
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#F3F4F5')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)

        Row() {
          Button({ type: ButtonType.Capsule }) {
            Text('使用此模板')
              .fontSize(16)
              .fontColor($r('sys.color.comp_background_list_card'))
          }
          .height(44)
          .layoutWeight(1)
          .backgroundColor('#0A59F7')
          .borderRadius(22)
          .onClick(() => {
            if (!this.isRequiredResumeFilled()) {
              const pa = GlobalContext.getUIContext().getPromptAction()
              pa.showDialog({
                message: '未填写必要的个人信息，请优先填写信息，再使用模板',
                buttons: [
                  { text: '取消', color: $r('sys.color.black') },
                  { text: '去填写', color: '#0A59F7' },
                ]
              }).then((data) => {
                if (data.index === 0) {
                  return
                } else if (data.index === 1) {
                  // 使用AppStorage传递返回按钮显示标志，避免路由参数导致的闪退
                  AppStorage.setOrCreate('resumePageShowBackButton', true)
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.RESUME_PAGE,
                    builder: wrapBuilder(ResumePageBuilder),
                  })
                }
              })
              return
            }
            this.initWebView()
            this.vm.setApplied(false)
            this.applyDialogToPreview.open()
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .backgroundColor('#F3F4F5')
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage();
      return true
    })
  }
}
