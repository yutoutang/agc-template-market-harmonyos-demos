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

/**
 *  练习模式图标组件
 */
export class PracticeView {
  // 图标
  imageUri: ResourceStr;
  name: string;
  describe: string;

  constructor(imageUri: ResourceStr, name: string, describe: string) {
    this.imageUri = imageUri;
    this.name = name;
    this.describe = describe;
  }
}

export const PRACTICE_LIST_DATA: PracticeView[] = [
  new PracticeView($r('app.media.ic_sequence'), '每日一练', '1/3256'),
  new PracticeView($r('app.media.ic_practice_simulations'), '模拟考试', '仿真模拟'),
  new PracticeView($r('app.media.ic_practice_test_paper'), '全真试卷', '深度检测备考水平'),
  new PracticeView($r('app.media.ic_wrong_question'), '错题练习', '做错题查漏补缺'),
]

/**
 * 实现IDataSource接口的对象，用于瀑布流组件加载数据
 */
export class PracticeDataSource implements IDataSource {
  private practiceData: PracticeView[] = [];
  private dataListeners: DataChangeListener[] = [];

  constructor(practiceData: PracticeView[]) {
    for (let i = 0; i < practiceData.length; i++) {
      this.practiceData.push(practiceData[i]);
    }
  }

  /**
   * 获取索引对应的数据
   * @param index 数组索引
   * @returns
   */
  public getData(index: number): PracticeView {
    return this.practiceData[index];
  }

  /**
   * 获取数据总数
   * @returns
   */
  public totalCount(): number {
    return this.practiceData.length;
  }

  /**
   * 注册改变数据的控制器
   * @param listener 数据控制器
   */
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.dataListeners.indexOf(listener) < 0) {
      this.dataListeners.push(listener);
    }
  }

  /**
   * 注销改变数据的控制器
   * @param listener 数据控制器
   */
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.dataListeners.indexOf(listener)
    if (pos >= 0) {
      this.dataListeners.splice(pos, 1);
    }
  }

  /**
   * 通知控制器数据重新加载
   */
  notifyDataReload(): void {
    this.dataListeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  /**
   * 通知控制器数据增加
   * @param index 数组索引
   */
  notifyDataAdd(index: number): void {
    this.dataListeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  /**
   * 通知控制器数据变化
   * @param index 数组索引
   */
  notifyDataChange(index: number): void {
    this.dataListeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  /**
   * 通知控制器数据删除
   * @param index 数组索引
   */
  notifyDataDelete(index: number): void {
    this.dataListeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  /**
   * 通知控制器数据位置变化
   * @param from 起始位置
   * @param to 最终位置
   */
  notifyDataMove(from: number, to: number): void {
    this.dataListeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }
}