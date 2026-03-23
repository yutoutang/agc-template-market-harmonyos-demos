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

import { AppStorageV2 } from '@kit.ArkUI';
import {
  PreferenceUtil,
  PreferConstant,
  TopTabsBuilder,
  GlobalContextUtils,
  Banner,
  BreakpointType
} from 'commonlib';
import { PracticeDataSource, PRACTICE_LIST_DATA, PracticeView } from '../model/PracticeMode';
import { CourseQuestions } from '../model/CourseQuestions';
import { RouterMap, RouterModule } from 'commonlib';
import { Sample } from '../model/Course';
import { QuestionsRouterModel } from 'answer_questions';
import { TopicItemType } from 'answer_questions';
import { UserInfo } from 'login_info';
import { HomeVM } from '../viewmodels/HomeVM';

@ComponentV2
export struct HomePage {
  homeVM: HomeVM = HomeVM.instance;
  private listData: PracticeView[] = PRACTICE_LIST_DATA;
  private dataSource: PracticeDataSource = new PracticeDataSource(this.listData);
  // 核心功能图标数组
  @Local functions: CourseCoreBar[] = [new CourseCoreBar($r('app.media.ic_practice_camera'), '搜题'),
    new CourseCoreBar($r('app.media.ic__practice_wrong_question')
      , '错题'), new CourseCoreBar($r('app.media.ic_practice_star'), '收藏'),
    new CourseCoreBar($r('app.media.ic_practice_notes'), '笔记')];
  // 核心功能图标数组
  @Local coursePractice: CourseQuestions[] =
    [new CourseQuestions('建筑工程经济', 120, 300), new CourseQuestions('建筑工程项目管理', 1024, 3411),
      new CourseQuestions('建筑工程项目管理', 1024, 3411)];
  // 在AppStorageV2中创建一个key为Sample的键值对（如果存在，则返回AppStorageV2中的数据），并且和prop关联
  @Local prop: Sample = AppStorageV2.connect(Sample, () => new Sample())!;
  @Local logoUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;

  aboutToAppear(): void {
    // 获取存储在AppStorageV2中创建一个key为Sample的数据）
    this.prop = AppStorageV2.connect(Sample, 'Sample', () => new Sample())!;
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column }) {
        TopTabsBuilder({ title: '练习', type: this.prop.title });
        Scroll() {
          Column({ space: 10 }) {
            // 轮播图
            this.swiperBuilder();
            // 功能栏
            this.functionBarBuilder();
            Column() {
              // 练习模式
              this.practiceModeBuilder();
              // 科目练习
              this.subjectPracticeBuilder();
            }
            .margin({ bottom: $r('app.float.vp_12') });

            Blank()
              .layoutWeight(1);
          }
          .justifyContent(FlexAlign.Center);
        }
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1);
      };
    }
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('sys.color.background_secondary'))
    .width('100%')
    .height('100%');
  }

  /**
   * 科目练习
   */
  @Builder
  subjectPracticeBuilder() {
    Text('科目练习')
      .fontSize($r('sys.float.Subtitle_L'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))
      .width('100%')
      .textAlign(TextAlign.Start)
      .margin($r('app.float.vp_12'));

    if (!this.logoUser.isLogin) {
      Column() {
        Column() {
          Image($r('app.media.ic_noLogin'))
            .interpolation(ImageInterpolation.High)
            .objectFit(ImageFit.Fill)
            .width($r('app.float.vp_120'))
            .height($r('app.float.vp_120'))
            .clip(true);
          Text('登录后享受更多服务')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_tertiary'))
            .fontWeight(FontWeight.Regular);
        }
        .margin($r('app.float.vp_16'));
      }
      .width('100%')
      .justifyContent(FlexAlign.Center);
    } else {
      Grid() {
        ForEach(this.coursePractice, (item: CourseQuestions) => {
          GridItem() {
            CoursePracticeBuilder(item);
          };
        }, (item: CourseQuestions, index: number) => item.courseName + index);
      }
      .columnsTemplate('1fr '.repeat(new BreakpointType<number>({
        sm: 1,
        md: 2,
        lg: 3,
        xl: 3
      }).getValue(this.homeVM.breakPointModel.currentBreakpoint)))
      .columnsGap($r('app.float.vp_6'))
      .rowsGap($r('app.float.vp_6'))
      .borderRadius($r('app.float.vp_16'));
    }
  }

  /**
   * 练习模式
   */
  @Builder
  practiceModeBuilder() {
    Text('练习模式')
      .fontSize($r('sys.float.Subtitle_L'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))
      .width('100%')
      .textAlign(TextAlign.Start)
      .margin({ bottom: $r('app.float.vp_12') });
    Grid() {
      LazyForEach(this.dataSource, (practiceItem: PracticeView) => {
        GridItem() {
          ReusableFlowItem({ item: practiceItem });
        }
        .onClick(() => {
          if (!this.logoUser.isLogin) {
            RouterModule.push({ url: RouterMap.LOGIN_PAGE, param: false });
            return;
          }
          if (practiceItem.name === '每日一练') {
            RouterModule.push({ url: RouterMap.ANSWER_QUESTIONS_PAGE });
          } else if (practiceItem.name === '模拟考试') {
            RouterModule.push({ url: RouterMap.Mock_PAGE, param: 1 });
          } else if (practiceItem.name === '全真试卷') {
            RouterModule.push({ url: RouterMap.Mock_PAGE, param: 2 });
          } else {
            // 错题练习
            this.myWrongPracticeEvent();
          }
        });
      }, (practiceItem: PracticeView, index: number) => practiceItem.name + index);
    }
    .padding($r('app.float.vp_12'))
    .backgroundColor($r('sys.color.comp_background_primary'))
    .columnsTemplate('1fr '.repeat(new BreakpointType<number>({
      sm: 2,
      md: 4,
      lg: 4,
      xl: 4
    }).getValue(this.homeVM.breakPointModel.currentBreakpoint)))
    .columnsGap($r('app.float.vp_6'))
    .rowsGap($r('app.float.vp_6'))
    .borderRadius($r('app.float.vp_16'));
  }

  /**
   * 功能栏
   */
  @Builder
  functionBarBuilder() {
    Row({ space: 8 }) {
      ForEach(this.functions, (item: CourseCoreBar) => {
        CourseCoreBuilder(item);
      }, (item: CourseCoreBar, index: number) => item.description + index);
    }
    .height($r('app.float.vp_72'))
    .width('100%')
    .borderRadius($r('app.float.vp_16'))
    .backgroundColor($r('sys.color.comp_background_primary'))
    .justifyContent(FlexAlign.SpaceAround);
  }

  /**
   * 轮播图
   */
  @Builder
  swiperBuilder() {
    Banner();
  }

  // 错题练习点击事件
  myWrongPracticeEvent() {
    let arr: TopicItemType[] =
      PreferenceUtil.getInstance().get(PreferConstant.ERROR_RECORDS, []) as TopicItemType[];
    if (arr.length <= 0) {
      GlobalContextUtils.showToast({ message: '无错题数据' });
      return;
    }
    arr.sort((a, b) => b.jlStamp - a.jlStamp);
    let routerModel: QuestionsRouterModel = new QuestionsRouterModel();
    routerModel.sourceType = '错题练习';
    routerModel.datalist = arr;
    RouterModule.push({ url: RouterMap.ANSWER_QUESTIONS_PAGE, param: routerModel });
  }
}

@ComponentV2
struct ReusableFlowItem {
  @Param item: PracticeView = new PracticeView($r('app.media.ic_home'), '顺序练习', '1、3256');

  build() {
    Row() {
      Column() {
        Text(this.item.name)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_primary'));
        Text(this.item.describe)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontSize($r('sys.float.Caption_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: $r('app.float.vp_2') });
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1);

      // 存在对应的jpg文件才会显示图片
      Image(this.item.imageUri)
        .interpolation(ImageInterpolation.High)
        .objectFit(ImageFit.Fill)
        .width('32vp')
        .height('32vp')
        .clip(true)
        .margin({ left: $r('app.float.vp_4'), right: $r('app.float.vp_4') });
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .justifyContent(FlexAlign.SpaceBetween)
    .height($r('app.float.vp_56'))
    .width('100%')
    .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_16') })
    .borderRadius($r('app.float.vp_12'));
  }
}

@Builder
export function HomePageBuilder() {
  HomePage();
}

// 核心功能组件builder
@Builder
export function CourseCoreBuilder(mainFunctionItem: CourseCoreBar) {
  Column() {
    Image(mainFunctionItem.showIcon)
      .height($r('app.float.vp_24'))
      .width($r('app.float.vp_24'))
      .margin({ bottom: $r('app.float.vp_2') });
    Text(mainFunctionItem.description)
      .fontSize($r('sys.float.Caption_M'));
  }
  .width(64)
  .height(48)
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
  .onClick(() => {
    let userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
    if (!userInfo.isLogin) {
      RouterModule.push({ url: RouterMap.LOGIN_PAGE, param: false });
      return;
    }
    if (mainFunctionItem.description === '搜题') {
      RouterModule.push({ url: RouterMap.SEARCH_INPUT_PAGE });
    } else if (mainFunctionItem.description === '笔记') {
      RouterModule.push({ url: RouterMap.MY_NOTE_PAGE });
    } else if (mainFunctionItem.description === '错题') {
      RouterModule.push({ url: RouterMap.MY_WRONG_PAGE });
    } else if (mainFunctionItem.description === '收藏') {
      RouterModule.push({ url: RouterMap.MY_COLLECTION_PAGE });
    }
  });
}

// 封装核心功能class
@ObservedV2
export class CourseCoreBar {
  @Trace showIcon: ResourceStr = '';
  @Trace description: string = '';

  constructor(showIcon: ResourceStr, description: string) {
    this.showIcon = showIcon;
    this.description = description;
  }
}

// 核心功能组件builder
@Builder
export function CoursePracticeBuilder(questions: CourseQuestions) {
  Column() {
    Row() {
      Row() {
        Text(questions.courseName)
          .fontSize($r('sys.float.Subtitle_S'))
          .fontWeight(FontWeight.Medium);
      };

      Row() {
        Text('章节练习')
          .fontSize($r('sys.float.Caption_L'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'));
        Image($r('app.media.icon_right'))
          .width($r('app.float.vp_16'))
          .height($r('app.float.vp_16'))
          .margin({ left: $r('app.float.vp_5') });
      }.layoutWeight(1)
      .justifyContent(FlexAlign.End)
      .onClick(() => {
        // 跳转章节练习页面
        RouterModule.push({ url: RouterMap.CHAPTER_PRACTICE_PAGE });
      });
    }
    .margin({ bottom: $r('app.float.vp_11') });

    Row() {
      Text('进度')
        .margin({ right: 8 })
        .fontSize($r('sys.float.Body_S'));
      Text() {
        Span(questions.completeNumber + '')
          .fontColor($r('sys.color.comp_background_emphasize'));
        Span(' / ' + questions.questionsNumber + '');
      }
      .fontSize($r('sys.float.Body_S'));
    }
    .width('100%')
    .margin({ bottom: $r('app.float.vp_10') });

    Row() {
      Progress({ value: questions.completeNumber, total: questions.questionsNumber, type: ProgressType.Linear })
        .color($r('sys.color.comp_background_emphasize'))
        .value(questions.completeNumber)
        .width($r('app.float.vp_266'));
    }
    .width('100%');
  }
  .borderRadius($r('app.float.vp_16'))
  .height($r('app.float.vp_82'))
  .width('100%')
  .padding({
    top: $r('app.float.vp_12'),
    bottom: $r('app.float.vp_10'),
    left: $r('app.float.vp_12'),
    right: $r('app.float.vp_12')
  })
  .backgroundColor($r('sys.color.background_primary'))
  .onClick(() => {
    RouterModule.push({ url: RouterMap.CHAPTER_PRACTICE_PAGE });
  });
}