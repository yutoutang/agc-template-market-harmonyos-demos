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
export struct MyCollectionItem {
  @Event changeCollectionItem: (idx: number) => void = () => {
  };
  @Param @Require item: CollectionModel
  @Param @Require isSelectDelete: boolean
  @Param @Require idx: number

  build() {
    Column() {
      Row() {
        // 单选
        this.singleChoiceBuilder()
        // 父组件 点击右上角删除按钮显示  否则不显示
        this.isDeleteButtonBuilder()
      }.width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // 收藏内容
      this.contentBuilder()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding($r('app.float.vp_16'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.vp_16'))
    .margin({ bottom: $r('app.float.vp_8') })
  }

  /**
   * 收藏内容
   */
  @Builder
  contentBuilder() {
    Text(this.item.title)
      .fontColor($r('sys.color.font_primary'))
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(FontWeight.Regular)
      .maxLines(2)
      .lineHeight($r('app.float.vp_20'))
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }

  /**
   * 是否删除按钮
   */
  @Builder
  isDeleteButtonBuilder() {
    Row() {
      Image(this.item.isDelete ? $r('app.media.icon_Checked') : $r('app.media.icon_ans_common'))
        .height($r('app.float.vp_20'))
        .width($r('app.float.vp_20'))
    }
    .height($r('app.float.vp_24'))
    .width($r('app.float.vp_50'))
    .justifyContent(FlexAlign.End)
    .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.None)
    .onClick(() => {
      this.changeCollectionItem(this.idx)
    })
  }

  /**
   * 单选
   */
  @Builder
  singleChoiceBuilder() {
    Text($r('app.string.single_choice'))
      .width($r('app.float.vp_40'))
      .height($r('app.float.vp_24'))
      .textAlign(TextAlign.Center)
      .borderRadius($r('app.float.vp_8'))
      .backgroundColor('#4c5dc5')
      .fontColor($r('sys.color.font_on_primary'))
      .fontSize($r('sys.float.Caption_L'))
      .fontWeight(FontWeight.Regular)
      .margin({ bottom: $r('app.float.vp_4') })
  }
}

@ComponentV2
export struct MyCollectionPage {
  @Local isSelectDelete: boolean = false
  @Local collectionQues: CollectionModel[] = []
  // 收藏集合
  collectionArr: TopicItemType[] = []
  @Local isSelectAll: boolean = false
  @Local selectCount: number = 0
  @Local swipeDelete: boolean = false

  aboutToAppear(): void {
    this.initData()
  }

  /**
   * 顶部
   */
  @Builder
  topBuilder() {
    Row() {
      // 我的收藏
      TopBar({
        onClickBack: () => {
          RouterModule.pop()
        },
        title: $r('app.string.my_collection')
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
        if (!this.swipeDelete && this.collectionQues.length > 0) {
          this.isSelectDelete = !this.isSelectDelete
          this.selectCount = 0
          this.isSelectAll = false
          this.collectionQues.forEach((item: CollectionModel) => {
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
  itemEnd(idx: number) {
    Row() {
      Image($r('app.media.ic_public_trash_red'))
        .width($r('app.float.vp_24'))
        .height($r('app.float.vp_24'))
        .onClick(() => {
          this.deleteData(idx)
          this.swipeDelete = false
        })
    }
    .margin({ right: $r('app.float.vp_16') })
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  build() {
    Column() {
      this.topBuilder()
      Divider().color($r('sys.color.comp_divider'))
      if (this.collectionQues.length <= 0) {
        Text('暂无收藏记录')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.icon_secondary'))
          .height('100%')
      } else {
        // 收藏列表
        this.collectionListBuilder()
      }
    }
    .layoutWeight(1)
    .height('100%')
  }

  /**
   * 收藏列表
   */
  @Builder
  collectionListBuilder() {
    Column() {
      List() {
        ForEach(this.collectionQues, (item: CollectionModel, idx: number) => {
          ListItem() {
            MyCollectionItem({
              item: item,
              isSelectDelete: this.isSelectDelete,
              changeCollectionItem: () => {
                item.isDelete = !item.isDelete
                if (item.isDelete) {
                  this.selectCount++;
                } else {
                  this.selectCount--;
                }
                if (this.selectCount < this.collectionQues.length) {
                  this.isSelectAll = false
                } else {
                  this.isSelectAll = true
                }
              },
              idx: idx
            })
              .margin({
                left: $r('app.float.vp_16'),
                right: $r('app.float.vp_16'),
              })
          }
          .transition({ type: TransitionType.Delete, opacity: 0 })
          .swipeAction({
            edgeEffect: SwipeEdgeEffect.None,
            end: {
              builder: () => {
                this.itemEnd(idx)
              },
              actionAreaDistance: 26,
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
            if (this.collectionArr.length > 0) {
              let routerModel: QuestionsRouterModel = new QuestionsRouterModel()
              routerModel.sourceType = '我的收藏'
              routerModel.datalist = [this.collectionArr[idx]]
              RouterModule.push({ url: RouterMap.ANSWER_QUESTIONS_PAGE, param: routerModel })
            }
          })
        }, (item: CollectionModel, idx: number) => JSON.stringify(item.keyID + idx + ''))
        // 删除按钮
        this.deleteButtonBuilder()
      }
      .layoutWeight(1)
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
    .padding({
      top: $r('app.float.vp_12'),
    })
    .layoutWeight(1)
    .backgroundColor($r('sys.color.comp_background_gray'))
  }

  /**
   * 删除按钮
   */
  @Builder
  deleteButtonBuilder() {
    ListItem() {
      Row() {
        Row() {
          Image($r('app.media.icon_delete'))
            .width($r('app.float.vp_25'))
            .height($r('app.float.vp_25'))
            .margin($r('app.float.vp_8'))
          Text('删除')
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
        }
        .opacity(this.selectCount > 0 ? 1 : 0.4)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .backgroundColor('#4c5dc4')
        .width('100%')
        .borderRadius($r('app.float.vp_20'))
      }
      .height($r('app.float.vp_40'))
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), })
      .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.Hidden)
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
  initData() {
    try {
      let arr: TopicItemType[] =
        PreferenceUtil.getInstance().get(PreferConstant.EXAM_PREFER_COLLECT, []) as TopicItemType[];
      arr.sort((a, b) => b.jlStamp - a.jlStamp)
      this.collectionArr = arr;
      if (arr && arr.length > 0) {
        arr.forEach((element: TopicItemType) => {
          let model: CollectionModel = new CollectionModel()
          model.title = element.title
          model.keyID = element.keyID
          model.isDelete = false
          this.collectionQues.push(model)
        })
      }
      this.swipeDelete = this.collectionQues.length === 0
    } catch (e) {
      this.collectionArr = [];
      this.collectionQues = []
      this.swipeDelete = true
    }
  }

  // 移除
  async deleteData(idx: number) {
    this.collectionQues.splice(idx, 1)
    this.swipeDelete = this.collectionQues.length === 0
    this.collectionArr.splice(idx, 1)
    // 更新
    PreferenceUtil.getInstance().put(PreferConstant.EXAM_PREFER_COLLECT, this.collectionArr)
  }

  // 是否全选
  isSelAll() {
    if (!this.isSelectAll) {
      this.collectionQues.forEach((item: CollectionModel) => {
        item.isDelete = true;
      })
      this.isSelectAll = true
      this.selectCount = this.collectionQues.length;
    } else {
      this.collectionQues.forEach((item: CollectionModel) => {
        item.isDelete = false;
      })
      this.isSelectAll = false
      this.selectCount = 0
    }
  }

  // 移除所选中的
  async deleteSelectData() {
    if (this.selectCount === 0) {
      return
    }
    let arr: string[] = []
    this.collectionQues.forEach((model: CollectionModel) => {
      if (model.isDelete) {
        arr.push(model.keyID)
      }
    })
    this.collectionArr = this.collectionArr.filter((it: TopicItemType) => !arr.includes(it.keyID))
    this.collectionQues = this.collectionQues.filter((it: CollectionModel) => !it.isDelete)
    // 更新
    PreferenceUtil.getInstance().put(PreferConstant.EXAM_PREFER_COLLECT, this.collectionArr)
    if (this.collectionQues.length === 0) {
      this.isSelectDelete = false
    }
    this.swipeDelete = this.collectionQues.length === 0
  }
}

@Builder
export function MyCollectionPageBuilder() {
  MyCollectionPage()
}

@ObservedV2
class CollectionModel {
  title: string = ''
  keyID: string = ''
  @Trace isDelete: boolean = false
}