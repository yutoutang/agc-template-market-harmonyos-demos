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
  CollectionModel,
  CollectionRouter,
  CourseItemComponent,
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
  TopRowModifier
} from 'commonlib'
import { TopicItemComponent } from '../component/TopicItemComponent'

@ComponentV2
export struct MyCollectionPage {
  @Local topRowModifier: TopRowModifier = new TopRowModifier()
  @Local topicPreferences: TopicItemModelPreference[] = [];
  @Local collectionList: CollectionModel[] = []
  @Local collectionCourseList: CollectionModel[] = []
  @Local collectionTopicList: CollectionModel[] = []
  // 是否为课程
  @Local isCourse: boolean = true
  // 是否左滑
  @Local isLeftSwipe: boolean = false
  // 是否编辑
  @Local isEditCollection: boolean = false
  // 选中计数
  @Local selectCount: number = 0
  // 左滑删除下标
  @Provider() swipeIndex: number = 0
  @Local collectionRouter: CollectionRouter = CollectionRouter.instance();

  @Monitor('collectionRouter.isCollection')
  isCollectionChange() {
    this.collectionCourseList = []
    this.initCollectionCourseData()
  }

  @Monitor('collectionRouter.isAnswerUpdate')
  isAnswerUpdateChange() {
    this.collectionTopicList = []
    this.initCollectionTopicData()
  }

  @Monitor('isCourse')
  isCourseChange(monitor: IMonitor) {
    // 处于编辑模式时取消
    if (this.isEditCollection) {
      this.isEditCollection = false
      this.selectCount = 0
      this.collectionList.forEach((item: CollectionModel) => {
        item.isDelete = false
      })
    }
    // 处于左滑状态时取消
    if (this.isLeftSwipe) {
      this.isLeftSwipe = false
    }
    if (monitor.value()?.now) {
      this.collectionList = this.collectionCourseList
    } else {
      this.collectionList = this.collectionTopicList
    }
  }

  aboutToAppear(): void {
    // 我的收藏数据初始化
    this.initCollectionCourseData()
    this.initCollectionTopicData()
    this.collectionRouter.routerTitle = '我的收藏'
  }

  aboutToDisappear(): void {
    this.collectionRouter.routerTitle = ''
  }

  build() {
    Column() {
      // 顶部
      this.collectionTopBuilder()
      // 页签
      this.tabsBuilder()
      Column() {
        // 有数据时显示收藏列表
        this.collectionListBuilder()
        // 无数据时显示
        NoData({ text: $r('app.string.collection_no_data') })
          .visibility(this.collectionList.length === 0 ? Visibility.Visible : Visibility.None)
      }
      .layoutWeight(1)

      Blank()
      // 底部编辑栏
      BottomEditBar({
        selectCount: this.selectCount,
        deleteAllDialogContent: this.isCourse ? '是否删除全部课程？' : '是否删除全部题目？',
        deleteSelectDialogContent: this.isCourse ? `是否删除这${this.selectCount}节课程？` :
          `是否删除这${this.selectCount}道题目？`,
        deleteAllData: () => {
          this.deleteAllData()
        },
        deleteSelectData: () => {
          this.deleteSelectData()
        }
      }).visibility(this.isEditCollection ? Visibility.Visible : Visibility.None)
    }
    .height('100%')
    .width('100%')
  }

  /**
   * 页签
   */
  @Builder
  tabsBuilder() {
    Row() {
      Text($r('app.string.course'))
        .width('50%')
        .height('100%')
        .textAlign(TextAlign.Center)
        .backgroundColor(this.isCourse ? $r('sys.color.background_primary') : '')
        .borderRadius(this.isCourse ? 20 : 0)
        .shadow({
          radius: this.isCourse ? 10 : 0,
          color: 'rgba(0, 0, 0, 0.2)',
        })
        .fontColor(this.isCourse ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          this.isCourse = true
        })
      Text($r('app.string.topic'))
        .width('50%')
        .height('100%')
        .textAlign(TextAlign.Center)
        .backgroundColor(this.isCourse ? '' : $r('sys.color.background_primary'))
        .borderRadius(this.isCourse ? 0 : 20)
        .shadow({
          radius: this.isCourse ? 0 : 10,
          color: 'rgba(0, 0, 0, 0.2)',
        })
        .fontColor(this.isCourse ? $r('sys.color.font_secondary') : $r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          this.isCourse = false
        })
    }
    .height($r('app.float.vp_40'))
    .borderRadius(20)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .margin({
      top: $r('app.float.vp_8'),
      left: $r('app.float.vp_16'),
      bottom: $r('app.float.vp_8'),
      right: $r('app.float.vp_16'),
    })
  }

  /**
   * 下载列表
   */
  @Builder
  collectionListBuilder() {
    List() {
      ForEach(this.collectionList, ((item: CollectionModel, index: number) => {
        ListItem() {
          Row() {
            Image(item.isDelete ? $r('app.media.selected_on') : $r('app.media.selected_off'))
              .width($r('app.float.vp_24'))
              .height($r('app.float.vp_24'))
              .margin({ right: $r('app.float.vp_12') })
              .visibility(this.isEditCollection ? Visibility.Visible : Visibility.None)
            // 课程列表子项
            CourseItemComponent({
              courseTitle: item.courseTitle,
              courseDuration: item.courseDuration,
              learnProgress: item.learnProgress,
              cover: item.cover,
            }).visibility(this.isCourse ? Visibility.Visible : Visibility.None)
            // 题目列表子项
            TopicItemComponent({
              topicTitle: item.topicTitle,
              topicSource: item.topicSource
            }).visibility(this.isCourse ? Visibility.None : Visibility.Visible)
          }
          .width('100%')
          .onClick(() => {
            if (this.isEditCollection) {
              // 是否勾选数据
              this.isSelectData(item)
            } else {
              if (this.isCourse) {
                RouterModule.push({ url: RouterMap.RECORDED_DETAIL_PAGE, param: item.id })
              } else {
                let routerModel: QuestionsRouterModel = new QuestionsRouterModel()
                routerModel.sourcePageTitle = '我的收藏'
                routerModel.topicPreference = this.topicPreferences[index]
                this.collectionRouter.topicSource = item.topicSource
                RouterModule.push({ url: RouterMap.ANSWER_QUESTIONS_PAGE, param: routerModel });
              }
            }
          })
        }
        .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
        .transition({ type: TransitionType.Delete, opacity: 0 })
        .swipeAction({
          edgeEffect: SwipeEdgeEffect.None,
          end: {
            builder: () => {
              this.collectionLeftSwipeBuilder(index)
            },
            actionAreaDistance: this.isEditCollection ? 0 : 26,
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
    .width('100%')
    .height('auto')
    .scrollBar(BarState.Off)
    .padding({ bottom: $r('app.float.vp_8') })
  }

  /**
   * 左滑删除
   */
  @Builder
  collectionLeftSwipeBuilder(index: number) {
    LeftSwipeComponent({
      index: index,
      dialogContent: this.isCourse ? '是否删除此节课程？' : '是否删除此道题目？',
      confirmLeftSwipeDelete: () => {
        this.confirmLeftSwipeDelete()
      }
    }).visibility(this.isEditCollection ? Visibility.None : Visibility.Visible)

  }

  /**
   * 顶部
   */
  @Builder
  collectionTopBuilder() {
    Row() {
      TopBar({ title: $r('app.string.my_collection') })
      EditButton({
        isEdit: this.isEditCollection,
        onClickEdit: () => {
          this.onClickEdit()
        }
      })
    }
    .attributeModifier(this.topRowModifier)
  }

  /**
   * 初始化收藏题目数据
   */
  initCollectionTopicData() {
    // 获取收藏题目全部持久化缓存数据
    let topicData = PreferenceUtil.getInstance(PreferConstant.COLLECT_TOPIC_RECORDS).getAllSync()
    if (topicData) {
      this.topicPreferences = Object.values(topicData) as TopicItemModelPreference[];
    }
    // 按照时间顺序由近及远
    this.topicPreferences.sort((a, b) => b.time - a.time)
    this.topicPreferences.forEach((item: TopicItemModelPreference) => {
      let courseModel: CollectionModel = new CollectionModel()
      courseModel.id = item.keyID
      courseModel.time = item.time
      courseModel.isDelete = false
      courseModel.topicTitle = item.title
      courseModel.topicSource = item.topicSource
      this.collectionTopicList.push(courseModel)
    })
  }

  /**
   * 初始化收藏课程数据
   */
  initCollectionCourseData() {
    // 获取收藏课程全部持久化缓存数据
    let coursePreferences = PreferenceUtil.getInstance(PreferConstant.COLLECT_COURSE_RECORDS).getAllSync()
    let courseData: CollectionModel[] = []
    if (coursePreferences) {
      courseData = Object.values(coursePreferences) as CollectionModel[];
    }
    // 按照时间顺序由近及远
    courseData.sort((a, b) => b.time - a.time)
    courseData.forEach((item: CollectionModel) => {
      let courseModel: CollectionModel = new CollectionModel()
      courseModel.id = item.id
      courseModel.time = item.time
      courseModel.isDelete = false
      courseModel.courseTitle = item.courseTitle
      courseModel.courseDuration = item.courseDuration
      courseModel.learnProgress = item.learnProgress
      courseModel.cover = item.cover
      this.collectionCourseList.push(courseModel)
    })
    this.collectionList = this.collectionCourseList
  }

  /**
   * 点击编辑按钮
   */
  onClickEdit() {
    if (!this.isLeftSwipe && this.collectionList.length > 0) {
      this.isEditCollection = !this.isEditCollection
      if (!this.isEditCollection) {
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
    if (this.isCourse) {
      PreferenceUtil.getInstance(PreferConstant.COLLECT_COURSE_RECORDS).delete(this.collectionList[this.swipeIndex].id);
    } else {
      PreferenceUtil.getInstance(PreferConstant.COLLECT_TOPIC_RECORDS).delete(this.collectionList[this.swipeIndex].id);
    }
    this.collectionList.splice(this.swipeIndex, 1)
    this.isLeftSwipe = false
  }

  /**
   * 删除选中数据
   */
  deleteSelectData() {
    this.collectionList.forEach((item: CollectionModel) => {
      if (item.isDelete) {
        if (this.isCourse) {
          PreferenceUtil.getInstance(PreferConstant.COLLECT_COURSE_RECORDS).delete(item.id);
        } else {
          PreferenceUtil.getInstance(PreferConstant.COLLECT_TOPIC_RECORDS).delete(item.id);
        }
      }
    })
    if (this.isCourse) {
      this.collectionCourseList = this.collectionCourseList.filter((it: CollectionModel) => !it.isDelete)
    } else {
      this.collectionTopicList = this.collectionTopicList.filter((it: CollectionModel) => !it.isDelete)
    }
    this.collectionList = this.collectionList.filter((it: CollectionModel) => !it.isDelete)
    this.isEditCollection = false
    this.selectCount = 0
  }

  /**
   * 删除全部数据
   */
  deleteAllData() {
    if (this.isCourse) {
      PreferenceUtil.getInstance(PreferConstant.COLLECT_COURSE_RECORDS).clear();
      this.collectionCourseList = []
    } else {
      PreferenceUtil.getInstance(PreferConstant.COLLECT_TOPIC_RECORDS).clear();
      this.collectionTopicList = []
    }
    this.collectionList = []
    this.isEditCollection = false
  }

  /**
   * 是否勾选数据
   * @param item
   */
  isSelectData(item: CollectionModel) {
    item.isDelete = !item.isDelete
    if (item.isDelete) {
      this.selectCount++;
    } else {
      this.selectCount--;
    }
  }
}

@Builder
export function MyCollectionPageBuilder() {
  MyCollectionPage()
}