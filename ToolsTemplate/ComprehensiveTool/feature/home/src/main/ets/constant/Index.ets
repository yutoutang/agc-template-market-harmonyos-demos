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

import { ToolTypeModule } from '../model/Index';
import { Category, ToolType } from './Enum';

export const TOOL_TYPE_MODULES: ToolTypeModule[] = [
  {
    id: ToolType.ALL,
    category: Category.ALL,
    title: '全部',
    icon: $r('app.media.almanac'),
    url: '',
  },
  {
    id: ToolType.ALMANAC,
    category: Category.LIFE,
    title: '黄历',
    icon: $r('app.media.almanac'),
    url: 'AlmanacView',
  },
  {
    id: ToolType.CALCULATOR,
    title: '计算器',
    category: Category.CALCULATE,
    icon: $r('app.media.calculator'),
    url: 'HomePage',
  },
  {
    id: ToolType.SCIENCE_CALCULATOR,
    title: '科学计算器',
    category: Category.CALCULATE,
    icon: $r('app.media.calculator'),
    url: 'ScienceCalcHomePage',
  },
  {
    id: ToolType.DATE_CALCULATOR,
    title: '日期计算',
    category: Category.CALCULATE,
    icon: $r('app.media.date'),
    url: 'DateCalculatorPage',
  },
  {
    id: ToolType.EXCHANGE_RATE,
    title: '汇率计算',
    category: Category.CALCULATE,
    icon: $r('app.media.exchange'),
    url: 'ExchangeRateCalculatorPage',
  },
  {
    id: ToolType.CALORIES,
    title: '热量计算',
    category: Category.LIFE,
    icon: $r('app.media.calories'),
    url: 'CaloriesPage',
  },
  {
    id: ToolType.PERSONAL_INCOME_TAX_CALCULATOR,
    title: '个税计算器',
    category: Category.CALCULATE,
    icon: $r('app.media.income'),
    url: 'IncomePage',
  },
  {
    id: ToolType.REMOTE_CONTROLLER,
    title: '万能空调遥控器',
    category: Category.LIFE,
    icon: $r('app.media.remote'),
    url: 'RemotePage',
  },
  {
    id: ToolType.MORTGAGE_CALCULATOR,
    title: '房贷计算器',
    category: Category.CALCULATE,
    icon: $r('app.media.mortgage'),
    url: 'MortgageCalculationHome',
  },
  {
    id: ToolType.PERSONAL_NOTES,
    title: '隐私笔记',
    category: Category.LIFE,
    icon: $r('app.media.privacy_notes'),
    url: 'PersonalNotesPage',
  },
  {
    id: ToolType.MONEY_TRACK,
    title: '记账',
    category: Category.LIFE,
    icon: $r('app.media.money_track'),
    url: 'MoneyTrackPage',
  },
  {
    id: ToolType.DECOMPRESSION_TOOL,
    title: '敲木鱼',
    category: Category.LIFE,
    icon: $r('app.media.muyu'),
    url: 'DecompressionToolPage',
  },
  {
    id: ToolType.PICTURE_WATERMARK,
    title: '图片水印',
    category: Category.LIFE,
    icon: $r('app.media.watermark'),
    url: 'WaterMarksShow',
  },
  {
    id: ToolType.CALENDAR_EVENT,
    title: '倒计日',
    category: Category.LIFE,
    icon: $r('app.media.agenda'),
    url: 'CalendarEvent',
  },
  {
    id: ToolType.MOBILE_NFC,
    title: '手机NFC',
    category: Category.LIFE,
    icon: $r('app.media.nfc'),
    url: 'NfcHome',
  },
];
