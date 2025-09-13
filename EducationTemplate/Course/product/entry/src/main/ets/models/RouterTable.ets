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

import { RouterMap } from 'commonlib';
import {
  AnswerQuestionsBuilder,
  AnswerQuestionsExamBuilder,
  ChapterDetailBuilder,
  CourseListPageBuilder,
  ExamResultBuilder,
  LiveStreamingListPageBuilder,
  LookFileBuilder,
  MaterialPageBuilder,
  RecordedDetailBuilder,
  SearchPageBuilder,
  TestReportBuilder
} from 'home';
import {
  MyOrderBuilder,
  PersonalInfoPageBuilder,
  MessageBuilder,
  SystemMessageBuilder,
  FeedbackPageBuilder,
  CourseUpdateMessageBuilder,
  FeedbackRecordsPageBuilder,
  PrivacySetPageBuilder,
  SetUpPageBuilder,
  PrivacyStatementBuilder,
  PersonalInformationCollectionBuilder,
  DataSharingBuilder,
  AuthenticationBuilder,
  UserAgreementBuilder,
  PrivacyAgreementBuilder,
  AboutPageBuilder,
  MyCollectionPageBuilder,
  MyDownloadPageBuilder,
  MyCoursePageBuilder,
  MyWrongQuestionPageBuilder,
  WatchHistoryPageBuilder,
  MyCourseCommentsBuilder,
  OrderDetailPageBuilder
} from 'mine';
import { LaunchPageBuilder } from '../pages/Launch';
import { LaunchAdPageBuilder } from '../pages/LaunchAd';
import { LoginPageBuilder } from '../pages/Login';
import { MainEntryBuilder } from '../pages/MainEntry';
import { PrivacyPolicyBuilder } from '../pages/PrivacyPolicy';
import { PrivacyPolicyAlertBuilder } from '../pages/PrivacyPolicyAlert';

export class RouterTable {
  static builderMap: Map<string, WrappedBuilder<[object]>> = new Map<string, WrappedBuilder<[object]>>();

  // 初始化路由表
  public static routerInit() {
    // 启动页
    RouterTable.builderMap.set(RouterMap.LAUNCH_PAGE, wrapBuilder(LaunchPageBuilder));
    // 隐私
    RouterTable.builderMap.set(RouterMap.PRIVACY_POLICY_PAGE, wrapBuilder(PrivacyPolicyBuilder));
    // 隐私弹框页
    RouterTable.builderMap.set(RouterMap.PRIVACY_STATEMENT_ALERT_PAGE, wrapBuilder(PrivacyPolicyAlertBuilder));
    // 广告
    RouterTable.builderMap.set(RouterMap.LAUNCH_AD_PAGE, wrapBuilder(LaunchAdPageBuilder));
    // 主页
    RouterTable.builderMap.set(RouterMap.MAIN_ENTRY, wrapBuilder(MainEntryBuilder));
    // 登录
    RouterTable.builderMap.set(RouterMap.LOGIN_PAGE, wrapBuilder(LoginPageBuilder));

    // -------------------------------------------------- home
    RouterTable.builderMap.set(RouterMap.COURSE_LIST_PAGE, wrapBuilder(CourseListPageBuilder));
    RouterTable.builderMap.set(RouterMap.LIVE_STREAMING_LIST_PAGE, wrapBuilder(LiveStreamingListPageBuilder));
    RouterTable.builderMap.set(RouterMap.RECORDED_DETAIL_PAGE, wrapBuilder(RecordedDetailBuilder));
    RouterTable.builderMap.set(RouterMap.CHAPTER_DETAIL_PAGE, wrapBuilder(ChapterDetailBuilder));
    RouterTable.builderMap.set(RouterMap.SEARCH_PAGE, wrapBuilder(SearchPageBuilder));
    RouterTable.builderMap.set(RouterMap.MATERIAL_PAGE, wrapBuilder(MaterialPageBuilder));
    RouterTable.builderMap.set(RouterMap.ANSWER_QUESTIONS_PAGE, wrapBuilder(AnswerQuestionsBuilder));
    RouterTable.builderMap.set(RouterMap.ANSWER_QUESTIONS_EXAM_PAGE, wrapBuilder(AnswerQuestionsExamBuilder));
    RouterTable.builderMap.set(RouterMap.ANSWER_REPORT_PAGE, wrapBuilder(TestReportBuilder));
    RouterTable.builderMap.set(RouterMap.EXAM_RESULT_PAGE, wrapBuilder(ExamResultBuilder));
    RouterTable.builderMap.set(RouterMap.LOOK_FILE_PAGE, wrapBuilder(LookFileBuilder));
    // -------------------------------------------------- course

    // -------------------------------------------------- mine
    RouterTable.builderMap.set(RouterMap.MY_ORDER_PAGE, wrapBuilder(MyOrderBuilder));
    RouterTable.builderMap.set(RouterMap.PERSONAL_INFO_PAGE, wrapBuilder(PersonalInfoPageBuilder));
    RouterTable.builderMap.set(RouterMap.MY_COLLECTION_PAGE, wrapBuilder(MyCollectionPageBuilder));
    RouterTable.builderMap.set(RouterMap.MY_DOWNLOAD_PAGE, wrapBuilder(MyDownloadPageBuilder));
    RouterTable.builderMap.set(RouterMap.MY_WRONG_QUESTION_PAGE, wrapBuilder(MyWrongQuestionPageBuilder));
    RouterTable.builderMap.set(RouterMap.MESSAGE_PAGE, wrapBuilder(MessageBuilder));
    RouterTable.builderMap.set(RouterMap.SYSTEM_MESSAGE_PAGE, wrapBuilder(SystemMessageBuilder));
    RouterTable.builderMap.set(RouterMap.COURSE_MESSAGE_PAGE, wrapBuilder(CourseUpdateMessageBuilder));
    RouterTable.builderMap.set(RouterMap.FEEDBACK_PAGE, wrapBuilder(FeedbackPageBuilder));
    RouterTable.builderMap.set(RouterMap.FEEDBACK_RECORDS_PAGE, wrapBuilder(FeedbackRecordsPageBuilder));
    RouterTable.builderMap.set(RouterMap.SETUP_PAGE, wrapBuilder(SetUpPageBuilder));
    RouterTable.builderMap.set(RouterMap.PRIVACY_SET_PAGE, wrapBuilder(PrivacySetPageBuilder));
    RouterTable.builderMap.set(RouterMap.PRIVACY_STATEMENT_PAGE, wrapBuilder(PrivacyStatementBuilder));
    RouterTable.builderMap.set(RouterMap.PERSONAL_INFORMATION_PAGE, wrapBuilder(PersonalInformationCollectionBuilder));
    RouterTable.builderMap.set(RouterMap.DATA_SHARING_PAGE, wrapBuilder(DataSharingBuilder));
    RouterTable.builderMap.set(RouterMap.AUTHENTICATION_PAGE, wrapBuilder(AuthenticationBuilder));
    RouterTable.builderMap.set(RouterMap.USER_AGREEMENT, wrapBuilder(UserAgreementBuilder));
    RouterTable.builderMap.set(RouterMap.PRIVACY_AGREEMENT_PAGE, wrapBuilder(PrivacyAgreementBuilder));
    RouterTable.builderMap.set(RouterMap.ABOUT_PAGE, wrapBuilder(AboutPageBuilder));
    RouterTable.builderMap.set(RouterMap.MY_COURSE_PAGE, wrapBuilder(MyCoursePageBuilder));
    RouterTable.builderMap.set(RouterMap.MY_COURSE_HISTORY_PAGE, wrapBuilder(WatchHistoryPageBuilder));
    RouterTable.builderMap.set(RouterMap.MY_COURSE_COMMENTS_PAGE, wrapBuilder(MyCourseCommentsBuilder));
    RouterTable.builderMap.set(RouterMap.ORDER_DETAIL_PAGE, wrapBuilder(OrderDetailPageBuilder));

  }

  // 通过名称获取builder
  public static getBuilder(builderName: string): WrappedBuilder<[]> {
    let builder = RouterTable.builderMap.get(builderName);
    return builder as WrappedBuilder<[]>;
  }
}