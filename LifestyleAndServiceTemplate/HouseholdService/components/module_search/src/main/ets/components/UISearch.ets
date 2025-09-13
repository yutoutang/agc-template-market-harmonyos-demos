/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { LengthMetrics } from '@kit.ArkUI';
import { CommonUtils, IGoodInfo, UIEmpty, } from 'module_base'
import { UISearchController } from '../common/Utils';

@ComponentV2
export struct UISearch {
  @Param recommendList: string[] = [];
  @Param list: IGoodInfo[] = [];
  @Param controller: UISearchController = new UISearchController();
  @Event query: (content: string) => Promise<void> = () => Promise.resolve();
  @Event goBack: () => void = () => {
  };
  @Event jumpDetail: (good: IGoodInfo) => void = () => {
  };
  @Local searchRspList: IGoodInfo[] = [];
  @Local searchText: string = '';
  @Local showSearchRsp: boolean = false;

  @Monitor('list')
  onChange(monitor: IMonitor) {
    this.searchRspList = monitor.value()?.now as IGoodInfo[];
  }

  aboutToAppear(): void {
    this.controller.onBackPressed = () => {
      return this.onBack();
    }
  }

  onBack(): boolean {
    if (this.showSearchRsp) {
      this.initSearchParam();
      return true;
    }
    return false;
  }

  build() {
    Column() {
      this.TopBar()
      Stack() {
        if (this.recommendList.length) {
          this.Recommend()
        }
        if (this.showSearchRsp) {
          this.SearchRsp()
        }
      }
      .alignContent(Alignment.Top)
    }
    .width('100%')
    .height('100%')
  }

  initSearchParam() {
    this.showSearchRsp = false;
    this.searchText = '';
    this.searchRspList = [];
  }

  searchQuery(input: string) {
    this.searchText = input;
    if (!this.searchText) {
      this.initSearchParam();
      return;
    }
    this.query(this.searchText).then(() => {
      this.showSearchRsp = true;
    });
  }

  @Builder
  TopBar() {
    Row({ space: 10 }) {
      Search({ value: $$this.searchText, placeholder: '请输入名称查询' })
        .layoutWeight(1)
        .onChange(() => {
          this.searchQuery(this.searchText);
        })
      Text('取消')
        .fontSize(14)
        .fontColor(Color.Black)
        .onClick(() => {
          this.goBack();
        })
    }
    .height(40)
    .width('100%')
  }

  @Builder
  Recommend() {
    Column({ space: 10 }) {
      Text('热门搜索').fontSize(14).fontWeight(500)
      Flex({
        wrap: FlexWrap.Wrap,
        space: { main: new LengthMetrics(10), cross: new LengthMetrics(10) },
        justifyContent: FlexAlign.SpaceBetween,
      }) {
        ForEach(this.recommendList, (v: string) => {
          Button() {
            Text(v)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(500)
          }
          .backgroundColor($r('app.color.grey_5'))
          .padding({
            top: 4,
            bottom: 4,
            left: 8,
            right: 8,
          })
          .onClick(() => {
            this.searchQuery(v);
          })
        }, (v: string) => v)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .margin({ top: 10 })

  }

  @Builder
  SearchRsp() {
    Column() {
      if (this.searchRspList.length) {
        List() {
          ForEach(this.searchRspList, (v: IGoodInfo) => {
            ListItem() {
              Column() {
                Row({ space: 10 }) {
                  Image(CommonUtils.handleImgUrl(v.image)).width(84).height(70).borderRadius(4)
                  Column({ space: 10 }) {
                    Text(v.title).fontSize(14).fontWeight(500)
                    Text(v.subTitle).fontSize(12).fontWeight(400).fontColor($r('app.color.common_grey'))
                  }
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .margin({ top: 10, bottom: 10 })
                .onClick(() => {
                  this.jumpDetail(v);
                })

                Divider()
              }
              .alignItems(HorizontalAlign.Start)
            }

          }, (v: IGoodInfo) => v.id.toString() + v.subIndex)
        }
        .width('100%')
        .height('100%')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .scrollBar(BarState.Off)
      } else {
        UIEmpty().margin({ top: 150 })
      }
    }
    .width('100%')
    .height('calc(100% - 40vp)')
    .backgroundColor(Color.White)
  }
}

