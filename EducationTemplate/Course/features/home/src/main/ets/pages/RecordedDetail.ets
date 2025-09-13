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

import { promptAction, AppStorageV2 } from '@kit.ArkUI';
import {
  NoData,
  NumberUtil,
  RouterMap,
  RouterModule,
  OrderInfo,
  OrderState,
  CourseOrderInfo,
  PreferenceUtil,
  PreferConstant,
  CollectionModel,
  CollectionRouter,
  UserInfo
} from 'commonlib';
import { CourseCatalogModel, CourseModel, MyCourseClass } from 'http';
import { AggregatedPaymentPicker, ChannelType, MockApi, WxExtraInfo } from 'aggregated_payment';
import { Share } from 'aggregated_share';
import { HomeVM } from '../viewModels/HomeVM';

@Builder
export function RecordedDetailBuilder() {
  RecordedDetailPage();
}

@ComponentV2
export struct RecordedDetailPage {
  vm: HomeVM = HomeVM.instance;
  collectionRouter: CollectionRouter = CollectionRouter.instance();
  @Local courseDetail: CourseModel = new CourseModel()
  @Local arr: number[] = [5, 4, 3, 2, 1]
  @Local arrIcon: ResourceStr[] =
    [$r('app.media.ic_picture_01'), $r('app.media.ic_picture_04'), $r('app.media.ic_picture_03'),
      $r('app.media.ic_picture_02'), $r('app.media.ic_picture_05')]
  // 展示购买弹窗
  @Local isShowPay: boolean = false
  // 获取各支付方式的预下单信息
  @Local aliOrderStr: string = '';
  @Local hwOrderStr: string = '';
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  wxOrderReq: WxExtraInfo = new WxExtraInfo();

  aboutToAppear(): void {
    let courseId = RouterModule.getNavParam({ url: RouterMap.RECORDED_DETAIL_PAGE }) as string
    if (courseId && courseId.length > 0) {
      this.courseDetail =
        this.vm.courseData.courseList.find((course: CourseModel) => courseId === course.id) as CourseModel
      // 监听收藏状态
      this.monitorCollectionStatus()
      if (this.collectionRouter.routerTitle === '我的收藏') {
        this.collectionRouter.isCollection = true
      }
    }
  }

  build() {
    Column() {
      if (this.courseDetail && this.courseDetail.id.length > 0) {
        this.topBuilder()
        Scroll() {
          Column() {
            this.bannerBuilder()
            this.courseContent()
            this.courseCatalog()
            this.courseDetailBuilder()
          }
          .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring)

        this.bottomBuilder()
      } else {
        NoData({ text: '查询详情数据失败' })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  bottomBuilder() {
    Row() {
      // 分享
      Share({
        shareCodeInfo: {
          id: this.courseDetail.id,
          title: this.courseDetail.courseTitle,
          lecturer: this.courseDetail.lecturer!,
          coverUrl: 'coverUrl', // 分享的封面图片替换自己的
        },
        shareRenderBuilder: () => {
          this.shareCommentBuilder()
        },
      })

      Column() {
        Image(this.loginUser.isLogin && this.courseDetail.isCollection ? $r('app.media.ic_star') : $r('app.media.ic_public_star'))
          .width($r('app.float.vp_24'))
          .height($r('app.float.vp_24'))
          .margin({ bottom: 2 })
        Text($r('app.string.collect'))
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .margin({ left: $r('app.float.vp_8') })
      .onClick(() => {
        if (this.loginUser.isLogin) {
          this.clickCollectButton()
        } else {
          RouterModule.push({ url: RouterMap.LOGIN_PAGE })
        }
      })

      Blank()
        .layoutWeight(1)
      Button({
        type: ButtonType.Capsule,
        stateEffect: true,
      }) {
        Text(!this.courseDetail.isFree && !this.courseDetail.isPay ? '￥288 立即购买' : '立即学习')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium)
      }
      .backgroundColor($r('sys.color.multi_color_01'))
      .height(40)
      .width(200)
      .bindSheet(this.isShowPay, this.paymentChannelSheet(),
        {
          height: '65%',
          showClose: true,
          onDisappear: () => {
            this.isShowPay = false
          }
        })
      .onClick(() => {
        if (this.loginUser.isLogin) {
          if (!this.courseDetail.isFree && (this.courseDetail.payStatus === 0 || this.courseDetail.payStatus === 3)) {
            // 获取各支付方式的预下单信息
            this.wxOrderReq = MockApi.getWxPreOrderInfo();
            this.hwOrderStr = MockApi.getHuaweiOrderInfo();
            MockApi.getAliPreOrderInfo().then((res) => {
              this.aliOrderStr = res;
            });
            this.isShowPay = true
          } else if (!this.courseDetail.isFree && this.courseDetail.payStatus === 2) {
            let courseOrderInfo = AppStorageV2.connect(CourseOrderInfo, () => new CourseOrderInfo())!;
            courseOrderInfo.orderInfos.forEach((orderInfo: OrderInfo) => {
              if (orderInfo.courseId === this.courseDetail.id) {
                // 跳转订单页
                RouterModule.push({ url: RouterMap.MY_ORDER_PAGE })
              }
            })
          } else {
            if (this.courseDetail.courseCatalog && this.courseDetail.courseCatalog.length > 0) {
              this.courseDetail.catalogIndex = 0
              RouterModule.push({ url: RouterMap.CHAPTER_DETAIL_PAGE, param: this.courseDetail })
            } else {
              this.getUIContext().getPromptAction().showToast({ message: '缺少课程章节数据' })
            }
          }
        } else {
          RouterModule.push({ url: RouterMap.LOGIN_PAGE })
        }
      })
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height($r('app.float.vp_56'))
    .padding({ left: $r('app.float.vp_8'), right: $r('app.float.vp_16') })
  }

  /**
   * 点击收藏按钮
   */
  clickCollectButton() {
    if (this.courseDetail.isCollection) {
      PreferenceUtil.getInstance(PreferConstant.COLLECT_COURSE_RECORDS).delete(this.courseDetail.id)
      if (this.collectionRouter.routerTitle === '我的收藏') {
        this.collectionRouter.isCollection = false
      }
    } else {
      let collectRecord: CollectionModel = new CollectionModel()
      collectRecord.id = this.courseDetail.id
      collectRecord.courseTitle = this.courseDetail.courseTitle
      collectRecord.courseDuration = this.courseDetail.courseDuration
      collectRecord.learnProgress = this.courseDetail.learnProgress
      collectRecord.cover = this.courseDetail.cover
      collectRecord.time = Date.now()
      // 将收藏记录存入持久层
      PreferenceUtil.getInstance(PreferConstant.COLLECT_COURSE_RECORDS).put(collectRecord.id, collectRecord)
      if (this.collectionRouter.routerTitle === '我的收藏') {
        this.collectionRouter.isCollection = true
      }
    }
    // 监听收藏状态
    this.monitorCollectionStatus()
  }

  /**
   * 监听收藏状态
   */
  monitorCollectionStatus() {
    if (PreferenceUtil.getInstance(PreferConstant.COLLECT_COURSE_RECORDS).hasSync(this.courseDetail.id)) {
      this.courseDetail.isCollection = true
    } else {
      this.courseDetail.isCollection = false
    }
  }

  @Builder
  shareCommentBuilder() {
    Column() {
      Image($r('app.media.icon_public_share'))
        .width(20)
        .height(20)
        .margin({ bottom: 2 })
      Text('分享')
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
    }
    .width(48)
    .height(48)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 发起购买
   * @returns
   */
  @Builder
  paymentChannelSheet() {
    Column() {
      AggregatedPaymentPicker({
        price: '288',
        goodsName: '购买课程',
        channelInfo: [{
          channelType: ChannelType.HUAWEI_PAY,
          name: '华为支付',
          icon: $r('app.media.hw_pay_icon'),
          preOrderInfo: this.hwOrderStr,
        }, {
          channelType: ChannelType.WECHAT_PAY,
          preOrderInfo: this.wxOrderReq,
          appId: MockApi.WX_APP_ID,
          icon: $r('app.media.wx_pay_icon'),
          name: '微信支付',
        }, {
          channelType: ChannelType.ALI_PAY,
          name: '支付宝支付',
          icon: $r('app.media.ali_pay_icon'),
          preOrderInfo: this.aliOrderStr,
        }],
        paySuccessEvent: () => {
          let courseOrderInfo = AppStorageV2.connect(CourseOrderInfo, () => new CourseOrderInfo())!;
          let content: string = this.courseDetail.courseTitle
          let orderNo: string = '202508' + Date.now()
          let price: string = '288'
          const timestamp: number = Date.now();
          let orderInfo =
            new OrderInfo(this.courseDetail.id, OrderState.PAID, orderNo, content, this.courseDetail.cover!,
              this.courseDetail.description!, price, false, timestamp)
          orderInfo.courseId = this.courseDetail.id
          courseOrderInfo.orderInfos.unshift(orderInfo)
          promptAction.showToast({ message: '支付成功~' })
          this.isShowPay = false;
          this.courseDetail.isPay = true
          this.courseDetail.payStatus = 1
          // 课程购买成功后添加到我的课程
          let myCourseClass: MyCourseClass = AppStorageV2.connect(MyCourseClass, () => new MyCourseClass())!
          this.courseDetail.time = Date.now()
          myCourseClass.courseList.push(this.courseDetail)
        },
        payFailEvent: () => {
          let courseOrderInfo = AppStorageV2.connect(CourseOrderInfo, () => new CourseOrderInfo())!;
          let orderNo: string = '202508' + Date.now()
          let courseTitle: string = this.courseDetail.courseTitle
          let price: string = '288'
          const timestamp: number = Date.now();
          let orderInfo =
            new OrderInfo(this.courseDetail.id, OrderState.WAIT_TO_PAY, orderNo, courseTitle, this.courseDetail.cover!,
              this.courseDetail.description!, price, false, timestamp)
          orderInfo.courseId = this.courseDetail.id
          courseOrderInfo.orderInfos.push(orderInfo)
          AppStorageV2.connect(CourseOrderInfo, () => courseOrderInfo)!;
          promptAction.showToast({ message: '支付失败~' })
          this.isShowPay = false;
          this.courseDetail.payStatus = 2
        }
      })
    }.width('100%')
    .height('100%')
  }

  @Builder
  bannerBuilder() {
    Row() {
      Image($r('app.media.ic_banner_01'))
        .interpolation(ImageInterpolation.High)
        .width('100%')
        .height(184)
        .borderRadius(16)
    }
  }

  @Builder
  courseContent() {
    Column() {
      Text(this.courseDetail.courseTitle)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Text(this.courseDetail.description)
        .fontSize($r('sys.float.Caption_L'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
        .margin({ top: 12, bottom: 12 })
      Row()
        .backgroundColor($r('sys.color.comp_divider'))
        .width('100%')
        .height(0.5)
        .margin({ bottom: 12 })

      Text('主讲人：' + this.courseDetail.lecturer)
        .fontSize($r('sys.float.Caption_L'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)

      Row() {
        Image($r('app.media.icon_time'))
          .width($r('app.float.vp_15'))
          .height($r('app.float.vp_15'))
        Text(NumberUtil.getHourAndMinuteFormat(this.courseDetail.courseDuration!))
          .fontSize($r('sys.float.Caption_L'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
      }
      .margin({ top: 6, bottom: 12 })

      Row()
        .backgroundColor($r('sys.color.comp_divider'))
        .width('100%')
        .height(0.5)
        .margin({ bottom: 12 })

      Row() {
        Row() {
          ForEach(this.arrIcon, (icon: ResourceStr, idx: number) => {
            Image(icon)
              .interpolation(ImageInterpolation.High)
              .width($r('app.float.vp_24'))
              .height($r('app.float.vp_24'))
              .borderRadius(12)
              .margin({ left: -6 })
              .zIndex(this.arr.length - idx)
          }, (num: number, index: number) => JSON.stringify(num) + index)
        }
        .width('50%')
        .padding(6)

        Text(`${NumberUtil.getCountFormat(this.courseDetail.learnNumber)}人已学习`)
          .fontSize($r('sys.float.Caption_L'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
    .width('100%')
    .borderRadius(16)
    .padding(12)
    .margin(12)
  }

  @Builder
  courseCatalog() {
    if (this.courseDetail.courseCatalog && this.courseDetail.courseCatalog.length > 0) {
      Text('课程目录')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 8 })
        .alignSelf(ItemAlign.Start)

      Column() {
        Column() {
          ForEach(this.courseDetail.courseCatalog, (item: CourseCatalogModel, idx: number) => {
            this.catalogItem(item, idx)
          }, (num: number, index: number) => JSON.stringify(num) + index)
        }
        .borderRadius(16)
        .clip(true)
      }
    }
  }

  @Builder
  catalogItem(item: CourseCatalogModel, idx: number) {
    Column() {
      Row({ space: 8 }) {
        Text(`0${idx + 1}`)
          .fontSize($r('sys.float.Subtitle_M'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Bold)
        Text(item.catalogTitle)
          .fontSize($r('sys.float.Subtitle_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Button({
          type: ButtonType.Capsule,
          stateEffect: true,
        }) {
          Text((!this.courseDetail.isFree && !this.courseDetail.isPay) ? (idx === 0 ? '免费试看' : '去学习') :
            '去学习')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
        }
        .enabled((!this.courseDetail.isFree && !this.courseDetail.isPay) ? (idx === 0 ? true : false) : true)
        .backgroundColor($r('sys.color.multi_color_01'))
        .height(28)
        .width(72)
        .onClick(() => {
          if (this.loginUser.isLogin) {
            if (this.courseDetail.courseCatalog && this.courseDetail.courseCatalog.length > 0) {
              this.courseDetail.catalogIndex = idx
              RouterModule.push({ url: RouterMap.CHAPTER_DETAIL_PAGE, param: this.courseDetail })
            } else {
              this.getUIContext().getPromptAction().showToast({ message: '缺少课程章节数据' })
            }
          } else {
            RouterModule.push({ url: RouterMap.LOGIN_PAGE })
          }
        })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .height(52)

      Row()
        .backgroundColor($r('sys.color.comp_divider'))
        .width('100%')
        .height(0.5)
    }
    .backgroundColor(Color.White)
    .width('100%')
    .padding({ left: 12, right: 12 })
  }

  @Builder
  topBuilder() {
    Row() {
      Image($r('app.media.chevron_backward'))
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .onClick(() => {
          RouterModule.pop()
        })
      Text('录播课程详情')
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: $r('app.float.vp_8') })
      Blank()
        .layoutWeight(1)
    }
    .width('100%')
    .height($r('app.float.vp_56'))
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
  }

  @Builder
  courseDetailBuilder() {
    Column() {
      Text('课程详情')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })

      Image($r('app.media.ic_course_detail'))
        .width('100%')
        .aspectRatio(0.7)
        .borderRadius(16)
    }
    .margin({ top: 24, bottom: 24 })
  }
}
