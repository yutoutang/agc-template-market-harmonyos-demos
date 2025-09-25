import { TodoDataManager } from '../../mock/TodoDataManager';
import { TodoSection } from '../components/TodoSection';
import { ExtInfo, FilterInfo } from '../../mock/TitleDataManager';
import { UpdateTodoPlanTimeInfo } from '../../mock/UpdateTodoInfo';
import { DatePickerUpdater } from '../components/DatePickerUpdater';
import { SectionParam } from '../../types/Types';

@ComponentV2
export struct TodoSectionList {
  @Param labels: string[] = []
  @Param params: SectionParam[] = []
  @Param onScrollStartInvoke: () => void = () => {
  }
  @Param onScrollEdgeInvoke: () => void = () => {
  }
  scroller: Scroller = new Scroller()
  dataManager: TodoDataManager = TodoDataManager.instance
  statusManager: FilterInfo = FilterInfo.instance
  updateTodoInfo: UpdateTodoPlanTimeInfo = UpdateTodoPlanTimeInfo.instance
  extInfo: ExtInfo = ExtInfo.instance
  deleteDialogController: CustomDialogController = new CustomDialogController({
    builder: () => {
      this.deleteDialog();
    },
    backgroundColor: $r('sys.color.background_secondary'),
    alignment: DialogAlignment.Center
  });
  modifyDialogController: CustomDialogController = new CustomDialogController({
    builder: () => {
      this.modifyDialog();
    },
    backgroundColor: $r('sys.color.background_secondary'),
    alignment: DialogAlignment.Center
  });

  onDelete(taskID: string) {
    this.updateTodoInfo.deleteTaskID = taskID
    this.deleteDialogController.open()
  }

  onModify(taskID: string) {
    this.updateTodoInfo.modifyTaskID = taskID
    this.modifyDialogController.open()
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        ForEach(this.params, (item: SectionParam, index: number) => {
          if (item.isShow) {
            TodoSection({
              label: item.label,
              todoItems: item.data,
              onDelete: (taskID) => {
                this.onDelete(taskID)
              },
              onModify: (taskID) => {
                this.onModify(taskID)
              }
            })
          }
        },(item: SectionParam)=>JSON.stringify(item))
      }
      .zIndex(1)
    }
    .onDidScroll((xOffset: number, yOffset: number, scrollState: ScrollState) => {
      if (yOffset > 0) {
        this.onScrollStartInvoke()
      }
    })
    .onScrollEdge((side: Edge) => {
      if (side === Edge.Top) {
        this.onScrollEdgeInvoke()
      }
    })
    .width('100%')
    .height('100%')
    .align(Alignment.TopStart)
  }

  /**
   * 删除待办
   */
  @Builder
  deleteDialog() {
    Column({ space: 18 }) {
      Text('是否确认删除？')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Normal)
        .fontColor($r('sys.color.font_primary'))

      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Row() {
          Text($r('app.string.text_cancel'))
            .fontColor($r('sys.color.icon_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          this.deleteDialogController.close();
        })

        Row() {
          Text($r('app.string.dialog_delete'))
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.warning'))
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          this.dataManager.deleteById(this.updateTodoInfo.deleteTaskID)
          this.deleteDialogController.close();
        })
      }
      .padding({
        top: 10
      })
    }
    .justifyContent(FlexAlign.Center)
    .borderRadius(32)
    .height(120)
    .width('92%')
  }

  /**
   * 修改待办
   */
  @Builder
  modifyDialog() {
    Column({ space: 18 }) {
      DatePickerUpdater({ selectedTime: new Date() })

      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Row() {
          Text($r('app.string.text_cancel'))
            .fontColor($r('sys.color.icon_emphasize'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          this.modifyDialogController.close();
        })

        Row() {
          Text($r('app.string.text_confirm'))
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.warning'))
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          this.dataManager.updateTaskPlanTime(this.updateTodoInfo.modifyTaskID, this.updateTodoInfo.modifyPlanTime)
          this.modifyDialogController.close();
        })
      }
      .padding({
        top: 10
      })
    }
    .justifyContent(FlexAlign.Center)
    .borderRadius(32)
    .height(350)
    .width('92%')
  }
}