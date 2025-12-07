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

import { AppStorageV2 } from '@kit.ArkUI';
import {
  CollectionModel,
  CollectionRouter,
  NoData,
  NumberUtil,
  PreferConstant,
  PreferenceUtil,
  RouterMap,
  RouterModule,
  UserInfo
} from 'commonlib';
import { CommentModel, CourseModel } from 'http';
import { Score } from '../models/Score';
import dayjs from 'dayjs';
import { PlayerVM } from 'recorded_player';
import { LiveStreamingVM } from 'live_streaming';
import { HomeVM } from '../viewModels/HomeVM';
import { DownLoadSheet } from '../components/DownLoadSheet';
import { SharePicker } from 'aggregated_share';

@ComponentV2
export struct LiveDetailPage {
  @Local currentIndex: number = 0;
  @Local countdown: string = '';
  @Local days: string = '00';
  @Local minutes: string = '00';
  @Local seconds: string = '00';
  @Local hours: string = '00';
  @Local liveVM: LiveStreamingVM = LiveStreamingVM.instance;
  @Local playerVM: PlayerVM = PlayerVM.instance;
  @Local isShowDownSheet: boolean = false;
  @Local courseDetail: CourseModel = new CourseModel();
  vm: HomeVM = HomeVM.instance;
  private timer: number = 0;
  private countTimer: number = dayjs(Date.now()).add(0.2, 'minutes').valueOf();
  collectionRouter: CollectionRouter = CollectionRouter.instance();
  private reservationTime: string = '';

  @Builder
  topBuilder() {
    Row() {
      Image($r('app.media.chevron_backward'))
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .onClick(() => {
          RouterModule.pop();
        });
      Text('课程直播')
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: $r('app.float.vp_8') });
      Blank()
        .layoutWeight(1);
    }
    .width('100%')
    .height($r('app.float.vp_56'))
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') });
  }

  @Builder
  bannerBuilder() {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.ic_banner_01'))
          .interpolation(ImageInterpolation.High)
          .width('100%')
          .height('100%');
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.6)');
        Row() {
          Text('倒计时')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .margin({ right: $r('app.float.vp_16') });
          Text(this.days)
            .width($r('app.float.vp_24'))
            .aspectRatio(1)
            .borderRadius(5)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor('rgba(255,255,255,0.2)')
            .textAlign(TextAlign.Center);
          Text('天')
            .width($r('app.float.vp_24'))
            .aspectRatio(1)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .textAlign(TextAlign.Center);
          Text(this.hours)
            .width($r('app.float.vp_24'))
            .aspectRatio(1)
            .borderRadius(5)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor('rgba(255,255,255,0.2)')
            .textAlign(TextAlign.Center);
          Text(':')
            .height($r('app.float.vp_24'))
            .width($r('app.float.vp_10'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .textAlign(TextAlign.Center);
          Text(this.minutes)
            .width($r('app.float.vp_24'))
            .aspectRatio(1)
            .borderRadius(5)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor('rgba(255,255,255,0.2)')
            .textAlign(TextAlign.Center);
          Text(':')
            .height($r('app.float.vp_24'))
            .width($r('app.float.vp_10'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .textAlign(TextAlign.Center);
          Text(this.seconds)
            .width($r('app.float.vp_24'))
            .aspectRatio(1)
            .borderRadius(5)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor('rgba(255,255,255,0.2)')
            .textAlign(TextAlign.Center);
        }
        .visibility(this.seconds === '00' ? Visibility.None : Visibility.Visible);

        Row() {
          Text('点击进入直播间')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .margin({ right: $r('app.float.vp_16') });
        }
        .padding(20)
        .visibility(this.seconds === '00' ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          RouterModule.replace({ url: RouterMap.LIVE_STREAMING_PAGE, param: this.courseDetail.id });
        });
      }
      .width('100%')
      .height(184);
    };
  }

  @Builder
  courseContent() {
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
  }

  @Builder
  eventsBuilder() {
    Row() {
      Image(this.courseDetail.isCollection ? $r('app.media.ic_home_collect_on') : $r('app.media.ic_home_collect_off'))
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .onClick(() => {
          this.clickCollectButton();
        });

      Image($r('app.media.ic_home_share'))
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .onClick(() => {
          this.shareClick();
        });

      Image($r('app.media.ic_home_down'))
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .onClick(() => {
          if (this.courseDetail.liveState === 1) {
            this.isShowDownSheet = true;
          } else {
            this.getUIContext().getPromptAction().showToast({ message: '未开播不支持课件下载' });
          }
        });
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height($r('app.float.vp_56'))
    .padding({ left: $r('app.float.vp_32'), right: $r('app.float.vp_32') });
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
      Description({ description: this.courseDetail.description });
    }
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .margin({ top: $r('app.float.vp_12') });
  }

  @Builder
  liveShareBuilder() {
    Image($r('app.media.ic_home_share'))
      .width($r('app.float.vp_40'))
      .height($r('app.float.vp_40'));

  }

  @Builder
  downLoadBuilder() {
    DownLoadSheet({
      shouldDismiss: () => {
        RouterModule.push({ url: RouterMap.LOOK_FILE_PAGE });
        this.isShowDownSheet = false;
      }
    })
      .width('90%')
      .height(300);
  }

  startTimer() {
    this.timer = setInterval(() => {
      this.formatStamp(this.countTimer);
    }, 1000);
  }

  aboutToAppear(): void {
    let courseId = RouterModule.getNavParam({ url: RouterMap.LIVE_DETAIL_PAGE }) as string;
    if (courseId && courseId.length > 0) {
      this.courseDetail =
        this.vm.courseData.courseList.find((course: CourseModel) => courseId === course.id) as CourseModel;
      // 监听收藏状态
      this.monitorCollectionStatus();
      if (this.collectionRouter.routerTitle === '我的收藏') {
        this.collectionRouter.isCollection = true;
      }
    }
    this.startTimer();
    this.formatStamp(this.countTimer);
    this.reservationTime = dayjs().year() === dayjs(this.courseDetail.reservationTime).year() ?
      dayjs(this.courseDetail.reservationTime).format('MM/DD HH:mm').toString() :
      dayjs(this.courseDetail.reservationTime).format('YYYY/MM/DD HH:mm').toString();
  }

  /**
   * 监听收藏状态
   */
  monitorCollectionStatus() {
    if (PreferenceUtil.getInstance(PreferConstant.COLLECT_COURSE_RECORDS).hasSync(this.courseDetail.id)) {
      this.courseDetail.isCollection = true;
    } else {
      this.courseDetail.isCollection = false;
    }
  }

  formatStamp(timeStamp: number) {
    let leftTime = Number(dayjs(timeStamp).diff(dayjs().valueOf(), 'seconds'));
    // 计算天数
    let days = Math.floor(leftTime / 60 / 60 / 24);
    // 计算剩余小时、分钟、秒
    let hours = Math.floor((leftTime / 60 / 60) % 24);
    let minutes = Math.floor((leftTime / 60) % 60);
    let seconds = Math.floor(leftTime % 60);
    // 格式化输出
    if (days <= 0 && hours <= 0 && minutes <= 0 && seconds <= 0) {
      this.countTimer = 0;
      this.countdown = '--';
      clearInterval(this.timer); // 关闭定时器
      this.minutes = '00';
      this.minutes = '00';
      this.days = '00';
      this.hours = '00';
      this.courseDetail.liveState = 1;
    }
    this.minutes = (minutes < 10 ? '0' + minutes : minutes) + '';
    this.seconds = (seconds < 10 ? '0' + seconds : seconds) + '';
    this.days = (days < 10 ? '0' + days : days) + '';
    this.hours = (hours < 10 ? '0' + hours : hours) + '';
  }

  /**
   * 点击收藏按钮
   */
  clickCollectButton() {
    if (this.courseDetail.isCollection) {
      PreferenceUtil.getInstance(PreferConstant.COLLECT_COURSE_RECORDS).delete(this.courseDetail.id);
      if (this.collectionRouter.routerTitle === '我的收藏') {
        this.collectionRouter.isCollection = false;
      }
    } else {
      let collection: CollectionModel = new CollectionModel();
      collection.id = this.courseDetail.id;
      collection.cover = this.courseDetail.cover;
      collection.courseTitle = this.courseDetail.courseTitle;
      collection.learnProgress = this.courseDetail.learnProgress;
      collection.courseDuration = this.courseDetail.courseDuration;
      collection.time = Date.now();
      collection.liveState = this.courseDetail.liveState;
      // 将收藏记录存入持久层
      PreferenceUtil.getInstance(PreferConstant.COLLECT_COURSE_RECORDS).put(collection.id, collection);
      if (this.collectionRouter.routerTitle === '我的收藏') {
        this.collectionRouter.isCollection = true;
      }
    }
    // 监听收藏状态
    this.monitorCollectionStatus();
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

  build() {
    Column() {
      if (this.courseDetail && this.courseDetail.id.length > 0) {
        this.topBuilder();
        Scroll() {
          Column() {
            this.bannerBuilder();
            this.courseContent();
            this.eventsBuilder();
            this.tabContentBuilder();
            Blank()
              .layoutWeight(1);
          };
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring);

        Row()
          .bindSheet(this.isShowDownSheet, this.downLoadBuilder(), {
            // 半模态高度
            height: 300,
            dragBar: true, // 是否显示控制条
            backgroundColor: Color.White,
            showClose: true, // 是否显示关闭图标
            preferType:SheetType.CENTER,
            shouldDismiss: ((sheetDismiss: SheetDismiss) => {
              sheetDismiss.dismiss();
              this.isShowDownSheet = false;
            })
          })
          .width(0)
          .height(0);

      } else {
        NoData({ text: '查询详情数据失败' });
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}

@ComponentV2
export struct Description {
  @Param description: string = '';

  build() {
    Column() {
      Text(this.description)
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .margin({ top: 12 });

      Column() {
        Text('课程详情')
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Subtitle_L'))
          .fontColor($r('sys.color.font_primary'))
          .margin({ bottom: 12 });

        Image($r('app.media.ic_course_detail'))
          .width('100%')
          .aspectRatio(0.7)
          .borderRadius(16);
      }
      .margin({ top: 24, bottom: 24 });
    };
  }
}

@ComponentV2
export struct CommentComponent {
  @Local comments: CommentModel[] = [];
  private scroller: ListScroller = new ListScroller();

  @Builder
  commentBuilder() {
    Row() {
      Text(`用户评论·${this.comments.length}`)
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold);
    }
    .width('100%')
    .height(56)
    .backgroundColor(Color.White);

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
    .nestedScroll({
      scrollForward: NestedScrollMode.SELF_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    });
  }

  build() {
    Column() {
      this.commentBuilder();
    };
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

@Builder
export function LiveDetailPageBuilder() {
  LiveDetailPage();
}