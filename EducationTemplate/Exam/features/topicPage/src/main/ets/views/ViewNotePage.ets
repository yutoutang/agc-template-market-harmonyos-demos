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

import {
  PreferenceUtil,
  PreferConstant,
  Logger,
  TopBar,
  GlobalContextUtils,
  RouterMap,
  RouterModule
} from 'commonlib';
import { AddNoteDialog, TopicItemModelPreference } from 'answer_questions';
import { AnswerItemPreference } from 'answer_questions';

const TAG = 'ViewNotePage';

@ComponentV2
export struct ViewNotePage {
  @Local topicItemModelPref: TopicItemModelPreference = new TopicItemModelPreference();
  @Local note: string = '';
  scroller: Scroller = new Scroller();
  @Local isShowNoteSheet: boolean = false;

  aboutToAppear(): void {
    Logger.info(TAG, 'aboutToAppear');
    this.topicItemModelPref = RouterModule.getNavParam({ url: RouterMap.View_NOTE_PAGE })!;
    this.note = this.topicItemModelPref.note;
  }

  build() {
    Column() {
      this.topBuilder();
      Divider().color($r('sys.color.comp_background_tertiary'));
      // 题目作答详情
      this.answerDetailsBuilder();
    };
  }

  /**
   * 题目作答详情
   */
  @Builder
  answerDetailsBuilder() {
    Scroll(this.scroller) {
      Column() {
        Column() {
          Row() {
            Text($r('app.string.single_choice'))
              .height($r('app.float.vp_28'))
              .width($r('app.float.vp_72'))
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_on_primary'))
              .textAlign(TextAlign.Center)
              .borderRadius(8)
              .backgroundColor($r('app.color.view_report_btn'));
          }
          .width('100%')
          .margin($r('app.float.vp_12'));

          Text(this.topicItemModelPref.title)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_primary'))
            .width('100%')
            .margin({ bottom: $r('app.float.vp_15') });
          Column({ space: 17 }) {
            ForEach(this.topicItemModelPref.ques, (item: AnswerItemPreference) => {
              Row() {
                Image(item.showState === 1 ? $r('app.media.icon_wrong') :
                  (item.showState === 2 ? $r('app.media.icon_true') : $r('app.media.icon_ans_common')))
                  .width($r('app.float.vp_20'))
                  .height($r('app.float.vp_20'));
                Text(`${item.ans}` + '：' + `${item.ansTitle}`)
                  .margin({ left: $r('app.float.vp_14') })
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor($r('sys.color.font_primary'));
              }
              .padding({ right: $r('app.float.vp_16') })
              .width('100%');
            }, (item: AnswerItemPreference, index: number) => item.ansID + index);
          }
          .width('100%');
        }
        .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), bottom: $r('app.float.vp_12') })
        .width('100%');

        if (this.topicItemModelPref.isAnswer) {
          Column() {
            // 正确答案
            this.correctAnswerBuilder();
            Divider()
              .color($r('sys.color.comp_background_tertiary'))
              .margin({ top: $r('app.float.vp_24'), bottom: $r('app.float.vp_24') })
              .strokeWidth(8);
            // 解析
            this.parseBuilder();
            Divider()
              .strokeWidth(8)
              .color($r('sys.color.comp_background_tertiary'))
              .margin({ top: $r('app.float.vp_24'), bottom: $r('app.float.vp_24') });
            // 笔记
            this.noteBuilder();
          }
          .width('100%');
        }
        Blank(130);
      };
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring);
  }

  /**
   * 笔记
   */
  @Builder
  noteBuilder() {
    Column() {
      Row() {
        Text($r('app.string.note'))
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.icon_primary'))
          .fontWeight(FontWeight.Medium);
        Row() {
          Text('+')
            .height($r('app.float.vp_16'))
            .width($r('app.float.vp_16'))
            .fontColor($r('sys.color.font_on_primary'))
            .textAlign(TextAlign.Center)
            .borderRadius(8)
            .backgroundColor($r('app.color.view_report_btn'));
          Text($r('app.string.add_note'))
            .fontColor($r('app.color.view_report_btn'))
            .fontSize($r('sys.float.Body_M'))
            .margin({ left: $r('app.float.vp_4') })
            .fontWeight(FontWeight.Medium);
        }
        .height($r('app.float.vp_28'))
        .width($r('app.float.vp_92'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .justifyContent(FlexAlign.Center)
        .borderRadius(14)
        .bindSheet($$this.isShowNoteSheet, this.noteSheet(), {
          height: 360,
          backgroundColor: $r('sys.color.background_secondary'),
          showClose: false,
        })
        .onClick(() => {
          this.isShowNoteSheet = true;
        });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: $r('app.float.vp_12') });

      Row() {
        if (this.note) {
          Text(this.note)
            .fontColor($r('sys.color.icon_primary'))
            .fontSize($r('sys.float.Body_S'));
        } else {
          Text($r('app.string.note_desc'))
            .fontColor($r('sys.color.icon_secondary'))
            .fontSize($r('sys.float.Body_S'));
        }
      }
      .width('100%');
    }
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .width('100%');
  }

  // 正确答案
  @Builder
  correctAnswerBuilder() {
    Column() {
      Row() {
        Text($r('app.string.correct_answer'))
          .fontColor($r('sys.color.icon_primary'))
          .fontSize($r('sys.float.Body_M'));
        Text(this.topicItemModelPref.rightQues.toString())
          .fontColor($r('sys.color.multi_color_04'))
          .fontSize($r('sys.float.Body_M'))
          .height($r('app.float.vp_20'))
          .width($r('app.float.vp_28'))
          .textAlign(TextAlign.Center);
      }
      .width('100%')
      .height($r('app.float.vp_48'))
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({ left: $r('app.float.vp_12') })
      .borderRadius($r('app.float.vp_12'))
      .justifyContent(FlexAlign.Start);
    }
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .width('100%');
  }

  // 解析
  @Builder
  parseBuilder() {
    Column() {
      Row() {
        Text($r('app.string.parse'))
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.icon_primary'))
          .fontWeight(FontWeight.Medium);
      }
      .width('100%')
      .margin({ bottom: $r('app.float.vp_12') });

      Row() {
        Text(`答案解析：${this.topicItemModelPref.parse}`)
          .fontColor($r('sys.color.icon_primary'))
          .fontSize($r('sys.float.Body_S'));
      }
      .width('100%');
    }
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .width('100%');
  }

  /**
   * 顶部
   */
  @Builder
  topBuilder() {
    Row() {
      // 查看笔记
      TopBar({
        onClickBack: () => {
          RouterModule.pop();
        },
        title: $r('app.string.answer_questions')
      });
    }
    .width('100%')
    .height($r('app.float.vp_56'))
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  noteSheet() {
    AddNoteDialog({
      note: this.note,
      confirmAddNote: (note) => {
        this.isShowNoteSheet = false;
        this.confirmAddNote(note);
      },
      close: () => {
        this.isShowNoteSheet = false;
      }
    });
  }

  confirmAddNote(note: string) {
    let tempNote = note.trim();
    if (tempNote.length === 0) {
      GlobalContextUtils.showToast({ message: '请输入笔记内容' });
      return;
    }
    this.topicItemModelPref.note = note;
    this.note = note;
    this.topicItemModelPref.addNoteTime = new Date().getTime();
    // 更新持久层笔记数据
    PreferenceUtil.getInstance(PreferConstant.TOPIC_NOTES)
      .put(this.topicItemModelPref.keyID, this.topicItemModelPref);
  }
}

@Builder
export function ViewNotePageBuilder() {
  ViewNotePage();
}