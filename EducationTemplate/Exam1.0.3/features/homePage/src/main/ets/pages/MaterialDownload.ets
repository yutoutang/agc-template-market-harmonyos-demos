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

import { TopTabsBuilder } from 'commonlib'
import { CourseBookComponent } from '../components/CourseBookComponent'
import { CourseBook } from '../model/CourseBook'

@ComponentV2
export struct MaterialDownload {
  @Param courseBookArray: CourseBook[] = [new CourseBook('一级建造师精华题库', '三色速记手册', 423, 'pdf', 23),
    new CourseBook('二级建造师精华题库', '三色速记手册', 423, 'pdf', 23)]
  @Local materials: Material[] = []
  @Local downloadMaterials: string[] = []
  @Local downloading: boolean = false

  initMaterials() {
    this.courseBookArray.forEach((value: CourseBook) => {
      this.materials.push(new Material(value, false))
    })
  }

  aboutToAppear(): void {
    this.initMaterials()
  }

  build() {
    Column() {
      TopTabsBuilder({ title: '资料下载', bgColor: $r('sys.color.background_primary'), showBackButton: true })
        .margin({ bottom: '8vp' })
        .padding({ left: 16, right: 16 })
      // 待下载的资料列表
      this.courseListBuilder()
      // 下载按钮
      this.downloadButtonBuilder()
    }
    .width('100%')
    .height('100%')
  }

  // 下载按钮
  @Builder
  downloadButtonBuilder() {
    Row() {
      Image($r('app.media.ic_public_download'))
        .height('24vp')
        .width('24vp')
        .margin({ right: 8 })
      Text(this.downloading ? '正在下载' : '下载')
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_on_primary'))
    }
    .justifyContent(FlexAlign.Center)
    .height('40vp')
    .width('312vp')
    .backgroundColor('#4B5CC4')
    .borderRadius('20vp')
    .opacity(this.downloadMaterials.length !== 0 ? 1 : 0.6)
    .onClick(() => {
      // 表示处理下载逻辑
      if (this.downloadMaterials.length !== 0 && !this.downloading) {
        this.downloading = true
        let timer = setInterval(() => {
          this.getUIContext().getPromptAction().showToast({ message: '下载完成' })
          this.downloading = false
          clearInterval(timer)
        }, 3000)
      }
    })
  }

  // 待下载的资料列表
  @Builder
  courseListBuilder() {
    Column() {
      Scroll() {
        List() {
          ForEach(this.materials, (item: Material) => {
            ListItem() {
              Column() {
                Row() {
                  Column() {
                    CourseBookComponent({ courseBook: item.courseBook, pageType: 'MaterialDownload' })
                      .margin({ bottom: '5vp' })
                  }

                  Checkbox({ name: item.courseBook.bookName, group: 'MaterialGroup' })
                    .select(item.isSelected)
                    .selectedColor('#4B5CC4')
                    .shape(CheckBoxShape.CIRCLE)
                    .onChange((value: boolean) => {
                      if (value) {
                        this.downloadMaterials.push(item.courseBook.bookName)
                      } else {
                        this.downloadMaterials =
                          this.downloadMaterials.filter(name => name !== item.courseBook.bookName)
                      }
                    })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)

                Divider()
                  .width('100%')
              }
              .padding({ left: 28, right: 28 })
              .width('100%')
            }
          }, (item: CourseBook, index: number) => item.bookName + index)
        }
        .height('100%')
        .width('100%')
        .alignListItem(ListItemAlign.Center)
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
    }
    .padding({ top: '17vp' })
    .layoutWeight(1)
    .backgroundColor($r('sys.color.background_primary'))
    .width('100%')
  }
}

@Builder
export function MaterialDownloadBuilder() {
  MaterialDownload()
}

@ObservedV2
export class Material {
  @Trace courseBook: CourseBook
  @Trace isSelected: boolean

  constructor(courseBook: CourseBook, isSelected: boolean) {
    this.courseBook = courseBook
    this.isSelected = isSelected
  }
}

