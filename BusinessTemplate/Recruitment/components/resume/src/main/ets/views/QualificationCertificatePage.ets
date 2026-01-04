import { BarVM, CommonHeader } from 'common'
import { OHPage, phoneRouterControl, OHPageConfig } from 'oh_router'
import { QualificationCertificateModel, CertificateCategory } from '../viewsmodel/QualificationCertificateModel'
import { UnsavedChangesDialog, UnsavedChangesDialogController } from 'job_intention'

@Builder
export function QualificationCertificatePageBuilder() {
  QualificationCertificatePage()
}

interface SearchResultItem {
  cert: string
  category: string
  categoryIndex: number
}

interface HighlightParts {
  before: string
  match: string
  after: string
  hasMatch: boolean
}

interface HighlightTextPart {
  text: string
  isHighlight: boolean
}

@ComponentV2
export struct QualificationCertificatePage {
  @Local vm: QualificationCertificateModel = QualificationCertificateModel.instance
  @Local searchKeyword: string = ''
  @Local displayCategories: CertificateCategory[] = []
  @Local showExitDialog: boolean = false
  @Local selectedCategoryIndex: number = 0
  @Local searchResults: SearchResultItem[] = []
  @Local isSearchMode: boolean = false

  aboutToAppear(): void {
    // 初始化编辑状态
    this.vm.startEdit()
    this.displayCategories = this.vm.getCertificateCategories()
  }

  onPageShow(): void {
    // 页面显示时重新加载数据
    this.vm = QualificationCertificateModel.instance
    this.displayCategories = this.vm.getCertificateCategories()
  }

  // 搜索证书
  onSearch(keyword: string) {
    this.searchKeyword = keyword
    if (keyword.trim() === '') {
      this.isSearchMode = false
      this.searchResults = []
      this.displayCategories = this.vm.getCertificateCategories()
      this.selectedCategoryIndex = 0
    } else {
      this.isSearchMode = true
      // 构建搜索结果
      this.searchResults = []
      const allCategories = this.vm.getCertificateCategories()
      allCategories.forEach((category, categoryIndex) => {
        category.certificates.forEach(cert => {
          if (cert.toLowerCase().includes(keyword.toLowerCase())) {
            this.searchResults.push({
              cert: cert,
              category: category.category,
              categoryIndex: categoryIndex
            })
          }
        })
      })
    }
  }

  // 保存并返回
  saveAndBack() {
    this.vm.saveSelection()
    phoneRouterControl.popPage()
  }

  // 返回处理
  handleBack() {
    if (this.vm.hasChanges()) {
      UnsavedChangesDialogController.openDialog(this.getUIContext(), {
        onConfirm: () => {
          this.vm.cancelEdit()
          phoneRouterControl.popPage()
        },
        onCancel: () => {
        }
      })
    } else {
      phoneRouterControl.popPage()
    }
  }

  // 跳转到指定证书
  jumpToCertificate(categoryIndex: number, cert: string) {
    this.searchKeyword = ''
    this.isSearchMode = false
    this.searchResults = []
    this.vm.toggleCertificate(cert)
    setTimeout(() => {
      this.selectedCategoryIndex = categoryIndex
    }, 300)

  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render()
      },
      useSafePadding: true,
      pageBackgroundColor: '#FFFFFF',
      pageConfig: new OHPageConfig({
        onBackPress: () => {
          this.handleBack()
          return true
        }
      })
    })
  }

  @Builder
  render() {
    NavDestination() {
      Column() {
        // 标题栏
        CommonHeader({
          title: '技能证书',
          onReturnClick: () => {
            this.handleBack()
          },
          backgroundColorParam: '#FFFFFF'
        })

        // 搜索框
        Row() {
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(20)
            .fontColor([$r('sys.color.font_secondary')])
            .margin({ left: 16 })

          TextInput({ placeholder: '请搜索证书', text: $$this.searchKeyword })
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .fontSize(16)
            .onChange((value: string) => {
              this.onSearch(value)
            })
        }
        .width('100%')
        .height(40)
        .backgroundColor('#F5F5F5')
        .borderRadius(20)
        .margin({
          left: 16,
          right: 16,
          top: 8,
          bottom: 0
        })
        .padding({ right: 16 })

        // 搜索结果页面
        if (this.isSearchMode) {
          this.searchResultView()
        } else {
          // 左右分栏布局
          this.normalView()
        }

        // 保存按钮
        Button('保存')
          .width('calc(100% - 32px)')
          .height(48)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('#0A59F7')
          .borderRadius(24)
          .margin({
            left: 16,
            right: 16,
            top: 16,
            bottom: 16
          })
          .onClick(() => {
            this.saveAndBack()
          })

        // 未保存更改确认弹窗
        UnsavedChangesDialog({
          visible: this.showExitDialog,
          onConfirm: () => {
            this.showExitDialog = false
            this.vm.cancelEdit()
            phoneRouterControl.popPage()
          },
          onCancel: () => {
            this.showExitDialog = false
          }
        })
      }
      .width('100%')
      .height('100%')
      .padding({
        top: BarVM.instance.staBarH,
        bottom: BarVM.instance.aiBarH
      })
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.handleBack()
      return true
    })
  }

  // 正常视图
  @Builder
  normalView() {
    Row() {
      // 左侧分类列表
      if (this.searchKeyword.trim() === '') {
        List() {
          ForEach(this.displayCategories, (category: CertificateCategory, index: number) => {
            ListItem() {
              Text(category.category)
                .fontSize(14)
                .fontColor(this.selectedCategoryIndex === index ? '#333333' : '#666666')
                .fontWeight(this.selectedCategoryIndex === index ? FontWeight.Medium : FontWeight.Normal)
                .width('100%')
                .height(48)
                .textAlign(TextAlign.Center)
                .backgroundColor(this.selectedCategoryIndex === index ? '#FFFFFF' : '#F5F5F5')
                .onClick(() => {
                  this.selectedCategoryIndex = index
                })
            }
            .padding(0)
          }, (category: CertificateCategory, index: number) => `category-${index}`)
        }
        .width(90)
        .padding(0)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        .backgroundColor('#F5F5F5')
      }

      // 右侧证书列表
      List() {
        if (this.selectedCategoryIndex >= 0 && this.selectedCategoryIndex < this.displayCategories.length) {
          ForEach(this.displayCategories[this.selectedCategoryIndex].certificates,
            (cert: string, index: number) => {
              ListItem() {
                Text(cert)
                  .fontSize(15)
                  .textAlign(TextAlign.Center)
                  .fontColor(this.vm.isCertificateSelected(cert) ? '#0A59F7' : '#333333')
                  .width('100%')
                  .height(44)
                  .padding({ left: 16, right: 16 })
                  .backgroundColor(this.vm.isCertificateSelected(cert) ? '#E8F3FF' : '#F5F5F5')
                  .borderRadius(8)
                  .onClick(() => {
                    this.vm.toggleCertificate(cert)
                  })
              }
              .margin({
                left: 12,
                right: 12,
                top: index === 0 ? 0 : 4,
                bottom: 4
              })
              .backgroundColor(Color.Transparent)
            }, (cert: string) => cert)
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .backgroundColor('#FFFFFF')
      .padding({ top: 8, bottom: 8 })
    }
    .layoutWeight(1)
    .margin({ top: 16 })
    .alignItems(VerticalAlign.Top)
  }

  // 搜索结果视图
  @Builder
  searchResultView() {
    if (this.searchResults.length === 0) {
      Column() {
        Image($r('app.media.ic_no_search_result_found'))
          .width(120)
          .height(120)
          .margin({ top: 120 })

        Text('暂时没有搜索到您要找的内容呢')
          .fontSize(14)
          .fontColor('rgba(0,0,0,0.40)')
      }
      .width('100%')
      .layoutWeight(1)
    } else {
      List() {
        ForEach(this.searchResults, (item: SearchResultItem, index: number) => {
          ListItem() {
            this.buildHighlightText(item.cert, this.searchKeyword)
          }
          .height(48)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.jumpToCertificate(item.categoryIndex, item.cert)
          })
        }, (item: SearchResultItem) => item.cert)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .backgroundColor('#FFFFFF')
    }

  }

  // 获取高亮文本片段
  getHighlightParts(text: string, keyword: string): HighlightParts {
    const lowerText = text.toLowerCase()
    const lowerKeyword = keyword.toLowerCase()
    const index = lowerText.indexOf(lowerKeyword)

    if (index >= 0) {
      const parts: HighlightParts = {
        before: text.substring(0, index),
        match: text.substring(index, index + keyword.length),
        after: text.substring(index + keyword.length),
        hasMatch: true
      }
      return parts
    }
    const parts: HighlightParts = {
      before: '',
      match: '',
      after: text,
      hasMatch: false
    }
    return parts
  }

  // 高亮文本
  @Builder
  buildHighlightText(text: string, keyword: string) {
    if (keyword.trim() === '') {
      Text(text)
        .fontSize(15)
        .fontColor('#333333')
    } else {
      Row() {
        ForEach(this.renderHighlightParts(text, keyword), (part: HighlightTextPart, idx: number) => {
          Text(part.text)
            .fontSize(15)
            .fontColor(part.isHighlight ? '#0A59F7' : '#333333')
        }, (part: HighlightTextPart, idx: number) => `${idx}-${part.text}`)
      }
    }
  }

  // 渲染高亮部分
  renderHighlightParts(text: string, keyword: string): Array<HighlightTextPart> {
    const parts = this.getHighlightParts(text, keyword)
    const result: Array<HighlightTextPart> = []

    if (parts.hasMatch) {
      if (parts.before) {
        const beforePart: HighlightTextPart = { text: parts.before, isHighlight: false }
        result.push(beforePart)
      }
      const matchPart: HighlightTextPart = { text: parts.match, isHighlight: true }
      result.push(matchPart)
      if (parts.after) {
        const afterPart: HighlightTextPart = { text: parts.after, isHighlight: false }
        result.push(afterPart)
      }
    } else {
      const textPart: HighlightTextPart = { text: parts.after, isHighlight: false }
      result.push(textPart)
    }

    return result
  }
}
