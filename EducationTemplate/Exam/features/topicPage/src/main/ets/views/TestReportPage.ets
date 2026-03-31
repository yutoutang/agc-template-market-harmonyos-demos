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

import { util } from '@kit.ArkTS';
import dayjs from 'dayjs';
import { PreferenceUtil, Logger, PracticeModel, TopBar, RouterMap, RouterModule } from 'commonlib';
import { AnswerItem, TopicItemModel } from 'answer_questions';

export class TestReportModel {
  // 题库
  ques: TopicItemModel[] = [];
  // 1练习模式 2答题模式
  quesType: number = 1;
  // 练习时长(秒)
  practiceDuration: number = 0;
}

const TAG = 'TestReportPage';

@ComponentV2
export struct TestReportPage {
  // 已作答题目
  @Local resQues: TopicItemModel[] = [];
  // 1练习模式 2答题模式
  @Local quesType: number = 1;
  private ques: TopicItemModel[] = [];
  // 正确题数
  private rightCont: number = 0;
  // 错误题数
  private errCont: number = 0;
  // 正确率
  private accuracy: string = '0';
  textTimerController: TextTimerController = new TextTimerController();
  format: string = 'HH:mm:ss';
  practiceDuration: number = 0;
  timerCount: number = 0;

  aboutToAppear(): void {
    Logger.info(TAG, 'aboutToAppear');
    let temp: TestReportModel | undefined = RouterModule.getNavParam({ url: RouterMap.ANSWER_REPORT_PAGE });
    if (temp) {
      this.quesType = temp.quesType;
      // 报告
      if (temp.quesType === 1) {
        this.practiceDuration = temp.practiceDuration;
        this.timerCount = this.practiceDuration * 1000 + 1;
        this.ques = temp.ques;
        for (let index = 0; index < this.ques.length; index++) {
          let element = this.ques[index];
          this.resQues.push(element);
        }
        for (let index = 0; index < this.resQues.length; index++) {
          let element = this.resQues[index];
          if (element.selectQues.toString() === element.rightQues.toString()) {
            this.rightCont++;
          } else {
            this.errCont++;
          }
        }
        this.accuracy = (this.rightCont / this.ques.length * 100).toFixed(1);
        // 将练习记录存入持久层
        if (PreferenceUtil.getInstance()) {
          let practiceModel: PracticeModel = new PracticeModel();
          practiceModel.keyID = util.generateRandomUUID(true);
          practiceModel.date = dayjs().format('YYYY-MM-DD');
          practiceModel.subject = '建筑工程经济';
          practiceModel.practiceDuration = temp.practiceDuration;
          practiceModel.rightCount = this.rightCont;
          practiceModel.topicCount = this.ques.length;
          PreferenceUtil.getInstance().put(practiceModel.keyID, practiceModel);
        }
      } else {
        // 结果
        this.resQues = temp.ques;
      }
    }
  }

  build() {
    Column() {
      // 顶部
      this.topBuilder();
      //顶部图片
      this.topImageBuilder();
      // 练习数据
      this.testDataBuilder();
      // 分隔线
      Row()
        .width('100%')
        .height($r('app.float.vp_8'))
        .backgroundColor($r('sys.color.comp_background_tertiary'));
      // 题目列表
      this.topicListBuilder();
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('sys.color.comp_background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  /**
   * 题目列表
   */
  @Builder
  topicListBuilder() {
    List() {
      ForEach(this.resQues, (topicItemModel: TopicItemModel, index: number) => {
        ListItem() {
          Column() {
            Text(`${index + 1}、${topicItemModel.title}`)
              .width('100%')
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
              .margin({ bottom: $r('app.float.vp_15') });
            if (topicItemModel.showState === 1) {
              // 错误样式
              List() {
                ForEach(topicItemModel.ques,
                  (answerItem: AnswerItem) => {
                    ListItem() {
                      Row() {
                        Image(answerItem.showState === 1 ? $r('app.media.icon_wrong') :
                          (answerItem.showState === 2 ? $r('app.media.icon_true') : $r('app.media.icon_ans_common')))
                          .height($r('app.float.vp_20'))
                          .width($r('app.float.vp_20'));
                        Text(answerItem.ansTitle)
                          .fontSize($r('sys.float.Body_M'))
                          .fontColor($r('sys.color.font_primary'))
                          .padding({ left: $r('app.float.vp_8'), right: $r('app.float.vp_16') });
                      }.margin({ top: $r('app.float.vp_11') });
                    };
                  }, (item: AnswerItem, index: number) => item.ansID + index);
              }
              .width('auto')
              .height('auto')
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false });

              Column() {
                Row() {
                  Text('正确答案')
                    .fontSize($r('sys.float.Body_M'))
                    .fontColor($r('sys.color.icon_primary'));
                  Text(topicItemModel.rightQues.toString())
                    .fontColor($r('sys.color.multi_color_04'))
                    .fontSize($r('sys.float.Body_M'))
                    .width($r('app.float.vp_28'))
                    .height($r('app.float.vp_20'))
                    .textAlign(TextAlign.Center);
                };

                Row() {
                  Text('我的答案')
                    .fontSize($r('sys.float.Body_M'))
                    .fontColor($r('sys.color.icon_primary'));
                  Text(topicItemModel.selectQues.length > 0 ? topicItemModel.selectQues.toString() : '-')
                    .fontColor($r('sys.color.multi_color_08'))
                    .fontSize($r('sys.float.Body_M'))
                    .width($r('app.float.vp_28'))
                    .height($r('app.float.vp_20'))
                    .textAlign(TextAlign.Center);
                }
                .margin({ bottom: $r('app.float.vp_13') });

                // 分隔线
                Divider().opacity(0.2).strokeWidth(2);
                //解析
                Row() {
                  Text($r('app.string.parse'))
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.icon_primary'));
                }
                .width('100%')
                .margin({ top: $r('app.float.vp_8'), bottom: $r('app.float.vp_12') });

                Row() {
                  Text(`答案解析：${topicItemModel.parse}`)
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.icon_primary'));
                }
                .width('100%');
              }
              .width('100%')
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .borderRadius($r('app.float.vp_12'))
              .alignItems(HorizontalAlign.Start)
              .padding($r('app.float.vp_12'))
              .margin({ top: $r('app.float.vp_14'), bottom: $r('app.float.vp_26') });
            } else if (topicItemModel.showState === 0) {
              // 题目未答样式
              List() {
                ForEach(topicItemModel.ques, (answerItem: AnswerItem) => {
                  ListItem() {
                    Row() {
                      Image(topicItemModel.rightQues.includes(answerItem.ans) ? $r('app.media.icon_true') :
                        $r('app.media.icon_ans_common'))
                        .height($r('app.float.vp_20'))
                        .width($r('app.float.vp_20'));
                      Text(answerItem.ansTitle)
                        .fontSize($r('sys.float.Body_M'))
                        .fontColor($r('sys.color.font_primary'))
                        .padding({ left: $r('app.float.vp_8'), right: $r('app.float.vp_16') });
                    }.margin({ top: $r('app.float.vp_11') });
                  };
                }, (item: AnswerItem, index: number) => item.ansID + index);
              }
              .width('auto')
              .height('auto')
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false });

              Column() {
                Row() {
                  Text($r('app.string.correct_answer'))
                    .fontSize($r('sys.float.Body_M'))
                    .fontColor($r('sys.color.icon_primary'));
                  Text(topicItemModel.rightQues.toString())
                    .fontColor($r('sys.color.multi_color_04'))
                    .fontSize($r('sys.float.Body_M'))
                    .width($r('app.float.vp_28'))
                    .height($r('app.float.vp_20'))
                    .textAlign(TextAlign.Center);
                };

                Row() {
                  Text($r('app.string.my_answer'))
                    .fontSize($r('sys.float.Body_M'))
                    .fontColor($r('sys.color.icon_primary'));
                  Text(topicItemModel.selectQues.length > 0 ? topicItemModel.selectQues.toString() : '-')
                    .fontColor($r('sys.color.multi_color_08'))
                    .fontSize($r('sys.float.Body_M'))
                    .width($r('app.float.vp_28'))
                    .height($r('app.float.vp_20'))
                    .textAlign(TextAlign.Center);
                }
                .margin({ bottom: $r('app.float.vp_13') });

                // 分隔线
                Divider().color($r('sys.color.comp_background_tertiary')).strokeWidth(2);
                //解析
                Row() {
                  Text($r('app.string.parse'))
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.icon_primary'));
                }
                .width('100%')
                .margin({ top: $r('app.float.vp_8'), bottom: $r('app.float.vp_12') });

                Row() {
                  Text(`答案解析：${topicItemModel.parse}`)
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.icon_primary'));
                }
                .width('100%');
              }
              .width('100%')
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .borderRadius($r('app.float.vp_12'))
              .alignItems(HorizontalAlign.Start)
              .padding($r('app.float.vp_12'))
              .margin({ top: $r('app.float.vp_12'), bottom: $r('app.float.vp_35') });
            } else {
              // 题目答对样式
              List() {
                ForEach(topicItemModel.ques, (answerItem: AnswerItem) => {
                  ListItem() {
                    Row() {
                      Image(answerItem.showState === 1 ? $r('app.media.icon_wrong') :
                        (answerItem.showState === 2 ? $r('app.media.icon_true') : $r('app.media.icon_ans_common')))
                        .height($r('app.float.vp_20'))
                        .width($r('app.float.vp_20'));
                      Text(answerItem.ansTitle)
                        .fontSize($r('sys.float.Body_M'))
                        .fontColor($r('sys.color.font_primary'))
                        .padding({ left: $r('app.float.vp_8'), right: $r('app.float.vp_16') });
                    }.margin({ top: $r('app.float.vp_11') });
                  };
                }, (item: AnswerItem, index: number) => item.ansID + index);
              }
              .width('auto')
              .height('auto')
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false });

              Row() {
                Text($r('app.string.correct_answer'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor($r('sys.color.icon_primary'));
                Text(topicItemModel.selectQues.toString())
                  .fontColor($r('sys.color.multi_color_04'))
                  .fontSize($r('sys.float.Body_M'))
                  .width($r('app.float.vp_28'))
                  .height($r('app.float.vp_20'))
                  .textAlign(TextAlign.Center);
              }
              .width('100%')
              .height($r('app.float.vp_44'))
              .padding({ left: $r('app.float.vp_12') })
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .borderRadius($r('app.float.vp_12'))
              .margin({ top: $r('app.float.vp_12'), bottom: $r('app.float.vp_35') });
            }
          };
        };
      }, (item: TopicItemModel, index: number) => item.keyID + index);
    }
    .layoutWeight(1)
    .width('auto')
    .height('auto')
    .margin($r('app.float.vp_16'))
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true });
  }

  /**
   * 练习数据
   */
  @Builder
  testDataBuilder() {
    Row({ space: 40 }) {
      Column() {
        TextTimer({ isCountDown: true, count: this.timerCount, controller: this.textTimerController })
          .format(this.format)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'));
        Text($r('app.string.practice_duration'))
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'));
      }
      .justifyContent(FlexAlign.Center);

      Column() {
        Text(`${this.errCont}`)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.multi_color_08'));
        Text($r('app.string.error_answer_count'))
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'));
      }
      .justifyContent(FlexAlign.Center);

      Column() {
        Text(`${this.rightCont}`)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.multi_color_04'));
        Text($r('app.string.correct_answer_count'))
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'));
      }
      .justifyContent(FlexAlign.Center);

      Column() {
        Text(this.accuracy + '%')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'));
        Text($r('app.string.correct_rate'))
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'));
      }
      .justifyContent(FlexAlign.Center);
    }
    .width('100%')
    .height($r('app.float.vp_64'))
    .justifyContent(FlexAlign.SpaceAround)
    .visibility(this.quesType === 1 ? Visibility.Visible : Visibility.None);
  }

  /**
   * 顶部图片
   */
  @Builder
  topImageBuilder() {
    Row() {
      Text('建筑工程经济')
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'));
    }
    .width('100%')
    .height($r('app.float.vp_96'))
    .backgroundImage($r('app.media.image_top'))
    .backgroundImageSize(ImageSize.Cover)
    .justifyContent(FlexAlign.Center);
  }

  /**
   * 顶部
   */
  @Builder
  topBuilder() {
    Row() {
      // 查看报告
      TopBar({
        onClickBack: () => {
          RouterModule.pop();
        },
        title: this.quesType === 1 ? $r('app.string.view_report_btn') : $r('app.string.view_result')
      });
    }
    .width('100%')
    .height($r('app.float.vp_56'))
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .justifyContent(FlexAlign.SpaceBetween);
  }
}

@Builder
export function TestReportBuilder() {
  TestReportPage();
}