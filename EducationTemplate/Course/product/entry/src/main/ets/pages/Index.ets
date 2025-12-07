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

import { window, AlertDialog } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { Logger, QuestionsRouterModel, RouterMap, RouterModule } from 'commonlib';
import { PlayerVM } from 'recorded_player';
import { RouterTable } from '../models/RouterTable';
import { common } from '@kit.AbilityKit';

@Entry
@ComponentV2
struct Index {
  // 弹框页
  dialogPages: string[] = [RouterMap.PRIVACY_STATEMENT_ALERT_PAGE, RouterMap.LOGIN_PAGE, RouterMap.INPUT_COMMENT_PAGE];
  @Local playerVM: PlayerVM = PlayerVM.instance;
  backPageDialogController: CustomDialogController | undefined = undefined;

  aboutToAppear(): void {
    window.getLastWindow(getContext(this)).then((windowClass: window.Window) => {
      windowClass.setWindowLayoutFullScreen(true);
      windowClass.on('windowEvent', (data) => {
        if (data === window.WindowEventType.WINDOW_INACTIVE || data === window.WindowEventType.WINDOW_HIDDEN) {
          let paths: string[] = RouterModule.stack.getAllPathName();
          let lastElement: string = paths[paths.length -1];
          if (lastElement === RouterMap.CHAPTER_DETAIL_PAGE) {
            emitter.emit('autoStartPip');
          }
        }
        if (data === window.WindowEventType.WINDOW_SHOWN) {
          emitter.emit('playerPause', { data: { isPlaying: true } });
        }
      });
    });
    RouterModule.replace({ url: RouterMap.LAUNCH_PAGE });
  }

  @Builder
  pageMap(name: string) {
    NavDestination() {
      RouterTable.getBuilder(name).builder();
    }
    .mode(this.dialogPages.includes(name) ? NavDestinationMode.DIALOG : NavDestinationMode.STANDARD)
    .backgroundColor(this.dialogPages.includes(name) ? 'rgba(0,0,0,0)' :
      $r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true)
    .onBackPressed(() => {
      if (name === 'AnswerQuestionsExamPage' || name === 'AnswerQuestionsPage') {
        return this.isOpenDialog(name);
      }
      if (name === RouterMap.RECORDED_DETAIL_PAGE) {
        let eventData: emitter.EventData = {
          data: { refresh: true }
        };
        emitter.emit('queryCourse', eventData);
      }
      if (name === RouterMap.MATERIAL_PAGE) {
        let eventData: emitter.EventData = {
          data: { isPlaying: true }
        };
        emitter.emit('playerPause', eventData);
      }
      if (name === RouterMap.CHAPTER_DETAIL_PAGE) {
        emitter.emit('chapterDetailBack');
      }
      return false;
    })
    .onShown(() => {
      if (name === RouterMap.LIVE_STREAMING_PAGE) {
        this.setStatusBarTextColor('#FFFFFF');
      }
    })
    .onHidden(() => {
      if (name === RouterMap.LIVE_STREAMING_PAGE) {
        this.setStatusBarTextColor('#000000');
      }
    });
  }

  isOpenDialog(name: string): boolean {
    if (name === 'AnswerQuestionsExamPage') {
      this.backPageDialogOpen(
        '您还有题目没有作答是否直接交卷结束考试！',
        '结束考试',
        '继续考试',
      );
      return true;
    } else if (name === 'AnswerQuestionsPage') {
      let routerModel: QuestionsRouterModel | string | undefined =
        RouterModule.getNavParam({ url: RouterMap.ANSWER_QUESTIONS_PAGE });
      if (routerModel instanceof QuestionsRouterModel) {
        return false;
      }
      this.backPageDialogOpen(
        '您的练习计划还没有完成！确定需要退出本次练习吗？',
        '结束练习',
        '继续练习',
      );
      return true;
    }
    return false;
  }

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
            RouterModule.pop();
          },
        },
      }),
    });
    this.backPageDialogController.open();
  }

  public setStatusBarTextColor(statusContentColor: string) {
    const ctx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    let windowClass = ctx.windowStage.getMainWindowSync();
    let sysBarProperties = {
      statusBarContentColor: statusContentColor,
    } as window.SystemBarProperties;
    windowClass.setWindowSystemBarProperties(sysBarProperties);
  }

  build() {
    Navigation(RouterModule.stack) {
    }
    .hideNavBar(true)
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.pageMap)
    .id(this.playerVM.navId);
  }
}