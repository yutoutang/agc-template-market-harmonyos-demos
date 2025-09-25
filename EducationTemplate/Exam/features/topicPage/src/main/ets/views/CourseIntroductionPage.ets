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

import { PreferenceUtil, PreferConstant, TopTabsBuilder } from 'commonlib'
import { RouterModule, RouterMap } from 'router_module';
import {
  PracticeDataSource,
  PRACTICE_LIST_DATA,
  PracticeMode,
  SUB_EXERCISES_DATA,
  SubjectExercises
} from '../viewModel/PracticeMode';
import { MyDataSource } from '../viewModel/CourseHomeModel'
import { QuestionsRouterModel, TopicItemType } from 'answer_questions';

@ComponentV2
export struct CourseIntroductionPage {
  private swiperController: SwiperController = new SwiperController();
  private data: MyDataSource = new MyDataSource([]);
  private listData: PracticeMode[] = PRACTICE_LIST_DATA;
  private dataSource: PracticeDataSource = new PracticeDataSource(this.listData);
  private subExercisesListData: SubjectExercises[] = SUB_EXERCISES_DATA;
  @Local currentIndex: number = 0;

  aboutToAppear(): void {
    let list: string[] = [];
    list.push('app.media.ic_questionDetail_banner')
    list.push('app.media.ic_questionDetail_banner')
    list.push('app.media.ic_questionDetail_banner')
    list.push('app.media.ic_questionDetail_banner')
    list.push('app.media.ic_questionDetail_banner')
    this.data = new MyDataSource(list);
  }

  build() {
    Column() {
      TopTabsBuilder({ showBackButton: true, bgColor: $r('sys.color.background_primary') })
        .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      Scroll() {
        Column() {
          // banner
          this.bannerBuilder()
          // 业务栏
          this.toolBuilder()
          // 练习模式/学习资料
          this.customTabBuilder()
        }
        .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12') })
        .layoutWeight(1)
        .backgroundColor($r('sys.color.background_secondary'))
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  bannerBuilder() {
    Swiper(this.swiperController) {
      LazyForEach(this.data, (item: string) => {
        Image($r(item)).width('100%').height(190)
          .interpolation(ImageInterpolation.High)
      }, (item: string, index: number) => item + index)
    }
    .cachedCount(2)
    .margin({ top: $r('app.float.vp_12') })
    .index(1)
    .autoPlay(true)
    .interval(3000)
    .loop(true)
    .duration(1000)
    .itemSpace(0)
    .indicator( // 设置圆点导航点样式
      new DotIndicator()
        .itemWidth($r('app.float.vp_8'))
        .itemHeight($r('app.float.vp_8'))
        .selectedItemWidth($r('app.float.vp_16'))
        .selectedItemHeight($r('app.float.vp_8'))
        .color($r('sys.color.comp_background_tertiary'))
        .selectedColor(Color.Blue)
        .maxDisplayCount(9))
    .curve(Curve.Linear)
  }

  // 业务选项
  @Builder
  toolBuilder() {
    Row({ space: 5 }) {
      Column() {
        Image($r('app.media.ic__practice_wrong_question'))
          .interpolation(ImageInterpolation.High)
          .objectFit(ImageFit.Fill)
          .width($r('app.float.QuestionModel_ICON_SIZE'))
          .height($r('app.float.QuestionModel_ICON_SIZE'))
          .clip(true)
          .backgroundColor(Color.Transparent)

        Text('我的错题')
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontSize($r('sys.float.Caption_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.icon_primary'))
          .margin($r('app.float.vp_5'))
      }
      .width($r('app.float.vp_64'))
      .height($r('app.float.vp_48'))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        RouterModule.push({ url: RouterMap.MY_WRONG_PAGE })
      })

      Column() {
        Image($r('app.media.ic_practice_star'))
          .interpolation(ImageInterpolation.High)
          .objectFit(ImageFit.Fill)
          .width($r('app.float.QuestionModel_ICON_SIZE'))
          .height($r('app.float.QuestionModel_ICON_SIZE'))
          .clip(true)
          .backgroundColor(Color.Transparent)
        Text('练习收藏')
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontSize($r('sys.float.Caption_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.icon_primary'))
          .margin($r('app.float.vp_5'))
      }
      .width($r('app.float.vp_64'))
      .height($r('app.float.vp_48'))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ left: $r('app.float.vp_44'), right: $r('app.float.vp_44') })
      .onClick(() => {
        RouterModule.push({ url: RouterMap.MY_COLLECTION_PAGE })
      })

      Column() {
        Image($r('app.media.ic_practice_notes'))
          .interpolation(ImageInterpolation.High)
          .objectFit(ImageFit.Fill)
          .width($r('app.float.QuestionModel_ICON_SIZE'))
          .height($r('app.float.QuestionModel_ICON_SIZE'))
          .clip(true)
          .backgroundColor(Color.Transparent)
        Text('我的笔记')
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontSize($r('sys.float.Caption_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.icon_primary'))
          .margin($r('app.float.vp_5'))
      }
      .width($r('app.float.vp_64'))
      .height($r('app.float.vp_48'))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        RouterModule.push({ url: RouterMap.MY_NOTE_PAGE });
      })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height($r('app.float.vp_72'))
    .borderRadius($r('app.float.vp_16'))
    .margin({ top: $r('app.float.vp_10') })
    .backgroundColor(Color.White)
  }

  // 练习tab
  @Builder
  PracticeBuilder() {
    Column() {
      Grid() {
        LazyForEach(this.dataSource, (item: PracticeMode) => {
          GridItem() {
            ReusableFlowItem({ item: item })
          }
          .width('100%')
          .height($r('app.float.vp_40'))
          .backgroundColor(Color.White)
          .onClick(() => {
            if (item.name === '每日一练') {
              RouterModule.push({ url: RouterMap.ANSWER_QUESTIONS_PAGE });
            } else if (item.name === '模拟考试') {
              RouterModule.push({ url: RouterMap.Mock_PAGE, param: 1 });
            } else if (item.name === '全真试卷') {
              RouterModule.push({ url: RouterMap.Mock_PAGE, param: 2 });
            } else {
              // 错题练习
              this.myWrongPracticeEvent()
            }
          })
        }, (item: PracticeMode, index: number) => item.name + index)
      }
      .cachedCount(2)
      .columnsTemplate('1fr 1fr')
      .columnsGap($r('app.float.vp_8'))
      .rowsGap($r('app.float.vp_8'))
      .width('100%')
      .height($r('app.float.vp_112'))
      .borderRadius($r('app.float.vp_16'))
      .padding($r('app.float.vp_12'))
      .backgroundColor($r('sys.color.background_primary'))

      Text('练习模式')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin($r('app.float.vp_12'))
      List({ space: 8 }) {
        ForEach(this.subExercisesListData, (subjectItem: SubjectExercises) => {
          ListItem() {
            SubjectItem({ subjectItem: subjectItem })
          }
          .onClick(() => {
            RouterModule.push({ url: RouterMap.ANSWER_QUESTIONS_PAGE });
          })
        }, (item: SubjectExercises, index: number) => item.name + index)
      }
      .width('100%')
      .height(this.subExercisesListData.length * 82)
      .layoutWeight(1)
      .margin({ bottom: $r('app.float.vp_8') })
      .scrollBar(BarState.Off)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })

      Blank()
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .layoutWeight(1)
  }

  // 学习资料
  @Builder
  studyMaterialsBuilder() {
    Column() {
      List({ space: 8 }) {
        ForEach(this.subExercisesListData, (subItem: SubjectExercises) => {
          ListItem() {
            InfoItem({ subjectItem: subItem })
          }
        }, (item: SubjectExercises, index: number) => item.name + index)
      }
      .height('auto')
      .width('auto')
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .margin({ bottom: $r('app.float.vp_8') })
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })

      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Row() {
          Text('更多资料')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.Start)
            .margin({ right: $r('app.float.vp_8') })
          Image($r('app.media.icon_right'))
            .width($r('app.float.vp_8'))
            .height($r('app.float.vp_10'))
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
      .width($r('app.float.vp_92'))
      .height($r('app.float.vp_28'))
      .stateEffect(false)
      .borderRadius($r('app.float.vp_14'))
      .margin({ top: $r('app.float.vp_16'), bottom: $r('app.float.vp_16') })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        RouterModule.push({ url: RouterMap.MATERIAL_DOWNLOAD_PAGE });
      })

      Blank()
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
  }

  @Builder
  TabBuilder(index: number, name: string) {
    Row() {
      Row() {
        Text(name)
          .fontSize($r('sys.float.Body_M'))
          .fontColor(this.currentIndex === index ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Medium)
          .id(index.toString())
      }
      .justifyContent(FlexAlign.Center)
      .width($r('app.float.vp_165'))
      .height('100%')
      .borderRadius($r('app.float.vp_18'))
      .backgroundColor(this.currentIndex === index ? Color.White : $r('sys.color.comp_background_tertiary'))
    }
    .width('100%')
    .height($r('app.float.vp_36'))
    .borderRadius($r('app.float.vp_18'))
  }

  // Tab
  @Builder
  customTabBuilder() {
    Row() {
      Row() {
        Text('练习模式')
          .fontSize($r('sys.float.Body_M'))
          .fontColor(this.currentIndex === 0 ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Medium)
      }
      .width($r('app.float.vp_165'))
      .height($r('app.float.vp_40'))
      .borderRadius($r('app.float.vp_20'))
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(this.currentIndex === 0 ? Color.White : Color.Transparent)
      .onClick(() => {
        this.currentIndex = 0
      })

      Row() {
        Text('学习资料')
          .fontSize($r('sys.float.Body_M'))
          .fontColor(this.currentIndex === 1 ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Medium)
      }
      .width($r('app.float.vp_165'))
      .height($r('app.float.vp_40'))
      .borderRadius($r('app.float.vp_20'))
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(this.currentIndex === 1 ? Color.White : Color.Transparent)
      .onClick(() => {
        this.currentIndex = 1
      })
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .width('100%')
    .height($r('app.float.vp_40'))
    .borderRadius($r('app.float.vp_20'))
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: $r('app.float.vp_12'), bottom: $r('app.float.vp_12') })

    if (this.currentIndex === 0) {
      // 练习模式
      this.PracticeBuilder()
    } else {
      // 学习资料
      this.studyMaterialsBuilder()
    }
  }

  // 错题练习点击事件
  myWrongPracticeEvent() {
    let arr: TopicItemType[] =
      PreferenceUtil.getInstance().get(PreferConstant.ERROR_RECORDS, []) as TopicItemType[];
    if (arr.length <= 0) {
      this.getUIContext().getPromptAction().showToast({ message: '无错题数据' })
      return
    }
    arr.sort((a, b) => b.jlStamp - a.jlStamp)
    let routerModel: QuestionsRouterModel = new QuestionsRouterModel()
    routerModel.sourceType = '错题练习'
    routerModel.datalist = arr
    RouterModule.push({ url: RouterMap.ANSWER_QUESTIONS_PAGE, param: routerModel })
  }
}

@ComponentV2
struct ReusableFlowItem {
  @Param item: PracticeMode = new PracticeMode($r('app.media.ic_home'), '顺序练习', '1、3256')

  build() {
    Row() {
      Column() {
        Text(this.item.name)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
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
      Image(this.item.imageSrc)
        .interpolation(ImageInterpolation.High)
        .objectFit(ImageFit.Fill)
        .width($r('app.float.QuestionModel_ICON_SIZE'))
        .height($r('app.float.QuestionModel_ICON_SIZE'))
        .clip(true)
        .margin({ left: $r('app.float.vp_5'), right: $r('app.float.vp_5') })
    }
    .backgroundColor('#F1F3F5')
    .justifyContent(FlexAlign.SpaceBetween)
    .height($r('app.float.vp_40'))
    .width('100%')
    .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_15') })
    .borderRadius($r('app.float.vp_12'))
  }
}

@ComponentV2
struct SubjectItem {
  @Param subjectItem: SubjectExercises = new SubjectExercises($r('app.media.ic_home'), '建筑工程经济', 0, 0)

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.subjectItem.name)
            .fontSize($r('sys.float.Subtitle_S'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
          Text() {
            Span('进度 ')
              .fontSize($r('sys.float.Body_S'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
            Span(`${this.subjectItem.progress}`)
              .fontSize($r('sys.float.Body_S'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.multi_color_09'))
            Span(`/${this.subjectItem.total}`)
              .fontSize($r('sys.float.Body_S'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
          }
          .textAlign(TextAlign.Start)
          .margin({ top: $r('app.float.vp_13'), bottom: $r('app.float.vp_10') })

          Row() {
            Progress({ value: this.subjectItem.progress, total: this.subjectItem.total, type: ProgressType.Linear })
              .color($r('sys.color.multi_color_09'))
              .value(this.subjectItem.progress)
              .width('100%')
              .height($r('app.float.vp_4'))
          }
          .width('100%')
          .height($r('app.float.vp_4'))
          .backgroundColor($r('sys.color.comp_background_secondary'))
          .borderRadius($r('app.float.vp_2'))
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Image($r('app.media.icon_right'))
          .width($r('app.float.vp_16'))
          .height($r('app.float.vp_16'))
          .margin({ left: $r('app.float.vp_24') })
      }
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height('100%')
    }
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height($r('app.float.vp_82'))
    .padding($r('app.float.vp_12'))
    .borderRadius($r('app.float.vp_16'))
  }
}

@ComponentV2
struct InfoItem {
  @Param subjectItem: SubjectExercises = new SubjectExercises($r('app.media.ic_home'), '建筑工程经济', 0, 0)

  build() {
    Column() {
      Row() {
        Image(this.subjectItem.imageSrc)
          .width($r('app.float.vp_48'))
          .height($r('app.float.vp_48'))
          .margin({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12') })
        Column() {
          Text('建筑工程经济')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
          Text('建筑工程经济')
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
      .height($r('app.float.vp_48'))

      Row() {
        Row() {
          Text('已有423人浏览')
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_tertiary'))
            .textAlign(TextAlign.Start)
        }
        .height($r('app.float.vp_32'))

        Blank()
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Row() {
            Image($r('app.media.ic_public_share_arrow'))
              .width($r('app.float.vp_16'))
              .height($r('app.float.vp_16'))
              .margin({ right: $r('app.float.vp_5') })

            Text('分享')
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.Start)
          }
          .width($r('app.float.vp_64'))
          .height($r('app.float.vp_28'))
          .borderRadius($r('app.float.vp_14'))
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            this.getUIContext().getPromptAction().showToast({ message: '暂不支持分享' })
          })
        }
        .stateEffect(false)
        .margin({ right: $r('app.float.vp_12') })
        .backgroundColor(Color.White)
        .borderRadius($r('app.float.vp_14'))
        .onClick(() => {
        })

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Row() {
            Image($r('app.media.ic_public_down'))
              .width($r('app.float.vp_16'))
              .height($r('app.float.vp_16'))
              .margin({ right: $r('app.float.vp_5') })
            Text('下载')
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.Start)
          }
          .width($r('app.float.vp_64'))
          .height($r('app.float.vp_28'))
          .borderRadius($r('app.float.vp_14'))
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
        }
        .stateEffect(false)
        .backgroundColor(Color.White)
        .borderRadius($r('app.float.vp_14'))
        .onClick(() => {
          RouterModule.push({ url: RouterMap.MATERIAL_DOWNLOAD_PAGE })
        })
      }
      .margin({ top: $r('app.float.vp_16') })
      .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12') })
      .width('100%')
      .height($r('app.float.vp_32'))
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .backgroundColor(Color.White)
    .width('100%')
    .height($r('app.float.vp_115'))
    .padding($r('app.float.vp_12'))
    .borderRadius($r('app.float.vp_16'))
  }
}

@Builder
export function CourseIntroductionBuilder() {
  CourseIntroductionPage()
}