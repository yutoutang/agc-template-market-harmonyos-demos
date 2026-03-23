import { RouterMap, RouterUtils, CommonConstants, KNOWLEDGE_DRAW_DATA, Course, BreakpointNameEnum,
  BreakpointModel } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { CommonKnowledgePageVM } from '../viewmodels/CommonKnowledgePageVM';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function CommonKnowledgePageBuilder() {
  CommonKnowledgePage()
}

interface GridSettingInfo {
  template: string;
  colGap: number;
  rowGap: number;
}

@ComponentV2
struct CommonKnowledgePage {
  vm: CommonKnowledgePageVM = new CommonKnowledgePageVM();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get gridSetting() {
    const gridSettingInfo: GridSettingInfo  = {
      template: '1fr 1fr',
      colGap: 8,
      rowGap: 8,
    }
    if ([BreakpointNameEnum.MD].includes((this.breakPointModel.currentBreakpoint))) {
      gridSettingInfo.template = '1fr 1fr 1fr 1fr'
      gridSettingInfo.colGap = 12
      gridSettingInfo.rowGap = 12
    }
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes((this.breakPointModel.currentBreakpoint))) {
      gridSettingInfo.template = '1fr 1fr 1fr 1fr 1fr 1fr'
      gridSettingInfo.colGap = 16
      gridSettingInfo.rowGap = 16
    }
    return gridSettingInfo
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '运动健身常识普及',
        })
        Grid() {
          ForEach(KNOWLEDGE_DRAW_DATA, (item: Course) => {
            GridItem() {
              Column() {
                Image(item.cover)
                  .width('100%')
                  .borderRadius(8)
                Text(item.courseTitle)
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.Body_S'))
                  .padding({ top: 8 })
              }
              .width('100%')
              .backgroundColor($r('sys.color.white'))
              .padding(8)
              .borderRadius(8)
              .alignItems(HorizontalAlign.Center)
              .onClick(() => RouterUtils.pushPathByName(RouterMap.COMMON_KNOWLEDGE_DETAIL, item.id))
            }
          })
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .columnsTemplate(this.gridSetting.template)
        .columnsGap(this.gridSetting.colGap)
        .rowsGap(this.gridSetting.rowGap)
        .padding({ left: 24, right: 24 })
        .margin({ bottom: 30 })
        .layoutWeight(1)  // 添加布局权重
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('app.color.home_background'))
    }
    .hideTitleBar(true)
  }
}
