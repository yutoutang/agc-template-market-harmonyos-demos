import { LengthMetrics, MeasureText } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import hilog from '@ohos.hilog';
import { ChannelConstants } from '../constants/Constants';
import { PositionXY, TabInfo } from '../model/Model';


@ComponentV2
export struct ChannelsSortEdit {
  @Param dataList: TabInfo[] = [];
  @Param fontSizeRatio: number = 1
  @Local selected: TabInfo[] = [];
  @Local unSelected: TabInfo[] = [];
  @Local copySelected: TabInfo[] = [];
  @Local copyUnSelected: TabInfo[] = [];
  @Local content: TabInfo = {
    id: '',
    text: '',
    selected: false,
    order: 0,
  };
  @Local dragContent: TabInfo = {
    id: '',
    text: '',
    selected: false,
    order: 0,
  };
  @Local dragContentIndex: number = -1;
  @Local hoverId: number | string = '';
  @Local gridComState: boolean = false;
  @Local menuSwitch: boolean = false;
  @Local areaWidth: number = 0;
  @Local blockWidth: number = 0;
  @Local blockHeight: number = 0;
  @Local longScaleOnePointTwo: number = 1;
  @Local scaleGridItemNinetyPercent: number = 1;
  @Local reboundSize: number = 1;
  @Local scaleIcon: number = 1;
  @Local addIconShow: boolean = false;
  @Local scaleAddIcon: number = 0;
  @Local isStartDrag: boolean = false;
  @Local insertIndex: number = -1;
  @Local itemIndex: number = 0;
  @Local editGridDataLength: number = -1;
  @Local isTouchDown: boolean = false;
  @Local addItemMoveX: number = 0;
  @Local addItemMoveY: number = 0;
  @Local editItemMoveX: number = 0;
  @Local editItemMoveY: number = 0;
  @Local unSelectedIndex: number = 0;
  @Local clickAddBtn: boolean = false;
  @Local selectedIndex: number = -1;
  @Local clickRemoveBtn: boolean = false;
  @Local addAreaLongPressGesture: boolean = false;
  @Local arraySelectIsChange: number = 0;
  @Local arrayUnSelectIsChange: number = 0;
  @Local textItemEditWidth: number = 0;
  @Local textItemEditHeight: number = 0;
  @Local imageItemWidth: number = 0;
  @Local saveClick: boolean = false;
  @Local imageTextAddIconShow: boolean = false;
  @Local imageTextRemoveIconShow: boolean = false;
  @Local firstIn: boolean = true;
  @Local fontSizeScale: number | undefined = 1;
  @Local fontWeightScale: number | undefined = 1;
  @Local customColumns: string = '1fr 1fr 1fr 1fr';
  @Local editGridHeight: number = 0;
  @Local addGridHeight: number = 0;
  @Local subTitleHeight: number = 0;
  @Local colNum: number = ChannelConstants.COL_IMAGE_TEXT;
  @Event onSave?: (select: TabInfo[], unselect: TabInfo[]) => void;
  @Event onCancel?: () => void;
  @Local isFollowingSystemFontScale: boolean = false;
  @Local maxAppFontScale: number = 1;
  @Local readFlag: boolean = true;
  @Local readIndex4AddArea: number = -1;
  @Local readIndex4EditArea: number = -1;
  @Local isPointToAddTitleBarEditButton: boolean = false;
  @Local isPointToEditTitleBarSaveButton: boolean = false;
  @Event onChannelClick: (select: TabInfo) => void
  private eps = 1e-08

  @Monitor('gridComState')
  onGridComStateChange() {
    this.textItemEditWidth = this.gridComState ? this.blockWidth - 24 : this.blockWidth - 16;
    this.blockHeight = this.gridComState ?
      this.textItemEditHeight + ChannelConstants.EDIT_BLOCK_TEXT_ITEM_SAFE_MARGIN :
      this.textItemEditHeight + ChannelConstants.DEFAULT_BLOCK_TEXT_ITEM_SAFE_MARGIN;
  }

  @Monitor('fontSizeScale')
  calcAreaInfo() {
    // 重新获取字体倍数，并重新计算列数
    this.calcColNum();
    this.blockWidth = this.getBlockWidth(); // gridItem width
    this.textItemEditWidth = this.gridComState ? this.blockWidth - 24 : this.blockWidth - 16;
    this.imageItemWidth = this.blockWidth - 16; // image Width
    this.calcTextItemEditHeight();
    this.blockHeight = this.gridComState ?
      this.textItemEditHeight + ChannelConstants.EDIT_BLOCK_TEXT_ITEM_SAFE_MARGIN :
      this.textItemEditHeight + ChannelConstants.DEFAULT_BLOCK_TEXT_ITEM_SAFE_MARGIN;
    this.calcGridHeight();
  }

  // component rendering
  aboutToAppear() {
    this.selected = this.dataList && this.deduplicate(this.dataList).filter(val => val.selected).sort(this.sortBy());
    this.unSelected = this.dataList && this.deduplicate(this.dataList).filter(val => !val.selected).sort(this.sortBy());
    this.copySelected = this.selected.slice();
    this.copyUnSelected = this.unSelected.slice();
    this.editGridDataLength = this.selected.length;
    try {
      let uiContent: UIContext = this.getUIContext();
      this.isFollowingSystemFontScale = uiContent.isFollowingSystemFontScale();
      this.maxAppFontScale = uiContent.getMaxFontScale();
      this.fontSizeScale = this.decideFontScale(uiContent);
      this.fontWeightScale =
        (uiContent.getHostContext() as common.UIAbilityContext)?.config?.fontWeightScale ??
        ChannelConstants.DEFAULT_FONT_WEIGHT_SCALE;
    } catch (exception) {
      let code = (exception as BusinessError).code;
      let message = (exception as BusinessError).message;
      console.error('Ace',
        `GridObjectSortComponent Faild to init fontsizescale info, code:${code}, message: ${message}`);
    }
    this.calcGridHeight();
    setTimeout(() => {
      this.firstIn = false;
    }, 500);
  }

  getAdaptiveSymbolFontSize(): string {
    let fontScale: number | undefined = this.fontSizeScale;
    if (!this.isFollowingSystemFontScale || fontScale === undefined) {
      fontScale = ChannelConstants.MIN_FONT_SCALE;
    }
    fontScale = Math.min(ChannelConstants.MIN_SYMBOL_FONT_SCALE, fontScale);
    fontScale = Math.max(fontScale, ChannelConstants.MIN_FONT_SCALE);
    return (fontScale * ChannelConstants.SYMBOL_SIZE_12FP).toString() + 'vp';
  }

  getSymbolFontSizeFrom(imageSize?: number | Resource | undefined): string | Resource {
    if (imageSize === undefined) {
      return ChannelConstants.SYMBOL_DEFAULT;
    }
    if (typeof imageSize === 'number') {
      return (imageSize as number).toString() + 'vp';
    }
    return imageSize as Resource;
  }

  calcTextItemEditHeight() {
    let sizeOptions: SizeOptions = MeasureText.measureTextSize({
      textContent: this.dataList[0]?.text ?? '',
      fontSize: `${(LengthMetrics.resource($r('sys.float.ohos_id_text_size_button3'))?.value ??
      ChannelConstants.DEFAULT_TEXT_SIZE) * (this.fontSizeScale ?? ChannelConstants.DEFAULT_FONT_SIZE_SCALE)}vp`,
      overflow: TextOverflow.Ellipsis,
      maxLines: ChannelConstants.TEXT_MAX_LINES,
    });
    this.textItemEditHeight = this.fontSizeScale === ChannelConstants.DEFAULT_FONT_SIZE_SCALE ?
    ChannelConstants.GRID_ITEM_HEIGHT_TEXT : px2vp(sizeOptions.height as number);
    this.textItemEditHeight = this.textItemEditHeight + ChannelConstants.PADDING_EIGHT * 2;
  }

  decideFontScale(uiContent: UIContext): number {
    if (!this.isFollowingSystemFontScale) {
      return 1;
    }
    let systemFontScale: number | undefined =
      (uiContent.getHostContext() as common.UIAbilityContext)?.config?.fontSizeScale ??
      ChannelConstants.DEFAULT_FONT_SIZE_SCALE;
    return Math.min(systemFontScale, this.maxAppFontScale, ChannelConstants.MAX_FONT_SCALE);
  }

  private calcColNum() {
    if (this.fontSizeScale && this.fontSizeScale > ChannelConstants.DEFAULT_FONT_SIZE_SCALE) {
      this.customColumns = ChannelConstants.GRID_COL_3;
      this.colNum = ChannelConstants.COL_IMAGE_TEXT;
    } else {
      this.customColumns = ChannelConstants.GRID_COL_4;
      this.colNum = ChannelConstants.COL_TEXT;
    }
  }

  // component disappear
  aboutToDisappear() {
    animateTo({
      duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
      curve: ChannelConstants.COMMON_BEZIER,
    }, () => {
      this.gridComState = false;
    });
    this.menuSwitch = false;
    this.selected = this.copySelected;
    this.unSelected = this.copyUnSelected;
  }

  // Array deduplication
  deduplicate(arr: TabInfo[]) {
    const result: TabInfo[] = [];
    arr.forEach(item => {
      if (!result.some(x => x.id === item.id)) {
        result.push(item);
      }
    });
    return result;
  }

  sortBy() {
    return (a: TabInfo, b: TabInfo) => {
      return a.order - b.order;
    };
  }

  // cancel edit function
  cancelEdit(): void {
    if (this.isStartDrag || this.clickAddBtn || this.clickRemoveBtn) {
      return;
    }
    animateTo({
      duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
      curve: ChannelConstants.LONG_TOUCH_SCALE,
    }, () => {
      this.longScaleOnePointTwo = 1;
    })
    animateTo({
      duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
      curve: ChannelConstants.COMMON_BEZIER,
    }, () => {
      this.gridComState = false;
    });
    this.menuSwitch = false;
    this.selected = this.copySelected.slice();
    this.unSelected = this.copyUnSelected.slice();
    this.editGridDataLength = this.selected.length;
    this.calcGridHeight();
    this.isPointToAddTitleBarEditButton = true;
    this.onCancel && this.onCancel();
  }

  // Enter edit function
  goEdit(): void {
    animateTo({
      duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
      curve: ChannelConstants.COMMON_BEZIER,
    }, () => {
      this.gridComState = true;
    });
    this.menuSwitch = true;
    this.isPointToEditTitleBarSaveButton = true;
    this.calcGridHeight();
  }

  pointToEditTitleBarSaveButton(): void {
    if (this.isPointToEditTitleBarSaveButton) {
      let editableTittleBarUniqueId =
        this.getUIContext().getFrameNodeById(ChannelConstants.EDIT_TITLE_BAR_ID)?.getFirstChild()?.getUniqueId();
    }
  }

  // save data
  onSaveEdit(): void {
    if (this.isStartDrag) {
      return;
    }
    animateTo({
      duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
      curve: ChannelConstants.LONG_TOUCH_SCALE,
    }, () => {
      this.longScaleOnePointTwo = 1;
    })
    this.editGridDataLength = this.selected.length;
    animateTo({
      duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
      curve: ChannelConstants.COMMON_BEZIER,
    }, () => {
      this.gridComState = false;
      this.copySelected = this.selected.slice();
      this.copyUnSelected = this.unSelected.slice();
      const selected = this.getNewData(this.selected, true, 0);
      const unSelected = this.getNewData(this.unSelected, false, this.selected.length);
      this.selected = selected;
      this.unSelected = unSelected;
      this.calcGridHeight();
      this.onSave && this.onSave(selected, unSelected);
    });
    setTimeout(() => {
      this.saveClick = false;
    }, ChannelConstants.ENTER_EXIT_ICON_DURATION);
    this.menuSwitch = false;
    this.isPointToAddTitleBarEditButton = true;
  }

  // Drag and move triggering event
  onDragMoveEvent(event: ItemDragInfo, itemIndex: number, insertIndex: number): void {
    if (this.content.disabled) {
      return
    }
    if (!this.gridComState || (event.x < this.blockWidth / 3 && event.y < this.blockHeight / 3)) {
      return;
    }
    let targetIndex: number = insertIndex;
    if (targetIndex < 0) {
      targetIndex = this.selected.length - 1;
    }
    if (this.dragContent.visibility !== Visibility.Hidden) {
      this.dragContent.visibility = Visibility.Hidden;
    }
    this.insertIndex = insertIndex;
  }

  // delete Editing an Area Item
  handleDeleteClick(content: TabInfo): void {
    if (content.disabled && this.gridComState) {
      return
    }
    if (!this.gridComState) {
      this.onChannelClick(content)
      return
    }
    if (this.clickAddBtn || this.clickRemoveBtn) {
      return;
    }
    this.clickRemoveBtn = true;
    this.scaleIcon = 0;
    this.arraySelectIsChange = 1;
    let currentIndex = this.selected.findIndex(val => val.id === content.id);
    this.content = content;
    this.selectedIndex = currentIndex;
    this.calcGridHeight();
    animateTo({
      curve: ChannelConstants.REMOVE_ADD_SPRING, onFinish: () => {
        this.scaleIcon = 1;
        this.selected.splice(currentIndex, 1);
        this.unSelected.unshift(content);
        this.calcGridHeight();
        this.editGridDataLength = this.editGridDataLength - 1;
        this.editItemMoveX = 0;
        this.editItemMoveY = 0;
        this.arraySelectIsChange = 2;
        this.clickRemoveBtn = false;
        this.readFlag = false;
        // 播报区域为添加域的第1个，index为0
        this.readIndex4AddArea = 0;
        this.onSave && this.onSave(this.selected, this.unSelected);
      },
    }, () => {
      let addItemGridPosition = this.getAddItemGridPosition();
      this.editItemMoveX = addItemGridPosition.x;
      this.editItemMoveY = addItemGridPosition.y;
    });
  }

  getNewData(data: TabInfo[],
    state: boolean, startIndex: number): TabInfo[] {
    return data.map((val, index) => {
      val.selected = state;
      val.order = startIndex + index;
      val.visibility = Visibility.Visible;
      return val;
    });
  }

  // Obtains the width of each girdItem.
  getBlockWidth(): number {
    const blockWidth: number = (this.areaWidth) / this.colNum;
    return blockWidth;
  }

  calcGridHeight(): void {
    this.editGridHeight = this.getGridHeight(this.selected, ChannelConstants.EDIT);
    this.addGridHeight = this.getGridHeight(this.unSelected);
  }

  // calculated altitude
  getGridHeight(data: TabInfo[], state?: string): number {
    let height: number = 0;
    let selectLen: number = data.length;
    data.forEach(item => {
      if (item.visibility === Visibility.Hidden) {
        selectLen = selectLen - 1;
      }
    });
    let addRow: number = 0;
    let lastColumn: boolean = selectLen % this.colNum === 0;
    if (this.clickAddBtn && lastColumn) {
      addRow = 1;
    } else if (this.isStartDrag && lastColumn && state) {
      addRow = 1;
    } else if (this.clickRemoveBtn && lastColumn && !state) {
      addRow = 1;
    } else {
      addRow = 0;
    }
    let rowNumber: number = Math.ceil(selectLen / this.colNum) + addRow;
    height = this.blockHeight * rowNumber;
    if (selectLen === 0) {
      height = 0;
    }
    return height;
  }

  // Display area icon in image_text mode
  imageTextRemoveIcon(select: TabInfo): Resource {
    const clickRemoveIcon: boolean = this.clickRemoveBtn && this.content.id === select.id;
    const icon = clickRemoveIcon ?
    $r('sys.symbol.plus_circle_fill') : $r('sys.symbol.minus_circle_fill');
    return icon;
  }

  // Drag position calculation in the editing area
  getCoodXY(index: number): PositionXY {
    let x: number = 0;
    let y: number = 0;
    const gridCol: number = this.colNum;
    const lastCol: number = Math.trunc(index % gridCol);
    if (index >= this.dragContentIndex) {
      if (index <= this.insertIndex && index !== this.dragContentIndex) {
        // item  newline
        if (lastCol === 0) {
          x = x + this.blockWidth * (gridCol - 1);
          y = y - this.blockHeight;
        } else {
          // left move
          x = x - this.blockWidth;
        }
      }
    } else {
      if (index >= this.insertIndex) {
        // item  newline
        if (lastCol === gridCol - 1) {
          x = x - this.blockWidth * (gridCol - 1);
          y = y + this.blockHeight;
        } else {
          // right move
          x = x + this.blockWidth;
        }
      }
    }
    if (!this.isStartDrag) {
      x = 0;
      y = 0;
    }
    return { x, y };
  }

  // Position calculation when an item is deleted, Displacement to the first position. (top => bottom)
  getAddItemGridPosition(): PositionXY {
    const len: number = this.selected.length;
    const col: number = this.colNum;
    const removeCol: number = (this.selectedIndex + 1) % col;
    const currentLine: number = Math.ceil((this.selectedIndex + 1) / col);
    const totalRows: number = Math.ceil(len / col);
    let xNew: number = 0;
    if (removeCol === 0) {
      xNew = (this.fontSizeScale && this.fontSizeScale > 1) ? -this.blockWidth * 2 : -this.blockWidth * 3;
    } else {
      xNew = -this.blockWidth * (removeCol - 1);
    }
    let subTitleHeight: number = ChannelConstants.SUBTITLE_HEIGHT;
    let yNew: number = 0;
    const removeNumY: number = totalRows - currentLine;
    const minusLine: number = len % col;
    const line: number = minusLine === 1 ? removeNumY : removeNumY + 1;
    if (this.fontSizeScale && this.fontSizeScale > 1) {
      subTitleHeight = this.subTitleHeight;
    }
    yNew = line * this.blockHeight + subTitleHeight;
    return {
      x: xNew,
      y: yNew,
    };
  }

  // When an item is deleted, the filling position of other items is calculated.
  getCoveringGridPosition(index: number): PositionXY {
    let xNew: number = 0;
    let yNew: number = 0;
    if (index > this.selectedIndex && this.arraySelectIsChange !== 2) {
      xNew = index % this.colNum === 0 ? this.blockWidth * (this.colNum - 1) : -this.blockWidth;
      yNew = index % this.colNum === 0 ? -this.blockHeight : 0;
    }
    return {
      x: xNew,
      y: yNew,
    };
  }

  // Position calculation when adding an item. (bottom => top)
  getEditItemGridPosition(data: TabInfo[], removeIndex: number): PositionXY {
    const len: number = data.length;
    const col: number = this.colNum;
    const insertCol: number = Math.trunc(len % col);
    const removeCol: number = Math.trunc(removeIndex % col);
    let xNew: number = Math.abs(insertCol - removeCol) * this.blockWidth;

    if (insertCol < removeCol) {
      xNew = -xNew;
    } else if (insertCol > removeCol) {
      xNew = xNew;
    } else {
      xNew = 0;
    }

    let yNew: number = 0;
    let itemHeight: number = 0;
    let removeRow: number = Math.trunc(removeIndex / this.colNum);
    let subTitleHeight: number = ChannelConstants.SUBTITLE_HEIGHT;
    const textShowAreaEditItem: boolean = this.gridComState;
    if (textShowAreaEditItem) {
      itemHeight = (removeRow + 1) * (this.blockHeight - 8) + 8;
    } else {
      itemHeight = (removeRow + 1) * this.blockHeight;
    }
    if (this.fontSizeScale && this.fontSizeScale > 1) {
      subTitleHeight = this.subTitleHeight;
    }
    yNew = itemHeight + subTitleHeight;
    return {
      x: xNew,
      y: yNew,
    };
  }

  // When an item is added, the filling of other items in the addition area is calculated.
  getCoveringGridPositionBottom(index: number): PositionXY {
    let xNew: number = 0;
    let yNew: number = 0;
    const lastCol: boolean = index % this.colNum === 0;
    const textShowAreaItemHeight: number =
      this.gridComState ? -this.blockHeight + 8 : -this.blockHeight;
    if (index > this.unSelectedIndex && this.arrayUnSelectIsChange !== 2) {
      xNew = lastCol ? this.blockWidth * (this.colNum - 1) : -this.blockWidth;
      yNew = lastCol ? textShowAreaItemHeight : 0;
    }
    return {
      x: xNew,
      y: yNew,
    };
  }

  // When an item is deleted, other items in the addition area are moved rightwards.
  getAddItemRightMove(index: number): PositionXY {
    let x: number = this.blockWidth;
    let y: number = 0;
    let lastCol: boolean = (index + 1) % this.colNum === 0;
    if (lastCol) {
      x = -this.blockWidth * (this.colNum - 1);
      y = this.blockHeight - 8;
    }
    return { x, y };
  }

  // Display area movement function
  getShowAreaItemTranslate(index: number): PositionXY {
    if (this.dataList[index]?.disabled) {
      return { x: 0, y: 0 };
    }
    // Position when dragging
    if (this.isStartDrag) {
      let coodXY = this.getCoodXY(index);
      return {
        x: coodXY.x,
        y: coodXY.y,
      };
    }

    // Position when remove item
    if (!this.isStartDrag && index === this.selectedIndex) {
      return {
        x: this.editItemMoveX,
        y: this.editItemMoveY,
      };
    }

    // Filling position
    if (!this.isStartDrag && index !== this.selectedIndex && this.clickRemoveBtn) {
      let coveringGridPosition = this.getCoveringGridPosition(index);
      return {
        x: coveringGridPosition.x,
        y: coveringGridPosition.y,
      };
    }
    return { x: 0, y: 0 };
  }

  // Add area movement function
  getAddAreaItemTranslate(index: number): PositionXY {
    // When an item is removed, the added area is moved rightward.
    if (this.clickRemoveBtn) {
      let addItemRightMove = this.getAddItemRightMove(index);
      return {
        x: addItemRightMove.x,
        y: addItemRightMove.y,
      };
    }

    // Move the position when adding an item.
    if (!this.clickRemoveBtn && index === this.unSelectedIndex) {
      return {
        x: this.addItemMoveX,
        y: -this.addItemMoveY,
      };
    }

    // Filling position when adding
    if (!this.clickRemoveBtn && index !== this.unSelectedIndex && this.clickAddBtn) {
      let coveringGridPositionBottom = this.getCoveringGridPositionBottom(index);
      return {
        x: coveringGridPositionBottom.x,
        y: coveringGridPositionBottom.y,
      };
    }

    return { x: 0, y: 0 };
  }

  @Builder
  returnBuilder() {
  }

  @Builder
  PixelMapBuilder(text: ResourceStr) {
    Stack({ alignContent: Alignment.Center }) {
      Row() {
        Text(text)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(14)

        Image($r('app.media.ic_delete'))
          .width(10)
          .height(10)
          .draggable(false)
      }
      .borderRadius(50)
      .padding({
        left: ChannelConstants.TEXT_PADDING_LEFT_RIGHT,
        right: ChannelConstants.TEXT_PADDING_LEFT_RIGHT,
      })
      .scale({ x: this.longScaleOnePointTwo, y: this.longScaleOnePointTwo })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .width(this.textItemEditWidth)
      .height(this.textItemEditHeight)
    }
    .clip(false)
    .height(this.blockHeight * 1.5)
    .width(this.blockWidth * 1.2)
  }

  handleAddIconClick(content: TabInfo): void {
    if (this.clickAddBtn || this.clickRemoveBtn) {
      return;
    }
    this.scaleIcon = 0;
    this.content = content;
    const index = this.unSelected.findIndex(i => i.id === content.id);
    this.editGridDataLength = this.selected.length + 1;
    const endPosition = this.getEditItemGridPosition(this.selected, index);
    this.unSelectedIndex = index;
    this.arrayUnSelectIsChange = 1;
    this.clickAddBtn = true;
    this.calcGridHeight();
    animateTo({
      curve: ChannelConstants.REMOVE_ADD_SPRING,
      onFinish: () => {
        if (!this.selected.some(val => val.id === content.id)) {
          this.arrayUnSelectIsChange = 2;
          this.scaleIcon = 1;
          this.selected.push(content);
          this.unSelected.splice(index, 1);
          this.calcGridHeight();
          this.addItemMoveX = 0;
          this.addItemMoveY = 0;
          if (!this.gridComState) {
            this.onSaveEdit();
          }
          this.clickAddBtn = false;
          this.onSave && this.onSave(this.selected, this.unSelected);
        }
      },
    }, () => {
      this.addItemMoveX = endPosition.x;
      this.addItemMoveY = endPosition.y;
    })
    this.readFlag = false;
    this.readIndex4EditArea = this.editGridDataLength - 1;
  }

  // 文本模式拖动排序区域item
  @Builder
  TextBlockBuilder(select: TabInfo) {
    Stack() {
      Row() {
      }
      .padding({
        left: 16,
        right: 16,
        top: 8,
        bottom: 8,
      })
      .borderRadius(16)
      .translate(this.gridComState ? this.clickRemoveBtn &&
        select.id === this.content.id ? { x: 0 } : { x: -4 } : { x: 0 })
      .height('100%')
      .animation(!this.firstIn ? {
        duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
        curve: this.gridComState ? ChannelConstants.DRAG_SPRING : ChannelConstants.COMMON_BEZIER,
      } : { duration: 0 })
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))

      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Text(select.text)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(14 * this.fontSizeRatio)

        Image($r('app.media.ic_delete'))
          .width(10)
          .height(10)
          .draggable(false)
          .fillColor($r('sys.color.font_primary'))
          .transition({ type: TransitionType.All, scale: { x: 0, y: 0, centerX: '50%' } })
          .scale(select.id === this.content.id ? { x: this.scaleIcon, y: this.scaleIcon } : {})
          .visibility(this.gridComState && !select.disabled ? Visibility.Visible : Visibility.None)
          .animation({
            duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
            curve: ChannelConstants.COMMON_BEZIER,
          })
          .margin({ left: 5 })
      }
      .onClick(() => this.handleDeleteClick(select))
      .accessibilityGroup(true)
      .accessibilityText(this.gridComState ? select.text + '删除' : select.text + '跳转')
      .borderRadius(16)
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .translate(this.gridComState ? this.clickRemoveBtn && select.id === this.content.id ?
        { x: 0 } : { x: -4 } : { x: 0 })
      .padding({
        top: 8,
        bottom: 8,
      })
      .animation(!this.firstIn ? {
        duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
        curve: this.gridComState ? ChannelConstants.DRAG_SPRING : ChannelConstants.COMMON_BEZIER,
      } : { duration: 0 })
    }
    .scale(select.id === this.content.id ? { x: this.longScaleOnePointTwo, y: this.longScaleOnePointTwo } : {})
    .padding({
      left: ChannelConstants.MARGIN_EIGHT,
      right: ChannelConstants.MARGIN_EIGHT,
    })
    .height(this.textItemEditHeight)
  }

  // 文本模式添加区域item
  @Builder
  TextBlockAddItemBuilder(select: TabInfo) {
    Stack() {
      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Image($r('app.media.add'))
          .width(13)
          .height(13)
          .draggable(false)
          .fillColor($r('sys.color.font_primary'))
          .visibility(this.addIconShow && select.id === this.content.id ? Visibility.None : Visibility.Visible)
          .transition({ type: TransitionType.All, scale: { x: 0, y: 0 } })
          .margin({ right: 5 })
          .animation({
            duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
            curve: ChannelConstants.COMMON_BEZIER,
          })

        Text(select.text)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(14 * this.fontSizeRatio)
      }
      .onClick(() => this.handleAddIconClick(select))
      .accessibilityGroup(true)
      .accessibilityText(select.text as string + '添加')
      .padding({ top: 8, bottom: 8 })
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .borderRadius(16)
      .translate(this.addIconShow && select.id === this.content.id && this.gridComState ? { x: -4 } : { x: 0 })
      .animation({
        duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
        curve: ChannelConstants.COMMON_BEZIER,
      })
    }
    .scale(select.id === this.content.id ? { x: this.longScaleOnePointTwo, y: this.longScaleOnePointTwo } : {})
    .padding({
      left: ChannelConstants.MARGIN_EIGHT,
      right: ChannelConstants.MARGIN_EIGHT,
    })
    .height(this.textItemEditHeight)
  }

  onAddTagLongPressEnd(): void {
    this.addAreaLongPressGesture = false;
    animateTo({
      duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
      curve: ChannelConstants.LONG_TOUCH_SCALE,
    }, () => {
      this.longScaleOnePointTwo = 1;
    });
  }

  @Builder
  AddTagBuilder() {
    Grid() {
      ForEach(this.unSelected, (item: TabInfo, index: number) => {
        GridItem() {
          Stack() {
            this.TextBlockAddItemBuilder(item);
          }
          .accessibilityLevel('no')
          .onHover((isHover: boolean) => {
            if (isHover) {
              this.hoverId = item.id;
            } else {
              this.hoverId = '';
            }
          })
          .margin({
            bottom: ChannelConstants.MARGIN_EIGHT,
          })
          .clickEffect({ level: ClickEffectLevel.LIGHT })
          .gesture(
            LongPressGesture({ repeat: true })
              .onAction((event: GestureEvent) => {
                if (!this.gridComState) {
                  animateTo({
                    duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
                    curve: ChannelConstants.COMMON_BEZIER,
                  }, () => {
                    this.addAreaLongPressGesture = true;
                    this.gridComState = true;
                  });
                  this.menuSwitch = true;
                  setTimeout(() => {
                    this.pointToRepeat(ChannelConstants.ADD);
                  }, ChannelConstants.ENTER_EXIT_ICON_DURATION);
                } else {
                  animateTo({
                    duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
                    curve: ChannelConstants.LONG_TOUCH_SCALE,
                  }, () => {
                    this.longScaleOnePointTwo = 1.05;
                  })
                }
                this.calcGridHeight();
              })
              .onActionEnd(() => {
                this.onAddTagLongPressEnd();
              })
              .onActionCancel(() => {
                this.onAddTagLongPressEnd();
              }),
          )
          .id(`add_grid_item_${index}`)
        }
        .clip(false)
        .translate(this.getAddAreaItemTranslate(index))
        .animation({
          curve: this.clickRemoveBtn ? ChannelConstants.DRAG_SPRING :
            index === this.unSelectedIndex ? ChannelConstants.REMOVE_ADD_SPRING : ChannelConstants.DRAG_SPRING,
        })
      }, (item: TabInfo) => item.id.toString())
    }
    .accessibilityLevel('no')
    .translate(this.clickRemoveBtn && this.selected.length % this.colNum === 1 ? { y: -this.blockHeight } : {})
    .animation({
      duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
      curve: ChannelConstants.COMMON_BEZIER,
    })
    .columnsTemplate(this.customColumns)
    .clip(false)
    .height(this.addGridHeight)
    .scrollBar(BarState.Off)
  }

  handleAddItemTouch(event: TouchEvent, item: TabInfo): void {
    if (this.clickAddBtn || this.clickRemoveBtn) {
      return;
    }
    if (event.type === TouchType.Down) {
      this.content = item;
      this.isTouchDown = true;
    }
    if (event.type === TouchType.Cancel) {
      this.isTouchDown = false;
      return;
    }
    if (event.type === TouchType.Up) {
      this.isTouchDown = false;
      if (this.addAreaLongPressGesture || Math.abs(this.longScaleOnePointTwo - 1.05) < this.eps) {
        return;
      }
      animateTo({
        duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
        curve: ChannelConstants.COMMON_BEZIER,
      }, () => {
        this.addIconShow = true;
      })
      this.scaleAddIcon = 1;
      this.scaleIcon = 0;
      const index = this.unSelected.findIndex(i => i.id === item.id);
      this.editGridDataLength = this.selected.length + 1;
      const endPosition = this.getEditItemGridPosition(this.selected, index);
      this.content = item;
      this.unSelectedIndex = index;
      this.clickAddBtn = true;
      this.arrayUnSelectIsChange = 1;
      this.calcGridHeight();
      animateTo({
        curve: ChannelConstants.REMOVE_ADD_SPRING, onFinish: () => {
          if (!this.selected.some(val => val.id === item.id)) {
            this.scaleIcon = 1;
            this.scaleAddIcon = 0;
            this.selected.push(item);
            this.unSelected.splice(index, 1);
            this.calcGridHeight();
            this.arrayUnSelectIsChange = 2;
            this.addItemMoveX = 0;
            this.addItemMoveY = 0;
            if (!this.gridComState) {
              this.onSaveEdit();
            }
            animateTo({
              duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
              curve: ChannelConstants.COMMON_BEZIER,
            }, () => {
              this.addIconShow = false;
            });
            this.clickAddBtn = false;
          }
        },
      }, () => {
        this.addItemMoveX = endPosition.x;
        this.addItemMoveY = endPosition.y;
      })

      this.readFlag = false;
      this.readIndex4EditArea = this.editGridDataLength - 1;
    }
  }

  handleAddItemClick(item: TabInfo): void {
    if (this.clickAddBtn || this.clickRemoveBtn) {
      return;
    }
    this.content = item;

    this.isTouchDown = false;
    if (this.addAreaLongPressGesture || Math.abs(this.longScaleOnePointTwo - 1.05) < this.eps) {
      return;
    }
    animateTo({
      duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
      curve: ChannelConstants.COMMON_BEZIER,
    }, () => {
      this.addIconShow = true;
    })
    this.scaleAddIcon = 1;
    this.scaleIcon = 0;
    const index = this.unSelected.findIndex(i => i.id === item.id);
    this.editGridDataLength = this.selected.length + 1;
    const endPosition = this.getEditItemGridPosition(this.selected, index);
    this.content = item;
    this.unSelectedIndex = index;
    this.clickAddBtn = true;
    this.arrayUnSelectIsChange = 1;
    this.calcGridHeight();
    animateTo({
      curve: ChannelConstants.REMOVE_ADD_SPRING, onFinish: () => {
        if (!this.selected.some(val => val.id === item.id)) {
          this.scaleIcon = 1;
          this.scaleAddIcon = 0;
          this.selected.push(item);
          this.unSelected.splice(index, 1);
          this.calcGridHeight();
          this.arrayUnSelectIsChange = 2;
          this.addItemMoveX = 0;
          this.addItemMoveY = 0;
          if (!this.gridComState) {
            this.onSaveEdit();
          }
          animateTo({
            duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
            curve: ChannelConstants.COMMON_BEZIER,
          }, () => {
            this.addIconShow = false;
          });
          this.clickAddBtn = false;
        }
      },
    }, () => {
      this.addItemMoveX = endPosition.x;
      this.addItemMoveY = endPosition.y;
    })

    this.readFlag = false;
    this.readIndex4EditArea = this.editGridDataLength - 1;
  }

  @Builder
  EditTagBuilder() {
    Column() {
      Grid() {
        ForEach(this.selected, (select: TabInfo, index: number) => {
          GridItem() {
            Stack() {
              this.TextBlockBuilder(select);
            }
            .onHover((isHover: boolean) => {
              if (isHover) {
                this.hoverId = select.id;
              } else {
                this.hoverId = '';
              }
            })
            .clickEffect({ level: ClickEffectLevel.LIGHT })
            .clip(false)
            .margin({
              bottom: this.gridComState ? ChannelConstants.ROW_GAP : ChannelConstants.MARGIN_EIGHT,
            })
            .onTouch((event: TouchEvent) => {
              if (this.clickAddBtn || this.clickRemoveBtn) {
                return;
              }
              if (event.type === TouchType.Down) {
                this.content = select;
                this.isTouchDown = true;
              }

              if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                this.isTouchDown = false;
                animateTo({
                  duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
                  curve: ChannelConstants.LONG_TOUCH_SCALE,
                }, () => {
                  this.longScaleOnePointTwo = 1;
                })
              }
            })
            .id(`edit_grid_item_${index}`)
          }
          .clip(false)
          .translate(this.getShowAreaItemTranslate(index))
          .animation({
            curve: this.isStartDrag ? ChannelConstants.DRAG_SPRING :
              index === this.selectedIndex ? ChannelConstants.REMOVE_ADD_SPRING : ChannelConstants.DRAG_SPRING,
          })
          .visibility(select.visibility)
        }, (item: TabInfo) => item.id.toString())
      }
      .accessibilityLevel('no')
      .scrollBar(BarState.Off)
      .parallelGesture(
        LongPressGesture({ repeat: true })
          .onAction((event: GestureEvent) => {
            if (this.content.disabled) {
              return
            }
            if (!this.gridComState) {
              animateTo({
                duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
                curve: ChannelConstants.COMMON_BEZIER,
              }, () => {
                this.gridComState = true;
              });
              this.menuSwitch = true;
              setTimeout(() => {
                this.pointToRepeat(ChannelConstants.EDIT);
              }, ChannelConstants.ENTER_EXIT_ICON_DURATION);
            } else {
              animateTo({
                duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
                curve: ChannelConstants.LONG_TOUCH_SCALE,
              }, () => {
                this.longScaleOnePointTwo = 1.05;
              });
            }
            this.calcGridHeight();
          })
          .onActionCancel(() => {
            if (this.content.disabled) {
              return
            }
            if (this.isStartDrag) {
              this.insertItem(this.itemIndex, this.itemIndex);
            }
          }),
      )
      .clip(false)
      .editMode(this.gridComState)
      .columnsTemplate(this.customColumns)
      .height(this.editGridHeight)
      .animation(!this.firstIn ? {
        duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
        curve: ChannelConstants.COMMON_BEZIER,
      } : { duration: 0 })
      .onItemDragStart((event: ItemDragInfo, itemIndex: number) => {
        if (this.content.disabled) {
          return this.returnBuilder();
        }
        this.itemIndex = itemIndex;
        this.selectedIndex = -1;
        if (!this.gridComState) {
          return this.returnBuilder();
        }
        this.isStartDrag = true;
        this.insertIndex = itemIndex;
        this.dragContent = this.selected[itemIndex];
        this.dragContentIndex = itemIndex;
        return this.PixelMapBuilder(this.dragContent?.text);
      })
      .onItemDrop((event: ItemDragInfo, itemIndex: number, insertIndex: number, isSuccess: boolean) => {
        if (this.content.disabled) {
          return
        }
        this.insertItem(itemIndex, insertIndex);
      })
      .onItemDragMove(
        (event: ItemDragInfo, itemIndex: number, insertIndex: number) =>
        this.onDragMoveEvent(event, itemIndex, insertIndex),
      )
    }
    .accessibilityLevel('no')
    .parallelGesture(
      LongPressGesture({ repeat: true })
        .onAction(() => {
          this.menuSwitch = true;
        }))
  }

  pointToRepeat(type: string): void {
    let index = -1;
    if (type === ChannelConstants.ADD) {
      index = this.unSelected.findIndex(i => i.id === this.content.id);
      this.readIndex4AddArea = index;
    } else {
      index = this.selected.findIndex(i => i.id === this.content.id);
      this.readIndex4EditArea = index;
    }
  }

  insertItem(itemIndex: number, insertIndex: number): void {
    if (!this.gridComState) {
      return;
    }
    animateTo({
      duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
      curve: ChannelConstants.LONG_TOUCH_SCALE,
    }, () => {
      this.longScaleOnePointTwo = 1;
    })
    this.isStartDrag = false;
    if (insertIndex !== -1) {
      if (this.selected[insertIndex].disabled) {
        this.selected.splice(itemIndex, 1);
        this.selected.splice(itemIndex, 0, this.dragContent);
      } else {
        this.selected.splice(itemIndex, 1);
        this.selected.splice(insertIndex, 0, this.dragContent);
      }
    } else {
      this.insertIndex = itemIndex;
    }
    this.dragContent.visibility = Visibility.Visible;
    this.calcGridHeight();
    this.readFlag = false;
    this.readIndex4EditArea = this.insertIndex;
    this.onSave && this.onSave(this.selected, this.unSelected);
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Row({ space: 8 }) {
            Row({ space: 8 }) {
              Text('我的频道')
                .fontWeight(FontWeight.Medium)
                .fontSize(16 * this.fontSizeRatio)
                .fontColor($r('sys.color.font_primary'))
              Text('点击进入频道')
                .fontSize(12 * this.fontSizeRatio)
                .fontColor($r('sys.color.font_tertiary'))
                .accessibilityLevel('no')
            }

            Row() {
              Text(!this.gridComState ? '编辑' : '完成')
                .fontColor($r('app.color.channel_theme'))
            }
            .onClick(() => {
              this.gridComState = !this.gridComState
              if (this.gridComState) {
                this.goEdit()
              } else {
                this.onSaveEdit()
              }
            })
          }
          .margin({ bottom: 16 })
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          this.EditTagBuilder()
          // addArea
          Row({ space: 8 }) {
            Text('推荐频道')
              .fontWeight(FontWeight.Medium)
              .fontSize(16 * this.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
            Text('点击添加')
              .fontSize(12 * this.fontSizeRatio)
              .fontColor($r('sys.color.font_tertiary'))
              .accessibilityLevel('no')
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .translate(this.clickRemoveBtn && this.selected.length % this.colNum === 1 ? { y: -this.blockHeight } : {})
          .animation({
            duration: ChannelConstants.ENTER_EXIT_ICON_DURATION,
            curve: ChannelConstants.COMMON_BEZIER,
          })
          .margin({ bottom: 16, top: 24 })
          .onAreaChange((oldValue: Area, newValue: Area) => {
            this.subTitleHeight = Number(newValue.height);
          })

          this.AddTagBuilder()
        }
        .onAreaChange((oldValue: Area, newValue: Area) => {
          this.areaWidth = Number(newValue.width);
          this.calcAreaInfo();
        }).width('100%')
      }
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .margin({ top: 16 })
  }

  getStringByResourceToken(value?: string, ...args: Array<string | number>): string {
    if (value) {
      try {
        return getContext(this).resourceManager.getStringByNameSync(value, ...args);
      } catch (error) {
        hilog.error(0x3900, 'Ace', `GridObjectSortComponent getStringByResourceToken, error: ${error.toString()}`);
      }
    }
    return '';
  }
}