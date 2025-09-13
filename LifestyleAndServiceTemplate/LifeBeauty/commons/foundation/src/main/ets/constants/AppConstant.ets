/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

/**
 * 服务端请求的基础url
 */
export const BASE_URL = '';


/**
 * todo
 */
export enum CurAppInfo {
  CLIENT_ID = 'xxx',// client_id
  PUSH_TEMPLATE_ID = 'xxx', // 推送服务通知模板ID，多个以,相隔
}

/**
 * 预约状态
 */
export enum AppointState {
  NEW = 10,
  FINISH = 30,
  CANCEL = 40,
  OVER_TIME = 50,
}

/**
 * 团购订单的状态
 */
export enum GroupOrderStatus {
  AVAILABLE = 0,
  USE_UP = 1,
  REFUND = 2,
}

/**
 * 详情中富文本类型
 */
export enum IntroType {
  IMAGE = 'image',
  TEXT = 'text',
}

/**
 * 下单类型，团购/次卡
 */
export enum OrderType {
  SINGLE_CARD = 'single_card',
  GROUP = 'group',
}

// 手机号正则
export const PHONE_REG = /^[1][3,4,5,6,7,8,9][0-9]{9}$/;