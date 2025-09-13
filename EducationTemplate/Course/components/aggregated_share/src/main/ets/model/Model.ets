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

import { HashMap } from '@kit.ArkTS'
import { image } from '@kit.ImageKit'

// 分享内容
export class ShareOptions {
  id: string = ''
  title: string = ''
  lecturer: string = '' //讲师
  coverUrl: string | undefined = '' // 封面图片
}

export class ShareKinds {
  id: string = ''
  icon: string = ''
  name: string = ''
}

export class ScreenInfo {
  screenWidth: number = 0
  screenHeight: number = 0
}

export class PopupBaseController {
  hide: () => void = () => {
  }
}

export interface NewsQrCode {
  articleId: string
}


export class QqShareData {
  shareJson: string = ''
  timestamp: number = new Date().getTime()
  nonce: number = 0
  shareJsonSign: string = ''
}

export interface QqShareContent {
  msgStyle: number
  title: string
  url: string
  pictureUrl: string
}

export class QqShareResult {
  resultType: ShareResultType = 0;
  code: number = 0;
  message: string | undefined | null = undefined;
  detail: string | undefined | null = undefined;
  extra: HashMap<string, string> = new HashMap();
}

export enum ShareResultType {
  Success = 1,
  Cancel = 2,
  Error = 3
}

export interface ShareSheetParams {
  onPost: (isOpen: boolean, pixmap: image.PixelMap) => void
  shareCodeInfo: ShareOptions
}
