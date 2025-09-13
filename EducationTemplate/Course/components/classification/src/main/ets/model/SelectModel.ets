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

export class SelectRoleModel {
  id: string = '';
  title: string = ''; // 1级别标题
  list?: OneLevelTabContent[]
}

export class OneLevelTabContent {
  id: string = '';
  title: string = ''; // 2级标题
  list?: TwoLevelTabContent[]
}

export class TwoLevelTabContent {
  id: string = '';
  title: string = ''; // 2级标题
  list?: ThreeLevelTabContent[]
}

export class ThreeLevelTabContent {
  id: string = '';
  title: string = '';
  list?: RoleDetail[]
}

export class RoleDetail {
  id: string = '';
  title: string = '';
}