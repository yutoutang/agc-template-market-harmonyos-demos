import { common } from '@kit.AbilityKit';
import {
  CommonUtils,
  Constant,
  DETAIL_MAP,
  EventEmitName,
  HouseDetailRouteParam,
  HouseTabBarModule,
  HouseType,
  https,
  IBasicHouse,
  IHistoryRequest,
  Logger,
  RouterModule,
  TitleBar,
} from 'foundation';
import { SEARCH_HOUSE_TAB } from '../constant/Constant';
import { HomeVM } from '../viewmodel/HomeVM';

@Builder
export function HouseSearchBuilder() {
  HouseSearch();
}

@ComponentV2
export struct HouseSearch {
  vm: HomeVM = HomeVM.instance;
  @Local searchTabIndex: number = 0;
  @Local searchType: HouseType = HouseType.NEW;
  @Local keyword: string = '';

  aboutToAppear(): void {
    this.vm.searchHouse(this.searchType, this.keyword);
  }

  aboutToDisappear(): void {
    // 退出初始化搜索条件
    this.keyword = '';
    this.searchTabIndex = 0;
    this.vm.searchHouseList = [];
  }

  @Computed
  get navPathName() {
    let pathName = DETAIL_MAP.get(this.searchType);
    return pathName;
  }

  recordHistory(houseId: string) {
    let param: IHistoryRequest = {
      type: this.searchType,
      date: CommonUtils.getDate(),
      houseId: houseId,
    };
    https.recordHistory(param).then((res) => {
      if (res.code === 0) {
        Logger.info('record history success');
      }
    });
  }

  @Builder
  noSearchResultBuilder() {
    Column({ space: 2 }) {
      Image($r('app.media.search_empty')).size({ width: 120, height: 120 });
      Text('暂无搜索结果').fontSize(14).opacity(0.6);
    }.width(Constant.FULL_PERCENT).alignItems(HorizontalAlign.Center).margin({ top: 32 });
  }

  @Builder
  searchResultBuilder() {
    Column({ space: 16 }) {
      ForEach(this.vm.searchHouseList, (item: IBasicHouse) => {
        Column({ space: 4 }) {
          Row() {
            Row({ space: 8 }) {
              Image($r('app.media.ic_search_location')).size({ width: 16, height: 16 });
              Text(item.cell).fontSize(14).fontWeight(FontWeight.Medium).opacity(0.9).fontColor($r('sys.color.black'));
            };

            Text();
          }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

          Row() {
            Text(item.address).fontSize(10).opacity(0.4).margin({ left: 24 }).fontColor($r('sys.color.black'));

            Text(`${(this.vm.calcDistance(item.latitude, item.longitude) / 1000).toFixed(2)}km`)
              .fontSize(10)
              .opacity(0.4)
              .fontColor($r('sys.color.black'));
          }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
        }.onClick(() => {
          (this.getUIContext().getHostContext() as common.UIAbilityContext).eventHub.emit(EventEmitName.INIT_MAP,
            item.latitude, item.longitude);
          this.recordHistory(item.houseId);
          RouterModule.push({
            url: this.navPathName ?? '',
            param: {
              houseId: item.houseId,
              allowFollow: true,
            } as HouseDetailRouteParam,
          });
        });
      }, (item: IBasicHouse) => item.houseId);
    }.backgroundColor($r('sys.color.white')).padding(12).borderRadius(16);
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({ title: '搜索' });
        Column() {
          Search({ value: this.keyword, placeholder: '请输入关键字搜索' }).searchButton('搜索', {
            fontSize: 14,
          }).onSubmit((value: string) => {
            this.keyword = value;
            this.vm.searchLoading = true;
            this.vm.searchHouse(this.searchType, this.keyword);
          });

          Row({ space: 12 }) {
            ForEach(SEARCH_HOUSE_TAB, (item: HouseTabBarModule, index: number) => {
              Text(item.title)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .backgroundColor(this.searchTabIndex === index ? '#64BB5C' : '#E6E8E9')
                .fontColor(this.searchTabIndex === index ? $r('sys.color.white') : $r('sys.color.black'))
                .padding(10)
                .borderRadius(16)
                .width(72)
                .textAlign(TextAlign.Center)
                .onClick(() => {
                  this.searchType = item.id;
                  this.searchTabIndex = index;
                  this.vm.searchLoading = true;
                  this.vm.searchHouse(this.searchType, this.keyword);
                });
            }, (item: HouseTabBarModule, index: number) => item.title.toString());
          }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.Start).margin({ bottom: 12 });

          if (this.vm.searchLoading) {
            LoadingProgress().width(40);
          } else {
            if (this.vm.searchHouseList.length) {
              this.searchResultBuilder();
            } else {
              this.noSearchResultBuilder();
            }
          }
        }
        .padding({ left: 16, right: 16 });
      }.height('100%').backgroundColor('#F1F3F5')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }.hideTitleBar(true);
  }
}