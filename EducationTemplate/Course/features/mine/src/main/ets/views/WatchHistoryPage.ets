/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { emitter } from '@kit.BasicServicesKit';
import {
  LeftSwipeComponent,
  TopBar,
  EditButton,
  NoData,
  BottomEditBar,
  TopRowModifier,
  RouterModule,
  RouterMap,
} from 'commonlib'
import { CourseCatalogModel, CourseModel } from 'http';
import { MyVM } from '../viewModel/MyVM';
import { CourseHistoryComponent } from '../component/CourseHistoryComponent';

@ComponentV2
export struct WatchHistory {
  @Local topRowModifier: TopRowModifier = new TopRowModifier()
  @Local isEdit: boolean = false
  @Local vm: MyVM = MyVM.instance;
  @Local isSwipe: boolean = false
  @Local selectCount: number = 0
  @Local swipeCourseIndex: number = 0

  aboutToAppear(): void {
    // 我的课程数据初始化
    this.vm.queryCourseHistoryList()
    emitter.on('queryCourse', (event: emitter.EventData) => {
      let isRefresh = event.data!.refresh as boolean
      if (isRefresh) {
        this.vm.queryCourseHistoryList()
      }
    })
  }

  build() {
    Column() {
      this.topBuilder()
      Column() {
        this.listBuilder()
        // 无数据时显示
        NoData({ text: '无课程观看记录' })
          .visibility(this.vm.historyList.length === 0 ? Visibility.Visible : Visibility.None)
      }
      .padding({ top: $r('app.float.vp_8') })
      .layoutWeight(1)

      BottomEditBar({
        deleteAllDialogContent: '是否删除全部记录？',
        selectCount: this.selectCount,
        deleteSelectDialogContent: `是否删除这${this.selectCount}条记录？`,
        deleteSelectData: () => {
          this.deleteSelectData()
        },
        deleteAllData: () => {
          this.deleteAllData()
        }
      }).visibility(this.isEdit ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  listBuilder() {
    List() {
      ForEach(this.vm.historyList, ((item: CourseModel, index: number) => {
        ListItem() {
          Row() {
            Image(item.isDelete ? $r('app.media.selected_on') : $r('app.media.selected_off'))
              .margin({ right: $r('app.float.vp_12') })
              .height($r('app.float.vp_24'))
              .width($r('app.float.vp_24'))
              .visibility(this.isEdit ? Visibility.Visible : Visibility.None)
            CourseHistoryComponent({
              cover: item.cover,
              courseTitle: item.courseTitle,
              learnProgress: item.isStudyEnd ? 100 : item.learnProgress,
            })
          }
          .width('100%')
          .onClick(() => {
            if (this.isEdit) {
              this.isSelectData(item)
            } else {
              RouterModule.push({ url: RouterMap.RECORDED_DETAIL_PAGE, param: item.id })
            }
          })
        }
        .transition({ type: TransitionType.Delete, opacity: 0 })
        .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
        .swipeAction({
          edgeEffect: SwipeEdgeEffect.None,
          end: {
            actionAreaDistance: this.isEdit ? 0 : 26,
            builder: () => {
              this.courseLeftSwipeBuilder(index)
            },
            onStateChange: (state: SwipeActionState) => {
              if (state === SwipeActionState.EXPANDED) {
                this.isSwipe = true
              } else if (state === SwipeActionState.COLLAPSED) {
                this.isSwipe = false
              }
            },
          }
        })
      }), (item: CourseModel, index: number) => item.id + index)
    }
    .layoutWeight(1)
    .padding({ bottom: $r('app.float.vp_8') })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  @Builder
  courseLeftSwipeBuilder(index: number) {
    LeftSwipeComponent({
      dialogContent: '是否删除此记录？',
      index: index,
      confirmLeftSwipeDelete: (idx: number) => {
        this.swipeCourseIndex = idx
        this.swipeDelete()
      }
    }).visibility(this.isEdit ? Visibility.None : Visibility.Visible)
  }

  @Builder
  topBuilder() {
    Row() {
      TopBar({ title: $r('app.string.my_course_history') })
      EditButton({
        isEdit: this.isEdit,
        onClickEdit: () => {
          this.onEditButton()
        }
      })
    }
    .attributeModifier(this.topRowModifier)
  }

  isSelectData(item: CourseModel) {
    item.isDelete = !item.isDelete
    if (!item.isDelete) {
      this.selectCount--;
    } else {
      this.selectCount++;
    }
  }

  deleteAllData() {
    this.vm.historyList.forEach((item: CourseModel) => {
      this.vm.courseData.courseList.forEach((course: CourseModel) => {
        if (item.id === course.id) {
          course.isWatch = false
          course.isStudyEnd = false
          course.learnProgress = 0
          course.courseCatalog.forEach((catalog: CourseCatalogModel) => {
            catalog.isStudyEnd = false
            catalog.learnProgress = 0
          })
        }
      })
    })
    this.vm.historyList = []
    this.isEdit = false
    this.selectCount = 0

  }

  deleteSelectData() {
    this.vm.historyList.forEach((item: CourseModel) => {
      if (item.isDelete) {
        this.vm.courseData.courseList.forEach((course: CourseModel) => {
          if (item.id === course.id) {
            course.isWatch = false
            course.isStudyEnd = false
            course.learnProgress = 0
            course.courseCatalog.forEach((catalog: CourseCatalogModel) => {
              catalog.isStudyEnd = false
              catalog.learnProgress = 0
            })
          }
        })
      }
    })
    this.vm.historyList = this.vm.historyList.filter((it: CourseModel) => it.isDelete === false)
    this.isEdit = false
    this.selectCount = 0
  }

  swipeDelete() {
    let item: CourseModel = this.vm.historyList[this.swipeCourseIndex]
    this.vm.courseData.courseList.forEach((course: CourseModel) => {
      if (item.id === course.id) {
        course.isWatch = false
        course.isStudyEnd = false
        course.learnProgress = 0
        course.courseCatalog.forEach((catalog: CourseCatalogModel) => {
          catalog.isStudyEnd = false
          catalog.learnProgress = 0
        })
      }
    })
    this.vm.historyList.splice(this.swipeCourseIndex, 1)
    this.isSwipe = false
    this.isEdit = false
    this.selectCount = 0
  }

  onEditButton() {
    if (!this.isSwipe && this.vm.historyList.length > 0) {
      this.isEdit = !this.isEdit
      if (!this.isEdit) {
        this.selectCount = 0
        this.vm.historyList.forEach((item: CourseModel) => {
          item.isDelete = false
        })
      }
    }
  }
}

@Builder
export function WatchHistoryPageBuilder() {
  WatchHistory()
}