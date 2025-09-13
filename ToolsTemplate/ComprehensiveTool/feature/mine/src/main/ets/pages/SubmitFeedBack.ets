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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { MineVM } from '../viewmodel/MineVM';
import { ComponentContent, LevelMode } from '@kit.ArkUI';
import { PromptActionUtil } from '../utils/PromptActionUtil';
import { Feedback } from '../components/Feedback';
import { FeedbackItemType } from '../model/FeedbackRecordModel';

@Builder
export function SubmitFeedBackBuilder() {
  SubmitFeedBack();
}

@Builder
function contentConfirmTips(stack: NavPathStack) {
  Column({ space: 16 }) {
    Text('温馨提示')
      .fontWeight(FontWeight.Bold)
      .fontSize(20)
      .fontColor($r('sys.color.font_primary'))
      .opacity(0.9)
      .width('100%')
      .textAlign(TextAlign.Center);
    Text('编辑内容尚未提交，是否确定退出？')
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))
      .opacity(0.9);
    Row() {
      Text('取消').fontColor($r('sys.color.font_emphasize')).width('50%').textAlign(TextAlign.Center).onClick(() => {
        PromptActionUtil.closeDialog(privacyContentNode);
      });
      Text('|').height(24).opacity(0.05);
      Text('确定').fontColor($r('sys.color.font_emphasize')).width('50%').textAlign(TextAlign.Center).onClick(() => {
        PromptActionUtil.closeDialog(privacyContentNode);
        stack.pop();
      });
    };
  }
  .padding(24)
  .borderRadius(32)
  .backgroundColor($r('sys.color.ohos_id_blur_style_component_ultra_thick_color'))
  .width('90%');
}

let getUIContext: UIContext;
let privacyContentNode: ComponentContent<Object>;

@ComponentV2
export struct SubmitFeedBack {
  vm: MineVM = MineVM.instance;
  @Local message: string = 'BindSheet';
  @Local isSelected: boolean = false;
  @Local localImgUri: string = '';
  @Local phoneNo: string = '';
  controller: TextInputController = new TextInputController();

  aboutToAppear(): void {
    getUIContext = this.getUIContext();
    privacyContentNode =
      new ComponentContent(getUIContext, wrapBuilder<[NavPathStack]>(contentConfirmTips), this.vm.pathStack);
  }

  aboutToDisappear(): void {
    this.vm.content = '';
  }

  confirmDialog() {
    PromptActionUtil.setContext(getUIContext);
    PromptActionUtil.setContentNode(privacyContentNode);
    PromptActionUtil.setOptions({
      levelMode: LevelMode.EMBEDDED,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        hilog.info(0xFF00, 'SubmitFeedBack', JSON.stringify(dismissDialogAction.reason));
      },
    });
    PromptActionUtil.openDialog();
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Row({ space: 8 }) {
            Image($r('app.media.icon_nav_left'))
              .size({ height: 40, width: 40 })
              .onClick(() => {
                this.vm.content.length ? this.confirmDialog() : this.vm.pathStack.pop();
              });
            Text('意见与反馈')
              .fontSize(20)
              .width('50%')
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .fontColor($r('sys.color.black'))
              .fontWeight(FontWeight.Medium);
          };

          Image($r('app.media.feedbacks')).size({ width: 40, height: 40 }).onClick(() => {
            this.vm.pathStack.pushPathByName('FeedBacks', null);
          });
        }
        .margin({ bottom: 8 })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({
          left: 12,
          right: 12,
        });

        Feedback({
          des: 100,
          num: 3,
          butOnClick: (val: FeedbackItemType) => {
            this.vm.submit(val);
          },
        });
      }
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }.hideTitleBar(true).onBackPressed(() => {
      let flag = true;
      if (this.vm.content.length) {
        this.confirmDialog()
      } else {
        flag = false;
      }
      return flag;
    });
  }
}
