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

import { emitter } from '@kit.BasicServicesKit'
import { AppStorageV2 } from '@kit.ArkUI'
import {
  TopBar,
  EditButton,
  NoData,
  BottomEditBar,
  LeftSwipeComponent,
  TopRowModifier,
  UserInfo,
  RouterModule,
  RouterMap,
} from 'commonlib'
import { MyVM } from '../viewModel/MyVM'
import { CommentModel, CourseCatalogModel, CourseModel } from 'http'

@ComponentV2
export struct MyCourseComments {
  @Local isEdit: boolean = false
  @Local topRowModifier: TopRowModifier = new TopRowModifier()
  @Local commentsDelete: boolean = false
  @Local vm: MyVM = MyVM.instance;
  @Local selectCount: number = 0
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  @Local swipeCourseIndex: number = 0

  aboutToAppear(): void {
    this.vm.queryCommentsDataList()
    emitter.on('queryComments', (event: emitter.EventData) => {
      let isRefresh = event.data!.refresh as boolean
      if (isRefresh) {
        this.vm.queryCommentsDataList()
      }
    })
  }

  build() {
    Column() {
      this.topBuilder()
      Column() {
        if (this.vm.commentsList.length === 0) {
          // 无数据时显示
          NoData({ text: '暂无评论' })
        } else {
          this.commentsListBuilder()
        }
      }
      .padding({ top: $r('app.float.vp_8') })
      .layoutWeight(1)

      BottomEditBar({
        deleteAllDialogContent: '是否删除全部评论？',
        selectCount: this.selectCount,
        deleteSelectDialogContent: `是否删除这${this.selectCount}条评论？`,
        deleteAllData: () => {
          this.deleteAllData()
        },
        deleteSelectData: () => {
          this.deleteSelectData()
        },
      })
        .visibility(this.isEdit ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  commentsListBuilder() {
    List({ space: 10 }) {
      ForEach(this.vm.commentsList, ((item: CommentModel, index: number) => {
        ListItem() {
          Row() {
            Image(item.isDelete ? $r('app.media.selected_on') : $r('app.media.selected_off'))
              .margin({ right: $r('app.float.vp_12') })
              .width($r('app.float.vp_24'))
              .height($r('app.float.vp_24'))
              .visibility(this.isEdit ? Visibility.Visible : Visibility.None)
            MyComments({ item: item, isEdit: this.isEdit })
          }
          .width('100%')
          .onClick(() => {
            if (this.isEdit) {
              this.isSelectData(item)
            } else {
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
              this.swipeBuilder(index)
            },
            onStateChange: (state: SwipeActionState) => {
              if (state === SwipeActionState.EXPANDED) {
                this.commentsDelete = true
              } else if (state === SwipeActionState.COLLAPSED) {
                this.commentsDelete = false
              }
            },
          }
        })
      }), (item: CommentModel, index: number) => item.id + index)
    }
    .layoutWeight(1)
    .padding({ bottom: $r('app.float.vp_8') })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  @Builder
  topBuilder() {
    Row() {
      TopBar({ title: $r('app.string.my_course_comments') })
      EditButton({
        onClickEdit: () => {
          this.editButton()
        },
        isEdit: this.isEdit,
      })
    }
    .attributeModifier(this.topRowModifier)
  }

  editButton() {
    if (!this.commentsDelete && this.vm.commentsList.length > 0) {
      this.isEdit = !this.isEdit
      if (!this.isEdit) {
        this.selectCount = 0
        this.vm.commentsList.forEach((item: CommentModel) => {
          item.isDelete = false
        })
      }
    }
  }

  isSelectData(item: CommentModel) {
    item.isDelete = !item.isDelete
    if (item.isDelete) {
      this.selectCount++;
    } else {
      this.selectCount--;
    }
  }

  deleteAllData() {
    this.vm.courseData.courseList.forEach((course: CourseModel) => {
      course.courseCatalog.forEach((courseCatalog: CourseCatalogModel) => {
        courseCatalog.comments = []
      })
    })
    this.vm.commentsList = []
    this.isEdit = false
  }

  deleteSelectData() {
    this.vm.commentsList.forEach((comment: CommentModel) => {
      if (comment.isDelete) {
        this.vm.courseData.courseList.forEach((course: CourseModel) => {
          if (comment.courseId === course.id) {
            course.courseCatalog[comment.catalogIndex].comments =
              course.courseCatalog[comment.catalogIndex].comments.filter((it: CommentModel) => it.id !== comment.id)
          }
        })
      }
    })
    this.vm.commentsList = this.vm.commentsList.filter((it: CommentModel) => it.isDelete === false)
    this.selectCount = 0
    this.isEdit = false
  }

  confirmSwipeDelete() {
    let comment = this.vm.commentsList[this.swipeCourseIndex]
    this.vm.courseData.courseList.forEach((course: CourseModel) => {
      if (comment.courseId === course.id) {
        course.courseCatalog[comment.catalogIndex].comments =
          course.courseCatalog[comment.catalogIndex].comments.filter((it: CommentModel) => it.id !== comment.id)
      }
    })
    this.vm.commentsList.splice(this.swipeCourseIndex, 1)
    this.commentsDelete = false
  }

  @Builder
  swipeBuilder(index: number) {
    LeftSwipeComponent({
      dialogContent: '是否删除该此评论？',
      index: index,
      confirmLeftSwipeDelete: (idx: number) => {
        this.swipeCourseIndex = idx
        this.confirmSwipeDelete()
      }
    }).visibility(this.isEdit ? Visibility.None : Visibility.Visible)
  }
}

@ComponentV2
export struct MyComments {
  @Param item: CommentModel = new CommentModel()
  @Param isEdit: boolean = false
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  @Local vm: MyVM = MyVM.instance;

  build() {
    Row() {
      Image(this.loginUser.isLogin ?
        (this.loginUser.avatar && this.loginUser.avatar !== '') ? this.loginUser.avatar :
        $r('app.media.ic_user_default') :
      $r('app.media.icon_me_not_login_avatar'))
        .width($r('app.float.vp_16'))
        .height($r('app.float.vp_16'))
        .borderRadius($r('app.float.vp_8'))
        .margin({ right: $r('app.float.vp_8') })
      Column() {
        Text(this.loginUser.name)
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
        Text(this.item.comment)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: $r('app.float.vp_8'), bottom: $r('app.float.vp_8') })
        Row() {
          Image(this.item.cover)
            .width($r('app.float.vp_64'))
            .height($r('app.float.vp_36'))
            .margin({ right: $r('app.float.vp_8') })

          Text(this.item.courseTitle)
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .wordBreak(WordBreak.BREAK_ALL)
            .layoutWeight(1)
        }
        .padding($r('app.float.vp_8'))
        .height($r('app.float.vp_52'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius($r('app.float.vp_8'))
        .onClick(() => {
          let courseDetail: CourseModel =
            this.vm.courseData.courseList.find((course: CourseModel) => this.item.courseId === course.id) as CourseModel
          courseDetail.catalogIndex = this.item.catalogIndex
          RouterModule.push({ url: RouterMap.CHAPTER_DETAIL_PAGE, param: courseDetail })
        })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .margin({ top: $r('app.float.vp_2') })
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.Start)
  }
}

@Builder
export function MyCourseCommentsBuilder() {
  MyCourseComments()
}