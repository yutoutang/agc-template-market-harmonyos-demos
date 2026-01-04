import { IPosition } from '../types/Types';

@ComponentV2
export struct DragList {
  @Param arr: IPosition[] = [];
  @Param itemHeight: number = 100;
  @Param listMargin: number = 10;
  @Event exchangeNext: (pre: number) => void;
  @BuilderParam itemUi: (index: number) => void;
  @Local itemOffsetList: number[] = [];
  private _listScroller: ListScroller = new ListScroller();
  private _dragIndex: number = -1;
  private _originDragIndex: number = -1;
  private _itemTotalHeight: number = this.itemHeight + this.listMargin;
  private _dragOffsetY: number = 0;
  private _relativeOffsetY: number = 0;
  private _listMaxScrollOffsetY: number = 0;
  private _originListOffsetY: number = 0;
  private _listArea: Area = {
    width: 0,
    height: 0,
    position: {},
    globalPosition: {},
  };

  aboutToAppear(): void {
    this.itemOffsetList = new Array<number>(this.arr.length);
    this._itemTotalHeight = this.itemHeight + this.listMargin;
  }

  initState() {
    this.itemOffsetList = this.itemOffsetList.map(() => 0);
    this._dragIndex = -1;
    this._originDragIndex = -1;
    this._dragOffsetY = 0;
    this._originListOffsetY = this._listScroller.currentOffset().yOffset;
  }

  startDragItem(dragIndex: number) {
    this.initState();
    animateTo({ curve: Curve.Linear }, () => {
      this._dragIndex = dragIndex;
      this._originDragIndex = dragIndex;
    });
  }

  increaseDragIndex(eventOffsetY: number) {
    let tmp = this.arr.splice(this._dragIndex, 1);
    this.arr.splice(this._dragIndex + 1, 0, tmp[0]);
    this.exchangeNext(this._dragIndex);
    this._dragIndex = this._dragIndex + 1;
    this.itemOffsetList[this._dragIndex] = eventOffsetY - (this._dragIndex - this._originDragIndex) *
    this._itemTotalHeight + this._listScroller.currentOffset().yOffset - this._originListOffsetY;
    this.itemOffsetList[this._dragIndex - 1] = this._itemTotalHeight;
    animateTo({ curve: Curve.Sharp, duration: 100 }, () => {
      this.itemOffsetList[this._dragIndex - 1] = 0;
    });
  }

  decreaseDragIndex(eventOffsetY: number) {
    let tmp = this.arr.splice(this._dragIndex, 1);
    this.arr.splice(this._dragIndex - 1, 0, tmp[0]);
    this.exchangeNext(this._dragIndex - 1);
    this._dragIndex = this._dragIndex - 1;
    this.itemOffsetList[this._dragIndex] = eventOffsetY - (this._dragIndex - this._originDragIndex) *
    this._itemTotalHeight + this._listScroller.currentOffset().yOffset - this._originListOffsetY;
    this.itemOffsetList[this._dragIndex + 1] = -this._itemTotalHeight;
    animateTo({ curve: Curve.Sharp, duration: 100 }, () => {
      this.itemOffsetList[this._dragIndex + 1] = 0;
    });
  }

  cancelDrag() {
    this.initState();
  }

  endDragItem() {
    animateTo({ curve: Curve.Sharp, duration: 100 }, () => {
      this.initState();
    });
  }

  /**
   * 处理拖拽更新事件
   *
   * 该函数负责处理拖拽过程中的各种逻辑，包括：
   * - 计算和限制拖拽偏移量
   * - 处理列表自动滚动
   * - 根据当前位置判断是否需要调整项目顺序
   *
   * @param event - 手势事件对象，包含拖拽过程中的坐标信息
   */
  private handleDragUpdate(event: GestureEvent): void {
    // 计算当前拖拽项的偏移量
    this._dragOffsetY = event.offsetY - (this._dragIndex - this._originDragIndex) * this._itemTotalHeight +
    this._listScroller.currentOffset().yOffset - this._originListOffsetY;

    // 限制dragOffsetY上下界
    let maxOffsetY = (this.arr.length - this._dragIndex - 1) * this._itemTotalHeight - this.listMargin;
    let minOffsetY = -this._dragIndex * this._itemTotalHeight + this.listMargin;
    this._dragOffsetY = Math.min(maxOffsetY, this._dragOffsetY);
    this._dragOffsetY = Math.max(minOffsetY, this._dragOffsetY);

    // 计算相对偏移量用于确定插入位置
    this._relativeOffsetY = this._dragOffsetY + this._dragIndex * this._itemTotalHeight + this.itemHeight / 2;
    this.itemOffsetList[this._dragIndex] = this._dragOffsetY;

    // 获取手指信息并计算在列表中的相对位置
    let fingerInfo = event.fingerList[0];
    let clickPercentY = (fingerInfo.globalY - Number(this._listArea.globalPosition.y)) /
    Number(this._listArea.height);

    // 根据手指位置处理列表自动滚动
    this.handleAutoScroll(clickPercentY);

    // 获取当前滑动到的index并调整项目顺序
    let insertIndex = Math.trunc(this._relativeOffsetY / this._itemTotalHeight);
    if (this._dragIndex < insertIndex) {
      this.increaseDragIndex(event.offsetY);
    } else if (this._dragIndex > insertIndex) {
      this.decreaseDragIndex(event.offsetY);
    }
  }

  /**
   * 处理列表自动滚动
   *
   * 当拖拽项接近列表顶部或底部时，自动滚动列表以显示更多内容
   *
   * @param clickPercentY - 手指点击位置相对于列表高度的百分比
   */
  private handleAutoScroll(clickPercentY: number): void {
    if (clickPercentY > 0.8 && !this._listScroller.isAtEnd()) {
      let scrollVelocity = clickPercentY > 0.9 ? 4 : 2;
      if (this._listMaxScrollOffsetY - this._listScroller.currentOffset().yOffset > scrollVelocity + 5) {
        this._listScroller.scrollTo({
          xOffset: 0,
          yOffset: this._listScroller.currentOffset().yOffset += scrollVelocity,
        });
      }
    } else if (clickPercentY < 0.2 && this._listScroller.currentOffset().yOffset >= 0) {
      let scrollVelocity = clickPercentY < 0.1 ? 4 : 2;
      if (this._listScroller.currentOffset().yOffset > scrollVelocity + 5) {
        this._listScroller.scrollTo({
          xOffset: 0,
          yOffset: this._listScroller.currentOffset().yOffset -= scrollVelocity,
        });
      }
    }
  }

  build() {
    List({ space: this.listMargin, scroller: this._listScroller }) {
      ForEach(this.arr, (item: IPosition, index: number) => {
        ListItem() {
          this.itemUi(index)
        }
        .width('100%')
        .height(this.itemHeight)
        .zIndex(this._dragIndex === index ? 1 : 0)
        .scale(this._dragIndex === index ? { x: 1.05, y: 1.05 } : {})
        .offset({ y: this.itemOffsetList[index] })
        .gesture(GestureGroup(GestureMode.Sequence,
          LongPressGesture({ fingers: 1, repeat: false, duration: 200 }),
          PanGesture()
            .onActionStart(() => {
              this.startDragItem(index);
            })
            .onActionUpdate((event: GestureEvent) => {
              this.handleDragUpdate(event)
            })
            .onActionEnd(() => {
              this.endDragItem();
            }),
        ).onCancel(() => {
          this.cancelDrag();
        }),
        )
      }, (item: IPosition) => item.name+'_'+item.code)
    }
    .clip(false)
    .cachedCount(this.arr.length)
    .width('100%')
    .edgeEffect(EdgeEffect.Spring,{alwaysEnabled:false})
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this._listArea = newValue;
      this._listMaxScrollOffsetY = this.arr.length * this.itemHeight - 10;
    })
  }
}