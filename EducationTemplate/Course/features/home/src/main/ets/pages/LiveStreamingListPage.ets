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

import { AppStorageV2, display } from '@kit.ArkUI'
import { emitter } from '@kit.BasicServicesKit'
import dayjs from 'dayjs'
import { RouterMap, RouterModule, TopBar, UserInfo } from 'commonlib'
import { Course, CourseModel } from 'http'
import { HomeVM } from '../viewModels/HomeVM'
import { LiveBroadcastSign } from '../components/LiveBroadcastSign'
import { LiveNumberOverlay } from '../components/LiveNumberOverlay'
import { LiveStreamingItem } from '../components/LiveStreamingItem'
import { PlayerVM } from 'recorded_player'
import { LiveStreamingVM } from 'live_streaming'

@ComponentV2
export struct LiveStreamingListPage {
  // 屏幕宽度
  @Param screenWidth: number = display.getDefaultDisplaySync().width / display.getDefaultDisplaySync().scaledDensity;
  @Local searchValue: string = ''
  // 搜索后的正在直播课程列表
  @Local searchLiveBroadcastCourseList: Course[] = []
  // 搜索后的精彩回顾课程列表
  @Local searchHighlightsCourseList: Course[] = []
  @Local columnsTemplateCount: number = 0
  @Local playerVM: PlayerVM = PlayerVM.instance;
  @Local liveVM: LiveStreamingVM = LiveStreamingVM.instance;
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  model: HomeVM = HomeVM.instance
  // 当前屏幕折叠态（仅折叠屏设备下有效）
  curFoldStatus: display.FoldStatus = display.FoldStatus.FOLD_STATUS_UNKNOWN;

  regDisplayListener(): void {
    display.on('foldStatusChange', async (curFoldStatus: display.FoldStatus) => {
      // 同一个状态重复触发不做处理
      if (this.curFoldStatus === curFoldStatus) {
        return;
      }
      this.curFoldStatus = curFoldStatus;
      this.setCurFoldCount()
    })
  }

  setCurFoldCount() {
    if (this.curFoldStatus === display.FoldStatus.FOLD_STATUS_FOLDED ||
      this.curFoldStatus === display.FoldStatus.FOLD_STATUS_UNKNOWN) {
      this.columnsTemplateCount = 2
    } else {
      this.columnsTemplateCount = 4
    }
  }

  aboutToAppear(): void {
    if (display.isFoldable()) {
      this.regDisplayListener();
    }
    this.curFoldStatus = display.getFoldStatus()
    this.model.getLiveBroadcastCourseList()
    this.model.getHighlightsCourseList()
    this.setCurFoldCount()
  }

  build() {
    Column() {
      TopBar({ title: $r('app.string.live_streaming_courses') })
        .margin({ left: $r('app.float.vp_16') })
      Scroll() {
        Column() {
          // 搜索
          this.searchLiveStreamingBuilder()
          // 正在直播
          this.liveBroadcastBuilder()
          // 精彩回顾
          this.highlightsBuilder()
        }
        .constraintSize({ minHeight: '100%' })
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
      }
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), bottom: $r('app.float.vp_16') })
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
  }

  /**
   * 正在直播
   */
  @Builder
  liveBroadcastBuilder() {
    Text($r('app.string.live_broadcast'))
      .fontSize($r('sys.float.Subtitle_L'))
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_primary'))
      .margin({ bottom: $r('app.float.vp_16'), top: $r('app.float.vp_16') })
    LoadingProgress()
      .width($r('app.float.vp_40'))
      .height($r('app.float.vp_40'))
      .visibility(this.model.liveBroadcastCourseList.length === 0 ? Visibility.Visible : Visibility.None)
    Stack() {
      NoSearchCourse()
        .visibility(this.searchValue && this.searchLiveBroadcastCourseList.length === 0 ? Visibility.Visible :
          Visibility.None)
      Grid() {
        ForEach(this.searchValue ? this.searchLiveBroadcastCourseList : this.model.liveBroadcastCourseList,
          (item: Course) => {
            GridItem() {
              this.liveBroadcastItemBuilder(item)
            }
            .onClick(() => {
              this.playerVM.stopPip()
              if (this.loginUser.isLogin) {
                if (item.liveState === 2) {
                  RouterModule.push({ url: RouterMap.LIVE_DETAIL_PAGE, param: item?.id })
                } else {
                  RouterModule.push({ url: RouterMap.LIVE_STREAMING_PAGE, param: item?.id })
                }
              } else {
                RouterModule.push({ url: RouterMap.LOGIN_PAGE })
              }
            })
          }, (item: Course) => item.id)
      }
      .rowsTemplate('1r')
      .columnsGap($r('app.float.vp_8'))
      .scrollBar(BarState.Off)
      .height($r('app.float.vp_226'))
      .edgeEffect(EdgeEffect.Spring)
      .nestedScroll({
        scrollForward: NestedScrollMode.SELF_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
    }
  }

  /**
   * 正在直播子项
   */
  @Builder
  liveBroadcastItemBuilder(item: Course) {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        Image(item.cover)
          .width('100%')
          .height($r('app.float.vp_116'))
        LiveNumberOverlay({ liveNumber: item.liveNumber })
      }

      LiveBroadcastSign().position({ x: $r('app.float.vp_8'), y: $r('app.float.vp_8') })
        .visibility(item.liveState === 1 ? Visibility.Visible : Visibility.None)
      Column() {
        Text(item.courseTitle)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Start)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .wordBreak(WordBreak.BREAK_ALL)
        Column() {
          Text(dayjs().year() === dayjs(item.reservationTime).year() ?
            dayjs(item.reservationTime).format('MM/DD HH:mm') :
            dayjs(item.reservationTime).format('YYYY/MM/DD HH:mm'))
            .fontSize($r('sys.float.Caption_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_secondary'))
            .height($r('app.float.vp_16'))
            .margin({ bottom: $r('app.float.vp_4') })

          Text('主讲老师: ' + item.lecturer)
            .fontSize($r('sys.float.Caption_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_secondary'))
            .height($r('app.float.vp_16'))
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)
      .padding($r('app.float.vp_12'))
      .layoutWeight(1)
    }
    .width($r('app.float.vp_206'))
    .height('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(8)
    .clip(true)
  }

  /**
   * 精彩回顾
   */
  @Builder
  highlightsBuilder() {
    Text($r('app.string.highlights'))
      .fontSize($r('sys.float.Subtitle_L'))
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_primary'))
      .margin({ bottom: $r('app.float.vp_16'), top: $r('app.float.vp_24') })
    LoadingProgress()
      .width($r('app.float.vp_40'))
      .height($r('app.float.vp_40'))
      .visibility(this.model.highlightsCourseList.length === 0 ? Visibility.Visible : Visibility.None)
    NoSearchCourse()
      .visibility(this.searchValue && this.searchHighlightsCourseList.length === 0 ? Visibility.Visible :
        Visibility.None)
    Grid() {
      ForEach(this.searchValue ? this.searchHighlightsCourseList : this.model.highlightsCourseList,
        (item: Course, idx: number) => {
          GridItem() {
            LiveStreamingItem({ course: item })
          }
          .onClick(() => {
            this.liveVM.stopPip()
            if (this.loginUser.isLogin) {
              let courseDetail =
                this.model.courseData.courseList.find((course: CourseModel) => item?.id ===
                course.id) as CourseModel
              courseDetail.catalogIndex = 0
              emitter.emit('changeCourseId', { data: { courseId: courseDetail.id } })
              RouterModule.push({ url: RouterMap.CHAPTER_DETAIL_PAGE, param: courseDetail })
            } else {
              RouterModule.push({ url: RouterMap.LOGIN_PAGE })
            }
          })
        }, (item: Course) => item.id)
    }
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .columnsTemplate(this.columnsTemplateCount === 4 ? '1fr 1fr 1fr 1fr' : '1fr 1fr')
    .rowsGap($r('app.float.vp_8'))
    .columnsGap($r('app.float.vp_8'))
    .scrollBar(BarState.Off)
    .maxCount(4)
    .nestedScroll({
      scrollForward: NestedScrollMode.SELF_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
  }

  /**
   * 搜索
   */
  @Builder
  searchLiveStreamingBuilder() {
    Search({ placeholder: '搜索', value: this.searchValue })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .width('100%')
      .onChange((value: string) => {
        this.searchLiveStreamingCourse(value)
      })
  }

  /**
   * 搜索直播课程
   * @param value
   */
  searchLiveStreamingCourse(value: string) {
    this.searchValue = value.replace(/^\s+|\s+$/g, '');
    let tempLiveBroadcast: Course[] = [];
    let tempHighlights: Course[] = [];
    this.model.liveBroadcastCourseList.forEach((item: Course) => {
      if (item.courseTitle.indexOf(this.searchValue) !== -1) {
        tempLiveBroadcast.push(item)
      }
    })
    this.model.highlightsCourseList.forEach((item: Course) => {
      if (item.courseTitle.indexOf(this.searchValue) !== -1) {
        tempHighlights.push(item)
      }
    })
    this.searchLiveBroadcastCourseList = tempLiveBroadcast
    this.searchHighlightsCourseList = tempHighlights;
  }
}

@ComponentV2
export struct NoSearchCourse {
  build() {
    Column() {
      Image($r('app.media.search_no_result'))
        .width($r('app.float.vp_120'))
        .height($r('app.float.vp_120'))
      Text('未找到相关课程')
        .fontSize($r('sys.float.Subtitle_S'))
        .fontColor($r('sys.color.font_tertiary'))
    }
    .width('100%')
    .height($r('app.float.vp_226'))
    .justifyContent(FlexAlign.Center)
  }
}


@Builder
export function LiveStreamingListPageBuilder() {
  LiveStreamingListPage()
}