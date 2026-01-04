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

export interface SecondData {
  list: Array<string>
  data: SecondContent[]
}

export interface SecondContent {
  title: string
  data: Array<string>
}

export interface ThirdData {
  list: Array<string>
  data: Array<string>
}

// 数据中心
@ObservedV2
export class Sample {
  @Trace id: string = '1111';
  @Trace title: string = '一级建筑师';
}
