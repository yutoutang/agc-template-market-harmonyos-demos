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

// 跳转三级分类  传递的数据对象
@ObservedV2
class ThirdParam {
  @Trace list: string[]
  @Trace thirdItem: ThirdItemModel

  constructor(list: string[], thirdItem: ThirdItemModel) {
    this.list = list;
    this.thirdItem = thirdItem;
  }
}

// 跳转二级分类  传递的数据对象
@ObservedV2
class SecondParam {
  @Trace list: string[]
  @Trace secondItem: SecondItemModel

  constructor(list: string[], secondItem: SecondItemModel) {
    this.list = list;
    this.secondItem = secondItem;
  }
}

@ObservedV2
class ItemDetail {
  // 最后选择的返回对象 返回对象的标题
  @Trace title: string = ''
  // ID
  @Trace id: string = ''
}

@ObservedV2
class ThirdItemModel {
  // 三级分类对应的对象  ID
  @Trace id: string = ''
  // 标题
  @Trace title: string = ''
  // 包含的数组
  @Trace list: ItemDetail[] = []
}

@ObservedV2
class SecondItemModel {
  // 二级分类对应的对象  ID
  @Trace id: string = ''
  // 数组
  @Trace list: ThirdItemModel[] = []
  // 对象的标题
  @Trace title: string = ''
}

export { SecondItemModel, ThirdItemModel, ItemDetail, SecondParam, ThirdParam }