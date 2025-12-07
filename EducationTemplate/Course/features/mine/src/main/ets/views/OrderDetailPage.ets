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

import { pasteboard } from '@kit.BasicServicesKit';
import { promptAction, AppStorageV2 } from '@kit.ArkUI';
import dayjs from 'dayjs'
import { CourseModel, COURSE_DATA, MyCourseClass } from 'http';
import {
  TopBar,
  MyScrollModifier,
  OrderInfo,
  OrderState,
  RouterModule,
  RouterMap,
  CourseOrderInfo
} from 'commonlib';
import { MyInfo } from './OrderListPage';
import { MyVM } from '../viewModel/MyVM';

@ComponentV2
export struct OrderDetailPage {
  @Local vm: MyVM = MyVM.instance;
  @Local info: OrderInfo = new OrderInfo('', OrderState.WAIT_TO_PAY, '', '', '',
    '', '', false, 0)
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier()
  textTimerController: TextTimerController = new TextTimerController();
  @Local payType: string = '华为支付';
  refreshCallback: () => void = () => {
  }

  aboutToAppear(): void {
    let temp = RouterModule.getNavParam({ url: RouterMap.ORDER_DETAIL_PAGE }) as MyInfo
    if (temp) {
      this.info = temp.info
      this.refreshCallback = temp.refreshCallback
    }
  }

  build() {
    Column() {
      TopBar({ title: $r('app.string.order_detail') })
        .margin({ left: $r('app.float.vp_16') })
      Scroll() {
        Column() {
          this.orderType()
          this.goodsDetailInfo()
          this.orderInfo()
        }
        .width('100%')
        .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), bottom: $r('app.float.vp_16') })
        .alignItems(HorizontalAlign.Start)
      }
      .attributeModifier(this.scrollModifier)

      Column() {
        this.orderBottomInfo()
      }
      .width('100%')
      .backgroundColor($r('sys.color.background_primary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  orderBottomInfo() {
    Row() {
      if (this.info.orderState === OrderState.WAIT_TO_PAY) {
        Text('合计：')
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .margin({ left: $r('app.float.vp_23') })
        Text('￥' + this.info.price)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.multi_color_08'))
          .margin({ left: $r('app.float.vp_2') })
      }
      Blank()
      Button(this.info.orderState === OrderState.WAIT_TO_PAY ? '立即支付' :
        (this.info.orderState === OrderState.PAID ? '立即学习' : '重新下单'))
        .padding(0)
        .backgroundColor($r('sys.color.multi_color_01'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .width($r('app.float.vp_160'))
        .height($r('app.float.vp_40'))
        .onClick(() => {
          if (this.info.orderState === OrderState.CANCELLED) {
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
            this.refreshCallback()
            RouterModule.pop(true)
          } else if (this.info.orderState === OrderState.WAIT_TO_PAY) {
            let sampleOrderInfo = AppStorageV2.connect(CourseOrderInfo, () => new CourseOrderInfo())!;
            sampleOrderInfo.orderInfos.forEach((orderInfo: OrderInfo) => {
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
            sampleOrderInfo.orderInfos = sampleOrderInfo.orderInfos
            this.refreshCallback()
            RouterModule.pop(true)
          } else if (this.info.orderState === OrderState.PAID) {
            // 跳转详情页去学习
            let item = COURSE_DATA.find(course => course.courseTitle === this.info.courseTitle)
            RouterModule.push({ url: RouterMap.RECORDED_DETAIL_PAGE, param: item?.id })
          }
        })
        .margin({ right: $r('app.float.vp_16') })
    }
    .width('100%')
    .height($r('app.float.vp_56'))
  }

  @Builder
  orderInfo() {
    Column() {
      Text('订单信息')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Divider()
        .strokeWidth(2)
        .color($r('sys.color.comp_background_tertiary'))
        .margin({ top: $r('app.float.vp_12') })
      this.infoPayItem('支付方式', this.payType,
        this.info.orderState === OrderState.WAIT_TO_PAY ? $r('app.media.icon_right') : undefined)
      this.infoItem('订单编号', this.info.orderNo, $r('app.media.copy'))

      this.infoItem('下单时间',
        dayjs().year() === dayjs(this.info.orderTime).year() ? dayjs(this.info.orderTime).format('YYYY-MM-DD HH:mm') :
        dayjs(this.info.orderTime).format('YYYY/MM/DD HH:mm'), undefined)
    }
    .alignItems(HorizontalAlign.Start)
    .height($r('app.float.vp_157'))
    .borderRadius($r('app.float.vp_16'))
    .backgroundColor($r('sys.color.background_primary'))
    .padding(12)
    .width('100%')
  }

  @Builder
  MenuBuilder() {
    Column() {
      Menu() {
        MenuItemGroup() {
          MenuItem({ content: '华为支付' })
            .onChange((selected) => {
              this.payType = '华为支付'
            })
          MenuItem({ content: '微信支付' })
            .onChange((selected) => {
              this.payType = '微信支付'
            })

          MenuItem({ content: '支付宝支付' })
            .onChange((selected) => {
              this.payType = '支付宝支付'
            })
        }
      }.width($r('app.float.vp_224'))
    }
  }

  @Builder
  infoPayItem(title: string, content: string, image?: Resource) {
    Row() {
      Text(title)
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight($r('app.float.vp_22'))
      Text(this.payType
      )
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ left: $r('app.float.vp_12') })
        .lineHeight($r('app.float.vp_22'))
      Blank()
      if (image) {
        Row() {
          Image(image)
            .width($r('app.float.vp_12')).height($r('app.float.vp_12'))
        }
        .width($r('app.float.vp_50'))
        .height($r('app.float.vp_12'))
        .justifyContent(FlexAlign.End)
        .bindMenu(this.MenuBuilder)

      }
    }
    .width('100%')
    .margin({ top: $r('app.float.vp_12') })
  }

  @Builder
  infoItem(title: string, content: string, image?: Resource) {
    Row() {
      Text(title)
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight($r('app.float.vp_22'))
      Text(content)
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ left: $r('app.float.vp_12') })
        .lineHeight($r('app.float.vp_22'))
      Blank()
      if (image) {
        Image(image)
          .width($r('app.float.vp_12')).height($r('app.float.vp_12'))
          .onClick(() => {
            if (title === '订单编号') {
              let paste: string = pasteboard.MIMETYPE_TEXT_PLAIN
              let orderNo: string = this.info.orderNo;
              let pasteData: pasteboard.PasteData = pasteboard.createData(paste, orderNo);
              let sysPaste: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
              sysPaste.setData(pasteData, (err) => {
                if (err) {
                  promptAction.showToast({ message: '复制失败' })
                  return;
                }
                promptAction.showToast({ message: '复制成功' })
              });
            }
          })
      }
    }
    .width('100%')
    .margin({ top: $r('app.float.vp_12') })
  }

  @Builder
  goodsDetailInfo() {
    Column() {
      Text('商品信息')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
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
      .margin({ top: $r('app.float.vp_12') })

      Divider()
        .strokeWidth(2)
        .color($r('sys.color.comp_background_tertiary'))
        .margin({ left: $r('app.float.vp_108'), top: $r('app.float.vp_12') })
      Row() {
        Text('实际金额：')
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
      .margin({ top: $r('app.float.vp_12') })
    }
    .alignItems(HorizontalAlign.Start)
    .height($r('app.float.vp_158'))
    .borderRadius($r('app.float.vp_16'))
    .backgroundColor($r('sys.color.background_primary'))
    .padding(12)
    .margin({ bottom: $r('app.float.vp_12') })
    .width('100%')
  }

  @Builder
  orderType() {
    Column() {
      Text(this.info.orderState === OrderState.WAIT_TO_PAY ? '待支付...' :
        (this.info.orderState === OrderState.PAID ? '已完成' : '已取消'))
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .height($r('app.float.vp_32'))
      if (this.info.orderState === OrderState.WAIT_TO_PAY) {
        Row() {
          Text('订单将在 ')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
          // 计时器
          TextTimer({
            isCountDown: true,
            count: this.info.orderTime + 30 * 60 * 1000 - Date.now(),
            controller: this.textTimerController
          })
            .format('HH:mm:ss')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.multi_color_08'))
            .onTimer((_utc: number, elapsedTime: number) => {
              if (elapsedTime >= (this.info.orderTime + 30 * 60 * 1000 - Date.now()) / 100) {
                this.info.orderState = OrderState.CANCELLED
                promptAction.showToast({ message: '订单已取消' })
              }
            })
            .onAppear(() => {
              this.textTimerController.start();
            })
            .onDisAppear(() => {
              this.textTimerController.reset();
            })
          Text(' 后自动取消')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }
        .height($r('app.float.vp_19'))
        .margin({ top: $r('app.float.vp_6') })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ left: $r('app.float.vp_8'), top: $r('app.float.vp_24'), bottom: $r('app.float.vp_24') })
  }
}

@Builder
export function OrderDetailPageBuilder() {
  OrderDetailPage()
}