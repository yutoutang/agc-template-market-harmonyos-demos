import { common } from '@kit.AbilityKit';
import { Constant, DETAIL_MAP } from '../constants/Constant';
import { RouterModule } from '../router/RouterModule';
import { CommonUtils } from '../util/Utils';
import { IHistoryRequest } from '../model/IRequest';
import { https } from '../http/HttpApis';
import { Logger } from '../util/Logger';
import { HouseDetailRouteParam, HouseOptions } from '../model/Index';
import { EventEmitName, HouseType } from '../constants/Enum';

@Extend(Text)
function labelText(color: ResourceStr) {
  .backgroundColor(color).fontColor($r('sys.color.black')).borderRadius(8).padding({
    left: 8,
    right: 8,
    top: 4,
    bottom: 4,
  });
}

@Extend(Text)
function commonText(size: number, opacity: number, weight?: number) {
  .fontSize(size).opacity(opacity).fontWeight(weight).fontColor($r('sys.color.black'));
}

@ComponentV2
export struct HouseCard {
  @Local indent: Length = 0;
  @Param @Require houseOptions: HouseOptions;
  @Event selectHouse: (select: boolean) => void;

  aboutToAppear(): void {
    if (this.houseOptions.type === HouseType.NEW) {
      this.indent = 36;
    } else if (this.houseOptions.type === HouseType.SECOND) {
      this.indent = 54;
    }
  }

  @Computed
  get navPathName() {
    let pathName = DETAIL_MAP.get(this.houseOptions.type);
    return pathName;
  }

  @Computed
  get unitPrice() {
    return this.houseOptions.type === HouseType.RENT ? `${this.houseOptions.house.unit}/月` :
      `${this.houseOptions.house.unit}/㎡`;
  }

  @Computed
  get houseTag() {
    return this.houseOptions.type === HouseType.SECOND ? '人气好房' : `${this.houseOptions.house.status}`;
  }

  @Computed
  get houseTitle() {
    return this.houseOptions.type === HouseType.NEW ? `${this.houseOptions.house.cell}` :
      `${this.houseOptions.house.title}`;
  }

  recordHistory() {
    let param: IHistoryRequest = {
      type: this.houseOptions.type,
      date: CommonUtils.getDate(),
      houseId: this.houseOptions.house.houseId,
    };
    https.recordHistory(param).then((res) => {
      if (res.code === 0) {
        Logger.info('record history success');
      }
    });
  }

  build() {
    Row({ space: 14 }) {
      Image(CommonUtils.handleImgUrl(this.houseOptions.house.thumbnail, this.getUIContext().getHostContext()!))
        .size({ height: 122, width: 120 })
        .borderRadius({ topLeft: 16, bottomLeft: 16 })
        .autoResize(true);

      Stack({ alignContent: Alignment.End }) {
        Column() {
          Stack({ alignContent: Alignment.TopStart }) {
            Text(this.houseTitle)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .opacity(0.9)
              .textIndent(this.indent)
              .fontColor($r('sys.color.black'));

            if (this.houseOptions.type !== HouseType.RENT) {
              Text(this.houseTag)
                .fontColor($r('sys.color.white'))
                .borderRadius(8)
                .backgroundColor('#64BB5C')
                .fontSize(8)
                .padding({
                  top: 3,
                  bottom: 3,
                  left: 8,
                  right: 8,
                });
            }
          }.width('calc(100% - 144vp)').margin({ bottom: 6 });

          Row({ space: 8 }) {
            Text(`${this.houseOptions.house.area}`).commonText(10, 0.9);
            Text(`${this.houseOptions.house.district}`).commonText(10, 0.9);
            Text(`${CommonUtils.getHouseSpace(this.houseOptions.house)}㎡`).commonText(10, 0.9);
          }.margin({ bottom: 4 });

          Row({ space: 4 }) {
            ForEach(this.houseOptions.house.labels, (item: string) => {
              Text(item)
                .fontSize(8)
                .labelText('#F1F3F5');
            }, (item: string) => item);
          }.margin({ bottom: 4 });

          Row() {
            if (this.houseOptions.type !== HouseType.SECOND) {
              Text(this.unitPrice).fontSize(14).fontColor('#E84026').fontWeight(FontWeight.Bold);
            } else {
              Row({ space: 8 }) {
                Text(`${this.houseOptions.house.total[0]}万`)
                  .fontSize(14)
                  .fontColor('#E84026')
                  .fontWeight(FontWeight.Bold);
                Text(`${this.houseOptions.house.unit}/㎡`).fontSize(10).opacity(0.4).fontColor($r('sys.color.black'));
              };
            }
          };
        }.alignItems(HorizontalAlign.Start);

        if (this.houseOptions.enableEdit && this.houseOptions.inEdit) {
          Checkbox({ name: this.houseOptions.house.houseId, group: 'checkboxGroup' })
            .selectedColor('#64BB5C')
            .shape(CheckBoxShape.CIRCLE)
            .size({ width: 14, height: 14 })
            .margin({ left: '45%' })
            .onChange((value: boolean) => {
              this.selectHouse(value);
            });
        }
      };
    }
    .borderRadius(16)
    .height(122)
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('sys.color.white'))
    .width(Constant.FULL_PERCENT)
    .onClick(() => {
      (this.getUIContext().getHostContext() as common.UIAbilityContext).eventHub.emit(EventEmitName.INIT_MAP,
        this.houseOptions.house.latitude, this.houseOptions.house.longitude);
      this.recordHistory();
      RouterModule.push({
        url: this.navPathName ?? '',
        param: {
          houseId: this.houseOptions.house.houseId,
          allowFollow: this.houseOptions.allowFollow,
        } as HouseDetailRouteParam,
      });
    });
  }
}