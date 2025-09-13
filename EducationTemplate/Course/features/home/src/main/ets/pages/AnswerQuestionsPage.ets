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

import { AlertDialog } from '@kit.ArkUI';
import {
  PreferenceUtil,
  Logger,
  PreferConstant,
  RouterModule,
  RouterMap,
  AnswerItem,
  AnswerItemPreference,
  TopicItemModel,
  TopicItemModelPreference,
  QuestionsRouterModel,
  CollectionRouter
} from 'commonlib';
import { AnswerQuestionsComponent } from '../components/AnswerQuestionsComponent';
import { TestReportModel } from './TestReportPage';

const TAG = 'AnswerQuestionsPage';

@ComponentV2
export struct AnswerQuestionsPage {
  @Provider() ques: TopicItemModel[] = [];
  @Provider() practiceDuration: number = 0;
  @Provider() currentIndex: number = 0
  @Provider() currentModel: TopicItemModel = new TopicItemModel()
  @Provider() rightCont: number = 0
  @Provider() errCont: number = 0
  @Provider() isCollection: boolean = false
  // 题目来源
  @Provider() topicSource?: string
  // 页面路由：我的错题/我的收藏
  @Provider() routerModel?: QuestionsRouterModel
  collectionRouter: CollectionRouter = CollectionRouter.instance();
  // 返回弹框
  backDialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: '温馨提示',
      content: '您的练习计划还没有完成！确定需要退出本次练习吗？',
      primaryButton: {
        value: '结束练习',
        fontColor: $r('sys.color.font_tertiary'),
        action: () => {
          RouterModule.pop()
        },
      },
      secondaryButton: {
        value: '继续练习',
        action: () => {
        }
      },
    }),
  })

  aboutToAppear(): void {
    Logger.info(TAG, 'aboutToAppear')
    let temp: QuestionsRouterModel | string | undefined =
      RouterModule.getNavParam({ url: RouterMap.ANSWER_QUESTIONS_PAGE })
    if (temp instanceof QuestionsRouterModel) {
      this.routerModel = temp
    } else {
      this.topicSource = temp
    }
    if (this.routerModel?.sourcePageTitle === '我的收藏') {
      this.collectionRouter.isAnswerUpdate = false
    }
  }

  build() {
    AnswerQuestionsComponent({
      isCollectionEvent: () => {
        this.isCollectionEvent()
      },
      addWrongQuestionRecord: () => {
        this.addWrongQuestionRecord()
      },
      storageCollectClick: () => {
        this.storageCollectClick()
      },
      viewReport: () => {
        this.viewReport()
      },
      onClickBack: () => {
        if (this.routerModel || this.rightCont + this.errCont === 10) {
          RouterModule.pop()
        } else {
          this.backDialogController.open();
        }
      }
    })
  }

  // 修改收藏状态
  isCollectionEvent() {
    let data = PreferenceUtil.getInstance(PreferConstant.COLLECT_TOPIC_RECORDS).get(this.currentModel.keyID);
    if (data) {
      this.isCollection = true
    } else {
      this.isCollection = false
    }
  }

  viewReport() {
    // 跳转到测试报告页面
    let testReport: TestReportModel = new TestReportModel();
    testReport.ques = this.ques;
    testReport.quesType = 1;
    testReport.practiceDuration = this.practiceDuration;
    RouterModule.replace({ url: RouterMap.ANSWER_REPORT_PAGE, param: testReport });
  }

  // 添加错题记录
  addWrongQuestionRecord() {
    if (this.topicSource) {
      let wrongRecord: TopicItemModelPreference = this.transTopicItemType()
      // 将错题记录存入持久层
      PreferenceUtil.getInstance(PreferConstant.WRONG_QUESTION_RECORDS).put(wrongRecord.keyID, wrongRecord)
    }
  }

  // 收藏记录
  storageCollectClick() {
    if (this.routerModel?.sourcePageTitle === '我的收藏') {
      let collectRecord: TopicItemModelPreference = this.transTopicItemType()
      collectRecord.topicSource = this.collectionRouter.topicSource
      // 将收藏记录存入持久层
      PreferenceUtil.getInstance(PreferConstant.COLLECT_TOPIC_RECORDS).put(collectRecord.keyID, collectRecord)
      this.collectionRouter.isAnswerUpdate = true
    } else {
      if (this.isCollection) {
        PreferenceUtil.getInstance(PreferConstant.COLLECT_TOPIC_RECORDS).delete(this.currentModel.keyID)
      } else {
        let collectRecord: TopicItemModelPreference = this.transTopicItemType()
        // 将收藏记录存入持久层
        PreferenceUtil.getInstance(PreferConstant.COLLECT_TOPIC_RECORDS).put(collectRecord.keyID, collectRecord)
      }
      // 修改收藏状态
      this.isCollectionEvent()
    }
  }

  // 类型转换
  transTopicItemType(): TopicItemModelPreference {
    let topicPref: TopicItemModelPreference = new TopicItemModelPreference()
    topicPref.type = this.currentModel.type;
    topicPref.title = this.currentModel.title;
    topicPref.keyID = this.currentModel.keyID;
    topicPref.rightQues = this.currentModel.rightQues;
    topicPref.parse = this.currentModel.parse;
    topicPref.selectQues = this.currentModel.selectQues;
    topicPref.showState = this.currentModel.showState;
    topicPref.isAnswer = this.currentModel.isAnswer;
    topicPref.topicSource = this.topicSource;
    topicPref.time = Date.now()
    let answerPrefList: AnswerItemPreference[] = []
    this.currentModel.ques.forEach((answerItem: AnswerItem) => {
      let answerPref: AnswerItemPreference = new AnswerItemPreference()
      answerPref.ansTitle = answerItem.ansTitle
      answerPref.ans = answerItem.ans
      answerPref.ansID = answerItem.ansID
      answerPref.isSelect = answerItem.isSelect
      answerPref.state = answerItem.showState
      answerPrefList.push(answerPref)
    })
    topicPref.ques = answerPrefList
    return topicPref;
  }
}

@Builder
export function AnswerQuestionsBuilder() {
  AnswerQuestionsPage()
}

