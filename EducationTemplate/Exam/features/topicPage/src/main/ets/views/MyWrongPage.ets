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

import { QuestionsRouterModel, TopicItemType } from 'answer_questions';
import { PreferenceUtil, PreferConstant, TopBar } from 'commonlib';
import { RouterMap, RouterModule } from 'router_module';

@ComponentV2
export struct MyWrongItem {
  @Event changeCollectionItem: (idx: number) => void = () => {
  };
  @Param @Require item: WrongModel
  @Param @Require isSelectDelete: boolean
  @Param @Require idx: number

  build() {
    Column() {
      // 单选
      this.singleChoiceBuilder()
      // 错题标题
      this.titleBuilder()
    }
    .alignItems(HorizontalAlign.Start)
    .padding($r('app.float.vp_16'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.vp_16'))
    .margin({ bottom: $r('app.float.vp_8') })
    .width('100%')
  }

  /**
   * 错题标题
   */
  @Builder
  titleBuilder() {
    Text(this.item.title)
      .fontColor($r('sys.color.font_primary'))
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(FontWeight.Regular)
      .lineHeight($r('app.float.vp_20'))
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }

  /**
   * 单选
   */
  @Builder
  singleChoiceBuilder() {
    Row() {
      Text($r('app.string.single_choice'))
        .textAlign(TextAlign.Center)
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Caption_L'))
        .fontWeight(FontWeight.Regular)
        .margin({ bottom: $r('app.float.vp_4') })
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_24'))
        .borderRadius($r('app.float.vp_8'))
        .backgroundColor('#4c5dc5')
      // 是否删除按钮
      Row() {
        Image(this.item.isDelete ? $r('app.media.icon_Checked') : $r('app.media.icon_ans_common'))
          .width($r('app.float.vp_20'))
          .height($r('app.float.vp_20'))
      }
      .width($r('app.float.vp_50'))
      .height($r('app.float.vp_24'))
      .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.None)
      .justifyContent(FlexAlign.End)
      .onClick(() => {
        this.changeCollectionItem(this.idx)
      })
    }.width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@ComponentV2
export struct MyWrongIndexPage {
  @Local isSelectDelete: boolean = false
  @Local wrongQues: WrongModel[] = []
  wrongArr: TopicItemType[] = []
  @Local isSelectAll: boolean = false
  @Local selectCount: number = 0
  @Local swipeDelete: boolean = false

  aboutToAppear(): void {
    this.initData()
  }

  @Builder
  topBuilder() {
    Row() {
      // 我的错题
      TopBar({
        onClickBack: () => {
          RouterModule.pop()
        },
        title: $r('app.string.my_wrong')
      })
      Row() {
        Image(!this.isSelectAll ? $r('app.media.icon_select_all_off') : $r('app.media.icon_select_all'))
          .height($r('app.float.vp_40'))
          .width($r('app.float.vp_40'))
          .onClick(() => {
            this.isSelAll()
          })
          .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.Hidden)
        Image($r('app.media.ic_public_trash'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .opacity(this.swipeDelete ? 0.4 : 1)
          .margin({ left: $r('app.float.vp_8') })
      }
      .onClick(() => {
        if (!this.swipeDelete && this.wrongQues.length > 0) {
          this.isSelectDelete = !this.isSelectDelete
          this.selectCount = 0
          this.isSelectAll = false
          this.wrongQues.forEach((item: WrongModel) => {
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

  @Builder
  itemEndComponent(idx: number) {
    Row() {
      Image($r('app.media.ic_public_trash_red'))
        .width($r('app.float.vp_24'))
        .height($r('app.float.vp_24'))
        .onClick(() => {
          this.swipeDelete = false
          this.deleteData(idx)
        })
    }.margin({ right: $r('app.float.vp_16') })
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  build() {
    Column() {
      this.topBuilder()
      Divider().color($r('sys.color.comp_divider'))
      if (this.wrongQues.length <= 0) {
        Text('暂无错题记录')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.icon_secondary'))
          .height('100%')
      } else {
        // 错题列表
        this.wrongListBuilder()
      }
    }
    .layoutWeight(1)
    .height('100%')
  }

  /**
   * 错题列表
   */
  @Builder
  wrongListBuilder() {
    Column() {
      List() {
        ForEach(this.wrongQues, (item: WrongModel, idx: number) => {
          ListItem() {
            MyWrongItem({
              isSelectDelete: this.isSelectDelete,
              item: item,
              changeCollectionItem: () => {
                item.isDelete = !item.isDelete
                if (item.isDelete) {
                  this.selectCount++;
                } else {
                  this.selectCount--;
                }
                if (this.selectCount < this.wrongQues.length) {
                  this.isSelectAll = false
                } else {
                  this.isSelectAll = true
                }
              },
              idx: idx
            }).margin({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), })
          }
          .transition({ type: TransitionType.Delete, opacity: 0 })
          .swipeAction({
            edgeEffect: SwipeEdgeEffect.None,
            end: {
              actionAreaDistance: 26,
              builder: () => {
                this.itemEndComponent(idx)
              },
              onStateChange: (state: SwipeActionState) => {
                if (state === SwipeActionState.EXPANDED) {
                  this.isSelectDelete = false
                  this.swipeDelete = true
                } else if (state === SwipeActionState.COLLAPSED) {
                  this.swipeDelete = false
                }
              }
            }
          })
          .onClick(() => {
            if (this.wrongArr.length > 0) {
              let routerModel: QuestionsRouterModel = new QuestionsRouterModel()
              routerModel.datalist = [this.wrongArr[idx]]
              routerModel.sourceType = '我的错题'
              RouterModule.push({ url: RouterMap.ANSWER_QUESTIONS_PAGE, param: routerModel })
            }
          })
        }, (item: WrongModel, idx: number) => JSON.stringify(item.keyID + idx + ''))
        // 删除
        this.deleteBuilder()
      }
      .width('auto')
      .height('auto')
      .layoutWeight(1)
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
    }.layoutWeight(1)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({
      top: $r('app.float.vp_12'),
    })
  }

  /**
   * 删除
   */
  @Builder
  deleteBuilder() {
    ListItem() {
      Row() {
        Row() {
          Image($r('app.media.icon_delete'))
            .width($r('app.float.vp_25'))
            .height($r('app.float.vp_25'))
            .margin($r('app.float.vp_8'))
          Text('删除')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize($r('sys.float.Body_L'))
            .textAlign(TextAlign.Center)
        }
        .opacity(this.selectCount > 0 ? 1 : 0.4)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .borderRadius($r('app.float.vp_20'))
        .backgroundColor('#4c5dc4')
      }
      .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.Hidden)
      .height($r('app.float.vp_40'))
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), })
      .margin({ top: $r('app.float.vp_38') })
      .onClick(() => {
        // 删除选中
        this.deleteSelectData()
      })
    }
  }

  /**
   * 数据初始化
   */
  async initData() {
    try {
      let arr: TopicItemType[] =
        PreferenceUtil.getInstance().get(PreferConstant.ERROR_RECORDS, []) as TopicItemType[];
      arr.sort((a, b) => b.jlStamp - a.jlStamp)
      this.wrongArr = arr;
      if (arr && arr.length > 0) {
        arr.forEach((element: TopicItemType) => {
          let model: WrongModel = new WrongModel()
          model.isDelete = false
          model.keyID = element.keyID
          model.title = element.title
          this.wrongQues.push(model)
        })
      }
      this.swipeDelete = this.wrongQues.length === 0
    } catch (e) {
      this.wrongArr = [];
      this.wrongQues = []
      this.swipeDelete = true
    }
  }

  // 移除
  deleteData(idx: number) {
    this.wrongQues.splice(idx, 1)
    this.swipeDelete = this.wrongQues.length === 0
    this.wrongArr.splice(idx, 1)
    PreferenceUtil.getInstance().put(PreferConstant.ERROR_RECORDS, this.wrongArr)
  }

  // 移除所选中的
  deleteSelectData() {
    if (this.selectCount === 0) {
      return
    }
    let arr: string[] = []
    this.wrongQues.forEach((model: WrongModel) => {
      if (model.isDelete) {
        arr.push(model.keyID)
      }
    })
    this.wrongQues = this.wrongQues.filter((it: WrongModel) => !it.isDelete)
    this.wrongArr = this.wrongArr.filter((it: TopicItemType) => !arr.includes(it.keyID))
    PreferenceUtil.getInstance().put(PreferConstant.ERROR_RECORDS, this.wrongArr)
    if (this.wrongQues.length === 0) {
      this.isSelectDelete = false
    }
    this.swipeDelete = this.wrongQues.length === 0
  }

  // 是否全选
  isSelAll() {
    if (!this.isSelectAll) {
      this.wrongQues.forEach((item: WrongModel) => {
        item.isDelete = true;
      })
      this.isSelectAll = true
      this.selectCount = this.wrongQues.length;
    } else {
      this.wrongQues.forEach((item: WrongModel) => {
        item.isDelete = false;
      })
      this.isSelectAll = false
      this.selectCount = 0
    }
  }
}

@Builder
export function MyWrongPageBuilder() {
  MyWrongIndexPage()
}

@ObservedV2
class WrongModel {
  title: string = ''
  keyID: string = ''
  @Trace isDelete: boolean = false
}
