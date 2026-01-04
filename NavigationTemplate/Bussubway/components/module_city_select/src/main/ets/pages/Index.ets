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
import { common } from '@kit.AbilityKit';
import { SingleBtn } from '../components/SingleBtn';
import { Utils } from '../common/Utils';
import { ALL_CITY_LIST, HOT_CITY_LIST } from '../common/Constant';
import { CitySelectController, ICityGroup } from '../common/Model';

@ComponentV2
export struct UICitySelect {
  @Param currentCity: string = '';
  @Param recentVisitList: string[] = [];
  @Param controller: CitySelectController = new CitySelectController();
  @Local showSearchRsp: boolean = false;
  @Local searchKey: string = '';
  @Local searchList: string[] = [];
  @Local selectIndex: number = 0;
  @Local isLoading: boolean = false;
  @Local showCrossCityDialog: boolean = false;
  @Local selectedCity: string = '';
  scrollerOut: Scroller = new Scroller();
  scroller: Scroller = new Scroller();
  alphaIndexList: string[] = Utils.generateAlphaList(ALL_CITY_LIST);
  flatList: string[] = [];
  private context: Context = this.getUIContext().getHostContext() as common.UIAbilityContext

  @Computed
  get emptyLabel() {
    if (this.searchKey && this.searchList.length === 0) {
      return '暂未查询相关城市信息';
    }
    return '输入关键词查找结果';
  }

  @Event goBack: (city?: string) => void = () => {
  };
  @Event emitUpdateCityLocation: (city: string) => void = () => {
  };
  @Event emitUpdateRecentCityList: (city: string) => void = () => {
  };

  aboutToAppear(): void {
    this.controller.onBackPressed = () => {
      if (this.showSearchRsp) {
        this.searchKey = '';
        this.searchList = [];
        this.showSearchRsp = false;
        return true;
      }
      return false;
    };

    this.flatList = ALL_CITY_LIST.reduce((acc, obj) => {
      return acc.concat(obj.list);
    }, ['']);
  }

  build() {
    Stack() {
      Scroll(this.scrollerOut) {
        Column() {
          // 自定义头部
          Row() {
            Image($r('app.media.ic_back'))
              .width(40)
              .aspectRatio(1)
              .onClick(() => {
                this.goBack()
              })
            Text('选择城市')
              .fontSize(18)
              .margin({ left: 15 })
              .fontWeight(FontWeight.Bold)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)

          }
          .width('100%')
          .padding({ left: 10 })
          .margin({ bottom: 10 })

          this.TopSearch()
          Stack() {
            Column() {
              Column({ space: 20 }) {
                this.CurrentLocation()
                this.HotCityList()
              }
              .padding({ left: 10, right: 10 })

              this.ListDivider()
              this.AllCityList()
            }
            .alignItems(HorizontalAlign.Start)

            if (this.showSearchRsp) {
              this.SearchRsp()
            }
          }
          .alignContent(Alignment.Top)
        }
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      if (!this.showSearchRsp) {
        this.AlphaIndex()
      }
      this.CrossCityDialog()
    }
    .alignContent(Alignment.End)
    .padding({ bottom: 10 })
  }

  onClickCity(city: string) {
    if (city === this.currentCity) {
      // 选择当前城市，正常返回
      this.goBack(city);
      this.emitUpdateRecentCityList(city);
    } else {
      // 选择其他城市，显示跨城服务弹窗
      this.selectedCity = city;
      this.showCrossCityDialog = true;
    }
  }

  @Builder
  AlphaIndex() {
    AlphabetIndexer({ arrayValue: this.alphaIndexList, selected: this.selectIndex })
      .usingPopup(true)
      .alignStyle(IndexerAlign.Right)
      .padding({ right: 4 })
      .onSelect((tabIndex: number) => {
        this.scrollerOut.scrollEdge(Edge.Bottom);
        this.scroller.scrollToIndex(tabIndex);
      })
  }

  @Builder
  TopSearch() {
    Row({ space: 10 }) {
      Search({ value: $$this.searchKey, placeholder: '请输入名称查询' }).layoutWeight(1)
        .onClick(() => {
          this.showSearchRsp = true;
        })
        .onChange(() => {
          if (!this.searchKey) {
            this.searchList = [];
            return;
          }
          this.searchList = this.flatList.filter(v => v.includes(this.searchKey));
        })

      Text('取消')
        .fontSize(14)
        .fontColor(Color.Black)
        .onClick(() => {
          this.goBack();
        })
    }
    .width('100%')
    .height(66)
    .padding({ left: 10, right: 10, bottom: 10 })
  }

  @Builder
  SearchRsp() {
    Scroll() {
      Column() {
        if (!this.searchList.length) {
          Column({ space: 10 }) {
            Image($r('app.media.ic_empty')).width(56).height(47)
            Text(this.emptyLabel).fontColor('#565656').fontSize(14)
          }
          .width('100%')
          .margin({ top: 200 })
        } else {
          ForEach(this.searchList, (item: string) => {
            Column() {
              Text(item).height(40).onClick(() => {
                this.onClickCity(item);
              })
              Divider()
            }
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(Color.White)
          }, (v: string) => v)
        }
      }
    }
    .padding({ left: 10, right: 10 })
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
    .height('calc(100% - 66vp)')
    .backgroundColor(Color.White)

  }

  @Builder
  CurrentLocation() {
    Column({ space: 10 }) {
      Text('当前定位').fontSize(14).fontWeight(500)
      Row() {
        SingleBtn({
          city: this.currentCity || '无法获取',
          fgColor: $r('app.color.common_theme_color'),
          onClickEvent: () => {
            if (this.currentCity) {
              this.onClickCity(this.currentCity);
            }
          },
        })

        Blank()
        if (this.isLoading) {
          LoadingProgress().width(24).aspectRatio(1).color($r('sys.color.icon_secondary')).margin({ left: 10 })
        } else {
          Text('重新定位')
            .fontSize(14)
            .fontColor($r('app.color.common_theme_color'))
            .onClick(() => {
              this.isLoading = true;
              Utils.applyLocationGlobal(this.context).then(globalSwitch => {
                if (globalSwitch) {
                  Utils.applyLocationPermission().then((cityLoc: string) => {
                    this.isLoading = false;
                    this.emitUpdateCityLocation(cityLoc);
                  })
                } else {
                  this.isLoading = false;
                }
              })
            })
        }

      }
      .width('100%')
      .padding({ right: 10 })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  HotCityList() {
    Column({ space: 10 }) {
      Text('热门城市').fontSize(14).fontWeight(500)

      Grid() {
        ForEach(HOT_CITY_LIST, (item: string) => {
          GridItem() {
            SingleBtn({
              city: item,
              onClickEvent: () => {
                this.onClickCity(item);
              },
            })
          }
        }, (v: string) => v)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(10)
      .rowsGap(10)
      .padding({ right: 40, bottom: 20 })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ListDivider() {
    Row().width('100%').height(8).backgroundColor($r('app.color.common_page_bg'))
  }

  @Builder
  AllCityList() {
    Column() {
      Text('城市列表').fontSize(14)
        .fontWeight(500)
        .height(36)
      List({
        space: 10,
        scroller: this.scroller,
      }) {
        ForEach(ALL_CITY_LIST, (item: ICityGroup) => {
          ListItem() {
            Column() {
              Text(item.name).fontSize(14).fontWeight(500)
              ForEach(item.list, (city: string) => {
                Column() {
                  Text(city)
                    .width('100%')
                    .height(40)
                    .fontSize(14)
                    .fontWeight(400)
                    .onClick(() => {
                      this.onClickCity(city);
                    })
                  Divider()
                }
              }, (v: string) => v)
            }
            .alignItems(HorizontalAlign.Start)
          }
        }, (item: ICityGroup) => item.name)
      }
      .width('100%')
      .height('calc(100% - 36vp)')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      })
      .onScrollIndex((start: number) => {
        this.selectIndex = start;
      })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 10, right: 10 })
  }

  // 不跨城市弹窗
  @Builder
  CrossCityDialog() {
    if (this.showCrossCityDialog) {
      Stack() {
        // 半透明背景遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            this.showCrossCityDialog = false;
          })

        // 弹窗内容
        Column() {
          Text('暂未支持跨城服务')
            .fontSize(16)
            .fontWeight(500)
            .fontColor('#333333')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 15 })

          Text(`您当前所在城市为「${this.currentCity}」`)
            .fontSize(16)
            .fontColor('#666666')
            .textAlign(TextAlign.Center)
          Row() {

          }
          .width('100%')
          .border({ width: { bottom: 1 }, color: '#f2f2f2' })
          .margin({ top: 24, bottom: 24 })

          Text('回到我的城市')
            .fontSize(16)
            .fontColor('#53a0f6')
            .onClick(() => {
              this.showCrossCityDialog = false;
              this.goBack(this.currentCity);
              this.emitUpdateRecentCityList(this.currentCity);
            })
        }
        .width(280)
        .height(170)
        .padding({
          top: 24,
          bottom: 24,
          left: 20,
          right: 20
        })
        .backgroundColor(Color.White)
        .borderRadius(12)
        .shadow({
          radius: 20,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 4
        })
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Center)
    }
  }
}
