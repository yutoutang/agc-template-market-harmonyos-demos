import { MyConfig, TrafficParams } from 'commons';
import { ItemRestriction, SegmentButton, SegmentButtonOptions, SegmentButtonTextItem } from '@kit.ArkUI';
import { pasteboard } from '@kit.BasicServicesKit';
import {
  MyTrafficItem,
  MyTrafficList,
  MyTrafficListChildList,
  MyTrafficListLineList,
  MyTrafficZiZhuMapList,
  MyTrafficZiZhuMapListChild,
  MyTrafficZiZhuMapListChildItem,
} from '../viewModel/MyUniversalModel';
import { getMyTrafficJson } from '../service/myUniversalService';

@Builder
export function TrafficBuilder() {
  Traffic();
}

@Component
struct Traffic {
  @Consume('pageStack') pageStack: NavPathStack;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('token') token: string = '';
  @StorageProp('deviceId') deviceId: string = '';
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';
  @State loading: boolean = false;
  @State tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '接送机' }, { text: '班车信息' }, {
      text: '自助交通',
    }] as ItemRestriction<SegmentButtonTextItem>,
    textPadding: {
      top: 10,
      bottom: 10,
    },
  });
  @State tabSelectedIndexes: number[] = [0];
  @State myTabSelectedIndexes: number = 0;
  @State secondSelectIndex: number = 0;
  @State allData: MyTrafficItem[] = [];
  @State secondTabList: string[] = [];
  // 接送机
  @State transfer: MyTrafficList[] = [];
  // 班车信息——小山村-大广场
  @State busList1: MyTrafficListChildList[] = [];
  // 班车信息——签到酒店- 东莞篮球中心
  @State busList2: MyTrafficListLineList[] = [];
  // 班车信息——签到酒店- 小山村H区/大广场
  @State busList3: MyTrafficListLineList[] = [];
  // 自助交通
  @State selfTransportation: MyTrafficItem = {
    desc: '',
    optionalVehicleModels: '',
    reservationChannel: '',
    tip: '',
    traffic: [],
    ziZhuMapList: [],
  };

  @Builder
  CommonTitle(text: string, icon: string, href: string) {
    Row() {
      Row() {
        Image(`${MyConfig.URL}${icon}`).width(20).margin({ right: 6 });
        Text(text).fontColor('#244AFD').fontSize(16).fontWeight(FontWeight.Bold);
      };
    }.padding({ top: 18, bottom: 14 }).width('100%').justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  DateTitle(text: string) {
    Row() {
      Column().width(3).height(14).backgroundColor('#F2403D').margin({ right: 5 });
      Text(text).fontColor('#000000').fontSize(16).fontWeight(FontWeight.Bold);
    }.width('100%').margin({ bottom: 12, top: 16 });
  }

  @Builder
  ItemCard(text: string, line: string, time: string, desc?: string) {
    Column() {
      Row() {
        Image(`${MyConfig.URL}my2%2Ficon_bus.png?token=4d266e7a-4a8f-4a5b-b75e-815265942a33`)
          .width(15)
          .margin({ right: 6 });
        Text(text)
          .fontColor('#000000')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .lineHeight(21);
      }.margin({ bottom: 12 });

      if (line) {
        Text(line).fontColor('#99000000').fontSize(12).lineHeight(18).fontWeight(FontWeight.Bold);
      }
      Text(time).fontColor('#99000000').fontSize(12).lineHeight(18);
      if (desc) {
        Text(desc).fontColor('#99000000').fontSize(12).lineHeight(18);
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor('#F7F7F7')
    .borderRadius(14);

  }

  @Builder
  SecondTab(text: string, index: number) {
    Column() {
      Text(text)
        .fontSize(12)
        .fontColor(this.secondSelectIndex === index ? '#e6000000' : '#99000000')
        .lineHeight(16)
        .fontWeight(this.secondSelectIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .textAlign(TextAlign.Center);
    }
    .width(100)
    .height(45)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.secondSelectIndex === index ? 'rgba(0,0,0,0.05)' : 'transparent')
    .borderRadius(20)
    .onClick(() => {
      this.secondSelectIndex = index;
    });
  }

  aboutToAppear(): void {
    let params: TrafficParams | undefined =
      this.pageStack.getParamByName('Traffic')[this.pageStack.getParamByName('Traffic').length-
        1] as (TrafficParams | undefined);
    if (params && params.levelOneTap) {
      this.tabSelectedIndexes = [Number(params.levelOneTap)];
      this.myTabSelectedIndexes = Number(params.levelOneTap);
    }
    if (params && params.levelTwoTap) {
      this.secondSelectIndex = Number(params.levelTwoTap);
    }
    this.loadData();
  }

  loadData() {
    getMyTrafficJson().then((res) => {
      this.allData = res.data;
      this.allData.forEach((item: MyTrafficItem) => {
        if (item.tapName === '接送机') {
          this.transfer = item.list as MyTrafficList[];
        }
        if (item.tapName === '班车信息') {
          this.secondTabList = item.tapNameList as string[];
          item.childList?.forEach((childItem) => {

            if (childItem.fileName === 'bus3') {
              this.busList1 = childItem.childLineList as MyTrafficListChildList[];
            }
            if (childItem.fileName === 'bus1') {
              this.busList2 = childItem.childLineList as MyTrafficListLineList[];
            }
            if (childItem.fileName === 'bus2') {
              this.busList3 = childItem.childLineList as MyTrafficListLineList[];
            }
          });
        }
        if (item.tapName === '自助交通') {
          this.selfTransportation = item as MyTrafficItem;
        }
      });
      this.loading = false;
    });
  }

  copyText(text: string) {
    const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    const systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteboardData); // 将数据放入剪切板
    systemPasteboard.getData().then((data) => {
      if (data) {
        this.getUIContext().getPromptAction().showToast({ message: '复制成功' });
      } else {
        this.getUIContext().getPromptAction().showToast({ message: '复制失败' });
      }
    });
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          SegmentButton({
            options: this.tabOptions,
            selectedIndexes: $tabSelectedIndexes,
            onItemClicked: (indexes) => {
              this.myTabSelectedIndexes = indexes;
            },
          })
            .margin({
              top: 12,
              bottom: 12,
            });

          Scroll() {
            if (this.loading) {
              LoadingProgress()
                .layoutWeight(1)
                .width(80);
            } else {
              Column() {
                if (this.myTabSelectedIndexes === 0) {
                  ForEach(this.transfer, (item: MyTrafficList, index) => {
                    this.CommonTitle(item.title, item.icon, item.href);
                    Column() {
                      ForEach(item.list, (it: MyTrafficListChildList, index2) => {
                        this.DateTitle(it.date);
                        Column({ space: 8 }) {
                          ForEach(it.lineList, (i: MyTrafficListLineList, index3) => {
                            this.ItemCard(i.name, i.line, i.time);
                          }, (item: MyTrafficListLineList) => JSON.stringify(item));
                        };
                      }, (it: MyTrafficListChildList) => JSON.stringify(it));
                    }
                    .padding({ bottom: 14, left: 16, right: 16 })
                    .backgroundColor('#ffffff')
                    .borderRadius(15);
                  }, (item: MyTrafficList) => JSON.stringify(item));
                }

                if (this.myTabSelectedIndexes === 1) {
                  Column() {
                    Row() {
                      ForEach(this.secondTabList, (item: string, index) => {
                        this.SecondTab(item, index);
                      }, (item: string) => item);
                    }
                    .justifyContent(this.currentBreakpoint === 'sm' ? FlexAlign.Center : FlexAlign.SpaceAround)
                    .width(this.currentBreakpoint === 'sm' ? '100%' : 540);

                    Column() {
                      // 篮球
                      if (this.secondSelectIndex === 0) {
                        Column({ space: 8 }) {
                          ForEach(this.busList2, (i: MyTrafficListLineList, index3) => {
                            this.ItemCard(i.name, i.line, i.time);
                          }, (item: MyTrafficListLineList) => JSON.stringify(item));
                        }
                        .margin({ top: 16 })
                        .alignItems(HorizontalAlign.Start);
                      }
                      //小山村h区
                      if (this.secondSelectIndex === 1) {
                        Column({ space: 8 }) {
                          ForEach(this.busList3, (i: MyTrafficListLineList, index3) => {
                            this.ItemCard(i.name, i.line, i.time);
                          }, (item: MyTrafficListLineList) => JSON.stringify(item));
                        }
                        .margin({ top: 16 })
                        .alignItems(HorizontalAlign.Start);
                      }
                      // 大广场
                      if (this.secondSelectIndex === 2) {
                        ForEach(this.busList1, (it: MyTrafficListChildList, index2) => {
                          this.DateTitle(it.date);
                          Column({ space: 8 }) {
                            ForEach(it.lineList, (i: MyTrafficListLineList, index3) => {
                              this.ItemCard(i.name, i.line, i.time, i.desc);
                            }, (item: MyTrafficListLineList) => JSON.stringify(item));
                          };
                        }, (item: MyTrafficListChildList) => JSON.stringify(item));
                      }
                    }
                    .padding({ left: 14, right: 14 });
                  }
                  .margin({
                    top: 16,
                  })
                  .padding({
                    top: 16,
                    bottom: 16,
                  })
                  .backgroundColor('#ffffff')
                  .borderRadius(15);
                }

                if (this.myTabSelectedIndexes === 2) {
                  Column() {
                    Text() {
                      Span('乘坐高铁抵达：')
                        .fontWeight(700);
                      Span(this.selfTransportation.optionalVehicleModels).fontWeight(500);
                    }.fontSize(13)
                    .lineHeight(18)
                    .fontColor('#e6000000');

                    Text() {
                      Span('乘坐飞机抵达：')
                        .fontWeight(700);
                      Span(this.selfTransportation.reservationChannel).fontWeight(500);
                    }.fontSize(13)
                    .lineHeight(18)
                    .fontColor('#e6000000');

                    Divider()
                      .color($r('sys.color.comp_background_emphasize'))
                      .width('100%')
                      .margin({ top: 20, bottom: 8 });
                    ForEach(this.selfTransportation.ziZhuMapList, (item: MyTrafficZiZhuMapList, index) => {
                      Column() {
                        Row() {
                          Column() {
                            Text(item.title)
                              .fontSize(14)
                              .fontWeight(FontWeight.Bold)
                              .lineHeight(20)
                              .fontColor('#000000');

                          }.layoutWeight(1).margin({ right: 10 }).alignItems(HorizontalAlign.Start);

                        }.width('100%').margin({ top: 12, bottom: 8 });

                        Column() {
                          ForEach(item.traffic,
                            (ziZhuMapListChild: MyTrafficZiZhuMapListChild, idx: number) => {
                              Row() {
                                Text(ziZhuMapListChild.name)
                                  .fontSize(12)
                                  .fontColor('#e6000000')
                                  .lineHeight(18);
                                Column({ space: 12 }) {
                                  ForEach(ziZhuMapListChild.children,
                                    (itemAddress: MyTrafficZiZhuMapListChildItem, index1: number) => {
                                      Column() {
                                        Row() {
                                          Text() {
                                            Span(`${itemAddress.copyText}${itemAddress.desc}`)
                                              .fontColor('#99000000');
                                          }.fontSize(12).layoutWeight(1).margin({ right: 15 }).lineHeight(18);

                                          Image(`${MyConfig.URL}my2%2Fmy_copy.svg?token=9272c2e3-0c1d-44a3-b695-d05c6f74a86d`)
                                            .width(16)
                                            .height(16)
                                            .onClick(() => {
                                              this.copyText(itemAddress.copyText);
                                            });
                                        };
                                      };
                                    }, (item: MyTrafficZiZhuMapListChildItem) => JSON.stringify(item));
                                }.layoutWeight(1);
                              }
                              .alignItems(VerticalAlign.Top)
                              .padding({
                                top: 12,
                                bottom: 12,
                              })
                              .width('100%');

                              if (idx !== item.traffic.length - 1) {
                                Divider()
                                  .color($r('sys.color.comp_background_emphasize'))
                                  .width('100%');
                              }
                            }, (item: MyTrafficZiZhuMapListChild) => JSON.stringify(item));

                        }.padding({
                          left: 12,
                          right: 12,
                        })
                        .backgroundColor('#F7F7F7')
                        .borderRadius(14);
                      };
                    }, (item: MyTrafficZiZhuMapList) => JSON.stringify(item));

                  }
                  .margin({ top: 16 })
                  .alignItems(HorizontalAlign.Start)
                  .padding({
                    top: 23,
                    bottom: 23,
                    left: 14,
                    right: 14,
                  })
                  .backgroundColor('#ffffff')
                  .borderRadius(15);
                }
              }
              .constraintSize({ minHeight: '100%' })
              .padding({ bottom: 100 });
            }
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring);
        }
        .padding({ left: 16, right: 16 });
      };
    }
    .title('交通出行')
    .backgroundColor('#F1F3F5')
    .padding({ top: px2vp(this.topRectHeight) });
  }
}