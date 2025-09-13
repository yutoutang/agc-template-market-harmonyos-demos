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

import { util } from '@kit.ArkTS'
import dayjs from 'dayjs';

@ObservedV2
export class DownloadModel {
  id: string = util.generateRandomUUID(true);
  // 资料名称
  materialName: string = '';
  // 资料来源
  materialSource: string = '';
  // 文件类型
  fileType: string = '';
  // 文件uri
  fileUri: string = '';
  // 下载时间
  time: number = 0;
  // 是否删除
  @Trace isDelete?: boolean = false;
}


export const DOWNLOAD_DATA: DownloadModel[] = [
  {
    id: util.generateRandomUUID(true),
    materialName: '一级建造师精华题库',
    materialSource: '最新CPA注会题库',
    fileType: 'pdf',
    fileUri: '',
    time: dayjs('2025-7-30').valueOf()
  },
]

 