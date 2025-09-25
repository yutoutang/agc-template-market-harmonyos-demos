import { TodoItem } from '../model/TodoItem';
import { addTodoTaskBuilder } from './builder/AddTodoTaskBuilder';
import { TodoDataManager } from '../mock/TodoDataManager';
import { ExtInfo, FilterInfo, TodoListTabInfo } from '../mock/TitleDataManager';
import { TodoTitleBar } from './components/TodoTitleBar';
import { UpdateTodoPlanTimeInfo } from '../mock/UpdateTodoInfo';
import { TodoSectionList } from './components/TodoSectionList';
import { StatusFilterEnum } from '../enum/FilterEnum';
import { AvoidArea } from '@ohos_agcit/daily_schedule_component_lib';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct TodoPage {
  dataManager: TodoDataManager = TodoDataManager.instance
  statusManager: FilterInfo = FilterInfo.instance
  updateTodoInfo: UpdateTodoPlanTimeInfo = UpdateTodoPlanTimeInfo.instance
  todoListTabInfo: TodoListTabInfo = TodoListTabInfo.instance
  extInfo: ExtInfo = ExtInfo.instance
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local isShowAddTodoSheet: boolean = false;
  @Local deleteTaskID: string = '';
  @Provider('title') title: string = '';
  @Provider('selectedTime') selectedTime: Date = new Date()
  @Provider('repetitionType') repetitionType: number = 0
  @Provider('repetitionMultiType') repetitionMultiType: number[] = [];
  @Provider('reminderType') reminderType: number = 0
  @Provider('priorityType') priorityType: number = 0

  aboutToAppear(): void {
    this.restore()
  }

  save() {
    this.dataManager.addTask(new TodoItem('', this.title, this.selectedTime, this.repetitionType, this.reminderType,
      this.priorityType, false))
    this.restore()
  }

  restore() {
    this.title = ''
    this.selectedTime = new Date()
    this.repetitionType = 0
    this.reminderType = 0
    this.priorityType = 0
  }

  build() {
    Column() {
      TodoTitleBar({
        onSort: () => {
          this.extInfo.isDescending = !this.extInfo.isDescending
          this.dataManager.sortTask(this.extInfo.isDescending)
        }
      })
        .align(Alignment.Center)

      Stack() {
        if (this.dataManager.allTasks.length !== 0) {
          TodoSectionList({
            params: [
              {
                label: $r('app.string.todo_section_today'),
                data: this.dataManager.todayTasks,
                isShow:
                [StatusFilterEnum.ALL].indexOf(this.todoListTabInfo.statusIndex) !== -1
              },
              {
                label: $r('app.string.todo_section_tomorrow'),
                data: this.dataManager.tomorrowTasks,
                isShow:
                [StatusFilterEnum.ALL].indexOf(this.todoListTabInfo.statusIndex) !== -1
              },
              {
                label: $r('app.string.todo_section_all'),
                data: this.dataManager.allNotCompleteTasks,
                isShow:
                [StatusFilterEnum.ALL].indexOf(this.todoListTabInfo.statusIndex) !== -1
              },
              {
                label: $r('app.string.todo_section_complete'),
                data: this.dataManager.finishedTasks,
                isShow: this.extInfo.isShowFinished &&
                  [StatusFilterEnum.ALL, StatusFilterEnum.FINISHED].indexOf(this.todoListTabInfo.statusIndex) !== -1
              },
              {
                label: $r('app.string.todo_section_expire'),
                data: this.dataManager.expiredTasks,
                isShow:
                [StatusFilterEnum.ALL, StatusFilterEnum.EXPIRED].indexOf(this.todoListTabInfo.statusIndex) !== -1
              }
            ]
          })
        } else {
          Column() {
            Column() {
              Image($r('app.media.todo_bg'))
                .width(100)
                .height(150)
              Text('暂无待办事项，请开始添加吧～').fontWeight(FontWeight.Normal).fontColor($r('sys.color.font_tertiary'))
            }
          }
          .justifyContent(FlexAlign.Center)
          .height('60%')
          .width('100%')
        }


        Image($r('app.media.icon_add'))
          .height(44)
          .width(44)
          .onClick(() => {
            this.isShowAddTodoSheet = !this.isShowAddTodoSheet
          })
          .zIndex(2)
          .position({ x: '80%', y: '85%' })
          .bindSheet($$this.isShowAddTodoSheet, addTodoTaskBuilder({
            onConfirm: () => {
              if (this.title === '') {
                this.getUIContext().getPromptAction().showToast({
                  message: '内容不能为空',
                  alignment: Alignment.Bottom
                })
                return
              }
              this.save()
              this.isShowAddTodoSheet = !this.isShowAddTodoSheet;
            },
            onClose: () => {
              this.isShowAddTodoSheet = !this.isShowAddTodoSheet;
            }
          }), {
            height: SheetSize.LARGE,
            preferType: SheetType.BOTTOM,
            showClose: false
          })
      }
      .align(Alignment.TopStart)
      .height('90%')
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .padding({ top: px2vp(this.avoidArea.topRectHeight) + 10 })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}


