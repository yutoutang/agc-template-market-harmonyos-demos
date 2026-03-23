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

import { AddNotePage } from '../components/AddNotePage';

@ComponentV2
export struct AddNoteDialog {
  @Param note: string = '';
  @Param confirmAddNote: (note: string) => void = () => {
  };
  @Param close: () => void = () => {
  };

  build() {
    AddNotePage({
      note: this.note,
      close: () => {
        this.close();
      },
      confirmAddNote: (note) => {
        this.confirmAddNote(note);
        this.close();
      }
    })
  }
}