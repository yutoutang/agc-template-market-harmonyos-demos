import { OptionsModel, ComponentSizeModel } from '../common/StepModel'
import { Constants, Direction } from '../common/Constants'

@Extend(Text)
function textStyle(textWidth: Length, fontWeight: FontWeight, textFontColor: ResourceColor, isRow: boolean = true) {
  .constraintSize({
    maxWidth: textWidth
  })
  .fontWeight(fontWeight)
  .fontColor(textFontColor)
  .padding({ right: isRow ? 0 : Constants.TEXT_COLOUM_OFFSET })
}

@ComponentV2
export struct UISteps {
  // 当前已完成步骤
  @Param active: number = Constants.START_ID

  scroller: Scroller = new Scroller()

  // 选中颜色
  @Param activeColor: ResourceColor = $r('sys.color.ohos_id_color_activated')
  // 排列方向：Direction.ROW：横向，Direction.COLOUM：纵向
  @Param @Once directionSteps: Direction = Direction.ROW

  @Monitor('directionSteps')
  directionStepsChange(){
    this.onDirectionUpdated();
  }
  // 图标
  @Param activeIcon: Resource = $r('app.media.ic_todo_filled')
  // 分割器组件的尺寸
  @Param dividerSize: number | string = Constants.INIT_SIZE
  // 标题字体大小
  @Param titleFontSize: Length = $r('sys.float.ohos_id_text_size_sub_title3')
  // 描述字体大小
  @Param descFontSize: Length = $r('sys.float.ohos_id_text_size_body3')
  // 标题和描述的宽度
  @Param textWidth: number | string = Constants.DEFAULT_TEXT_WIDTH
  // 数据源
  @Param @Require options: OptionsModel[]
  // 是否所有的步骤都在一屏显示
  @Param @Once isFullShow: boolean = false

  // 页面展示的数据
  // showOptions: OptionsOverflowModel[] = []
  // 是否横向
  @Local isRow: boolean = true

  @Param @Once componentSize: ComponentSizeModel = new ComponentSizeModel()

  @Monitor('componentSize', 'isFullShow')
  sizeChange(){
    this.changeDivider()
  }

  @Local dividerRelSize: Length = Constants.INIT_SIZE;

  aboutToAppear(): void {
    this.onDirectionUpdated()
  }

  changeDivider(): void {
    this.queryDividerLength()
  }

  // 监控步骤条方向
  onDirectionUpdated(): void {
    this.isRow = this.directionSteps === Direction.ROW
  }

  // 获取文本最大宽度
  queryMaxWidth() {
    return (this.isFullShow && this.isRow) ? this.dividerRelSize : this.textWidth
  }

  // 获取分割器组件的长度
  queryDividerLength() {
    let len = this.options.length;
    let size: Length;
    let componentSize = this.isRow ? Number(this.componentSize.width) : Number(this.componentSize.heigth);
    let halfComponentSize = this.queryHalf(componentSize)
    if (this.isFullShow) {
      size = (componentSize - (len * Constants.ICON_SIZE)) / len
    } else {
      size = this.lengthUnitConversion(this.dividerSize, componentSize)
    }
    this.dividerRelSize = halfComponentSize > size ? size : halfComponentSize
  }

  // 长度单位数据转换
  lengthUnitConversion(val: number | string, size: number) {
    if (typeof val === 'string') {
      if (isNaN(parseFloat(val))) {
        return 0
      }
      if (val.endsWith('px')) {
        return px2vp(parseFloat(val))
      }
      if (val.endsWith('%')) {
        return size * parseFloat(val) / 100
      }
      return parseFloat(val)
    }
    return val
  }

  queryHalf(numOne: number = Constants.INIT_NUMBER, numTwo: number = Constants.INIT_NUMBER) {
    return (numOne - numTwo) / 2
  }

  queryColor(index: number, isText: Boolean = false) {
    // 未选中
    if (index > this.active) {
      if (isText) {
        return $r('sys.color.ohos_id_color_text_tertiary')
      } else {
        return $r('sys.color.ohos_id_color_fourth');
      }
    }
    if (isText) {
      return $r('sys.color.ohos_id_color_text_primary');
    }
    return this.activeColor;
  }

  // 图标
  @Builder
  stepIconBuilder(index: number, isPassed?: boolean) {
    Column() {
      // 等于0 是 蓝色小圆点
      if (index === 0 || (this.active === index &&index === this.options.length - 1)){
        this.circleShape($r('sys.color.ohos_id_color_activated'));
      } else if (this.active > index) {
        // 大于 index 是√
        Image(this.activeIcon)
          .fillColor(this.activeColor)
          .width(Constants.ICON_CONTEXT_SIZE)
      } else if (this.active === index && isPassed !== false){
        // 等于 index 是 两圈圆点
        Image($r('app.media.current_step'))
          .width(Constants.ICON_CONTEXT_SIZE)
      } else if (this.active === index && isPassed === false){
        Image($r('app.media.stop_step'))
          .width(Constants.ICON_CONTEXT_SIZE)
     } else {
        // 其它是灰色小圆点
        this.circleShape($r('sys.color.ohos_id_color_fourth'))
      }
    }
    .width(Constants.ICON_SIZE)
    .height(Constants.ICON_SIZE)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .id(`icon${index}`)
    .alignRules(this.isRow ? {
      left: { anchor: `divider${index}`, align: HorizontalAlign.End },
    } : {
      top: { anchor: `divider${index}`, align: VerticalAlign.Bottom },
    })
  }


  @Builder
  circleShape(color: ResourceStr){
    Stack() {
      // 焦点框
      Text()
        .width(Constants.ICON_CONTEXT_SIZE)
        .height(Constants.ICON_CONTEXT_SIZE)
        .borderRadius(Constants.BORDER_RADIOUS)
        .border({
          width:  0,
          color: null,
          radius: Constants.BORDER_RADIOUS
        })
        .opacity(Constants.DEFAULT_OPACITY)
      Text()
        .width(Constants.ICON_TEXT_SIZE)
        .height(Constants.ICON_TEXT_SIZE)
        .borderRadius(Constants.BORDER_RADIOUS)
        .backgroundColor(color)
    }
  }
  // 文本
  @Builder
  stepTextBuilder(item: OptionsModel, index: number) {
    Column() {
      Row(){
        Text(item.title)
          .fontSize(this.titleFontSize)
          .textStyle(this.queryMaxWidth(), FontWeight.Medium,
              this.active >= index ? 'rgba(0,0,0,0.90)' : 'rgba(0,0,0,0.40)', this.isRow)
          .lineHeight(Constants.TITLE_HEIGHT_LINE)
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
        if (this.active === index && item.isPassed === false){
          Text('未通过')
            .fontSize(10)
            .fontColor('rgba(0,0,0,0.90)')
            .backgroundColor('rgba(0,0,0,0.05)')
            .borderRadius(4)
            .padding({
              left: 4,
              right: 4,
              top: 2,
              bottom: 2
            })
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      if (index === 0){
        Text('启动时间：2025-05-11')
          .fontSize(14)
          .fontColor('rgba(0,0,0,0.60)')
          .padding({
            top: 5
          })
      }
    }
    .id(`text${index}`)
    .onAreaChange((oldV: Area, newV: Area) => {
      item.stepWidth = newV.width
    })
    .clip(true)
    .height(!this.isRow ? Number(this.dividerRelSize) + Number(Constants.ICON_SIZE) : null)
    .alignItems(this.isRow ? HorizontalAlign.Center : HorizontalAlign.Start)
    .alignRules({
      left: {
        anchor: `icon${index}`,
        align: this.isRow ? HorizontalAlign.Start : HorizontalAlign.End
      },
      top: { anchor: `icon${index}`, align: this.isRow ? VerticalAlign.Bottom : VerticalAlign.Top },
    })
    .offset(this.isRow ? {
      x: -this.queryHalf(Number(item.stepWidth), Constants.ICON_SIZE)
    } : { x: Constants.TEXT_COLOUM_OFFSET })
  }

  // 分割器
  @Builder
  stepDividerBuilder(index: number) {
    if (index !== Constants.START_ID) {
      Divider()
        .vertical(!this.isRow)
        .width(this.isRow ? this.dividerRelSize : null)
        .height(!this.isRow ? this.dividerRelSize : null)
        .strokeWidth('1px')
        .color(this.queryColor(index))
        .id(`divider${index}`)
        .alignRules(this.isRow ? {
          left: { anchor: `icon${Number(index) - Constants.PREVIOUS_NUMBER}`, align: HorizontalAlign.End },
        } : {
          top: { anchor: `icon${Number(index) - Constants.PREVIOUS_NUMBER}`, align: VerticalAlign.Bottom }
        })
        .offset(
          this.isRow ? {
            y: this.queryHalf(Constants.ICON_SIZE, Constants.DIVIDER_WIDTH)
          } : {
            x: this.queryHalf(Constants.ICON_SIZE, Constants.DIVIDER_WIDTH)
          })
    }
  }

  build() {
    Column() {
      Scroll(this.scroller) {
        RelativeContainer() {
          ForEach(this.options, (item: OptionsModel, index: number) => {
            this.stepDividerBuilder(index)
            this.stepIconBuilder(index, item.isPassed)
            this.stepTextBuilder(item, index)
          }, (item:OptionsModel) => JSON.stringify(item))
        }
        .width(this.isFullShow ? null : 'auto')
        .height(this.isFullShow && !this.isRow ? null : 'auto')
      }
      .padding({ left: this.isRow ? (Number(this.dividerRelSize) - Constants.ICON_SIZE) / 2 : 0 })
      .scrollable(this.isRow ? ScrollDirection.Horizontal : ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .nestedScroll({ scrollForward: NestedScrollMode.SELF_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
    }
    .padding({ left: Constants.STEPS_PADDING, right: Constants.STEPS_PADDING })
    .onAreaChange((oldV: Area, newV: Area) => {
      this.componentSize.width = Number(newV.width) - (Constants.STEPS_PADDING * 2);
      this.componentSize.heigth = Number(newV.height) - (Constants.STEPS_PADDING * 2);
    })
  }
}
