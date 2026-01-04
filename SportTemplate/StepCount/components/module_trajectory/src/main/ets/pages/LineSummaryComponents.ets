import { AlertDialog, AppStorageV2, promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { MapModelViewModel } from '../viewmodels/MapModelVM';
import { Location, RouteType } from '../types/Types';
import {
  TrajectoryConstants,
  RouterMap,
  SELECT_DISTANCE_DEFAULT,
  SELECT_DISTANCE_OPTIONS,
  SELECT_LENGTH_DEFAULT,
  SELECT_LENGTH_OPTIONS,
  WAY_SORT_LIST
} from '../common/TrajectoryConstants';
import { TrajectoryCommonConstants } from '../constants/TrajectoryCommonConstants';
import { GpxFileProcessor, GpxTrackPoint } from '../common/GpxManager';
import { MonthItemModel, SportType } from '../model/SportModel';
import { TrackMapVM } from '../viewmodels/TrackMapVM';
import { TrajectoryWindowModel } from '../model/TrajectoryWindowModel';

@ComponentV2
export struct routeItem {
  @Param routeSelect: boolean = true
  @Event routeChange: (type: boolean) => void

  build() {
    Column() {
      Row() {
        Text(WAY_SORT_LIST[0].label)
          .backgroundImage(this.routeSelect ? $r('app.media.my_route') : $r('app.media.my_route_un'))
          .textAlign(TextAlign.Start)
          .itemStyles()
          .onClick(() => {
            this.routeChange(true)
          })

        Text(WAY_SORT_LIST[1].label)
          .backgroundImage(!this.routeSelect ? $r('app.media.others_route') : $r('app.media.others_route_un'))
          .textAlign(TextAlign.Start)
          .itemStyles()
          .onClick(() => {
            this.routeChange(false)
          })
      }
    }
  }

  @Styles
  itemStyles() {
    .backgroundImageSize({ width: 180, height: 80 })
    .width(180)
    .height(80)
    .padding({ left: 20 })
    .align(Alignment.Center)
  }
}

@ComponentV2
export struct myRouteList {
  @Local windowModel: TrajectoryWindowModel =
    AppStorageV2.connect(TrajectoryWindowModel, () => new TrajectoryWindowModel())!;
  vm: MapModelViewModel = new MapModelViewModel()
  @Consumer() stack: NavPathStack = new NavPathStack();
  @Local allCheckbox: boolean = false
  @Local defaultLatitude: number = 31.99227173519985
  @Local defaultLongitude: number = 118.7622219990476
  @Consumer() currentTypeTransmit: MonthItemModel[] = []
  gpxFile: GpxFileProcessor = new GpxFileProcessor(getContext(this) as common.UIAbilityContext)
  @Event onPopCallBack: (value: PopInfo) => void
  @Local vis: Visibility = Visibility.Visible
  @Local selectItem: number[] = [];
  @Event deleteSportData: (deleteItem: MonthItemModel[]) => void
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: '删除路线',
      secondaryTitle: '',
      content: '确定删除此路线？',
      primaryButton: {
        value: '取消',
        action: () => {
          hilog.info(0x0000, 'testTag', '%{public}s', 'it begin');
        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.deleteSportData(this.vm.removeByIndexList(this.selectItem))
          this.currentTypeTransmit = this.vm.currentType
          this.selectItem = []
        }
      },
    }),
  })

  deleteRoute() {
    if (this.selectItem.length !== 0) {
      this.dialogControllerConfirm.open()
    } else {
      promptAction.showToast({ message: '请勾选路线' });
    }
  }

  aboutToAppear() {
    this.vm.init(this.currentTypeTransmit.concat(TrackMapVM.inputData.filter(item => item.type === SportType.WALKING)))
  }

  aboutToDisappear(): void {
    this.currentTypeTransmit = this.vm.currentType
  }

  build() {
    Column() {
      CheckboxGroup({ group: 'checkboxGroup' })
        .checkboxShape(CheckBoxShape.ROUNDED_SQUARE)
        .selectAll(this.allCheckbox)
        .selectedColor($r('sys.color.comp_background_emphasize'))
        .visibility(Visibility.None)
      if (this.vm.currentType.length === 0) {
        Column() {
          Image($r('app.media.location_icons'))
            .width('149vp')
          Text($r('app.string.noData'))
            .fontColor('#999999')
            .fontSize(12)
            .margin({ top: 15 })
          Text($r('app.string.locationTip'))
            .fontColor('#999999')
            .fontSize(12)
            .width('238vp')
            .textAlign(TextAlign.Center)
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
      } else {
        List({ space: TrajectoryConstants.SPACE_12 }) {
          ForEach(this.vm.currentType, (v: MonthItemModel, index: number) => {
            ListItem() {
              Row() {
                Image($r('app.media.location'))
                  .width('22%')
                  .margin({ left: '3%' })
                  .borderRadius(TrajectoryConstants.RADIUS_16)
                Column() {
                  Text(this.vm.nameItem.get(v.distance + v.stepCount))
                    .fontSize(17)
                    .fontColor($r('sys.color.font_primary'))
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                    .textAlign(TextAlign.Start)
                  Row() {
                    Image($r('app.media.marshalling'))
                      .width(15)

                    Text((Math.floor((v?.distance ?? 0) / 100) / 10).toFixed(1) + '公里')
                      .fontSize(14)
                      .fontColor('#999999')
                      .margin({ left: 5 })
                  }
                  .justifyContent(FlexAlign.Start)
                  .margin({ top: 10 })

                  Text('运动记录生成')
                    .fontSize(14)
                    .fontColor('#999999')
                    .margin({ top: 10 })
                }
                .width('62%')
                .height(70)
                .borderRadius(TrajectoryConstants.RADIUS_16)
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Start)
                .margin({ left: '3%' })
                .onClick(() => {
                  this.stack.pushPath({
                    name: RouterMap.TRACK_MAP_PAGE, param: v, onPop: (value: PopInfo) => {
                      this.onPopCallBack(value)
                    }
                  })
                })

                Checkbox({ name: 'checkbox2' + index, group: 'checkboxGroup' })
                  .select(this.selectItem.indexOf(index) !== -1 ? true : false)
                  // .selectedColor($r('sys.color.comp_background_emphasize'))
                  .shape(CheckBoxShape.ROUNDED_SQUARE)
                  .width(20)
                  .align(Alignment.End)
                  .onChange((value: boolean) => {
                    if (value) {
                      this.selectItem.push(index)
                    } else {
                      this.selectItem = this.selectItem.filter(item => item !== index)
                    }
                  })
              }
              .width(TrajectoryConstants.FULL_PERCENT)
              .height(100)
              .padding(TrajectoryConstants.PADDING_XS)
              .borderRadius(TrajectoryConstants.RADIUS_16)
              .backgroundColor($r('sys.color.comp_background_primary'))
            }
            .padding({
              left: TrajectoryConstants.PADDING_PAGE,
              right: TrajectoryConstants.PADDING_PAGE
            })
          }, (v: RouteType) => v.name)
        }
        .width(TrajectoryConstants.FULL_PERCENT)
        .scrollBar(BarState.Off)
        .margin({ bottom: -40 })
        .layoutWeight(1)
        .visibility(this.vis)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }

      Row() {
        Text($r('app.string.inputRoute'))
          .fontColor($r('app.color.FF6017'))
      }
      .width(TrajectoryCommonConstants.HALF_PERCENT)
      .height($r('app.float.vp_40'))
      .backgroundColor('#E1E8EE')
      .margin({ bottom: TrajectoryConstants.SPACE_12 })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .borderRadius(TrajectoryCommonConstants.RADIUS_10)
      .onClick(async () => {
        let tracks: ESObject = await this.gpxFile.processGpxFile()
        let points: GpxTrackPoint[] = tracks[0].segments[0].points as GpxTrackPoint[]
        if (points.length > 0) {
          let place: Location[] = []
          points.forEach((point: GpxTrackPoint) => {
            place.push({ latitude: point?.lat, longitude: point?.lon })
          })
          let month: MonthItemModel = await this.vm.currentTypeAddData(place)
          TrackMapVM.inputData.push(month)
        }
      })

      Row() {
        Column() {
          Image($r('app.media.delete'))
            .width(15)
          Text($r('app.string.delete'))
            .bottomTextStyles()
        }
        .width('50%')
        .onClick(() => {
          this.deleteRoute()
        })

        Column() {
          Image($r('app.media.cancel'))
            .width(15)
          Text(this.allCheckbox ? '取消全选' : '全选')
            .bottomTextStyles()
        }
        .width('50%')
        .onClick(() => {
          if (this.allCheckbox) {
            this.allCheckbox = false
          } else {
            this.allCheckbox = true
          }
        })
      }
      .backgroundColor('#E1E8EE')
      .height(86)
      .alignItems(VerticalAlign.Center)
      .padding({ bottom: this.windowModel.windowBottomPadding })
    }.layoutWeight(1)
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.interactive_pressed'))
  }
}

@ComponentV2
export struct otherRouteList {
  @Local windowModel: TrajectoryWindowModel =
    AppStorageV2.connect(TrajectoryWindowModel, () => new TrajectoryWindowModel())!;
  @Event onPopCallBack: (value: PopInfo) => void
  @Local vm: MapModelViewModel = new MapModelViewModel()
  @Consumer() stack: NavPathStack = new NavPathStack();
  @Consumer() allCurrentTypeTransmit: MonthItemModel[] = []

  aboutToAppear(): void {
    this.vm.init(this.allCurrentTypeTransmit)
    this.vm.select()
  }

  build() {
    Column() {
      Row({ space: TrajectoryConstants.SPACE_12 }) {
        Select(SELECT_DISTANCE_OPTIONS)
          .selected(0)
          .layoutWeight(1)
          .value(SELECT_DISTANCE_DEFAULT)
          .selectedOptionBgColor('#FFFDE0D2')
          .selectedOptionFontColor($r('sys.color.font_primary'))
          .onSelect((index: number, v: string) => {
            this.vm.selectDistance = v
            this.vm.select()
          })
        Select(SELECT_LENGTH_OPTIONS)
          .selected(0)
          .layoutWeight(1)
          .value(SELECT_LENGTH_DEFAULT)
          .selectedOptionBgColor('#FFFDE0D2')
          .selectedOptionFontColor($r('sys.color.font_primary'))
          .onSelect((index: number, v: string) => {
            this.vm.selectLength = v
            this.vm.select()
          })
      }.width('100%')
      .padding({
        left: TrajectoryConstants.PADDING_PAGE,
        right: TrajectoryConstants.PADDING_PAGE
      })
      .margin({
        bottom: TrajectoryConstants.SPACE_12
      })

      List({ space: TrajectoryConstants.SPACE_12 }) {
        ForEach(this.vm.currentType, (v: MonthItemModel) => {
          ListItem() {
            Row() {
              Image($r('app.media.location'))
                .width('22%')
                .margin({ left: '3%' })
                .borderRadius(TrajectoryConstants.RADIUS_16)
              Column() {
                Text(this.vm.nameItem.get(v.distance + v.stepCount))
                  .fontSize(17)
                  .fontColor($r('sys.color.font_primary'))
                  .textAlign(TextAlign.Start)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Row() {
                  Image($r('app.media.marshalling'))
                    .width($r('app.float.vp_15'))
                  Text((Math.floor((v?.distance ?? 0) / 100) / 10).toFixed(1) + '公里')
                    .fontSize(14)
                    .fontColor('#999999')
                    .margin({ left: 5 })

                  Text('距您' + this.vm.distanceMap.get(v.distance + v.stepCount) + '公里')
                    .fontSize(14)
                    .fontColor('#999999')
                    .margin({ left: 15 })
                }
                .justifyContent(FlexAlign.Start)
                .margin({ top: 30 })
              }
              .width('62%')
              .height(70)
              .borderRadius(TrajectoryConstants.RADIUS_16)
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Start)
              .margin({ left: '3%' })
              .onClick(() => {
                this.stack.pushPath({
                  name: RouterMap.TRACK_MAP_PAGE, param: v, onPop: (value: PopInfo) => {
                    this.onPopCallBack(value)
                  }
                })
              })

              Column() {
                if (v.distance === 10000) {
                  Image($r('app.media.recommend'))
                    .width('100%')
                }
                Image($r('app.media.next'))
                  .width(15)
                  .margin({
                    top: v.distance === 10000 ? TrajectoryCommonConstants.PADDING_15 :
                      TrajectoryCommonConstants.PADDING_35
                  })
              }.layoutWeight(1)
              .height(TrajectoryCommonConstants.FULL_PERCENT)

            }
            .width(TrajectoryConstants.FULL_PERCENT)
            .height(100)
            .borderRadius(TrajectoryConstants.RADIUS_16)
            .backgroundColor($r('sys.color.comp_background_primary'))
          }
          .padding({
            left: TrajectoryConstants.PADDING_XL,
            right: TrajectoryConstants.PADDING_PAGE
          })
        }, (v: MonthItemModel) => String(v.stepCount))
      }
      .width(TrajectoryConstants.FULL_PERCENT)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
    .layoutWeight(1)
    .padding({ bottom: this.windowModel.windowBottomPadding })
  }
}

@Extend(Text)
function bottomTextStyles() {
  .fontSize(14)
  .fontColor('#999999')
  .margin({ top: 10 })
}