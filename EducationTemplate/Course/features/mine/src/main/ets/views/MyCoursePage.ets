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

import {
  TopBar,
  EditButton,
  NoData,
  BottomEditBar,
  LeftSwipeComponent,
  CourseItemComponent,
  TopRowModifier,
  RouterModule,
  RouterMap,
  MyCourseModel,
  MyCourseParam
} from 'commonlib'
import { CourseClass, CourseModel, MyCourseClass } from 'http'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct MyCoursePage {
  @Local topRowModifier: TopRowModifier = new TopRowModifier()
  @Local isCourseEdit: boolean = false
  @Local swipeCourseDelete: boolean = false
  @Local selectCount: number = 0
  @Local swipeCourseIndex: number = 0
  @Local myCourseList: MyCourseModel[] = []
  @Local param: MyCourseParam = MyCourseParam.instance()
  myCourseClass: MyCourseClass = AppStorageV2.connect(MyCourseClass, () => new MyCourseClass())!
  courseData: CourseClass = AppStorageV2.connect(CourseClass, () => new CourseClass())!

  @Monitor('param.isLearn')
  isAnswerUpdateChange() {
    if (this.param.isLearn) {
      this.myCourseClass.courseList.forEach((myCourse: CourseModel) => {
        this.courseData.courseList.forEach((course: CourseModel) => {
          if (myCourse.id === course.id) {
            myCourse = course
          }
        })
      })
      this.myCourseList = []
      this.transMyCourseModel()
      this.param.isLearn = false
    }
  }

  aboutToAppear(): void {
    this.initMyCourseData()
  }

  build() {
    Column() {
      this.courseTopBuilder()
      Column() {
        // 课程列表
        this.courseListBuilder()
        // 无数据时显示
        NoData({ text: $r('app.string.course_no_data') })
          .visibility(this.myCourseList.length === 0 ? Visibility.Visible : Visibility.None)
      }
      .layoutWeight(1)
      .padding({ top: $r('app.float.vp_8') })

      Blank()
      // 底部编辑栏
      BottomEditBar({
        selectCount: this.selectCount,
        deleteAllDialogContent: '是否删除全部课程？',
        deleteSelectDialogContent: `是否删除这${this.selectCount}节课程？`,
        deleteAllData: () => {
          this.deleteAllData()
        },
        deleteSelectData: () => {
          this.deleteSelectData()
        }
      }).visibility(this.isCourseEdit ? Visibility.Visible : Visibility.None)

    }
    .height('100%')
    .width('100%')
  }

  /**
   * 课程列表
   */
  @Builder
  courseListBuilder() {
    List() {
      ForEach(this.myCourseList, ((item: MyCourseModel, index: number) => {
        ListItem() {
          Row() {
            Image(item.isDelete ? $r('app.media.selected_on') : $r('app.media.selected_off'))
              .width($r('app.float.vp_24'))
              .height($r('app.float.vp_24'))
              .margin({ right: $r('app.float.vp_12') })
              .visibility(this.isCourseEdit ? Visibility.Visible : Visibility.None)
            // 课程列表子项
            CourseItemComponent({
              courseTitle: item.courseTitle,
              courseDuration: item.courseDuration,
              learnProgress: this.myCourseList[index].learnProgress,
              cover: item.cover,
            })
          }
          .width('100%')
          .onClick(() => {
            if (this.isCourseEdit) {
              // 是否勾选数据
              this.isSelectData(item)
            } else {
              RouterModule.push({ url: RouterMap.RECORDED_DETAIL_PAGE, param: item.id })
            }
          })
        }
        .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
        .transition({ type: TransitionType.Delete, opacity: 0 })
        .swipeAction({
          edgeEffect: SwipeEdgeEffect.None,
          end: {
            builder: () => {
              this.courseLeftSwipeBuilder(index)
            },
            actionAreaDistance: this.isCourseEdit ? 0 : 26,
            onStateChange: (state: SwipeActionState) => {
              if (state === SwipeActionState.EXPANDED) {
                this.swipeCourseDelete = true
              } else if (state === SwipeActionState.COLLAPSED) {
                this.swipeCourseDelete = false
              }
            },
          }
        })
      }), (item: MyCourseModel, index: number) => item.id + index)
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .scrollBar(BarState.Off)
    .padding({ bottom: $r('app.float.vp_8') })
  }

  /**
   * 是否勾选数据
   * @param item
   */
  isSelectData(item: MyCourseModel) {
    item.isDelete = !item.isDelete
    if (item.isDelete) {
      this.selectCount++;
    } else {
      this.selectCount--;
    }
  }

  /**
   * 删除全部课程
   */
  deleteAllData() {
    this.myCourseClass.courseList = []
    this.myCourseList = []
    this.isCourseEdit = false
  }

  /**
   * 删除选中课程
   */
  deleteSelectData() {
    this.myCourseList.forEach((item: MyCourseModel) => {
      if (item.isDelete) {
        this.myCourseClass.courseList =
          this.myCourseClass.courseList.filter((course: CourseModel) => course.id !== item.id)
      }
    })
    this.myCourseList = this.myCourseList.filter((it: MyCourseModel) => !it.isDelete)
    this.isCourseEdit = false
    this.selectCount = 0
  }

  /**
   * 确认左滑删除
   */
  confirmLeftSwipeDelete() {
    this.myCourseClass.courseList.splice(this.swipeCourseIndex, 1)
    this.myCourseList.splice(this.swipeCourseIndex, 1)
    this.swipeCourseDelete = false
  }

  /**
   * 左滑删除
   */
  @Builder
  courseLeftSwipeBuilder(index: number) {
    LeftSwipeComponent({
      index: index,
      dialogContent: '是否删除此节课程？',
      confirmLeftSwipeDelete: () => {
        this.confirmLeftSwipeDelete()
      }
    }).visibility(this.isCourseEdit ? Visibility.None : Visibility.Visible)
  }

  /**
   * 顶部
   */
  @Builder
  courseTopBuilder() {
    Row() {
      TopBar({ title: $r('app.string.my_course') })
      EditButton({
        isEdit: this.isCourseEdit,
        onClickEdit: () => {
          this.onClickEditButton()
        }
      })
    }
    .attributeModifier(this.topRowModifier)
  }

  /**
   * 点击编辑按钮
   */
  onClickEditButton() {
    if (!this.swipeCourseDelete && this.myCourseList.length > 0) {
      this.isCourseEdit = !this.isCourseEdit
      if (!this.isCourseEdit) {
        this.selectCount = 0
        this.myCourseList.forEach((item: MyCourseModel) => {
          item.isDelete = false
        })
      }
    }
  }

  initMyCourseData() {
    if (!this.param.isFreeCourseInit) {
      // 第一次进入页面时将免费课程添加到我的课程
      let freeCourseData: CourseModel[] =
        this.courseData.courseList.filter((item: CourseModel) => item.category === 1 && item.isFree)
      this.myCourseClass.courseList = this.myCourseClass.courseList.concat(freeCourseData)
      this.param.isFreeCourseInit = true
    }
    this.transMyCourseModel()
  }

  transMyCourseModel() {
    this.myCourseClass.courseList.sort((a, b) => b.time - a.time)
    this.myCourseClass.courseList.forEach((item: CourseModel) => {
      let courseModel: MyCourseModel = new MyCourseModel()
      courseModel.id = item.id
      courseModel.courseTitle = item.courseTitle
      courseModel.courseDuration = item.courseDuration
      courseModel.learnProgress = item.learnProgress
      courseModel.cover = item.cover
      courseModel.time = item.time
      courseModel.isDelete = false
      this.myCourseList.push(courseModel)
    })
  }
}

@Builder
export function MyCoursePageBuilder() {
  MyCoursePage()
}