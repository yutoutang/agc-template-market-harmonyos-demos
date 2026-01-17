export class TabConstant {
  // 占满全宽
  static readonly FULL_WIDTH: string = '100%';
  // 占满全高
  static readonly FULL_HEIGHT: string = '100%';
  // 页签摩擦系数
  static readonly FRICTION: number = 2;
  // 导航区间隙
  static readonly SPACE: number = 20;
  // TabBar栏左边距
  static readonly OFFSET_LEFT: number = 12;
  // TabBar栏右边距
  static readonly OFFSET_RIGHT: number = 12;
  // 选中颜色: Tab文字
  static readonly ACTIVE_COLOR: ResourceColor = $r('app.color.sys_brand_fuchsia');
  // 待选颜色: Tab文字
  static readonly FROZEN_COLOR: ResourceColor = $r('sys.color.font_secondary');
  // 选中大小: Tab文字
  static readonly ACTIVE_SIZE: string | number | Resource = 16;
  // 待选大小: Tab文字
  static readonly FROZEN_SIZE: string | number | Resource = 16;
  // 导航区背景颜色
  static readonly TAB_BAR_BGCOLOR: ResourceColor = '#F1F3F5';
  // 内容背景颜色
  static readonly TAB_CONTENT_BGCOLOR: ResourceColor = '#F1F3F5';
  // 选中文字粗细
  static readonly ACTIVE_WEIGHT: number | string | FontWeight = FontWeight.Medium;
  // 待选文字粗细
  static readonly FROZEN_WEIGHT: number | string | FontWeight = FontWeight.Normal;
  // 动画时长
  static readonly ANIMATION_DURATION: number = 300;
  // 导航区高度
  static readonly TAB_BAR_HEIGHT: number = 56;
  // 条形高度
  static readonly LINE_HEIGHT: number = 2;
  // 条形距离顶部位置
  static readonly RELATIVE_Y: number = 44;
}

@ComponentV2
export struct TabComp {
  /** 内容参数 **/
  // 初始Tab页索引,支持!!双向绑定
  @Param index: number = 0;
  @Event $index: (val: number) => void;
  // 页签名数组
  @Require @Param tabBar: string[];
  // TabContent内容,注意使用()=>{},防止this指向性问题、不动态刷新
  @BuilderParam contentUi: (index: number) => void = this.tabContentsDefaultBuilder;
  // TabBar自定义内容,背景色跟随tabBar栏,注意设置内边距
  @BuilderParam tabBarUi?: () => void;
  /** 样式参数 **/
  // 页签所处位置: 默认居顶
  @Param top: boolean = true;
  // 页签对齐方式: 默认均分
  @Param start: boolean = false;
  // 摩擦系数(左对齐且超长可滚动时)
  @Param friction: number | Resource = TabConstant.FRICTION;
  // 间隙
  @Param space: number = TabConstant.SPACE;
  // 页签左边距
  @Param offsetLeft: number = TabConstant.OFFSET_LEFT;
  // 页签右边距
  @Param offsetRight: number = TabConstant.OFFSET_RIGHT;
  // 选中颜色: 文字 + 条形
  @Param activeColor: ResourceColor = TabConstant.ACTIVE_COLOR;
  // 待选颜色: 同上
  @Param frozenColor: ResourceColor = TabConstant.FROZEN_COLOR;
  // 选中大小: 文字 + 条形
  @Param activeSize: string | number | Resource = TabConstant.ACTIVE_SIZE;
  // 待选大小: 同上
  @Param frozenSize: string | number | Resource = TabConstant.FROZEN_SIZE;
  // 选中文字粗细
  @Param activeWeight: number | string | FontWeight = TabConstant.ACTIVE_WEIGHT;
  // 待选文字粗细
  @Param frozenWeight: number | string | FontWeight = TabConstant.FROZEN_WEIGHT;
  // 页签区背景颜色
  @Param tabBarBgColor: ResourceColor = TabConstant.TAB_BAR_BGCOLOR;
  // 内容背景颜色
  @Param tabContentBgColor: ResourceColor = TabConstant.TAB_CONTENT_BGCOLOR;
  // 动画时长
  @Param animationDuration: number = TabConstant.ANIMATION_DURATION;
  // 导航区高度
  @Param tabBarHeight: Length = TabConstant.TAB_BAR_HEIGHT;
  // 条形高度
  @Param lineHeight: Length = TabConstant.LINE_HEIGHT;
  // 条形相对页签的垂直位置
  @Param relativeY: number = TabConstant.RELATIVE_Y;
  /** 本地参数 **/
  @Local localIndex: number = this.index;
  @Local indicatorLeftMargin: number = 0;
  @Local indicatorWidth: number = 0;
  private _tabsWidth: number = 0;
  private _textInfos: [number, number][] = [];
  private _isStartAnimateTo: boolean = false;
  private _tabController: TabsController = new TabsController();
  private _listController: Scroller = new Scroller();

  aboutToAppear(): void {
    for (let i = 0; i < this.tabBar.length; i++) {
      this._textInfos.push([0, 0]);
    }
  }

  build() {
    Column() {
      Tabs({
        barPosition: this.top ? BarPosition.Start : BarPosition.End,
        controller: this._tabController,
        index: this.index,
      }) {
        ForEach(this.tabBar, (item: string, index: number) => {
          TabContent() {
            Column() {
              this.contentUi(index);
            }.width(TabConstant.FULL_WIDTH).height(TabConstant.FULL_HEIGHT)
          }.tabBar(undefined)
        }, (item: string, index) => item + '_' + index)
      }
      .barHeight(0)
      .layoutWeight(1)
      .width(TabConstant.FULL_WIDTH)
      .barBackgroundColor(this.tabBarBgColor)
      .backgroundColor(this.tabContentBgColor)
      .animationDuration(this.animationDuration)
      .onSizeChange((_oldValue, newValue) => {
        this._tabsWidth = newValue.width as number;
        if (!this._isStartAnimateTo) {
          this._setIndicatorAttr(this._textInfos[this.localIndex][0], this._textInfos[this.localIndex][1]);
        }
      })
      .onChange((index: number) => {
        // 监听索引index的变化，实现页签内容的切换。
        this.localIndex = index;
        this.$index(index);
        this._listController.scrollToIndex(index - 1, true);
      })
      .onAnimationStart((_index: number, targetIndex: number) => {
        // 切换动画开始时触发该回调。下划线跟着页面一起滑动，同时宽度渐变。
        this.localIndex = targetIndex;
        this._startAnimateTo(this.animationDuration, this._textInfos[targetIndex][0], this._textInfos[targetIndex][1]);
      })
      .onAnimationEnd((index: number, event: TabsAnimationEvent) => {
        // 切换动画结束时触发该回调。下划线动画停止。
        let currentIndicatorInfo = this._getCurrentIndicatorInfo(index, event);
        this._startAnimateTo(0, currentIndicatorInfo.left, currentIndicatorInfo.width);
      })
      .onGestureSwipe((index: number, event: TabsAnimationEvent) => {
        // 在页面跟手滑动过程中，逐帧触发该回调。
        let currentIndicatorInfo = this._getCurrentIndicatorInfo(index, event);
        this.localIndex = currentIndicatorInfo.index;
        this._setIndicatorAttr(currentIndicatorInfo.left, currentIndicatorInfo.width);
      })

      Row() {
        if (this.start) {
          List({ space: this.space, scroller: this._listController }) {
            ForEach(this.tabBar, (item: string, index) => {
              ListItem() {
                this.tabBarBuilder(item, index);
              }
              .onAreaChange((_oldValue: Area, newValue: Area) => {
                this._textInfos[index] = [newValue.position.x as number, newValue.width as number];
                if (!this._isStartAnimateTo && this.localIndex === index && this._tabsWidth > 0) {
                  this._setIndicatorAttr(this._textInfos[this.localIndex][0], this._textInfos[this.localIndex][1]);
                }
              })
            }, (item: string, index) => item + '_' + index)
          }
          .layoutWeight(1)
          .lanes(1)
          .friction(this.friction)
          .height(TabConstant.FULL_HEIGHT)
          .contentStartOffset(this.offsetLeft)
          .contentEndOffset(this.offsetRight)
          .scrollBar(BarState.Off)
          .listDirection(Axis.Horizontal)
          .onWillScroll((xOffset: number) => {
            this.indicatorLeftMargin -= xOffset;
          })

          Column()
            .height(this.lineHeight)
            .width(this.indicatorWidth)
            .backgroundColor(this.activeColor)
            .position({ left: this.indicatorLeftMargin, top: this.relativeY })

          Column() {
            this.tabBarUi?.();
          }
          .zIndex(10)
          .offset({ right: 0 })
          .height(TabConstant.FULL_HEIGHT)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.tabBarBgColor)
        } else {
          Row({ space: this.space }) {
            ForEach(this.tabBar, (item: string, index) => {
              Row() {
                this.tabBarBuilder(item, index);
              }
              .onAreaChange((_oldValue: Area, newValue: Area) => {
                this._textInfos[index] = [newValue.position.x as number, newValue.width as number];
                if (!this._isStartAnimateTo && this.localIndex === index && this._tabsWidth > 0) {
                  this._setIndicatorAttr(this._textInfos[this.localIndex][0], this._textInfos[this.localIndex][1]);
                }
              })
            }, (item: string, index) => item + '_' + index)
          }.justifyContent(FlexAlign.Center).width(TabConstant.FULL_WIDTH)

          Column()
            .height(this.lineHeight)
            .width(this.indicatorWidth)
            .backgroundColor(this.activeColor)
            .position({ left: this.indicatorLeftMargin, top: this.relativeY })
        }
      }
      .height(this.tabBarHeight)
      .width(TabConstant.FULL_WIDTH)
      .backgroundColor(this.tabBarBgColor)
    }
    .layoutWeight(1).clip(true).reverse(this.top)
  }

  private _getCurrentIndicatorInfo(index: number, event: TabsAnimationEvent): Record<string, number> {
    let nextIndex = index;
    if (index > 0 && event.currentOffset > 0) {
      nextIndex--;
    } else if (index < this._textInfos.length - 1 && event.currentOffset < 0) {
      nextIndex++;
    }
    let indexInfo = this._textInfos[index];
    let nextIndexInfo = this._textInfos[nextIndex];
    let swipeRatio = Math.abs(event.currentOffset / this._tabsWidth);
    // 页面滑动超过一半，tabBar切换到下一页。
    let currentIndex = swipeRatio > 0.5 ? nextIndex : index;
    let currentLeft = indexInfo[0] + (nextIndexInfo[0] - indexInfo[0]) * swipeRatio;
    let currentWidth = indexInfo[1] + (nextIndexInfo[1] - indexInfo[1]) * swipeRatio;
    return { 'index': currentIndex, 'left': currentLeft, 'width': currentWidth };
  }

  private _startAnimateTo(duration: number, leftMargin: number, width: number) {
    this._isStartAnimateTo = true;
    this.getUIContext().animateTo({
      duration: duration,
      curve: Curve.Linear,
      iterations: 1,
      playMode: PlayMode.Normal,
      onFinish: () => {
        this._isStartAnimateTo = false;
      },
    }, () => {
      this._setIndicatorAttr(leftMargin, width);
    });
  }

  private _setIndicatorAttr(leftMargin: number, width: number) {
    this.indicatorWidth = width;
    this.indicatorLeftMargin = leftMargin;
  }

  @Builder
  tabBarBuilder(name: string, index: number) {
    Text(name)
      .height(TabConstant.FULL_HEIGHT)
      .fontColor(this.localIndex === index ? this.activeColor : this.frozenColor)
      .fontWeight(this.localIndex === index ? this.activeWeight : this.frozenWeight)
      .fontSize(this.localIndex === index ? this.activeSize : this.frozenSize)
      .id(index.toString())
      .onClick(() => {
        this._tabController.changeIndex(index);
      })
  }

  @Builder
  tabContentsDefaultBuilder(index: number) {
    Text('TabContent' + index)
      .fontWeight(FontWeight.Medium)
      .height(TabConstant.FULL_HEIGHT)
      .fontSize($r('sys.float.Title_M'))
  }
}