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

import { emitter } from '@kit.BasicServicesKit';
import { PreferConstant, PreferenceUtil, RouterMap, RouterModule } from 'commonlib'
import { CourseCatalogModel, CourseModel } from 'http';
import { Practice } from '../models/Practice'

@ComponentV2
export struct MaterialPage {
  @Local courseDetail: CourseModel = new CourseModel()
  // 是否为课程
  @Local selectIndex: number = 0
  @Local practices: Practice[] = [
    new Practice($r('app.media.ic_sequence'), '每日一练', '1/3256'),
    new Practice($r('app.media.ic_practice_simulations'), '模拟考试', '仿真模拟'),
  ]

  @Builder
  topBuilder() {
    Row() {
      Image($r('app.media.chevron_backward'))
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .margin({ left: $r('app.float.vp_16') })
        .onClick(() => {
          let eventData: emitter.EventData = {
            data: { isPlaying: true }
          }
          emitter.emit('playerPause', eventData)
          RouterModule.pop()
        })
    }
    .backgroundColor(Color.White)
    .width('100%')
    .height($r('app.float.vp_56'))
  }

  @Builder
  tabsBuilder() {
    Row() {
      Row() {
        Text('习题测试')
          .width('50%')
          .height('100%')
          .textAlign(TextAlign.Center)
          .backgroundColor(this.selectIndex === 0 ? $r('sys.color.background_primary') : '')
          .borderRadius(this.selectIndex === 0 ? 20 : 0)
          .shadow({
            radius: this.selectIndex === 0 ? 10 : 0,
            color: 'rgba(0, 0, 0, 0.2)',
          })
          .fontColor(this.selectIndex === 0 ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.selectIndex = 0
          })
        Text('资料下载')
          .width('50%')
          .height('100%')
          .textAlign(TextAlign.Center)
          .backgroundColor(this.selectIndex === 0 ? '' : $r('sys.color.background_primary'))
          .borderRadius(this.selectIndex === 0 ? 0 : 20)
          .shadow({
            radius: this.selectIndex === 0 ? 0 : 10,
            color: 'rgba(0, 0, 0, 0.2)',
          })
          .fontColor(this.selectIndex === 0 ? $r('sys.color.font_secondary') : $r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.selectIndex = 1
          })
      }
      .height($r('app.float.vp_40'))
      .width('100%')
      .borderRadius(20)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding($r('app.float.vp_16'))
  }

  @Builder
  listBuilder() {
    Scroll() {
      Column() {
        if (this.selectIndex === 0) {
          this.exercisesListBuilder()
        } else {
          this.downloadListBuilder()
        }
      }
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  exercisesListBuilder() {
    Column() {
      this.practiceModeBuilder()
      Text('课程目录')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ top: $r('app.float.vp_12'), bottom: $r('app.float.vp_12') })
      ForEach(this.courseDetail.courseCatalog, (item: CourseCatalogModel, idx: number) => {
        this.coursePracticeBuilder(item, idx)
      }, (item: CourseCatalogModel, index: number) => item.catalogTitle + index)
    }
    .width('100%')
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16')
    })
  }

  @Builder
  coursePracticeBuilder(item: CourseCatalogModel, idx: number) {
    Column() {
      Row() {
        Row() {
          Text(idx < 10 ? '0' + (idx + 1) : idx + '')
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ right: $r('app.float.vp_8') })
          Text(item.catalogTitle)
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
          Blank()
            .layoutWeight(1)
          Image($r('app.media.icon_right'))
            .width($r('app.float.vp_16'))
            .height($r('app.float.vp_16'))
            .margin({ left: $r('app.float.vp_5') })
        }
        .onClick(() => {
        })
      }
      .margin({ bottom: $r('app.float.vp_11') })

      Row() {
        Text('练习进度')
          .margin({ right: 8 })
          .fontSize($r('sys.float.Body_S'))
        Text() {
          Span(item.learnProgress + '')
            .fontColor($r('sys.color.multi_color_09'))
          Span(' / ' + '100')
        }
        .fontSize($r('sys.float.Body_S'))
      }
      .width('100%')
      .margin({ bottom: $r('app.float.vp_10') })

      Row() {
        Progress({ value: item.learnProgress, total: 100, type: ProgressType.Linear })
          .color($r('sys.color.multi_color_09'))
          .value(item.learnProgress)
          .width($r('app.float.vp_265'))
      }
      .width('100%')
    }
    .borderRadius($r('app.float.vp_16'))
    .height($r('app.float.vp_88'))
    .width('100%')
    .padding({
      top: $r('app.float.vp_12'),
      bottom: $r('app.float.vp_10'),
      left: $r('app.float.vp_12'),
      right: $r('app.float.vp_12')
    })
    .backgroundColor($r('sys.color.background_primary'))
    .margin({ bottom: $r('app.float.vp_8') })
    .onClick(() => {
      RouterModule.push({
        url: RouterMap.ANSWER_QUESTIONS_PAGE,
        param: this.courseDetail.courseTitle + '/' + item.catalogTitle
      });
    })
  }

  @Builder
  practiceModeBuilder() {
    Grid() {
      ForEach(this.practices, (practiceItem: Practice) => {
        GridItem() {
          CatalogItem({ item: practiceItem })
        }
        .width('100%')
        .height($r('app.float.vp_56'))
        .borderRadius($r('app.float.vp_12'))
        .backgroundColor(Color.White)
        .onClick(() => {
          if (practiceItem.name === '每日一练') {
            RouterModule.push({ url: RouterMap.ANSWER_QUESTIONS_PAGE, param: '每日一练' });
          } else {
            RouterModule.push({ url: RouterMap.ANSWER_QUESTIONS_EXAM_PAGE });
          }
        })
      }, (practiceItem: Practice, index: number) => practiceItem.name + index)
    }
    .cachedCount(2)
    .columnsTemplate('1fr 1fr')
    .columnsGap($r('app.float.vp_24'))
    .rowsGap($r('app.float.vp_8'))
    .height($r('app.float.vp_56'))
    .width('100%')
    .margin({ top: $r('app.float.vp_12') })
  }

  @Builder
  downloadListBuilder() {
    Column() {
      List({ space: 8 }) {
        ForEach([1], () => {
          ListItem() {
            InfoItem()
          }
        }, (item: number, index: number) => item + index + '')
      }
      .padding($r('app.float.vp_16'))
      .height('auto')
      .width('auto')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .layoutWeight(1)
      .margin({ bottom: $r('app.float.vp_8') })
    }
    .padding({ top: $r('app.float.vp_12') })
    .backgroundColor($r('sys.color.background_secondary'))
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
  }

  aboutToAppear(): void {
    let courseModel = RouterModule.getNavParam({ url: RouterMap.MATERIAL_PAGE }) as CourseModel
    if (courseModel) {
      this.courseDetail = courseModel
      this.selectIndex = courseModel.selectItem
    }
  }

  build() {
    Column() {
      this.topBuilder()
      this.tabsBuilder()
      this.listBuilder()
    }
    .backgroundColor(Color.White)
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}

@ComponentV2
struct CatalogItem {
  @Param item: Practice = new Practice($r('app.media.ic_sequence'), '顺序练习', '1、3256')

  build() {
    Row() {
      Column() {
        Text(this.item.name)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_primary'))
        Text(this.item.describe)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontSize($r('sys.float.Caption_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: $r('app.float.vp_2') })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 存在对应的jpg文件才会显示图片
      Image(this.item.imageUri)
        .interpolation(ImageInterpolation.High)
        .objectFit(ImageFit.Fill)
        .width('32vp')
        .height('32vp')
        .clip(true)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12') })
    .height('100%')
    .width('100%')
  }
}

@ComponentV2
struct InfoItem {
  @Local isShowLoading: boolean = false
  @Local isDown: boolean = false

  aboutToAppear(): void {
    this.getLoadData()
  }

  getLoadData() {
    let downloadState = PreferenceUtil.getInstance().get(PreferConstant.DOWNLOAD_KEY, '0')
    if (downloadState === '1') {
      this.isDown = true
    } else {
      this.isDown = false
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_public_pdf_file_textured'))
          .width($r('app.float.vp_48'))
          .height($r('app.float.vp_48'))
          .margin({ right: $r('app.float.vp_12') })
        Column() {
          Text('一级建造师精华题库')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
          Text('三色速记手册')
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.Start)
            .margin({ top: $r('app.float.vp_2') })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')

      Row() {
        Text(`已有423人浏览`)
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Lighter)
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Start)
          .width('auto')
        Blank()
          .layoutWeight(1)
        Row() {
          Image($r('app.media.ic_public_down'))
            .width($r('app.float.vp_16'))
            .height($r('app.float.vp_16'))
            .margin({ right: $r('app.float.vp_2') })
            .visibility(this.isDown ? Visibility.None : Visibility.Visible)
          Text(this.isDown ? '查看' : '下载')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor(this.isDown ? $r('sys.color.font_secondary') : $r('sys.color.font_primary'))
            .visibility(this.isShowLoading ? Visibility.None : Visibility.Visible)
            .onClick(() => {
              if (this.isDown) {
                RouterModule.push({ url: RouterMap.LOOK_FILE_PAGE })
              } else {
                this.isShowLoading = true
                PreferenceUtil.getInstance().put(PreferConstant.DOWNLOAD_KEY, '1')
                setTimeout(() => {
                  this.isShowLoading = false
                  this.getLoadData()
                }, 2000)
              }
            })
          LoadingProgress()
            .width($r('app.float.vp_24'))
            .height($r('app.float.vp_24'))
            .visibility(this.isShowLoading ? Visibility.Visible : Visibility.None)
        }
        .width($r('app.float.vp_64'))
        .height($r('app.float.vp_28'))
        .borderRadius($r('app.float.vp_14'))
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .margin({ top: $r('app.float.vp_16') })
    }
    .backgroundColor(Color.White)
    .width('100%')
    .height($r('app.float.vp_116'))
    .padding($r('app.float.vp_12'))
    .borderRadius($r('app.float.vp_16'))
    .justifyContent(FlexAlign.Center)
  }
}

@Builder
export function MaterialPageBuilder() {
  MaterialPage();
}