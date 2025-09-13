/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the 'License');
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an 'AS IS' BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

import { AlertDialog } from '@kit.ArkUI';

@CustomDialog
export struct DeleteDialog {
  customController: CustomDialogController;
  content: ResourceStr = '';
  confirmDelete: () => void = () => {
  }

  build() {
    AlertDialog({
      content: this.content,
      primaryButton: {
        value: '取消',
        fontColor: $r('sys.color.font_primary'),
        action: () => {
          this.customController.close();
        },
      },
      secondaryButton: {
        value: '删除',
        fontColor: $r('sys.color.warning'),
        action: () => {
          this.confirmDelete();
          this.customController.close();
        }
      },
    })
  }
}
 