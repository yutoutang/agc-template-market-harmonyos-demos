import { RouterMap, RouterUtils, CommonConstants, ADVANCED_COURSE_DATA, Course, BreakpointModel,
  BreakpointNameEnum } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { AdvancedCoursePageVM } from '../viewmodels/AdvancedCoursePageVM';
import { AppStorageV2, display } from '@kit.ArkUI';
import { NumberUtil } from 'mine/src/main/ets/utils/NumberUtil';

@Builder
export function AdvancedCoursePageBuilder() {
  AdvancedCoursePage()
}

interface GridSettingInfo {
  template: string;
  colGap: number;
  rowGap: number;
}

@ComponentV2
export struct AdvancedCourse {
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get gridSetting() {
    // 获取当前屏幕旋转角度（0-3 分别对应 0°、90°、180°、270°）
    let rotation: number = display.getDefaultDisplaySync().rotation;
    const gridSettingInfo: GridSettingInfo  = {
      template: '1fr 1fr',
      colGap: 8,
      rowGap: 8,
    }
    if (BreakpointNameEnum.MD === this.breakPointModel.currentBreakpoint) {
      gridSettingInfo.template = '1fr 1fr 1fr 1fr'
      gridSettingInfo.colGap = 12
    }
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes((this.breakPointModel.currentBreakpoint))) {
      if (rotation === 1 || rotation === 3) {
        gridSettingInfo.template = '1fr 1fr 1fr 1fr 1fr'
        gridSettingInfo.colGap = 16
        gridSettingInfo.rowGap = 16
      }
    }
    return gridSettingInfo
  }

  build() {
    Grid() {
      ForEach(ADVANCED_COURSE_DATA, (item: Course) => {
        GridItem() {
          Row() {
            Column() {
              Image(item.cover)
                .width('100%')
                .height(90)
                .borderRadius({ topLeft: 8, topRight: 8 })
              Column() {
                Text(item.courseTitle)
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.Body_M'))
                  .margin({ bottom: 8 })
                Text(`难度：${item.difficultyLevel}`)
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor('rgba(0, 0, 0, 0.4)')
                Row() {
                  Image($r('app.media.ic_time'))
                    .width(12)
                    .height(12)
                    .margin({ right: 9 })
                  Text(NumberUtil.getHourAndMinuteFormat(item.courseDuration))
                    .fontColor('rgba(0, 0, 0, 0.4)')
                    .fontWeight(FontWeight.Medium)
                    .fontSize($r('sys.float.Body_S'))
                }
              }
              .alignItems(HorizontalAlign.Start)
              .padding({
                left: 8,
                right: 8,
                top: 8,
                bottom: 8
              })
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .height(166)
            .backgroundColor($r('sys.color.white'))
            .borderRadius(8)
            .onClick(() => RouterUtils.pushPathByName(RouterMap.COURSE_DETAIL_PAGE, item.id))
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
      })
    }
    .columnsTemplate(this.gridSetting.template)
    .columnsGap(this.gridSetting.colGap)
    .rowsGap(this.gridSetting.rowGap)
  }
}

@ComponentV2
struct AdvancedCoursePage {
  vm: AdvancedCoursePageVM = new AdvancedCoursePageVM();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '进阶课程',
        })

        Column() {
          AdvancedCourse()
        }
        .margin({ left: 16, right: 16 })
      }
      .height('100%')
      .width('100%')
      .backgroundColor($r('app.color.course_background'))
    }
    .hideTitleBar(true)
  }
}
