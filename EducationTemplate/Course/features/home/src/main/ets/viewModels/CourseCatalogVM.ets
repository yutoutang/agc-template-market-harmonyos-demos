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

import { Logger } from 'commonlib';
import { queryCourseCatalogList, CourseCatalog } from 'http';

const TAG = '[CourseCatalogVM]';

@ObservedV2
export class CourseCatalogVM {
  @Trace catalogList: CourseCatalog[] = []
  private static catalogInstance: CourseCatalogVM;

  public static get instance() {
    if (!CourseCatalogVM.catalogInstance) {
      CourseCatalogVM.catalogInstance = new CourseCatalogVM();
    }
    return CourseCatalogVM.catalogInstance;
  }

  init() {
    queryCourseCatalogList().then(res => {
      if (res.status === 200) {
        this.catalogList = res.data
      }
      Logger.info(TAG, JSON.stringify(res))
    })
  }
}