/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the 'License');
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an 'AS IS' BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

import {
  BottomEditBar,
  EditButton,
  LeftSwipeComponent,
  NoData,
  PreferConstant,
  PreferenceUtil,
  QuestionsRouterModel,
  RouterMap,
  RouterModule,
  TopBar,
  TopicItemModelPreference,
  TopRowModifier,
  WrongQuestionModel
} from 'commonlib'
import { TopicItemComponent } from '../component/TopicItemComponent'

@ComponentV2
export struct MyWrongQuestionPage {
  @Local topRowModifier: TopRowModifier = new TopRowModifier()
  @Local topicPreferences: TopicItemModelPreference[] = [];
  @Local wrongQuestionList: WrongQuestionModel[] = []
  // 是否左滑
  @Local isLeftSwipe: boolean = false
  // 是否编辑
  @Local isEditWrong: boolean = false
  // 选中计数
  @Local selectCount: number = 0
  // 左滑删除下标
  @Provider() swipeIndex: number = 0

  aboutToAppear(): void {
    // 我的错题数据初始化
    this.initWrongQuestionData()
  }

  build() {
    Column() {
      // 顶部
      this.wrongQuestionTopBuilder()
      Column() {
        // 有数据时显示收藏列表
        this.wrongQuestionListBuilder()
        // 无数据时显示
        NoData({ text: $r('app.string.wrong_question_no_data') })
          .visibility(this.wrongQuestionList.length === 0 ? Visibility.Visible : Visibility.None)
      }
      .layoutWeight(1)

      Blank()
      // 底部编辑栏
      BottomEditBar({
        selectCount: this.selectCount,
        deleteAllDialogContent: '是否删除全部题目？',
        deleteSelectDialogContent: `是否删除这${this.selectCount}道题目？`,
        deleteAllData: () => {
          this.deleteAllData()
        },
        deleteSelectData: () => {
          this.deleteSelectData()
        }
      }).visibility(this.isEditWrong ? Visibility.Visible : Visibility.None)
    }
    .height('100%')
    .width('100%')
  }

  /**
   * 下载列表
   */
  @Builder
  wrongQuestionListBuilder() {
    List() {
      ForEach(this.wrongQuestionList, ((item: WrongQuestionModel, index: number) => {
        ListItem() {
          Row() {
            Image(item.isDelete ? $r('app.media.selected_on') : $r('app.media.selected_off'))
              .width($r('app.float.vp_24'))
              .height($r('app.float.vp_24'))
              .margin({ right: $r('app.float.vp_12') })
              .visibility(this.isEditWrong ? Visibility.Visible : Visibility.None)
            // 题目列表子项
            TopicItemComponent({
              topicTitle: item.topicTitle,
              topicSource: item.topicSource
            })
          }
          .width('100%')
          .onClick(() => {
            if (this.isEditWrong) {
              // 是否勾选数据
              this.isSelectData(item)
            } else {
              let routerModel: QuestionsRouterModel = new QuestionsRouterModel()
              routerModel.sourcePageTitle = '我的错题'
              routerModel.topicPreference = this.topicPreferences[index]
              RouterModule.push({ url: RouterMap.ANSWER_QUESTIONS_PAGE, param: routerModel });
            }
          })
        }
        .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
        .transition({ type: TransitionType.Delete, opacity: 0 })
        .swipeAction({
          edgeEffect: SwipeEdgeEffect.None,
          end: {
            builder: () => {
              this.wrongQuestionLeftSwipeBuilder(index)
            },
            actionAreaDistance: this.isEditWrong ? 0 : 26,
            onStateChange: (state: SwipeActionState) => {
              if (state === SwipeActionState.EXPANDED) {
                this.isLeftSwipe = true
              } else if (state === SwipeActionState.COLLAPSED) {
                this.isLeftSwipe = false
              }
            },
          }
        })
      }), (item: WrongQuestionModel, index: number) => item.id + index)
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .scrollBar(BarState.Off)
    .padding({ bottom: $r('app.float.vp_8') })
  }

  /**
   * 左滑删除
   */
  @Builder
  wrongQuestionLeftSwipeBuilder(index: number) {
    LeftSwipeComponent({
      index: index,
      dialogContent: '是否删除此道题目？',
      confirmLeftSwipeDelete: () => {
        this.confirmLeftSwipeDelete()
      }
    }).visibility(this.isEditWrong ? Visibility.None : Visibility.Visible)

  }

  /**
   * 顶部
   */
  @Builder
  wrongQuestionTopBuilder() {
    Row() {
      TopBar({ title: $r('app.string.my_wrong_question') })
      EditButton({
        isEdit: this.isEditWrong,
        onClickEdit: () => {
          this.onClickEdit()
        }
      })
    }
    .attributeModifier(this.topRowModifier)
  }

  /**
   * 我的错题数据初始化
   */
  initWrongQuestionData() {
    // 获取错题全部持久化缓存数据
    let data = PreferenceUtil.getInstance(PreferConstant.WRONG_QUESTION_RECORDS).getAllSync()
    if (data) {
      this.topicPreferences = Object.values(data) as TopicItemModelPreference[];
    }
    // 按照时间顺序由近及远
    this.topicPreferences.sort((a, b) => b.time - a.time)
    this.topicPreferences.forEach((item: TopicItemModelPreference) => {
      let courseModel: WrongQuestionModel = new WrongQuestionModel()
      courseModel.id = item.keyID
      courseModel.time = item.time
      courseModel.isDelete = false
      courseModel.topicTitle = item.title
      courseModel.topicSource = item.topicSource
      this.wrongQuestionList.push(courseModel)
    })
  }

  /**
   * 点击编辑按钮
   */
  onClickEdit() {
    if (!this.isLeftSwipe && this.wrongQuestionList.length > 0) {
      this.isEditWrong = !this.isEditWrong
      if (!this.isEditWrong) {
        this.selectCount = 0
        this.wrongQuestionList.forEach((item: WrongQuestionModel) => {
          item.isDelete = false
        })
      }
    }
  }

  /**
   * 确认左滑删除
   */
  confirmLeftSwipeDelete() {
    PreferenceUtil.getInstance(PreferConstant.WRONG_QUESTION_RECORDS)
      .delete(this.wrongQuestionList[this.swipeIndex].id);
    this.wrongQuestionList.splice(this.swipeIndex, 1)
    this.isLeftSwipe = false
  }

  /**
   * 删除选中数据
   */
  deleteSelectData() {
    this.wrongQuestionList.forEach((item: WrongQuestionModel) => {
      if (item.isDelete) {
        // 删除
        PreferenceUtil.getInstance(PreferConstant.WRONG_QUESTION_RECORDS).delete(item.id);
      }
    })
    this.wrongQuestionList = this.wrongQuestionList.filter((it: WrongQuestionModel) => !it.isDelete)
    this.isEditWrong = false
    this.selectCount = 0
  }

  /**
   * 删除全部数据
   */
  deleteAllData() {
    PreferenceUtil.getInstance(PreferConstant.WRONG_QUESTION_RECORDS).clear()
    this.wrongQuestionList = []
    this.isEditWrong = false
  }

  /**
   * 是否勾选数据
   * @param item
   */
  isSelectData(item: WrongQuestionModel) {
    item.isDelete = !item.isDelete
    if (item.isDelete) {
      this.selectCount++;
    } else {
      this.selectCount--;
    }
  }
}

@Builder
export function MyWrongQuestionPageBuilder() {
  MyWrongQuestionPage()
}