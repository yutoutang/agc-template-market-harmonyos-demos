import { promptAction } from '@kit.ArkUI';
import {
  Constant,
  DETAIL_MAP,
  HouseCard,
  HouseTabBarModule,
  HOUSE_TAB,
  IBasicHouse,
  TitleBar,
  FullLoadingComponent,
} from 'foundation';
import { HouseHistory } from '../model/Index';
import { MineVM } from '../viewmodel/MineVM';

@Builder
export function HistoryBuilder() {
  History();
}

@ComponentV2
export struct History {
  vm: MineVM = MineVM.instance;
  @Local inEdit: boolean = false;

  aboutToDisappear(): void {
    this.vm.houseTypeIndex = 0;
  }

  @Computed
  get checkedCount() {
    let count = 0;
    this.vm.checkedHouses.forEach(house => {
      house.houses.forEach((() => {
        count += 1;
      }));
    });
    return count;
  }

  @Computed
  get navPathName() {
    let pathName = DETAIL_MAP.get(this.vm.houseTypeIndex);
    return pathName;
  }

  @Computed
  get editStatus() {
    return this.vm.historyList.length && this.vm.historyList.some(item => item.houses.length);
  }

  @Builder
  historyListHeader(date: string) {
    Text(date)
      .fontSize(14)
      .opacity(0.6)
      .fontColor($r('sys.color.black'))
      .width(Constant.FULL_PERCENT)
      .textAlign(TextAlign.Start)
      .margin({ bottom: 8 });
  }

  @Builder
  EmptyBuilder() {
    Column() {
      Image($r('app.media.history_empty')).size({ height: 120, width: 120 });
      Text('暂无浏览结果')
        .fontSize(14)
        .opacity(0.4)
        .width(Constant.FULL_PERCENT)
        .textAlign(TextAlign.Center);
    }.margin({ top: 120 });
  }

  @Builder
  historyHeader() {
    Row() {
      Row({ space: 24 }) {
        ForEach(HOUSE_TAB, (item: HouseTabBarModule, index: number) => {
          Stack({ alignContent: Alignment.Center }) {
            if (this.vm.houseTypeIndex === index) {
              Image($r('app.media.oval')).size({ width: 12, height: 12 });
            }
            Text(item.title)
              .fontColor($r('sys.color.black'))
              .fontSize(14)
              .enabled(!this.inEdit)
              .fontWeight(this.vm.houseTypeIndex === index ? FontWeight.Bold : FontWeight.Regular)
              .opacity(this.vm.houseTypeIndex === index ? 0.9 : 0.6)
              .onClick(() => {
                // 切换先清空
                this.vm.loading = true;
                this.vm.historyList = [];
                this.vm.houseTypeIndex = index;
                this.vm.getHistoryList();
              });
          };
        }, (item: HouseTabBarModule, index: number) => item.title.toString());
      };

      if (this.editStatus) {
        Row({ space: 6 }) {
          Image(this.inEdit ? $r('app.media.ic_done') : $r('app.media.ic_edit')).size({ width: 16, height: 16 });
          Text(this.inEdit ? '完成' : '管理').fontSize(14).opacity(0.9).fontColor($r('sys.color.black'));
        }.onClick(() => {
          this.vm.checkedHouses = [];
          this.inEdit = !this.inEdit;
        });
      }
    }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  historyListBuilder() {
    if (this.vm.historyList.length && !this.vm.loading) {
      List({ space: 12 }) {
        ForEach(this.vm.historyList, (item: HouseHistory) => {
          if (item.houses.length) {
            ListItemGroup({ header: this.historyListHeader(item.date) }) {
              ListItem() {
                List({ space: 12 }) {
                  ForEach(item.houses, (house: IBasicHouse) => {
                    HouseCard({
                      houseOptions: {
                        house: house,
                        type: this.vm.houseTypeIndex + 1,
                        enableEdit: true,
                        inEdit: this.inEdit,
                        allowFollow: true
                      },
                      selectHouse: (value) => {
                        this.vm.handleCheckBoxResult(value, item.date, house.houseId);
                      },
                    });
                  }, (house: IBasicHouse) => house.houseId);
                };
              };
            };
          } else {
            this.EmptyBuilder();
          }
        }, (item: HouseHistory) => item.date);
      }.scrollBar(BarState.Off);
    } else {
      this.EmptyBuilder();
    }
  }

  @Builder
  editBuilder() {
    if (this.inEdit && this.vm.historyList.length) {
      Row() {
        Row({ space: 4 }) {
          CheckboxGroup({ group: 'checkboxGroup' })
            .checkboxShape(CheckBoxShape.CIRCLE)
            .selectedColor('#64BB5C')
            .size({ width: 14, height: 14 })
            .onChange((result: CheckboxGroupResult) => {
              this.vm.handleCheckBoxGroupResult(result);
            });
          Text('全选').fontSize(10).opacity(0.9);
        };

        Row({ space: 10 }) {
          Text() {
            Span('已选');
            Span(` ${this.checkedCount} `).fontColor('#64BB5C');
            Span('个');
          }.fontSize(10).opacity(0.9);

          Row({ space: 2 }) {
            Image($r('app.media.ic_delete')).size({ width: 16, height: 16 });
            Text('删除记录').fontSize(12).fontColor($r('sys.color.white'));
          }.backgroundColor($r('sys.color.ohos_id_color_badge_red')).padding(8).borderRadius(8).onClick(() => {
            if (!this.vm.checkedHouses.length) {
              this.getUIContext().getPromptAction().showToast({ message: '请选择至少一条浏览记录', duration: 1000 });
              return;
            }
            this.vm.deleteHistory(this.vm.checkedHouses);
            this.vm.deleteRemoteHistory(this.vm.houseTypeIndex + 1, this.vm.checkedHouses, this.getUIContext());
            // 清空勾选记录
            this.vm.checkedHouses = [];
            this.inEdit = false;
          });
        };
      }
      .padding({ left: 16, right: 16 })
      .width(Constant.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .position({ y: '90%' })
      .height('10%')
      .backgroundColor($r('sys.color.white'))
      .borderRadius({ topLeft: 16, topRight: 16 });
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.End }) {
        Column() {
          TitleBar({ title: '浏览记录' });
          if (this.vm.loading) {
            FullLoadingComponent();
          } else {
            Column({ space: 12 }) {
              this.historyHeader();
              this.historyListBuilder();
            }.padding(16);
          }
        }.height('100%')
        .backgroundColor('#F1F3F5')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);

        this.editBuilder();
      };
    }.hideTitleBar(true).onReady(() => {
      this.vm.loading = true;
      this.vm.getHistoryList();
    });
  }
}