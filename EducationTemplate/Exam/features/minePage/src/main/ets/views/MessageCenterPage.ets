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

import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointType, TopBar, RouterModule } from 'commonlib';
import { MessageItem, NumbObj } from '../viewModel/MessageModel';
import { MineVM } from '../viewModel/MineVM';

@ComponentV2
export struct MessageCenterPage {
  @Local isSelectDelete: boolean = false;
  @Local swiperLeft: boolean = false;
  @Local isAll: boolean = false;
  @Local selectCount: number = 0;
  // 在AppStorageV2中创建一个key为Sample的键值对（如果存在，则返回AppStorageV2中的数据），并且和prop关联
  @Local propNumbObj: NumbObj = AppStorageV2.connect(NumbObj, () => new NumbObj())!;
  mineVM: MineVM = MineVM.instance;

  build() {
    Column() {
      // 顶部
      this.topBuilder();
      Divider().color($r('sys.color.comp_divider'));
      Column() {
        if (this.propNumbObj.listArr.length > 0) {
          // 消息列表
          this.MessageItemsBuilder();
          // 删除按钮
          this.deleteButtonBuilder();
        } else {
          Text('当前暂无消息通知。')
            .height('100%')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.icon_secondary'));
        }
      }
      .layoutWeight(1)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  /**
   * 删除按钮
   */
  @Builder
  deleteButtonBuilder() {
    if (this.isSelectDelete) {
      Row() {
        Image($r('app.media.icon_delete'))
          .height($r('app.float.vp_24'))
          .width($r('app.float.vp_24'));
        Text('删除')
          .margin({ left: $r('app.float.vp_8') })
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium);
      }
      .opacity(this.selectCount > 0 ? 1 : 0.4)
      .width($r('app.float.vp_312'))
      .backgroundColor('#4c5dc4')
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)
      .padding({ top: $r('app.float.vp_8'), bottom: $r('app.float.vp_8') })
      .onClick(() => {
        if (this.selectCount > 0) {
          // 删除选中
          this.deleteSelectData();
        }
      });
    }
  }

  // 移除所选中的
  deleteSelectData() {
    this.isSelectDelete = false;
    this.propNumbObj.listArr = this.propNumbObj.listArr.filter((it: MessageItem) => it.isDelete === false);
  }

  // 是否全选
  isAllClick() {
    if (!this.isAll) {
      this.propNumbObj.listArr.forEach((item: MessageItem) => {
        item.isDelete = true;
      });
      this.selectCount = this.propNumbObj.listArr.length;
      this.isAll = true;
    } else {
      this.propNumbObj.listArr.forEach((item: MessageItem) => {
        item.isDelete = false;
      });
      this.selectCount = 0;
      this.isAll = false;
    }
  }

  /**
   * 我的课程列表
   */
  @Builder
  MessageItemsBuilder() {
    List({ space: 8 }) {
      ForEach(this.propNumbObj.listArr, ((item: MessageItem, index: number) => {
        ListItem() {
          Row() {
            Row() {
              Image(item.icon).width($r('app.float.vp_40')).height($r('app.float.vp_40')).margin($r('app.float.vp_12'));
              Column() {
                Text(item.title)
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('sys.float.Body_L'))
                  .fontWeight(FontWeight.Regular);
                Text(item.subtitle)
                  .fontColor($r('sys.color.font_secondary'))
                  .fontWeight(FontWeight.Regular)
                  .width($r('app.float.vp_170'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .fontSize($r('sys.float.Caption_L'));
              }.alignItems(HorizontalAlign.Start);
            }
            .layoutWeight(1)

            Row() {
              Text(item.time)
                .fontColor($r('sys.color.font_secondary'))
                .margin({ right: $r('app.float.vp_6') })
                .fontSize($r('sys.float.Caption_M'))
                .fontWeight(FontWeight.Regular);
              // 父组件 点击右上角删除按钮显示  否则不显示
              if (this.isSelectDelete) {
                Row() {
                  Image(item.isDelete ? $r('app.media.icon_Checked') : $r('app.media.icon_ans_common'))
                    .margin({ right: $r('app.float.vp_8') })
                    .width($r('app.float.vp_20'))
                    .height($r('app.float.vp_20'));
                }
                .margin({ right: $r('app.float.vp_6') })
                .height($r('app.float.vp_24'))
                .onClick(() => {
                  item.isDelete = !item.isDelete;
                  if (item.isDelete) {
                    this.selectCount++;
                  } else {
                    this.selectCount--;
                  }
                  if (this.selectCount < this.propNumbObj.listArr.length) {
                    this.isAll = false;
                  } else {
                    this.isAll = true;
                  }
                });
              }
            }.margin({ top: $r('app.float.vp_10') })
            .layoutWeight(1)
            .justifyContent(FlexAlign.End)
            .alignItems(VerticalAlign.Center);
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Top)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .borderRadius($r('app.float.vp_16'));
        }
        .layoutWeight(1)
        .clip(true)
        .transition({ type: TransitionType.Delete, opacity: 1 })
        .swipeAction({
          edgeEffect: SwipeEdgeEffect.None,
          end: {
            builder: () => {
              this.courseItemEnd(index);
            },
            actionAreaDistance: 26,
            onStateChange: (state: SwipeActionState) => {
              if (state === SwipeActionState.EXPANDED) {
                this.swiperLeft = true;
                this.isSelectDelete = false;
              } else if (state === SwipeActionState.COLLAPSED) {
                this.swiperLeft = false;
              }
            },
          }
        });
      }), (item: MessageItem, index: number) => item.id + index);
    }
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
      top: $r('app.float.vp_20'),
      bottom: $r('app.float.vp_46')
    })
    .width('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .lanes(new BreakpointType<number>({
      sm: 1,
      md: 2,
      lg: 3,
      xl: 3
    }).getValue(this.mineVM.breakPointModel.currentBreakpoint), 12);
  }

  @Builder
  courseItemEnd(index: number) {
    Row() {
      Image($r('app.media.ic_public_trash_red'))
        .width($r('app.float.vp_40'))
        .margin({ left: $r('app.float.vp_12') })
        .height($r('app.float.vp_40'))
        .onClick(() => {
          this.propNumbObj.listArr.splice(index, 1);
          this.swiperLeft = false;
        });
    }.padding($r('app.float.vp_4')).justifyContent(FlexAlign.SpaceEvenly);
  }

  /**
   * 顶部
   */
  @Builder
  topBuilder() {
    Row() {
      TopBar({
        onClickBack: () => {
          RouterModule.pop();
        },
        title: '消息中心'
      });
      Row() {
        Image(this.isAll ? $r('app.media.icon_select_all') : $r('app.media.icon_select_all_off'))
          .onClick(() => {
            this.isAllClick();
          })
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.Hidden);
        Image($r('app.media.ic_public_trash'))
          .margin({ left: $r('app.float.vp_8') })
          .height($r('app.float.vp_40'))
          .width($r('app.float.vp_40'))
          .opacity(this.propNumbObj.listArr.length === 0 || this.swiperLeft ? 0.4 : 1);
      }
      .onClick(() => {
        if (!this.swiperLeft && this.propNumbObj.listArr.length > 0) {
          this.isSelectDelete = !this.isSelectDelete;
          if (!this.isSelectDelete) {
            this.isAll = false;
            this.selectCount = 0;
            this.propNumbObj.listArr.forEach((item: MessageItem) => {
              item.isDelete = false;
            });
          }
        }
      });
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height($r('app.float.vp_56'))
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') });
  }
}

@Builder
export function MessageCenterBuilder() {
  MessageCenterPage();
}




