import { MapComponent, site } from '@kit.MapKit';
import { common } from '@kit.AbilityKit';
import { TitleBar } from 'module_base';
import { Facility } from '../model/Index';
import { SurroundVM } from '../viewmodel/SurroundVM';

@Builder
export function FullSurroundingBuilder() {
  FullSurrounding();
}

@ComponentV2
export struct FullSurrounding {
  vm: SurroundVM = SurroundVM.instance;
  @Local isShow: boolean = true;
  @Local isMinSheet: boolean = false;
  sheetHeight: number = 400;
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    this.vm.getFullSurroundFacilityList(this.context);
    this.context.eventHub.on('point-click', () => {
      this.isShow = true;
    });
  }

  aboutToDisappear(): void {
    // 清除筛选条件
    this.vm.typeIndex = 0;
    this.vm.keyIndex = 0;
    this.vm.fullFacilities = [];
    this.context.eventHub.off('point-click');
  }

  @Builder
  facilitySheetBuilder() {
    Column() {
      Column({ space: 12 }) {
        if (this.vm.fullFacilities.length) {
          Row({ space: 24 }) {
            ForEach(this.vm.fullFacilities, (item: Facility, index: number) => {
              Text(item.type)
                .fontSize(14)
                .fontWeight(this.vm.typeIndex === index ? FontWeight.Bold : FontWeight.Regular)
                .onClick(() => {
                  // 切换清空标记点
                  this.vm.typeIndex = index;
                  this.vm.keyIndex = 0;
                  this.vm.currentFacility = this.vm.fullFacilities[this.vm.typeIndex];
                  this.vm.keyword = this.vm.currentFacility.keyword.split(',')[0];
                  this.vm.getFacilityList();
                });
            }, (item: Facility, index: number) => item.name);
          }.width('100%').justifyContent(FlexAlign.Start);

          Row({ space: 12 }) {
            ForEach(this.vm.currentFacility?.keyword.split(','), (item: string, index: number) => {
              Text(item)
                .fontSize(12)
                .borderRadius(16)
                .backgroundColor(this.vm.keyIndex === index ? '#64BB5C' : 'rgba(0,0,0,0.10)')
                .fontColor(this.vm.keyIndex === index ? $r('sys.color.white') : 'rgba(0,0,0,0.90)')
                .padding({
                  left: 10,
                  right: 10,
                  top: 4,
                  bottom: 4,
                })
                .onClick(() => {
                  this.vm.keyIndex = index;
                  this.vm.keyword = this.vm.currentFacility?.keyword.split(',')[this.vm.keyIndex] ?? '';
                  this.vm.getFacilityList();
                });
            }, (item: string, index: number) => item + index.toString());
          }.width('100%').justifyContent(FlexAlign.Start);

          if (!this.isMinSheet) {
            List({ space: 12 }) {
              ForEach(this.vm.list, (item: site.Site) => {
                ListItem() {
                  Column({ space: 4 }) {
                    Row() {
                      Text(item.name)
                        .fontSize(14)
                        .opacity(0.9)
                        .width('60%')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis });
                      Text(`距离${(this.vm.calDistance(this.vm.mapUtil.mapOptions, item.location) /
                        1000).toFixed(2)}km`)
                        .fontSize(14)
                        .opacity(0.6);
                    }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                    Text(item.formatAddress).fontSize(10).opacity(0.6).width('100%').textAlign(TextAlign.Start);
                  };
                };
              }, (item: site.Site) => item.siteId);
            }.scrollBar(BarState.Off).height(this.vm.list.length ? 'calc(100% - 60vp)' : '100%');
          }
        } else {
          LoadingProgress().width(30).height(40);
        }
      }
      .backgroundColor($r('sys.color.white'))
      .padding(12)
      .borderRadius(16)
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center);
    }
    .height('100%')
    .padding({
      top: 8,
      bottom: 8,
      left: 16,
      right: 16,
    })
    .backgroundColor('#F1F3F5');
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        MapComponent({
          mapOptions: this.vm.mapUtil.mapOptions,
          mapCallback: this.vm.mapUtil.callback,
        }).height('100%').width('100%');

        TitleBar({ title: '完整配套', stack: this.vm.stack }).alignSelf(ItemAlign.Start);
      }.bindSheet($$this.isShow, this.facilitySheetBuilder(), {
        preferType: SheetType.CENTER,
        dragBar: true,
        showClose: false,
        detents: [this.sheetHeight, 124],
        maskColor: Color.Transparent,
        onDetentsDidChange: (he: number) => {
          this.isMinSheet = !(px2vp(he) === this.sheetHeight);
        },
        onWillDismiss: ((action: DismissSheetAction) => {
          if (action.reason === DismissReason.PRESS_BACK) {
            action.dismiss();
          }
        }),
      });
    }.hideTitleBar(true);
  }
}