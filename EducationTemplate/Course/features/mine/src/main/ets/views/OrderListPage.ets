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

import { AppStorageV2 } from '@kit.ArkUI';
import { pasteboard } from '@kit.BasicServicesKit';
import { CourseModel, COURSE_DATA, MyCourseClass } from 'http';
import { OrderInfo, OrderState, RouterMap, RouterModule, CourseOrderInfo } from 'commonlib';
import { MyVM } from '../viewModel/MyVM';

export enum OrderListType {
  //全部订单
  ALL = 0,
  //待支付
  WAIT_TO_PAY,
  //已支付
  PAID,
  //已取消
  CANCELLED
}

@ComponentV2
export struct OrderListPage {
  @Param orderType: OrderListType = OrderListType.ALL
  @Local orderInfo: OrderInfo[] = []
  @Param currentIndex: number = 0;
  @Local propOrder: CourseOrderInfo = AppStorageV2.connect(CourseOrderInfo, () => new CourseOrderInfo())!;

  @Monitor('currentIndex')
  onStrChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      if (path === 'currentIndex') {
        this.refreshData()
      }
    });
  }

  aboutToAppear(): void {
    this.refreshData()
  }

  refreshData() {
    if (this.orderType === OrderListType.ALL) {
      this.orderInfo = this.propOrder.orderInfos
    } else if (this.orderType === OrderListType.WAIT_TO_PAY) {
      this.orderInfo = this.propOrder.orderInfos.filter((item: OrderInfo) => item.orderState === OrderState.WAIT_TO_PAY)
    } else if (this.orderType === OrderListType.PAID) {
      this.orderInfo = this.propOrder.orderInfos.filter((item: OrderInfo) => item.orderState === OrderState.PAID)
    } else if (this.orderType === OrderListType.CANCELLED) {
      this.orderInfo = this.propOrder.orderInfos.filter((item: OrderInfo) => item.orderState === OrderState.CANCELLED)
    }
    //按照时间顺序由近及远
    this.orderInfo.sort((a, b) => b.orderTime - a.orderTime)
  }

  build() {
    Column() {
      if (this.orderInfo.length <= 0) {
        // 订单为空页面
        this.emptyOrderBuilder()
      } else {
        List({ space: 12 }) {
          ForEach(this.orderInfo, (obj: OrderInfo) => {
            ListItem() {
              OrderItem({
                info: obj,
                refreshEvent: () => {
                  this.refreshData()
                }
              })
            }
          }, (item: OrderInfo, idx: number) => item.orderNo + idx)
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .layoutWeight(1)
      }
    }
    .padding($r('app.float.vp_16'))
    .backgroundColor($r('sys.color.background_secondary'))
    .width('100%')
    .height('100%')
  }

  /**
   * 订单为空页面
   */
  @Builder
  emptyOrderBuilder() {
    Image($r('app.media.Empty'))
      .width($r('app.float.vp_105'))
      .height($r('app.float.vp_95'))
      .margin({ top: $r('app.float.vp_207'), bottom: $r('app.float.vp_36') })
    Text($r('app.string.order_empty'))
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Regular)
      .fontColor($r('sys.color.font_tertiary'))
  }
}

@ComponentV2
struct OrderItem {
  @Param info: OrderInfo = new OrderInfo('', OrderState.WAIT_TO_PAY, '', '', '',
    '', '', false, 0)
  @Param refreshEvent: () => void = () => {
  }
  @Local vm: MyVM = MyVM.instance;

  build() {
    Column() {
      // 订单号
      this.orderNoBuilder()
      // 课程内容
      this.courseContentBuilder()
      Divider()
        .color($r('sys.color.comp_divider'))
        .margin({ left: $r('app.float.vp_108'), top: $r('app.float.vp_16') })
      // 价格
      this.priceBuilder()
      // 底部按钮事件
      this.buttonOperateBuilder()
    }
    .onClick(() => {
      let myInfo: MyInfo = new MyInfo()
      myInfo.info = this.info
      myInfo.refreshCallback = () => {
        this.refreshEvent()
      }
      // 跳转详情页
      RouterModule.push({ url: RouterMap.ORDER_DETAIL_PAGE, param: myInfo })
    })
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: $r('app.float.vp_12'),
      right: $r('app.float.vp_12'),
      top: $r('app.float.vp_16'),
      bottom: $r('app.float.vp_16')
    })
    .backgroundColor($r('sys.color.background_primary'))
    .width('100%')
    .height($r('app.float.vp_197'))
    .borderRadius($r('app.float.vp_16'))
  }

  /**
   * 底部按钮事件Builder
   */
  @Builder
  buttonOperateBuilder() {
    Row() {
      Button(this.info.orderState === OrderState.WAIT_TO_PAY ? $r('app.string.cancel_order') :
      $r('app.string.delete_order'))
        .padding(0)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
        .width($r('app.float.vp_72'))
        .height($r('app.float.vp_28'))
        .onClick(() => {
          if (this.info.orderState === OrderState.WAIT_TO_PAY) {
            let courseOrderInfo = AppStorageV2.connect(CourseOrderInfo, () => new CourseOrderInfo())!;
            courseOrderInfo.orderInfos.forEach((orderInfo: OrderInfo) => {
              if (orderInfo.orderNo === this.info.orderNo) {
                orderInfo.orderState = OrderState.CANCELLED
                orderInfo.orderTime = Date.now();
                this.vm.courseData.courseList.forEach((course: CourseModel) => {
                  if (orderInfo.courseId === course.id) {
                    course.payStatus = 3
                  }
                })
              }
            })
            courseOrderInfo.orderInfos = courseOrderInfo.orderInfos
            this.refreshEvent()
          } else {
            let courseOrderInfo = AppStorageV2.connect(CourseOrderInfo, () => new CourseOrderInfo())!;
            let arr = courseOrderInfo.orderInfos.filter((item: OrderInfo) => item.orderNo !== this.info.orderNo)
            courseOrderInfo.orderInfos = arr
            this.refreshEvent()
          }
        })
      Button(this.info.orderState === OrderState.WAIT_TO_PAY ? $r('app.string.immediate_payment') :
        (this.info.orderState === OrderState.PAID ? $r('app.string.learn_now') : $r('app.string.reorder_again')))
        .padding(0)
        .backgroundColor($r('sys.color.multi_color_01'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .width($r('app.float.vp_72'))
        .height($r('app.float.vp_28'))
        .margin({ left: $r('app.float.vp_8') })
        .onClick(() => {
          if (this.info.orderState === OrderState.CANCELLED || this.info.orderState === OrderState.WAIT_TO_PAY) {
            let courseOrderInfo = AppStorageV2.connect(CourseOrderInfo, () => new CourseOrderInfo())!;
            courseOrderInfo.orderInfos.forEach((orderInfo: OrderInfo) => {
              if (orderInfo.orderNo === this.info.orderNo) {
                orderInfo.orderState = OrderState.PAID
                orderInfo.orderTime = Date.now();
                this.vm.courseData.courseList.forEach((course: CourseModel) => {
                  if (orderInfo.courseId === course.id) {
                    course.isPay = true
                    course.payStatus = 1
                    // 课程购买成功后添加到我的课程
                    let myCourseClass: MyCourseClass = AppStorageV2.connect(MyCourseClass, () => new MyCourseClass())!
                    course.time = Date.now()
                    myCourseClass.courseList.push(course)
                  }
                })
              }
            })
            courseOrderInfo.orderInfos = courseOrderInfo.orderInfos
            this.refreshEvent()
          } else if (this.info.orderState === OrderState.PAID) {
            // 跳转详情页去学习
            let item = COURSE_DATA.find(course => course.courseTitle === this.info.courseTitle)
            RouterModule.push({ url: RouterMap.RECORDED_DETAIL_PAGE, param: item?.id })
          }
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
    .margin({ top: $r('app.float.vp_12') })
  }

  /**
   * 价格Builder
   */
  @Builder
  priceBuilder() {
    Row() {
      Text('总计：')
        .fontSize($r('sys.float.Caption_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Text('￥' + this.info.price)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.multi_color_08'))
    }
    .alignItems(VerticalAlign.Bottom)
    .justifyContent(FlexAlign.End)
    .width('100%')
    .margin({ top: $r('app.float.vp_8') })
  }

  /**
   * 课程内容Builder
   */
  @Builder
  courseContentBuilder() {
    Row() {
      Image(this.info.courseIcon)
        .width($r('app.float.vp_96'))
        .height($r('app.float.vp_54'))
        .borderRadius(8)
      Column() {
        Text(this.info.courseTitle)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .wordBreak(WordBreak.BREAK_ALL)
        Text(this.info.courseIntroduction)
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_tertiary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .wordBreak(WordBreak.BREAK_ALL)
          .margin({ top: $r('app.float.vp_8') })

      }.margin({ left: $r('app.float.vp_12') })
      .layoutWeight(1).alignItems(HorizontalAlign.Start)

    }
    .width('100%')
    .margin({ top: $r('app.float.vp_17') })
  }

  /**
   * 订单号Builder
   */
  @Builder
  orderNoBuilder() {
    Row() {
      Text('订单号：' + this.info.orderNo)
        .fontSize($r('sys.float.Caption_L'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
      Image($r('app.media.copy'))
        .width($r('app.float.vp_12'))
        .height($r('app.float.vp_12'))
        .margin({ left: $r('app.float.vp_6') })
        .onClick(() => {
          let paste: string = pasteboard.MIMETYPE_TEXT_PLAIN
          let orderNo: string = this.info.orderNo;
          let pasteData: pasteboard.PasteData = pasteboard.createData(paste, orderNo);
          let sysPaste: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
          sysPaste.setData(pasteData, (err) => {
            if (err) {
              this.getUIContext().getPromptAction().showToast({ message: '复制失败', duration: 2000 });
              return;
            }
            this.getUIContext().getPromptAction().showToast({
              message: this.info.orderNo + '复制成功', duration: 2000
            });
          });
        })
      Blank()
      Text(this.info.orderState === OrderState.WAIT_TO_PAY ? $r('app.string.wait_pay') :
        (this.info.orderState === OrderState.PAID ? $r('app.string.pay_success') : $r('app.string.cancelled')))
        .fontSize($r('sys.float.Caption_L'))
        .fontWeight(FontWeight.Regular)
        .fontColor(this.info.orderState === OrderState.WAIT_TO_PAY ? $r('sys.color.multi_color_08') :
        $r('sys.color.font_secondary'))
    }
    .width('100%')
  }
}

export class MyInfo {
  info: OrderInfo = new OrderInfo('', OrderState.WAIT_TO_PAY, '', '', '',
    '', '', false, 0)
  refreshCallback: () => void = () => {
  }
}