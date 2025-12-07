/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AppStorageV2 } from '@kit.ArkUI';
import {
  CollectionModel,
  CollectionRouter,
  PreferConstant,
  PreferenceUtil,
  RouterMap,
  RouterModule,
  UserInfo,
  WindowSize
} from 'commonlib';
import { LiveStreaming, LiveStreamingVM, MoreSheet } from 'live_streaming';
import { DownLoadSheet } from '../components/DownLoadSheet';
import { emitter } from '@kit.BasicServicesKit';
import { CourseModel } from 'http';
import { HomeVM } from '../viewModels/HomeVM';
import dayjs from 'dayjs';
import { QQShareData, SharePicker } from 'aggregated_share';

@ComponentV2
export struct LiveStreamingPage {
  @Local homeVM: HomeVM = HomeVM.instance;
  @Local liveVM: LiveStreamingVM = LiveStreamingVM.instance;
  @Local courseDetail: CourseModel = new CourseModel();
  @Local windowSize: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!;
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  @Local isShowDescribe: boolean = false;
  @Local isShowMore: boolean = false;
  @Local isShowDownSheet: boolean = false;
  @Local isLayoutFullScreen: boolean = false;
  controller: TextAreaController = new TextAreaController();
  private scroller: Scroller = new Scroller();
  private reservationTime: string = '';
  collectionRouter: CollectionRouter = CollectionRouter.instance();

  @Builder
  topBuilder() {
    Column() {
      Row() {
        Image($r('app.media.icon_chevron_backward_dark01'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .onClick(() => {
            RouterModule.pop();
          });
        Text(this.courseDetail.courseTitle)
          .fontSize($r('sys.float.Subtitle_S'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_on_primary'))
          .margin({ left: $r('app.float.vp_8') })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: $r('app.float.vp_157') });
        Blank()
          .layoutWeight(1);
        Row() {
          Image($r('app.media.chevron_forward'))
            .width($r('app.float.vp_20'))
            .height($r('app.float.vp_20'));
        }
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .margin({ right: $r('app.float.vp_8') })
        .visibility(this.isShowDescribe === true ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          this.isShowDescribe = false;
        });

        Text('详情')
          .fontSize($r('sys.float.Caption_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .padding({
            top: $r('app.float.vp_6'),
            bottom: $r('app.float.vp_6'),
            left: $r('app.float.vp_8'),
            right: $r('app.float.vp_8')
          })
          .backgroundColor('rgba(32,34,36,1)')
          .margin({ right: $r('app.float.vp_16') })
          .borderRadius($r('app.float.vp_14'))
          .visibility(this.isShowDescribe === false ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            this.isShowDescribe = true;
          });

        Image($r('app.media.icon_live_dot_grid'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .onClick(() => {
            this.isShowMore = true;
          });
      }
      .width('100%')
      .height($r('app.float.vp_56'));

      Row({ space: 4 }) {
        Row({ space: 5 }) {
          Image($r('app.media.ic_live_streaming04'))
            .width($r('app.float.vp_28'))
            .height($r('app.float.vp_28'));
          Column() {
            Text('苏苏')
              .fontSize($r('sys.float.Caption_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_on_primary'))
              .margin({ bottom: 4 });

            Row() {
              Image($r('app.media.illustration'))
                .width(10)
                .height(10)
                .opacity(0.6);
              Text('1.8w')
                .fontSize($r('sys.float.Caption_S'))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_on_secondary'))
                .margin({ left: $r('app.float.vp_2') });
            };
          }
          .alignItems(HorizontalAlign.Start);
        };

        Blank()
          .layoutWeight(1);
        Image($r('app.media.ic_live_streaming01'))
          .width($r('app.float.vp_28'))
          .height($r('app.float.vp_28'));
        Image($r('app.media.ic_live_streaming02'))
          .width($r('app.float.vp_28'))
          .height($r('app.float.vp_28'));
        Image($r('app.media.ic_live_streaming03'))
          .width($r('app.float.vp_28'))
          .height($r('app.float.vp_28'));

        Text('2383')
          .fontSize($r('sys.float.Caption_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .padding({
            top: $r('app.float.vp_6'),
            bottom: $r('app.float.vp_6'),
            left: $r('app.float.vp_8'),
            right: $r('app.float.vp_8')
          })
          .backgroundColor('rgba(32,34,36,1)')
          .borderRadius($r('app.float.vp_18'))
          .visibility(this.isShowDescribe === false ? Visibility.Visible : Visibility.None);
      }
      .width('100%')
      .height($r('app.float.vp_32'))
      .margin({ top: $r('app.float.vp_12'), bottom: $r('app.float.vp_12') });
    }
    .width('100%')
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .visibility(this.isLayoutFullScreen ? Visibility.None : Visibility.Visible);
  }

  @Builder
  describeBuilder() {
    Column() {
      this.courseContent();
      this.eventBuilder();
      Row()
        .width('100%')
        .height($r('app.float.vp_8'))
        .backgroundColor('rgba(255,255,255,0.1)')
        .margin({ top: $r('app.float.vp_12') });
      Column() {
        Text('本场介绍')
          .fontSize($r('sys.float.Subtitle_L'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24 });
        Text('本课程带你了解常用的组件，以开发实例带你学习如果使用常用组件构建简单好用的页面')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Regular)
          .margin({ top: 12 });
        Column() {
          Text('课程详情')
            .fontSize($r('sys.float.Subtitle_L'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 12 });

          Image($r('app.media.ic_course_detail'))
            .width('100%')
            .aspectRatio(0.7)
            .borderRadius(16);
        }
        .width('100%')
        .margin({ top: 24, bottom: 24 });
      }
      .alignItems(HorizontalAlign.Start);
    }
    .backgroundColor('rgba(46,48,51,1)')
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') });
  }

  @Builder
  courseContent() {
    Column({ space: 5 }) {
      Row() {
        Image($r('app.media.ic_close_btn'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .borderRadius($r('app.float.vp_20'))
          .onClick(() => {
            this.isShowDescribe = false;
          });
      }
      .width('100%')
      .height($r('app.float.vp_64'))
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center);

      Text(this.courseDetail.courseTitle)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_on_primary'))
        .fontWeight(FontWeight.Medium);
      Text('主讲人：' + this.courseDetail.lecturer)
        .fontSize($r('sys.float.Caption_L'))
        .fontColor($r('sys.color.font_on_secondary'))
        .fontWeight(FontWeight.Regular);
      Text('直播时间：' + this.reservationTime)
        .fontSize($r('sys.float.Caption_L'))
        .fontColor($r('sys.color.font_on_secondary'))
        .fontWeight(FontWeight.Regular);
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%');
  }

  @Builder
  eventBuilder() {
    Row() {
      Row() {
        Image(this.courseDetail.isCollection ? $r('app.media.ic_public_star_on') : $r('app.media.ic_public_star_off'))
          .width($r('app.float.vp_20'))
          .height($r('app.float.vp_20'));
      }
      .width($r('app.float.vp_40'))
      .height($r('app.float.vp_40'))
      .backgroundColor('rgba(255,255,255,0.1)')
      .borderRadius($r('app.float.vp_20'))
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.clickCollectButton();
      });

      Row() {
        Image($r('app.media.ic_live_share'))
          .width($r('app.float.vp_20'))
          .height($r('app.float.vp_20'));
      }
      .width($r('app.float.vp_40'))
      .height($r('app.float.vp_40'))
      .backgroundColor('rgba(255,255,255,0.1)')
      .borderRadius($r('app.float.vp_20'))
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.shareEvent();
      });

      Row() {
        Image($r('app.media.ic_live_down'))
          .width($r('app.float.vp_20'))
          .height($r('app.float.vp_20'));
      }
      .width($r('app.float.vp_40'))
      .height($r('app.float.vp_40'))
      .backgroundColor('rgba(255,255,255,0.1)')
      .borderRadius($r('app.float.vp_20'))
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.isShowDownSheet = true;
      });
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height($r('app.float.vp_56'));
  }

  @Builder
  moreBuilder() {
    MoreSheet({
      moreSetEvent: (item: string) => {
        if (item === '画中画') {
          this.liveVM.startPip();
        }
      }
    })
      .padding(12)
      .width('100%')
      .height('100%');
  }

  @Builder
  downLoadBuilder() {
    DownLoadSheet({
      shouldDismiss: () => {
        emitter.emit('livePlayer', { data: { isPlaying: false } });
        RouterModule.push({ url: RouterMap.LOOK_FILE_PAGE });
        this.isShowDownSheet = false;
        this.isShowDescribe = false;
      }
    })
      .width('90%')
      .height(300);
  }

  aboutToAppear(): void {
    let courseId = RouterModule.getNavParam({ url: RouterMap.LIVE_STREAMING_PAGE }) as string;
    if (courseId && courseId.length > 0) {
      this.courseDetail =
        this.homeVM.courseData.courseList.find((course: CourseModel) => courseId === course.id) as CourseModel;
      // 监听收藏状态
      this.monitorCollectionStatus();
      if (this.collectionRouter.routerTitle === '我的收藏') {
        this.collectionRouter.isCollection = true;
      }
    }

    this.reservationTime = dayjs().year() === dayjs(this.courseDetail.reservationTime).year() ?
      dayjs(this.courseDetail.reservationTime).format('MM/DD HH:mm').toString() :
      dayjs(this.courseDetail.reservationTime).format('YYYY/MM/DD HH:mm').toString();

    this.liveVM.avatar = (this.loginUser.avatar && this.loginUser.avatar !== '') ? this.loginUser.avatar :
      $r('app.media.ic_user_default');
    this.liveVM.name = this.loginUser.name;
  }

  build() {
    Column() {
      this.topBuilder();
      LiveStreaming({
        fullScreen: (isLayoutFullScreen) => {
          this.isLayoutFullScreen = isLayoutFullScreen;
        },
        onSubmit: () => {
          this.scroller.scrollEdge(Edge.Bottom);
        },
        shareEvent: () => {
          this.shareEvent();
        },
        inputEvent: () => {
          RouterModule.push({ url: RouterMap.INPUT_COMMENT_PAGE });
        },
        downEvent: () => {
          this.isShowDownSheet = true;
        }
      });
      Row()
        .bindSheet(this.isShowDescribe, this.describeBuilder(), {
          height: '90%',
          dragBar: true, // 是否显示控制条
          backgroundColor: ($r('sys.color.mask_primary')),
          showClose: false, // 是否显示关闭图标
          preferType: SheetType.CENTER,
          shouldDismiss: ((sheetDismiss: SheetDismiss) => {
            sheetDismiss.dismiss();
            this.isShowDescribe = false;
          })
        })
        .size({ width: 0, height: 0 });
      Row()
        .bindSheet(this.isShowMore, this.moreBuilder(), {
          height: 250,
          dragBar: true, // 是否显示控制条
          backgroundColor: ($r('sys.color.font_on_primary')),
          showClose: true, // 是否显示关闭图标
          preferType: SheetType.CENTER,
          shouldDismiss: ((sheetDismiss: SheetDismiss) => {
            sheetDismiss.dismiss();
            this.isShowMore = false;
          })
        })
        .size({ width: 0, height: 0 });
      Row()
        .bindSheet(this.isShowDownSheet, this.downLoadBuilder(), {
          // 半模态高度
          height: 300,
          dragBar: true, // 是否显示控制条
          backgroundColor: Color.White,
          showClose: true, // 是否显示关闭图标
          preferType: SheetType.CENTER,
          shouldDismiss: ((sheetDismiss: SheetDismiss) => {
            sheetDismiss.dismiss();
            this.isShowDownSheet = false;
          })
        })
        .size({ width: 0, height: 0 });
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor('rgba(0,0,0,1)')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
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
      let collectRecord: CollectionModel = new CollectionModel();
      collectRecord.id = this.courseDetail.id;
      collectRecord.courseTitle = this.courseDetail.courseTitle;
      collectRecord.courseDuration = this.courseDetail.courseDuration;
      collectRecord.learnProgress = this.courseDetail.learnProgress;
      collectRecord.cover = this.courseDetail.cover;
      collectRecord.time = Date.now();
      collectRecord.liveState = this.courseDetail.liveState;
      // 将收藏记录存入持久层
      PreferenceUtil.getInstance(PreferConstant.COLLECT_COURSE_RECORDS).put(collectRecord.id, collectRecord);
      if (this.collectionRouter.routerTitle === '我的收藏') {
        this.collectionRouter.isCollection = true;
      }
    }
    // 监听收藏状态
    this.monitorCollectionStatus();
  }

  shareEvent() {
    const picker: SharePicker = new SharePicker({
      title: this.courseDetail.courseTitle,
      coverUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/commonwidget%2Fexample960x720.png',
      createTime: new Date().getTime(),
      landingPageUrl: 'https://developer.huawei.com/consumer/cn/activity/301757474300821213',
    });

    picker.setSignQQShareDataCB((shareJson: string) => {
      const signData = new QQShareData();
      signData.shareJson = shareJson;
      signData.timestamp = Date.parse(new Date().toString()) / 1000;
      signData.nonce = 62695688;
      signData.shareJsonSign = 'Hsvqs0IpjiN6DfFfhboGp+r3XzQ=';
      return Promise.resolve(signData);
    });

    picker.show({
      autoClose: true,
    });
  }
}

@Builder
export function LiveStreamingPageBuilder() {
  LiveStreamingPage();
}