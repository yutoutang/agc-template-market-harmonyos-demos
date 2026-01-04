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

export class MyDataSource implements IDataSource {
  private list: string[] = [];

  constructor(list: string[]) {
    this.list = list;
  }

  totalCount(): number {
    return this.list.length;
  }

  getData(index: number): string {
    return this.list[index];
  }

  registerDataChangeListener(): void {
  }

  unregisterDataChangeListener() {
  }
}

@ObservedV2
export class GoodCourse {
  @Trace id: string = ''
  @Trace isCollect: boolean = false
  @Trace title: string
  @Trace icon: ResourceStr
  @Trace name: string
  @Trace time: string
  @Trace introduction: string
  @Trace allSubject: string
  @Trace effectTime: string

  constructor(id: string, isCollect: boolean, title: string, icon: ResourceStr, name: string, time: string,
    introduction: string, allSubject: string, effectTime: string) {
    this.id = id
    this.isCollect = isCollect
    this.title = title
    this.icon = icon
    this.name = name
    this.time = time
    this.introduction = introduction
    this.allSubject = allSubject
    this.effectTime = effectTime
  }
}

@ObservedV2
export class MockObj {
  @Trace mockList: MockItem[] =
    [new MockItem('111', $r('app.media.icon_TestPaper'), '2025年一级建造师建筑工程考试试题试卷', 423),
      new MockItem('222', $r('app.media.icon_TestPaper'), '2025年一级建造师建筑工程考试试题试卷', 500)]
}

@ObservedV2
export class MockItem {
  @Trace id: string;
  @Trace imageSrc: ResourceStr;
  @Trace text: string;
  @Trace num: number;

  constructor(id: string, imageSrc: ResourceStr, text: string, num: number) {
    this.id = id;
    this.imageSrc = imageSrc;
    this.text = text;
    this.num = num;
  }
}

// 数据中心
@ObservedV2
export class Sample {
  @Trace id: string = '1111';
  @Trace title: string = '一级建筑师';
}