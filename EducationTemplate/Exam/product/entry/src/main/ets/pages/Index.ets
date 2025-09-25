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
import { RouterMap, RouterModule } from 'router_module';
import { PreferenceUtil, PreferConstant } from 'commonlib';
import { QuestionsRouterModel } from 'answer_questions';
import { RouterTable } from '../model/RouterTable';

@Entry
@ComponentV2
struct Index {
  // 弹框页
  dialogPages: string[] = [RouterMap.PRIVACY_USE_PAGE, RouterMap.LOGIN_PAGE]
  backPageDialogController?: CustomDialogController;
  content = ''
  leftButtonText = ''
  rightButtonText = ''

  backPageDialogOpen(content: string, leftButtonText: string, rightButtonText: string) {
    this.backPageDialogController = new CustomDialogController({
      builder: AlertDialog({
        primaryTitle: '温馨提示',
        content: content,
        secondaryButton: {
          value: rightButtonText,
          action: () => {
          }
        },
        primaryButton: {
          value: leftButtonText,
          fontColor: $r('sys.color.font_tertiary'),
          action: () => {
            RouterModule.pop()
          },
        },
      }),
    })
    this.backPageDialogController.open()
  }

  aboutToAppear() {
    //读取状态值，如果为空设置为true
    let isFirstLaunch = PreferenceUtil.getInstance().get(PreferConstant.FIRSTLAUNCH, true) as boolean
    if (isFirstLaunch) {
      //隐私政策
      RouterModule.replace({ url: RouterMap.PRIVACY_AGREEMENT_PAGE })
      return;
    }
    RouterModule.replace({ url: RouterMap.MAIN_PAGE })
  }

  @Builder
  pageMap(name: string) {
    NavDestination() {
      RouterTable.getBuilder(name).builder()
    }
    .mode(this.dialogPages.includes(name) ? NavDestinationMode.DIALOG : NavDestinationMode.STANDARD)
    .hideTitleBar(true)
    .onBackPressed(() => {
      return this.backPress(name)
    })
  }

  build() {
    Column() {
      Navigation(RouterModule.stack) {
      }
      .hideNavBar(true)
      .hideToolBar(true)
      .hideTitleBar(true)
      .hideBackButton(true)
      .mode(NavigationMode.Stack)
      .navDestination(this.pageMap)
    }
  }

  // 侧滑返回拦截
  backPress(name: string): boolean {
    if (this.isIntercept(name)) {
      this.backPageDialogOpen(this.content, this.leftButtonText, this.rightButtonText)
      return true
    }
    return false
  }

  isIntercept(name: string): boolean {
    if (name === 'AnswerQuestionsTwoPage') {
      this.content = '您还有题目没有作答是否直接交卷结束考试！'
      this.leftButtonText = '结束考试'
      this.rightButtonText = '继续考试'
      return true
    } else if (name === 'AnswerQuestionsPage') {
      let param: QuestionsRouterModel | undefined =
        RouterModule.getNavParam({ url: RouterMap.ANSWER_QUESTIONS_PAGE })
      if (param?.sourceType === '我的错题' || param?.sourceType === '我的收藏') {
        return false
      }
      this.content = '您的练习计划还没有完成！确定需要退出本次练习训练吗？'
      this.leftButtonText = '结束练习'
      this.rightButtonText = '继续练习'
      return true
    }
    return false
  }
}
