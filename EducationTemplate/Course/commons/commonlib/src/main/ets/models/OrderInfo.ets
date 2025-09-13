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

export enum OrderState {
  WAIT_TO_PAY = 0,
  PAID,
  CANCELLED,
  ALL
}

@ObservedV2
export class OrderInfo {
  @Trace id: string = '1111' // 唯一标识
  @Trace orderNo: string = '202310101523232345' // 订单号
  @Trace orderState: OrderState = OrderState.WAIT_TO_PAY // 订单状态
  @Trace courseTitle: string = 'HarmonyOS赋能套件介绍第一课' // 课程标题
  @Trace courseId: string = '' // 课程id
  @Trace courseIcon: ResourceStr = '' // 封面课程
  @Trace courseIntroduction: string = '课程介绍' // 课程介绍
  @Trace price: string = '288' // 价格
  @Trace isDelete: boolean = false // 是否删除
  // 下单时间
  @Trace orderTime: number = 0

  constructor(id: string, orderState: OrderState, orderNo: string, courseTitle: string, courseIcon: ResourceStr,
    courseIntroduction: string, price: string, isDelete: boolean, orderTime: number) {
    this.id = id
    this.orderState = orderState
    this.orderNo = orderNo
    this.courseTitle = courseTitle
    this.courseIcon = courseIcon
    this.courseIntroduction = courseIntroduction
    this.price = price
    this.isDelete = isDelete
    this.orderTime = orderTime
  }
}
// 订单数据
@ObservedV2
export class CourseOrderInfo {
  @Trace orderInfos: OrderInfo[] = [];
}
