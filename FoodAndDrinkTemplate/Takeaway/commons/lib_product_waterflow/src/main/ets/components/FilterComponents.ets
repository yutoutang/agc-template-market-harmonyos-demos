import { HashMap } from '@kit.ArkTS';
import { LengthMetrics } from '@kit.ArkUI';
import { CommonConstants } from 'lib_common';
import { ConditionsItem, MockHomeConfig } from 'lib_takeaway_api/src/main/ets/services/mockdata/MockHomeData';

@ComponentV2
export struct FilterComponents {
  static readonly EVALUATION_KEY: string = '商家评分';
  static readonly SALESVOLUME_KEY: string = '店铺销量';
  static readonly TIME_KEY: string = '配送时间';
  @Param
  scoreThreshold?: number = undefined; //最低评分阈值（可选）
  @Param
  salesThreshold?: number = undefined; // 最低销量阈值（可选）
  @Param
  deliveryTimeThreshold?: number = undefined; // 最大配送时间阈值（可选）
  @Param cancel: () => void = () => {
    // do nothing.
  }
  @Param confirm: () => void = () => {
    // do nothing.
  }
  @Event
  handleClickItem: (labels: HashMap<string, number>) => void;
  // 添加状态管理多选选项
  @Local selectedLabels: string[] = [];
  @Local selectedRecord: Record<string, string> = {};
  @Local selectedValue: HashMap<string, number> = new HashMap();
  // 添加初始化标志
  @Local isInitialized: boolean = false;

  build() {
    Column({ space: 22 }) {
      this.tjBuilder(FilterComponents.EVALUATION_KEY, MockHomeConfig.evaluationItem)
      this.tjBuilder(FilterComponents.SALESVOLUME_KEY, MockHomeConfig.salesVolumeItem)
      this.tjBuilder(FilterComponents.TIME_KEY, MockHomeConfig.deliveryTimeItem)

      Row({ space: 10 }) {
        Text('重置')
          .width(CommonConstants.FOUN_PERCENT)
          .height(CommonConstants.BTN_HEIGHT)
          .fontSize($r('sys.float.Body_L'))
          .fontColor(CommonConstants.FONT_COLOR_LEVEL2)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(CommonConstants.BACKGROUND_COLOR_GREY_2)
          .borderRadius(20)
          .margin({
            bottom: CommonConstants.PADDING_S,
          })
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.resetSelection();
            this.cancel();
          })

        Text('完成')
          .width(CommonConstants.FOUN_PERCENT)
          .height(CommonConstants.BTN_HEIGHT)
          .fontSize($r('sys.float.Body_L'))
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.app_theme'))
          .textAlign(TextAlign.Center)
          .borderRadius(20)
          .margin({
            bottom: CommonConstants.PADDING_S,
          })
          .onClick(() => {
            this.handleClickItem?.(this.selectedValue);
            this.confirm();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .borderRadius(20)
    }
    .padding({
      left: 16,
      right: 16,
      bottom: 16,
      top: 16
    })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    // 组件加载时初始化选择状态
    .onAppear(() => {
      if (!this.isInitialized) {
        this.initializeSelection();
        this.isInitialized = true;
      }
    })
  }

  /**
   * 根据传入的参数初始化选择状态
   */
  initializeSelection() {
    // 初始化商家评分选择
    if (this.scoreThreshold !== undefined) {
      this.initializeFilterSelection(
        FilterComponents.EVALUATION_KEY,
        this.scoreThreshold,
        MockHomeConfig.evaluationItem
      );
    }

    // 初始化店铺销量选择
    if (this.salesThreshold !== undefined) {
      this.initializeFilterSelection(
        FilterComponents.SALESVOLUME_KEY,
        this.salesThreshold,
        MockHomeConfig.salesVolumeItem
      );
    }

    // 初始化配送时间选择
    if (this.deliveryTimeThreshold !== undefined) {
      this.initializeFilterSelection(
        FilterComponents.TIME_KEY,
        this.deliveryTimeThreshold,
        MockHomeConfig.deliveryTimeItem
      );
    }
  }

  /**
   * 初始化单个筛选项的选择状态
   * @param category 类别名称
   * @param threshold 阈值
   * @param items 选项列表
   */
  initializeFilterSelection(category: string, threshold: number, items: ConditionsItem[]) {
    // 查找匹配的选项
    const matchedItem = items.find(item => item.latestSearch === threshold);
    if (matchedItem) {
      // 设置选中状态
      this.selectedLabels.push(matchedItem.label);
      this.selectedRecord[category] = matchedItem.label;
      this.selectedValue.set(category, matchedItem.latestSearch);
    }
  }

  /**
   * 重置所有选择
   */
  resetSelection() {
    this.selectedLabels = [];
    this.selectedValue.clear();
    this.selectedRecord = {};
  }

  @Builder
  tjBuilder(label: string, list: ConditionsItem[]) {
    Column() {
      Row() {
        Text(label)
          .fontSize(14)
          .fontColor(CommonConstants.FONT_COLOR_LEVEL2);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Bottom)
      .margin({ bottom: CommonConstants.SPACE_M });

      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(12), cross: LengthMetrics.vp(12) } }) {
        ForEach(list, (item: ConditionsItem) => {
          Row() {
            Text(item.label)
              .fontSize(14)
              .fontColor(this.selectedLabels.includes(item.label) ? '#FFF17D00' : CommonConstants.FONT_COLOR_LEVEL2)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          }
          .backgroundColor(this.selectedLabels.includes(item.label) ? '#FFFDEAD7' :
          CommonConstants.BACKGROUND_COLOR_GREY_2)
          .padding(CommonConstants.SPACE_S)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .borderRadius(6)
          .borderColor(this.selectedLabels.includes(item.label) ? '#FFF17D00' : CommonConstants.BACKGROUND_COLOR_GREY_2)
          .borderWidth(this.selectedLabels.includes(item.label) ? 2 : 0)
          .width(101)
          .height(44)
          .onClick(() => {
            this.handleItemSelection(label, item);
          });
        }, (item: ConditionsItem, index: number) => JSON.stringify(item));
      }
      .clip(true)
    };
  }

  /**
   * 处理选项点击事件
   * @param category 类别名称
   * @param item 选中的选项
   */
  handleItemSelection(category: string, item: ConditionsItem) {
    // 切换选中状态
    if (this.selectedLabels.includes(item.label)) {
      // 如果已选中，则移除
      this.selectedLabels = this.selectedLabels.filter(label => label !== item.label);
      this.selectedValue.remove(category)
    } else {
      // 判断相同类型是否已经选中，存在则取消
      if (this.selectedRecord[category]) {
        this.selectedLabels = this.selectedLabels.filter(value => value !== this.selectedRecord[category]);
      }
      // 如果未选中，则添加
      this.selectedLabels.push(item.label);
      this.selectedRecord[category] = item.label;
      this.selectedValue.set(category, item.latestSearch);
    }
  }
}
