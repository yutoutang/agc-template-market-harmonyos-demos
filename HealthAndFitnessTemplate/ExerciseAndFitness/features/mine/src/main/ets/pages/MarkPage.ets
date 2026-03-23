import dayjs from 'dayjs';
import { MineServiceApi } from 'lib_api';
import { BreakpointModel, BreakpointNameEnum, Course, COURSE_DATA } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { CourseItemComponent } from '../components/CourseItemComponent';
import { LeftSwipeComponent } from '../components/LeftSwipeComponent';
import { CollectionModel } from '../viewmodels/CollectionModel';
import { DeleteDialog } from '../viewmodels/DeleteDialog';
import { MarkViewModel } from '../viewmodels/MarkVM';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function MarkPageBuilder() {
  MarkPage()
}

@ComponentV2
struct MarkPage {
  @Local collectionList: CollectionModel[] = []

  @Local vm: MarkViewModel = new MarkViewModel();

  @Local isEdit: boolean = false
  // 是否左滑
  @Local isLeftSwipe: boolean = false
  // 选中计数
  @Local selectCount: number = 0
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  // 左滑删除下标
  @Provider() swipeIndex: number = 0
  // 删除弹框
  deleteDialogController?: CustomDialogController;

  async aboutToAppear() {
    // 我的收藏数据初始化
    this.initCollectionData()
  }

  aboutToDisappear(): void {
    this.saveCollectionData()
  }

  @Computed
  get gapSetting() {
    if (BreakpointNameEnum.MD === this.breakPointModel.currentBreakpoint) {
      return false
    }
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes((this.breakPointModel.currentBreakpoint))) {
      return false
    }
    return true
  }

  @Builder
  editBuilder() {
    Text(this.isEdit ? '取消' : '编辑')
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(20)
      .width(64)
      .height(40)
      .textAlign(TextAlign.Center)
      .onClick(() => {
        this.onClickEdit()
      })
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '我的收藏',
          rightPartBuilder: () => {
            this.editBuilder();
          },
        })

        Column() {
          // 有数据时显示收藏列表
          List() {
            ForEach(this.collectionList, ((item: CollectionModel, index: number) => {
              ListItem() {
                Row() {
                  Image(item.isDelete ? $r('app.media.selected_on') : $r('app.media.selected_off'))
                    .width(24)
                    .height(24)
                    .margin({ right: 12 })
                    .visibility(this.isEdit ? Visibility.Visible : Visibility.None)
                  // 课程列表子项
                  CourseItemComponent({
                    courseId: item.id,
                    courseTitle: item.courseTitle,
                    courseDuration: item.courseDuration,
                    learnProgress: item.learnProgress,
                    cover: item.cover,
                    time: item.time,
                  })
                }
                .width('100%')
                .onClick(() => {
                  if (this.isEdit) {
                    // 是否勾选数据
                    this.isSelectData(item)
                  }
                })
              }
              .padding({ left: 16, right: 16 })
              .transition({ type: TransitionType.Delete, opacity: 0 })
              .swipeAction({
                edgeEffect: SwipeEdgeEffect.None,
                end: {
                  builder: () => {
                    this.collectionLeftSwipeBuilder(index)
                  },
                  actionAreaDistance: this.isEdit ? 0 : 26,
                  onStateChange: (state: SwipeActionState) => {
                    if (state === SwipeActionState.EXPANDED) {
                      this.isLeftSwipe = true
                    } else if (state === SwipeActionState.COLLAPSED) {
                      this.isLeftSwipe = false
                    }
                  },
                }
              })
            }), (item: CollectionModel, index: number) => item.id + index)
          }
          .scrollBar(BarState.Off)
          .lanes(this.listLanes)
          // 无数据时显示
          Text('当前暂无收藏记录。')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.icon_secondary'))
            .height('100%')
            .visibility(this.collectionList.length === 0 ? Visibility.Visible : Visibility.None)
        }
        .padding({ left: this.gapSetting ? 0 : 18 })
        .layoutWeight(1)

        Row() {
          Column() {
            Image($r('app.media.ic_public_eraser'))
              .width(24)
              .height(24)
            Text('一键清空')
              .fontSize($r('sys.float.Caption_M'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
              .margin({ top: 4 })
          }
          .width('50%')
          .onClick(() => {
            // 删除全部
            this.dialogOpen('是否删除全部收藏？',true)
          })

          Column() {
            Image(this.selectCount > 0 ? $r('app.media.icon_delete_black') : $r('app.media.icon_delete_grey'))
              .width(24)
              .height(24)
            Text('删除')
              .fontSize($r('sys.float.Caption_M'))
              .fontWeight(FontWeight.Regular)
              .fontColor(this.selectCount > 0 ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
              .margin({ top: 4 })
          }
          .width('50%')
          .onClick(() => {
            // 删除选中
            this.dialogOpen(`是否删除${this.selectCount}条收藏？`)
          })
        }
        .margin({ bottom: 20 })
        .width('100%')
        .height(52)
      }
    }
    .hideTitleBar(true)
    .onShown(() => {
      this.collectionList = []
      this.initCollectionData()
    })
  }

  @Computed
  get listLanes() {
    if ([BreakpointNameEnum.SM].includes(this.breakPointModel.currentBreakpoint)) {
      return 1;
    } else if ([BreakpointNameEnum.MD].includes(this.breakPointModel.currentBreakpoint)) {
      return 2;
    }
    return 3;
  }

  /**
   * 左滑删除
   */
  @Builder
  collectionLeftSwipeBuilder(index: number) {
    LeftSwipeComponent({
      index: index,
      dialogContent: '是否删除此条收藏？',
      confirmLeftSwipeDelete: () => {
        this.confirmLeftSwipeDelete()
      }
    }).visibility(this.isEdit ? Visibility.None : Visibility.Visible)
  }

  /**
   * 我的收藏数据初始化
   */
  initCollectionData() {
    MineServiceApi.queryMyMarks().forEach((title: string) => {
      let courseModel: CollectionModel = new CollectionModel()
      const course = COURSE_DATA.find(item => item.courseTitle === title)
      if (course) {
        courseModel.id = course.id
        courseModel.isDelete = false
        courseModel.cover = course.cover
        courseModel.courseTitle = course.courseTitle
        courseModel.courseDuration = course.courseDuration
        courseModel.learnProgress = course.learnProgress
        courseModel.time = dayjs(course.time).format('YYYY-MM-DD')
      }
      this.collectionList.push(courseModel)
    })
    //按照时间顺序由近及远
    this.collectionList.sort((a, b) => dayjs(b.time).valueOf() - dayjs(a.time).valueOf())
  }

  /**
   * 我的收藏数据刷新
   */
  saveCollectionData() {
    MineServiceApi.clearMyMarks()
    COURSE_DATA.forEach((item: Course) => {
      AppStorage.setOrCreate<boolean>(item.id, false)
    })
    this.collectionList.forEach((item: CollectionModel) => {
      MineServiceApi.addMark(item.courseTitle as string)
      AppStorage.setOrCreate<boolean>(item.id, true)
    })
  }

  dialogOpen(content: ResourceStr, isDeleteAll?: boolean) {
    this.deleteDialogController = new CustomDialogController({
      builder: DeleteDialog({
        content: content,
        confirmDelete: () => {
          if (isDeleteAll) {
            this.deleteAllData()
          } else {
            this.deleteSelectData()
          }
        }
      }),
    })
    this.deleteDialogController.open()
  }

  onClickEdit() {
    if (!this.isLeftSwipe && this.collectionList.length > 0) {
      this.isEdit = !this.isEdit
      if (!this.isEdit) {
        this.selectCount = 0
        this.collectionList.forEach((item: CollectionModel) => {
          item.isDelete = false
        })
      }
    }
  }

  /**
   * 确认左滑删除
   */
  confirmLeftSwipeDelete() {
    this.collectionList.splice(this.swipeIndex, 1)
    this.isLeftSwipe = false
  }

  /**
   * 删除选中数据
   */
  deleteSelectData() {
    this.collectionList = this.collectionList.filter((it: CollectionModel) => it.isDelete === false)
    this.saveCollectionData()
    this.isEdit = false
    this.selectCount = 0
  }

  /**
   * 删除全部数据
   */
  deleteAllData() {
    this.collectionList = []
    this.isEdit = false
  }

  /**
   * 是否勾选数据
   * @param item
   */
  isSelectData(item: CollectionModel) {
    this.collectionList.forEach((it: CollectionModel) => {
      if (item.id === it.id) {
        item.isDelete = !item.isDelete
        it.isDelete = !it.isDelete
      }
    })
    if (item.isDelete) {
      this.selectCount++;
    } else {
      this.selectCount--;
    }
  }
}


