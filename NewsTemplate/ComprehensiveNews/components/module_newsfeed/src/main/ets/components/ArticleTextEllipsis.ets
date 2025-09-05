import { componentUtils, ComponentUtils, MeasureOptions } from '@kit.ArkUI'
import { ComInfoType } from 'module_imagepreview'
import { Highlight } from 'module_highlight'

@ComponentV2
export struct ArticleTextEllipsis {
  @Param isAll: boolean = true
  @Param text: string = ''
  @Param omitContent: string = '…'
  @Param fontSizeRatio: number = 1
  @Param searchKey: string = ''

  @Monitor('rows', 'text')
  onStrChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      this.formatText()
    })
  }

  @Local rows: number = 3
  @Local showText: string = ''
  @Local isExpand: boolean = false
  @Local textWidth: number = 0
  @Local textHeight: number = 0
  @Local maxLineHeight: number = 0
  private uiContext = this.getUIContext()
  /**
   * 测量文字尺寸
   */
  measureTextSize = (context: UIContext, option: MeasureOptions): Size => {
    let measureUtils = context.getMeasureUtils()
    return {
      width: px2vp(measureUtils.measureTextSize(option).width as number),
      height: px2vp(measureUtils.measureTextSize(option).height as number),
    }
  }
  /**
   * 获取组件信息
   * @param {context} UIContext
   * @param {key} 组件id
   * */
  getComponentsInfo = (context: UIContext, key: string): ComInfoType => {
    let comUtils: ComponentUtils = context.getComponentUtils()
    let info: componentUtils.ComponentInfo = comUtils.getRectangleById(key)
    return {
      width: px2vp(info.size.width),
      height: px2vp(info.size.height),
      localLeft: px2vp(info.localOffset.x),
      localTop: px2vp(info.localOffset.y),
      screenLeft: px2vp(info.screenOffset.x),
      screenTop: px2vp(info.screenOffset.y),
      windowLeft: px2vp(info.windowOffset.x),
      windowTop: px2vp(info.windowOffset.y),
    }
  }

  @Builder
  OmitContent() {
    Row() {
      Text(this.omitContent)
        .fontSize(16 * this.fontSizeRatio)
        .fontWeight(FontWeight.Medium)
      Text('全文')
        .fontColor($r('app.color.app_theme'))
        .fontSize(16 * this.fontSizeRatio)
        .fontWeight(FontWeight.Medium)
    }
  }

  aboutToAppear(): void {
    this.formatText()
  }

  formatText() {
    setTimeout(() => {
      this.textWidth = this.getComponentsInfo(this.uiContext, 'essay').width
      this.textHeight = this.measureText(this.text)
      this.maxLineHeight = this.measureText(this.text, this.rows)
      if (this.textHeight > this.maxLineHeight && this.isAll) {
        this.getTextByWidth()
      } else {
        this.showText = this.text
      }
    }, 100)
  }

  getTextByWidth() {
    let clipText = this.text
    let textHeight = this.textHeight
    while (textHeight > this.maxLineHeight) {
      clipText = clipText.substring(0, clipText.length - (this.rows * 2))
      textHeight = this.measureText(clipText + (this.textHeight > this.maxLineHeight ? this.omitContent : ''))
    }
    this.showText = clipText
  }

  measureText(text: string, rows?: number): number {
    return this.measureTextSize(this.uiContext, {
      textContent: text,
      constraintWidth: this.textWidth,
      fontSize: 16,
      maxLines: rows,
    }).height
  }

  build() {
    Row() {
      if (this.searchKey) {
        Highlight({
          keywords: [this.searchKey as string],
          sourceString: this.isExpand ? this.text : this.showText,
          highLightColor: '#E84026',
          textColor: $r('sys.color.font_primary'),
        })
      } else {
        Text() {
          Span(this.isExpand ? this.text : this.showText)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .fontSize(16 * this.fontSizeRatio)
          if (this.textHeight > this.maxLineHeight && !this.isExpand && this.isAll) {
            Span(this.omitContent)
              .fontSize(16 * this.fontSizeRatio)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Span('全文')
              .fontColor($r('app.color.app_theme'))
              .fontSize(16 * this.fontSizeRatio)
              .fontWeight(FontWeight.Medium)
          }
        }
      }
    }
    .id('essay')
    .width('100%')
  }
}