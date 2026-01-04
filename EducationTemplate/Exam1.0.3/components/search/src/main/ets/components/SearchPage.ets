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

import { AppStorageV2, LengthMetrics } from '@kit.ArkUI'

@ComponentV2
export struct SearchPage {
  // 传入值
  @Param mockSearchValue: string = ''
  @Local searchValue: string = ''
  @Local enterTypes: Array<EnterKeyType> =
    [EnterKeyType.Go, EnterKeyType.Search, EnterKeyType.Send, EnterKeyType.Done, EnterKeyType.Next,
      EnterKeyType.PREVIOUS, EnterKeyType.NEW_LINE];
  @Local index: number = 0;
  // 模拟后端数据源
  @Param searchSourceData: string[] = []
  @Local searchData: string[] = []
  @Local historySearch: string[] = AppStorageV2.connect(HistoryClass, () => new HistoryClass())!.historySearch
  @Local tags: string = '题库'
  // 初始化拿参数
  @Event initParam: () => void = () => {
  }
  // 点击跳转
  @Event clickSearchItem: (data: string) => void = () => {
  }
  // 回退
  @Event back: () => void = () => {
  }

  //搜索功能匹配数据源
  searchText() {
    this.searchData = []
    this.searchValue = this.searchValue.replace(/^\s+|\s+$/g, '');
    this.searchSourceData.forEach((item) => {
      if (item.indexOf(this.searchValue) !== -1) {
        this.searchData.push(item)
      }
    })
    if (this.searchValue) {
      if (this.historySearch.length) {
        let repeatFlage = false
        this.historySearch.forEach((item) => {
          if (item === this.searchValue) {
            repeatFlage = true
          }
        })
        if (repeatFlage) {
          return
        } else {
          this.historySearch.push(this.searchValue)
        }

      } else {
        this.historySearch.push(this.searchValue)
      }
    }
  }

  aboutToAppear(): void {
    this.initParam()
    this.searchValue = this.mockSearchValue
    this.searchText()
  }

  build() {
    Column() {
      // 顶部搜索框
      this.topSearchBuilder()
      if (this.searchValue) {
        // 搜索结果
        this.searchResultBuilder()
      } else {
        // 未搜索状态
        this.notSearchBuilder()
      }
    }
    .padding({ left: '16vp', right: '16vp' })
    .width('100%')
    .height('100%')
  }

  // 未搜索状态
  @Builder
  notSearchBuilder() {
    Row() {
      Text('历史搜索')
      Row() {
        Image($r('app.media.ic_delete'))
          .height('19vp')
          .margin({ right: '2vp' })
        Text('清空')
      }.onClick(() => {
        this.historySearch = []
        AppStorageV2.connect(HistoryClass, () => new HistoryClass())!.historySearch = this.historySearch
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: '12vp', top: '24vp' })

    if (this.historySearch.length !== 0) {
      Flex({
        direction: FlexDirection.Row,
        wrap: FlexWrap.Wrap,
        justifyContent: FlexAlign.Start,
        space: { cross: new LengthMetrics(12), main: new LengthMetrics(10) }
      }) {
        ForEach(this.historySearch, (item: string) => {
          // 历史搜索需要请求后端
          Button(item)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_primary'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              this.searchValue = item
              this.searchText()
            })
        }, (item: string, index) => item + index)
      }
      .width('100%')
    }
  }

  // 搜索结果
  @Builder
  searchResultBuilder() {
    if (this.searchData.length) {
      // 搜索结果 ---有数据
      ForEach(this.searchData, (item: string) => {
        Row() {
          Image($r('app.media.ic_search_01'))
            .height('13vp')
            .width('13vp')
            .margin({ right: 16 })
          Column() {
            Text() {
              Span(item.substring(0, item.indexOf(this.searchValue)))
              // 红色高亮文字
              Span(this.searchValue).fontColor('#F17F31')
              Span(item.substring(item.indexOf(this.searchValue) + this.searchValue.length, item.length))
            }
            .onClick(() => {
              this.clickSearchItem(item)
            })
            .height('100%')
            .width('100%')

            Divider().width('00%')
          }
          .width('296vp')
        }.width('100%').height('48vp')
      }, (item: string, index: number) => item + index)
    } else {
      // 搜索结果 ---无数据
      Column() {
        Image($r('app.media.ic_no_data'))
          .margin({ bottom: 24 })
          .width(160)
          .height(160)
          .margin({ top: 197 })
        Text('未找到相关课程')
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Caption_L'))
      }
      .layoutWeight(1)
    }
  }

  // 顶部搜索框
  @Builder
  topSearchBuilder() {
    Row() {
      Image($r('app.media.ic_backward')).height('40vp').width('40vp').margin({ right: '8vp' })
        .onClick(() => {
          this.back()
        })
      // 搜索文本框
      Search({ placeholder: '搜索', value: this.searchValue })
        .layoutWeight(1)
        .height('40vp')
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .enterKeyType(this.enterTypes[this.index])
        .margin({ right: '8vp' })
        .onChange((value: string) => {
          if (value === '') {
            this.searchData = [];
            this.searchValue = value
          }
        })
        .onSubmit((value: string) => {
          this.searchValue = value.replace(/^\s+|\s+$/g, '');
          this.searchText()
        })
    }
    .backgroundColor($r('sys.color.background_primary'))
    .height(56)
    .width('100%')
  }
}

// 自定义checkbox
class MyCheckboxStyle implements ContentModifier<CheckBoxConfiguration> {
  selectedColor: string = '#ffffff'
  numbers: number = 999
  types: string = '题库'

  constructor(selectedColor: string, numbers: number, types: string) {
    this.selectedColor = selectedColor;
    this.numbers = numbers;
    this.types = types;
  }

  applyContent(): WrappedBuilder<[CheckBoxConfiguration]> {
    return wrapBuilder(buildCheckbox)
  }
}

@Builder
function buildCheckbox(config: CheckBoxConfiguration) {
  Row() {
    Text((config.contentModifier as MyCheckboxStyle).types)
      .fontColor(config.selected ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
      .fontSize($r('sys.float.Body_M'))
    Text('' + (config.contentModifier as MyCheckboxStyle).numbers)
      .fontColor(config.selected ? $r('sys.color.font_on_tertiary') : $r('sys.color.font_primary'))
      .fontSize($r('sys.float.Body_S'))
  }
  .onClick(() => {
    if (config.selected) {
      config.triggerChange(false)
    } else {
      config.triggerChange(true)
    }
  })
  .justifyContent(FlexAlign.Center)
  .borderRadius(20)
  .backgroundColor(config.selected ? '#4B5CC4' : $r('sys.color.comp_background_tertiary'))
  .height('40vp')
  .width('84vp')
}

@ObservedV2
export class HistoryClass {
  @Trace historySearch: string[] = []
}