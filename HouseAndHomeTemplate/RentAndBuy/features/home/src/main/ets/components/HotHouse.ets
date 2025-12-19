import { LengthMetrics } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import {
  CommonUtils,
  EventEmitName,
  HouseType,
  https,
  IBasicHouse,
  IHistoryRequest,
  Logger,
  RouterModule,
  DETAIL_MAP,
  HouseDetailRouteParam,
} from 'foundation';
import { Util } from '../util/Util';

@ComponentV2
export struct HotHouse {
  @Param index: number = 0;
  @Param hotHouseList: IBasicHouse[] = [];

  getHouseType(index: number, type: HouseType) {
    let navPathName = DETAIL_MAP.get(index);
    if (!navPathName) {
      navPathName = DETAIL_MAP.get(type);
    }
    return navPathName ?? '';
  }

  recordHistory(houseId: string, type: HouseType) {
    let param: IHistoryRequest = {
      type: type,
      date: CommonUtils.getDate(),
      houseId: houseId,
    };
    https.recordHistory(param).then((res) => {
      if (res.code === 0) {
        Logger.info('record history success');
      }
    });
  }

  build() {
    Grid() {
      ForEach(this.hotHouseList, (item: IBasicHouse) => {
        GridItem() {
          Column() {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(CommonUtils.handleImgUrl(item.thumbnail, this.getUIContext().getHostContext()!))
                .borderRadius({ topLeft: 16, topRight: 16 });
              Row({ space: 4 }) {
                Image($r('app.media.location')).size({ height: 12, width: 8 });
                Text(item.cell).fontSize(10).opacity(0.9).fontColor($r('sys.color.white'));
              }
              .margin({ left: 10, bottom: 10 })
              .borderRadius(4)
              .alignItems(VerticalAlign.Center)
              .backgroundColor('rgba(0,0,0,0.2)')
              .padding(4)
              .height(22);
            };

            Column() {
              Text(item.title)
                .fontSize(12)
                .opacity(0.9)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontColor($r('sys.color.black'));

              Text(Util.getLayoutInfo(item)).fontSize(10).fontColor($r('sys.color.black'))
                .margin({ top: 4, bottom: 8 });

              Flex({
                direction: FlexDirection.Row,
                wrap: FlexWrap.Wrap,
                space: { main: new LengthMetrics(4), cross: new LengthMetrics(4) },
              }) {
                ForEach(item.labels, (item: string, index: number) => {
                  Text(item)
                    .fontSize(8)
                    .backgroundColor(index === 0 ? '#64BB5C' : '#F1F3F5')
                    .fontColor($r('sys.color.black'))
                    .borderRadius(8)
                    .padding({
                      left: 8,
                      right: 8,
                      top: 4,
                      bottom: 4,
                    });
                }, (item: string, index: number) => item);
              }.margin({ bottom: 8 });

              Flex({
                direction: FlexDirection.Row,
                wrap: FlexWrap.Wrap,
                alignItems: ItemAlign.Center,
                space: { main: new LengthMetrics(4), cross: new LengthMetrics(4) },
              }) {
                if (this.index !== HouseType.RENT) {
                  Text(`${Util.getHouseTotal(item)}`).fontSize(14).fontWeight(600).fontColor('#E84026');
                  Text(`${item.unit}元/㎡`).fontSize(10).opacity(0.4).fontColor($r('sys.color.black'));
                } else {
                  Text(`${item.unit}元/月`).fontSize(10).opacity(0.4).fontColor($r('sys.color.black'));
                }
              };
            }.padding(12).alignItems(HorizontalAlign.Start);
          }.backgroundColor($r('sys.color.white')).borderRadius(16);
        }.onClick(() => {
          (this.getUIContext().getHostContext() as common.UIAbilityContext).eventHub.emit(EventEmitName.INIT_MAP,
            item.latitude, item.longitude);
          this.recordHistory(item.houseId, item.type);
          RouterModule.push({
            url: this.getHouseType(this.index, item.type),
            param: {
              houseId: item.houseId,
              allowFollow: true,
            } as HouseDetailRouteParam,
          });
        });
      }, (item: IBasicHouse) => item.houseId);
    }.columnsTemplate('1fr 1fr').edgeEffect(EdgeEffect.Spring)
    .columnsGap(12)
    .rowsGap(12);
  }
}