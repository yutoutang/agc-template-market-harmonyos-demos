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
import { util } from '@kit.ArkTS';
import { AppStorageV2, window } from '@kit.ArkUI';
import { CommentPopup } from '../components/CommentPopup';
import {
  CollectionModel,
  CollectionRouter,
  MyCourseParam,
  NumberUtil,
  PreferConstant,
  PreferenceUtil,
  RouterMap,
  RouterModule,
  UserInfo,
  WindowSize
} from 'commonlib';
import { Score } from '../models/Score';
import { MovieItem, PlayerComponent, PlayerVM } from 'recorded_player';
import { CourseCatalogComponents } from '../components/CourseCatalogComponents';
import { CommentModel, CourseCatalogModel, CourseModel } from 'http';
import dayjs from 'dayjs';
import { DescribeComponent } from '../components/DescribeComponent';
import { HomeVM } from '../viewModels/HomeVM';
import { SharePicker } from 'aggregated_share';

@Builder
export function ChapterDetailBuilder() {
  ChapterDetailPage();
}

@ComponentV2
export struct ChapterDetailPage {
  @Local arr: number[] = [50, 40, 30, 20, 10];
  @Local isShow: boolean = false;
  @Local keyboardHeight: number = 0;
  // 窗口状态
  @Local windowStatusType: number = 0;
  @Local isLayoutFullScreen: boolean = false;
  @Local courseDetail: CourseModel = new CourseModel();
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  // 课程目录
  @Local isShowCatalog: boolean = false;
  @Local selectSelection: string = '';
  // 课程目录当前选中
  @Local indexNumber: number = 0;
  @Local comments: CommentModel[] = [];
  @Local playerVM: PlayerVM = PlayerVM.instance;
  @Local learnProgress: number = 0;
  @Local param: MyCourseParam = MyCourseParam.instance();
  @Local windowSize: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!;
  @Local currentIndex: number = 0;
  vm: HomeVM = HomeVM.instance;
  private scroller: ListScroller = new ListScroller();
  private reservationTime: string = '';
  collectRouter: CollectionRouter = CollectionRouter.instance();

  @Builder
  commentBottomBuilder() {
    Row() {
      Button({
        type: ButtonType.Capsule,
        stateEffect: true,
      }) {
        Text('发表评论')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .alignSelf(ItemAlign.Start);
      }
      .padding({ left: 12 })
      .align(Alignment.Start)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .height(40)
      .layoutWeight(1)
      .bindSheet(this.isShow, this.commentSheet(), {
        // 半模态高度
        height: 500 + this.keyboardHeight,
        dragBar: true, // 是否显示控制条
        backgroundColor: Color.White,
        showClose: true, // 是否显示关闭图标
        preferType:SheetType.CENTER,
        shouldDismiss: ((sheetDismiss: SheetDismiss) => { // 半模态页面交互式关闭回调函数
          sheetDismiss.dismiss();
          this.isShow = false;
        })
      })
      .onClick(() => {
        this.isShow = true;
      });

      if (this.courseDetail.category === 2 && this.courseDetail.liveState === 0) {
      } else {
        Column() {
          Image(this.courseDetail.isCollection ? $r('app.media.ic_star') : $r('app.media.ic_public_star'))
            .width(20)
            .height(20)
            .margin({ bottom: 2 });
          Text($r('app.string.collect'))
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium);
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .margin({ left: $r('app.float.vp_12'), right: $r('app.float.vp_8') })
        .onClick(() => {
          this.clickCollect();
        });

        Column() {
          Image($r('app.media.icon_public_share'))
            .width($r('app.float.vp_20'))
            .height($r('app.float.vp_20'))
            .margin({ bottom: 2 });
          Text('分享')
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium);
        }
        .width($r('app.float.vp_48'))
        .height($r('app.float.vp_48'))
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.shareClick();
        });
      }
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height($r('app.float.vp_56'))
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .backgroundColor(Color.White)
    .visibility((this.isLayoutFullScreen === true) ? Visibility.None : Visibility.Visible);
  }

  @Builder
  playerBuilder() {
    Row() {
      PlayerComponent({
        movieItems: this.playerVM.movieItemList,
        playerIndex: this.indexNumber,
        fullScreen: (isLayoutFullScreen: boolean) => {
          this.isLayoutFullScreen = isLayoutFullScreen;
        },
        selectionEvent: (idx: number) => {
          this.indexNumber = idx;
          this.selectSelection = this.playerVM.movieItemList[idx].movieTitle;
          this.comments = this.courseDetail.courseCatalog[this.indexNumber].comments;
          this.learnProgress = this.courseDetail.courseCatalog[this.indexNumber].isStudyEnd ? 100 :
            this.courseDetail.courseCatalog[this.indexNumber].learnProgress;
        },
        callbackTimeUpdate: (vol: number, total: number) => {
          if (this.courseDetail.courseCatalog[this.indexNumber].learnProgress >= 100) {
            this.courseDetail.courseCatalog[this.indexNumber].isStudyEnd = true;
          }
          this.courseDetail.courseCatalog[this.indexNumber].learnProgress = Math.floor(vol / total * 100);
        },
        shareEvent: () => {
          this.shareClick();
        }
      })
        .width('100%')
        .height(this.isLayoutFullScreen ? '100%' :
          (this.getUIContext().px2vp(this.windowSize.screenWidth) - 32) * 9 / 16)
        .borderRadius(this.isLayoutFullScreen ? 0 : 16)
        .clip(true);
    }
    .backgroundColor(Color.White)
    .width('100%')
    .padding(this.isLayoutFullScreen ? 0 : {
      top: $r('app.float.vp_10'),
      bottom: $r('app.float.vp_10'),
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16')
    });
  }

  @Builder
  courseContent() {
    Column() {
      Text('课程介绍')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium);
      Text(this.courseDetail.description)
        .fontSize($r('sys.float.Caption_L'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
        .maxLines(4)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .wordBreak(WordBreak.BREAK_ALL)
        .margin({ top: 6 });
      Row({ space: 8 }) {
        Button({
          type: ButtonType.Capsule,
          stateEffect: true,
        }) {
          Text('习题测试')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Regular);
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .height($r('app.float.vp_40'))
        .width($r('app.float.vp_88'))
        .onClick(() => {
          let eventData: emitter.EventData = {
            data: { isPlaying: false }
          };
          emitter.emit('playerPause', eventData);
          this.courseDetail.selectItem = 0;
          RouterModule.push({ url: RouterMap.MATERIAL_PAGE, param: this.courseDetail });
        });

        Button({
          type: ButtonType.Capsule,
          stateEffect: true,
        }) {
          Text('资料下载')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Regular);
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .height($r('app.float.vp_40'))
        .width($r('app.float.vp_88'))
        .onClick(() => {
          let eventData: emitter.EventData = {
            data: { isPlaying: false }
          };
          emitter.emit('playerPause', eventData);
          this.courseDetail.selectItem = 1;
          RouterModule.push({ url: RouterMap.MATERIAL_PAGE, param: this.courseDetail });
        });
      }
      .width('100%')
      .height($r('app.float.vp_56'))
      .alignItems(VerticalAlign.Center);
    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
    .width('100%')
    .padding({ top: 12, left: 16, right: 16 })
    .visibility(this.isLayoutFullScreen === true ? Visibility.None : Visibility.Visible);
  }

  @Builder
  commentBuilder() {
    Row() {
      Text(`用户评论·${this.comments.length}`)
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold);
    }
    .width('100%')
    .height($r('app.float.vp_56'))
    .backgroundColor(Color.White)
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .visibility(this.isLayoutFullScreen === true ? Visibility.None : Visibility.Visible);

    List({ scroller: this.scroller }) {
      ForEach(this.comments,
        ((item: CommentModel) => {
          ListItem() {
            CommentItem({ comment: item });
          };
        }), (item: CommentModel, index: number) => JSON.stringify(item) + index);
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .nestedScroll({
      scrollForward: NestedScrollMode.SELF_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
    .visibility(this.isLayoutFullScreen === true ? Visibility.None : Visibility.Visible);
  }

  @Builder
  commentSheet() {
    CommentPopup({
      submitEvent: (count: number, content: string) => {
        this.submitResult(count, content);
      }
    })
      .width('100%')
      .height(500);
  }

  @Builder
  topBuilder() {
    Row() {
      Image($r('app.media.chevron_backward'))
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .onClick(() => {
          RouterModule.pop();
        });
      if (this.courseDetail.category === 2 && this.courseDetail.liveState === 0) {
        Row()
          .width(0)
          .height(0);
      } else {
        Row() {
          Text(this.selectSelection)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width($r('app.float.vp_124'));

          Image($r('app.media.icon_arrow_bottom'))
            .width($r('app.float.vp_24'))
            .height($r('app.float.vp_24'));
        }
        .margin({ left: $r('app.float.vp_8') })
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius(20)
        .padding({
          left: $r('app.float.vp_16'),
          right: $r('app.float.vp_16'),
          top: $r('app.float.vp_8'),
          bottom: $r('app.float.vp_8')
        })
        .width($r('app.float.vp_174'))
        .onClick(() => {
          if (!this.playerVM.isSelections) {
            this.getUIContext().getPromptAction().showToast({ message: '购买后可切换' });
            return;
          }
          this.isShowCatalog = true;
        });

        Blank()
          .layoutWeight(1);
        Text(`学习进度${this.learnProgress}%`)
          .fontSize($r('sys.float.Caption_L'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'));
      }
    }
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
    })
    .width('100%')
    .height($r('app.float.vp_56'))
    .backgroundColor(Color.White)
    .visibility(this.isLayoutFullScreen === true ? Visibility.None : Visibility.Visible);
  }

  @Builder
  chapterSortBuilder() {
    Column() {
      CourseCatalogComponents({
        catalogList: this.courseDetail.courseCatalog,
        selectedIndex: this.indexNumber,
        clickCatalog: (indexNumber) => {
          // 更改播放源更换目录
          this.changeCatalog(indexNumber);
        }
      })
        .width('100%')
        .height('100%');
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK, {
      colorMode: ThemeColorMode.LIGHT,
      adaptiveColor: AdaptiveColor.DEFAULT,
      scale: 1.0
    })
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
      bottom: $r('app.float.vp_28')
    });
  }

  @Builder
  recordedBuilder() {
    Column() {
      this.courseContent();
      Row()
        .visibility(this.isLayoutFullScreen === true ? Visibility.None : Visibility.Visible)
        .backgroundColor($r('sys.color.background_secondary'))
        .width('100%')
        .height($r('app.float.vp_8'));
      if (this.courseDetail.courseCatalog.length > 0) {
        this.commentBuilder();
      }
    };
  }

  @Builder
  liveContentBuilder() {
    Column({ space: 5 }) {
      Text(this.courseDetail.courseTitle)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium);

      Text('主讲人：' + this.courseDetail.lecturer)
        .fontSize($r('sys.float.Caption_L'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular);
      Text('直播时间：' + this.reservationTime)
        .fontSize($r('sys.float.Caption_L'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular);
    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
    .width('100%')
    .padding($r('app.float.vp_16'));

    this.tabContentBuilder();
  }

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Medium)
        .margin({ bottom: $r('app.float.vp_10') });
      Row()
        .width($r('app.float.vp_56'))
        .height(2)
        .backgroundColor('#685DFF')
        .borderRadius(1)
        .opacity(this.currentIndex === index ? 1 : 0);
    }
    .alignItems(HorizontalAlign.Center)
    .width($r('app.float.vp_64'))
    .height('100%')
    .onClick(() => {
      this.currentIndex = index;
    });
  }

  @Builder
  tabContentBuilder() {
    Column() {
      Row({ space: 24 }) {
        this.tabBuilder(0, '本场介绍');
        this.tabBuilder(1, '用户评论');
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height($r('app.float.vp_40'));

      if (this.currentIndex === 0) {
        DescribeComponent({ description: this.courseDetail.description })
          .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') });
      } else {
        this.commentBuilder();
      }
    }
    .margin({ top: $r('app.float.vp_12') });
  }

  submitResult(count: number, content: string) {
    let commentModel: CommentModel = new CommentModel();
    commentModel.icon = this.loginUser.avatar;
    commentModel.nickName = this.loginUser.name;
    commentModel.comment = content;
    commentModel.score = count;
    commentModel.id = util.generateRandomUUID(true);
    commentModel.catalogId = this.courseDetail.courseCatalog![this.indexNumber].id;
    commentModel.courseId = this.courseDetail.id;
    commentModel.catalogIndex = this.indexNumber;
    commentModel.cover = this.courseDetail.cover;
    commentModel.courseTitle = this.courseDetail.courseTitle;
    let timestamp = Date.now();
    commentModel.time = timestamp;
    this.courseDetail.courseCatalog![this.indexNumber].comments?.push(commentModel);
    this.comments = this.courseDetail.courseCatalog![this.indexNumber].comments;
    this.comments.sort((a, b) => b.time - a.time);
    this.courseDetail.isComments = true;
    this.isShow = false;
    this.scroller.scrollEdge(Edge.Top);
    let eventData: emitter.EventData = {
      data: { refresh: true }
    };
    emitter.emit('queryComments', eventData);
  }

  aboutToAppear() {

    let courseModel = RouterModule.getNavParam({ url: RouterMap.CHAPTER_DETAIL_PAGE }) as CourseModel;
    this.setData(courseModel);

    window.getLastWindow(getContext(this)).then((currentWindow: window.Window) => {
      // 获取窗口属性
      let properties = currentWindow.getWindowProperties();
      let rect = properties.windowRect;
      if (this.getUIContext().px2vp(rect.height) <= 680) {
        this.windowStatusType = 5;
      }
      currentWindow.on('windowStatusChange', (windowStatusType) => {
        this.windowStatusType = windowStatusType;
      });
      currentWindow.on('avoidAreaChange', data => {
        if (data.type === window.AvoidAreaType.TYPE_KEYBOARD) {
          if (data.area.bottomRect.height === 0) {
            this.keyboardHeight = 0;
          } else {
            this.keyboardHeight = this.windowStatusType === 5 ? 0 : 100;
          }
        }
      });
    });

    emitter.on('changeCourseId', (event: emitter.EventData) => {
      let courseId = event.data!.courseId as string;
      let courseModel =
        this.vm.courseData.courseList.find((course: CourseModel) => courseId === course.id) as CourseModel;
      this.setData(courseModel);
      this.changeCatalog(this.indexNumber);
    });
    this.reservationTime = dayjs().year() === dayjs(this.courseDetail.reservationTime).year() ?
      dayjs(this.courseDetail.reservationTime).format('MM/DD HH:mm').toString() :
      dayjs(this.courseDetail.reservationTime).format('YYYY/MM/DD HH:mm').toString();
  }

  aboutToDisappear() {
    emitter.off('changeCourseId');
    let learnProgress: number = 0;
    this.courseDetail.courseCatalog.forEach((item: CourseCatalogModel) => {
      if (item.isStudyEnd) {
        learnProgress += 100;
      } else {
        learnProgress += item.learnProgress;
      }
    });
    if (learnProgress >= this.courseDetail.courseCatalog.length * 100) {
      this.courseDetail.isStudyEnd = true;
    } else {
      this.courseDetail.learnProgress =
        Math.floor(learnProgress / (this.courseDetail.courseCatalog.length * 100) * 100);
    }
    this.param.isLearn = true;
    // 监听收藏状态
    this.monitorCollectStatus();
    if (this.collectRouter.routerTitle === '我的收藏') {
      this.collectRouter.isCollection = true;
    }
  }

  setData(courseModel: CourseModel) {
    if (courseModel) {
      this.courseDetail = courseModel;
      if (this.courseDetail.isPay || this.courseDetail.isFree) {
        this.playerVM.isSelections = true;
      } else {
        this.playerVM.isSelections = false;
      }
      this.playerVM.movieItemList = [];
      this.courseDetail.courseCatalog?.forEach((item: CourseCatalogModel) => {
        this.playerVM.movieItemList.push(new MovieItem(item.id, item.catalogTitle, item.learnProgress, item.videoUrl!));
      });
      this.indexNumber = this.courseDetail.catalogIndex;
      this.selectSelection = this.playerVM.movieItemList[this.indexNumber].movieTitle;
      this.learnProgress = this.courseDetail.courseCatalog[this.indexNumber].isStudyEnd ? 100 :
        this.courseDetail.courseCatalog[this.indexNumber].learnProgress;
      this.comments = this.courseDetail.courseCatalog[this.indexNumber].comments;
      this.comments.sort((a, b) => b.time - a.time);
      this.courseDetail.isWatch = true;
      this.courseDetail.studyTime = Date.now();
      this.courseDetail.watchTime = Date.now();
      if (this.courseDetail.liveState === undefined) {
        this.courseDetail.isStudy = true;
      }
    }
  }

  /**
   * 点击收藏
   */
  clickCollect() {
    if (this.courseDetail.isCollection) {
      PreferenceUtil.getInstance(PreferConstant.COLLECT_COURSE_RECORDS).delete(this.courseDetail.id);
      if (this.collectRouter.routerTitle === '我的收藏') {
        this.collectRouter.isCollection = false;
      }
    } else {
      let collectItem: CollectionModel = new CollectionModel();
      collectItem.id = this.courseDetail.id;
      collectItem.courseTitle = this.courseDetail.courseTitle;
      collectItem.learnProgress = this.courseDetail.learnProgress;
      collectItem.courseDuration = this.courseDetail.courseDuration;
      collectItem.cover = this.courseDetail.cover;
      collectItem.time = Date.now();
      // 将收藏记录存入持久层
      PreferenceUtil.getInstance(PreferConstant.COLLECT_COURSE_RECORDS).put(collectItem.id, collectItem);
      if (this.collectRouter.routerTitle === '我的收藏') {
        this.collectRouter.isCollection = true;
      }
    }
    // 监听收藏状态
    this.monitorCollectStatus();
  }

  /**
   * 监听收藏状态
   */
  monitorCollectStatus() {
    if (PreferenceUtil.getInstance(PreferConstant.COLLECT_COURSE_RECORDS).hasSync(this.courseDetail.id)) {
      this.courseDetail.isCollection = true;
    } else {
      this.courseDetail.isCollection = false;
    }
  }

  shareClick() {
    const picker: SharePicker = new SharePicker({
      title: this.courseDetail.courseTitle,
      coverUrl: $r('app.media.ic_banner_01'),
      createTime: new Date().getTime(),
      landingPageUrl: 'https://developer.huawei.com/consumer/cn/activity/301757474300821213',
    });
    picker.show({
      autoClose: true,
    });
  }

  changeCatalog(indexNumber: number) {
    this.isShowCatalog = false;
    this.indexNumber = indexNumber;
    this.selectSelection = this.playerVM.movieItemList[indexNumber].movieTitle;
    this.comments = this.courseDetail.courseCatalog[this.indexNumber].comments;
    this.learnProgress = this.courseDetail.courseCatalog[this.indexNumber].isStudyEnd ? 100 :
      this.courseDetail.courseCatalog[this.indexNumber].learnProgress;
    let eventData: emitter.EventData = {
      data: { movieSelection: indexNumber }
    };
    emitter.emit('movieSelections', eventData);
  }

  build() {
    Column() {
      this.topBuilder();
      Scroll() {
        Column() {
          this.playerBuilder();
          if (this.courseDetail.category === 2 && this.courseDetail.liveState === 0) {
            // 回顾
            this.liveContentBuilder();
          } else {
            // 录播
            this.recordedBuilder();
          }
        }
        .justifyContent(FlexAlign.Start)
        .bindSheet($$this.isShowCatalog, this.chapterSortBuilder(), {
          height: SheetSize.MEDIUM,
          blurStyle: BlurStyle.Thick,
          showClose: true,
          preferType:SheetType.CENTER,
          title: { title: '课程目录' },
          onWillDismiss: () => {
            this.isShowCatalog = false;
          }
        });
      }
      .align(Alignment.Top)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(this.isLayoutFullScreen ? EdgeEffect.None : EdgeEffect.Spring);

      if (this.courseDetail.category === 2 && this.courseDetail.liveState === 0) {
        if (this.currentIndex === 0) {
        } else {
          this.commentBottomBuilder();
        }
      } else {
        this.commentBottomBuilder();
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(this.isLayoutFullScreen ? 'rgba(0,0,0,1)' : Color.White)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}

@ComponentV2
struct CommentItem {
  @Local arr: Score[] = [
    new Score('0', true),
    new Score('1', false),
    new Score('2', false),
    new Score('3', false),
    new Score('4', false),
  ];
  @Param @Require comment: CommentModel;
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;

  aboutToAppear(): void {
    this.arr.forEach((item: Score, idx: number) => {
      if (this.comment.score > idx) {
        item.select = true;
      } else {
        item.select = false;
      }
    });
  }

  build() {
    Row() {
      Image((this.loginUser.avatar && this.loginUser.avatar !== '') ? this.loginUser.avatar :
        $r('app.media.ic_user_default'))
        .width(46)
        .height(46)
        .margin({ right: 8 })
        .borderRadius(23);

      Column() {
        Text(this.comment.nickName)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium);
        Row() {
          ForEach(this.arr, (item: Score) => {
            Image(item.select ? $r('app.media.icon_star_on') : $r('app.media.icon_star_off'))
              .width(9)
              .height(9)
              .margin({ right: 2 });
          }, (item: number, index: number) => item + index + '');
          Text(this.comment.score + '')
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_tertiary'))
            .fontWeight(FontWeight.Regular)
            .margin({ left: 2 });
        }
        .margin({ top: 2, bottom: 8 });

        Text(this.comment.comment)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
          .lineHeight(19)
          .width('100%');
        Text(NumberUtil.getCoverDateString(this.comment.time))
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_tertiary'))
          .fontWeight(FontWeight.Regular)
          .margin({ top: 13, bottom: 13 });
        Text()
          .width('100%')
          .height(0.5)
          .backgroundColor('rgba(0,0,0,0.2)');
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start);
    }
    .backgroundColor(Color.White)
    .width('100%')
    .padding({ bottom: 10 })
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.Start);
  }
}