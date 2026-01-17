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

import { TopicItemModelPreference } from 'answer_questions';
import { PreferenceUtil, PreferConstant, Logger, TopBar } from 'commonlib';
import { RouterMap, RouterModule } from 'router_module';

const TAG = 'MyNotesPage';

@ComponentV2
export struct MyNotesPage {
  @Local topicItemModelPreferences: TopicItemModelPreference[] = [];
  @Local isSelectDelete: boolean = false
  @Local noteModels: NoteModel[] = []
  @Local notes: string[] = []
  @Local swipeDelete: boolean = false
  @Local isSelectAll: boolean = false
  @Local selectCount: number = 0

  aboutToAppear(): void {
    this.initData();
  }

  build() {
    Column() {
      // 顶部
      this.topBuilder();
      Divider().color($r('sys.color.comp_divider'))
      Column() {
        if (this.noteModels.length > 0) {
          // 笔记列表
          this.noteListBuilder()
          // 删除按钮
          this.deleteButtonBuilder()
        } else {
          Text('当前暂无笔记，您可以在练习中添加笔记。')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.icon_secondary'))
            .height('100%')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .width('100%')
    .height('100%')
  }

  initData() {
    this.noteModels = [];
    this.notes = [];
    // 获取笔记全部持久化缓存数据
    let value = PreferenceUtil.getInstance(PreferConstant.TOPIC_NOTES).getAllSync()
    if (value) {
      this.topicItemModelPreferences = Object.values(value) as TopicItemModelPreference[];
    }
    // 按照时间顺序由近及远
    this.topicItemModelPreferences.sort((a, b) => b.addNoteTime - a.addNoteTime)
    for (let index = 0; index < this.topicItemModelPreferences.length; index++) {
      let element = this.topicItemModelPreferences[index]
      let model: NoteModel = new NoteModel()
      model.note = element.note
      model.keyID = element.keyID
      model.isDelete = false
      this.noteModels.push(model)
      this.notes.push(element.note)
    }
  }

  /**
   * 删除按钮
   */
  @Builder
  deleteButtonBuilder() {
    Row() {
      Image($r('app.media.icon_delete'))
        .width($r('app.float.vp_24'))
        .height($r('app.float.vp_24'))
      Text('删除')
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .margin({ left: $r('app.float.vp_8') })
    }
    .width($r('app.float.vp_312'))
    .justifyContent(FlexAlign.Center)
    .borderRadius(20)
    .backgroundColor('#4c5dc4')
    .padding({ top: $r('app.float.vp_8'), bottom: $r('app.float.vp_8') })
    .opacity(this.selectCount > 0 ? 1 : 0.4)
    .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.Hidden)
    .onClick(() => {
      if (this.selectCount > 0) {
        // 删除选中
        this.deleteSelectData()
      }
    })
  }

  // 移除所选中的
  deleteSelectData() {
    this.noteModels.forEach((item: NoteModel) => {
      if (item.isDelete) {
        // 删除
        PreferenceUtil.getInstance(PreferConstant.TOPIC_NOTES).delete(item.keyID);
      }
    })
    this.notes = this.notes.filter((_it: string, index: number) => !this.noteModels[index].isDelete)
    this.topicItemModelPreferences = this.topicItemModelPreferences.filter((_it: TopicItemModelPreference,
      index: number) => !this.noteModels[index].isDelete)
    this.noteModels = this.noteModels.filter((it: NoteModel) => !it.isDelete)
    this.isSelectDelete = false
  }

  // 是否全选
  isSelectAllClick() {
    if (!this.isSelectAll) {
      this.noteModels.forEach((item: NoteModel, index: number) => {
        item.isDelete = true;
        this.noteModels[index].isDelete = item.isDelete
      })
      this.isSelectAll = true
      this.selectCount = this.noteModels.length;
    } else {
      this.noteModels.forEach((item: NoteModel, index: number) => {
        item.isDelete = false;
        this.noteModels[index].isDelete = item.isDelete
      })
      this.isSelectAll = false
      this.selectCount = 0
    }
  }

  // 笔记列表
  @Builder
  noteListBuilder() {
    List({ space: 8 }) {
      ForEach(this.noteModels, ((item: NoteModel, index: number) => {
        ListItem() {
          // 笔记子项
          this.noteItemBuilder(index)
        }
        .transition({ type: TransitionType.Delete, opacity: 0 })
        .swipeAction({
          edgeEffect: SwipeEdgeEffect.None,
          end: {
            builder: () => {
              this.itemEnd(item, index)
            },
            actionAreaDistance: 26,
            onStateChange: (state: SwipeActionState) => {
              if (state === SwipeActionState.COLLAPSED) {
                this.swipeDelete = false
              } else if (state === SwipeActionState.EXPANDED) {
                this.isSelectDelete = false
                this.swipeDelete = true
                this.isSelectAll = false
                this.selectCount = 0
                this.noteModels.forEach((item: NoteModel, index: number) => {
                  item.isDelete = false;
                  this.noteModels[index].isDelete = item.isDelete
                })
              }
            },
          }
        })
      }), (item: TopicItemModelPreference, idx: number) => JSON.stringify(item.keyID + idx + ''))
    }
    .width('auto')
    .height('auto')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
      top: $r('app.float.vp_12'),
      bottom: $r('app.float.vp_46')
    })
    .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
      Logger.info(TAG, 'Test Text isExpanding: ' + isExpanding + ', currentRatio:' + currentRatio)
      if (isExpanding) {
        this.initData()
      }
    })
  }

  @Builder
  noteItemBuilder(index: number) {
    Column() {
      Row() {
        Text($r('app.string.single_choice'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_24'))
          .fontSize($r('sys.float.Caption_L'))
          .fontColor($r('sys.color.font_on_primary'))
          .textAlign(TextAlign.Center)
          .backgroundColor($r('app.color.view_report_btn'))
          .borderRadius(8)
        // 父组件 点击右上角删除按钮显示  否则不显示
        Row() {
          Image(this.noteModels[index].isDelete ? $r('app.media.icon_Checked') :
          $r('app.media.icon_ans_common'))
            .height($r('app.float.vp_20'))
            .width($r('app.float.vp_20'))
        }
        .height($r('app.float.vp_24'))
        .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          this.noteModels[index].isDelete = !this.noteModels[index].isDelete
          if (this.noteModels[index].isDelete) {
            this.selectCount++;
          } else {
            this.selectCount--;
          }
          if (this.selectCount < this.noteModels.length) {
            this.isSelectAll = false
          } else {
            this.isSelectAll = true
          }
        })
      }
      .width('100%')
      .margin($r('app.float.vp_4'))
      .justifyContent(FlexAlign.SpaceBetween)

      Text(this.notes[index])
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .width('100%')
    }
    .width('100%')
    .padding($r('app.float.vp_12'))
    .borderRadius(16)
    .backgroundColor($r('sys.color.background_primary'))
    .onClick(() => {
      if (!this.isSelectDelete) {
        Logger.info(TAG, '点击事件-查看笔记')
        RouterModule.push({ url: RouterMap.View_NOTE_PAGE, param: this.topicItemModelPreferences[index] });
      }
    })
  }

  @Builder
  itemEnd(item: NoteModel, index: number) {
    Row() {
      Image($r('app.media.ic_public_trash_red'))
        .width($r('app.float.vp_24'))
        .height($r('app.float.vp_24'))
        .margin({ left: $r('app.float.vp_12') })
        .onClick(() => {
          this.swipeDelete = false
          this.notes.splice(index, 1)
          this.topicItemModelPreferences.splice(index, 1)
          this.noteModels.splice(index, 1)
          // 更新
          PreferenceUtil.getInstance(PreferConstant.TOPIC_NOTES).delete(item.keyID);
        })
    }.padding($r('app.float.vp_4')).justifyContent(FlexAlign.SpaceEvenly)
  }

  /**
   * 顶部
   */
  @Builder
  topBuilder() {
    Row() {
      // 我的笔记
      TopBar({
        onClickBack: () => {
          RouterModule.pop()
        },
        title: $r('app.string.my_notes')
      })
      Row() {
        Image(!this.isSelectAll ? $r('app.media.icon_select_all_off') : $r('app.media.icon_select_all'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.Hidden)
          .onClick(() => {
            this.isSelectAllClick()
          })
        Image($r('app.media.ic_public_trash'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .margin({ left: $r('app.float.vp_8') })
          .opacity(this.noteModels.length === 0 || this.swipeDelete ? 0.4 : 1)
      }
      .onClick(() => {
        if (!this.swipeDelete && this.noteModels.length > 0) {
          this.isSelectDelete = !this.isSelectDelete
          this.isSelectAll = false
          this.selectCount = 0
          this.noteModels.forEach((item: NoteModel, index: number) => {
            item.isDelete = false;
          })
        }
      })
    }
    .width('100%')
    .height($r('app.float.vp_56'))
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@Builder
export function MyNotesPageBuilder() {
  MyNotesPage()
}

@ObservedV2
class NoteModel {
  keyID: string = ''
  note: string = ''
  @Trace isDelete: boolean = false
}