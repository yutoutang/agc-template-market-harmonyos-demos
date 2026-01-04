import { map, mapCommon, petalMaps } from '@kit.MapKit';
import { TrackMap } from '../components/TrackMap';
import { RouterMap } from '../common/TrajectoryConstants';
import { Location } from '../types/Types';
import { GpxFileProcessor } from '../common/GpxManager';
import { MonthItemModel } from '../model/SportModel';
import { MapPublicLogic } from '../viewmodels/MapPublicLogic';
import { promptAction } from '@kit.ArkUI';
import { TrajectoryCommonConstants } from '../constants/TrajectoryCommonConstants';

@Builder
export function TrackMapPageBuilder() {
  TrackMapPage()
}

@ComponentV2
export struct TrackMapPage {
  @Local currentIndex: number = 1
  @Local mapController?: map.MapComponentController
  @Local routeData?: MonthItemModel
  @Local isSheetShow: boolean = true
  @Local address: string = ''
  @Local distance: string = ''
  @Local defaultLatitude: number = TrajectoryCommonConstants.defaultLatitude
  @Local defaultLongitude: number = TrajectoryCommonConstants.defaultLongitude
  resourceManager = getContext(this).resourceManager;
  stack: NavPathStack = new NavPathStack();

  queryDistancePointZoom(coordinates: Location[]): number {
    // 查找最远的两点
    let maxDistance = 0;
    let point1: ESObject
    let point2: ESObject
    for (let i = 0; i < coordinates.length; i++) {
      for (let j = i + 1; j < coordinates.length; j++) {
        const distance = map.calculateDistance(coordinates[i], coordinates[j])

        if (distance > maxDistance) {
          maxDistance = distance;
          point1 = coordinates[i];
          point2 = coordinates[j];
        }
      }
    }

    // 模型参数（根据数据拟合得出）
    const a = 21600000;
    const b = 0.64;
    return Math.log(a / maxDistance) / b;
  }

  @Builder
  myBuilder() {
    Column() {
      Text(this.address)
        .fontColor($r('app.color.black'))
        .fontSize($r('app.float.number_20'))
        .margin({ left: TrajectoryCommonConstants.PADDING_L, top: TrajectoryCommonConstants.PADDING_36 })

      Row() {
        Image($r('app.media.marshalling'))
          .width($r('app.float.vp_15'))
        Text(String(this.routeData!.distance / 1000) + this.resourceManager.getStringSync($r('app.string.KM').id))
          .margin({ left: TrajectoryCommonConstants.PADDING_XS })
          .fontSize(TrajectoryCommonConstants.FONTSIZE_14)
          .fontColor('#999999')
      }
      .justifyContent(FlexAlign.Start)
      .margin({ left: TrajectoryCommonConstants.PADDING_L, top: TrajectoryCommonConstants.PADDING_11 })

      Row() {
        Image($r('app.media.location_icon'))
          .width($r('app.float.vp_17'))
          .margin({ left: TrajectoryCommonConstants.PADDING_XS })
        Text(this.address)
          .margin({ left: TrajectoryCommonConstants.PADDING_XS })
          .fontSize(TrajectoryCommonConstants.FONTSIZE_14)
          .fontColor('#999999')
          .width($r('app.float.vp_140'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.resourceManager.getStringSync($r('app.string.fromYou').id) + this.distance +
        this.resourceManager.getStringSync($r('app.string.KM').id))
          .fontSize(TrajectoryCommonConstants.FONTSIZE_14)
          .fontColor('#999999')
          .margin({ left: $r('app.float.vp_25') })
        Text(this.resourceManager.getStringSync($r('app.string.navigation').id))
          .fontSize(TrajectoryCommonConstants.FONTSIZE_14)
          .fontColor($r('app.color.app_theme'))
          .margin({ left: TrajectoryCommonConstants.PADDING_15 })
          .onClick(() => {
            promptAction.showToast({ message: this.resourceManager.getStringSync($r('app.string.jumpFlower').id) })
            setTimeout(() => {
              if (this.routeData && this.routeData.locusPoints) {
                let params: petalMaps.RoutePlanParams = {
                  destinationPosition: {
                    latitude: this.routeData.locusPoints[0].latitude,
                    longitude: this.routeData.locusPoints[0].longitude
                  },
                };
                petalMaps.openMapRoutePlan(this.getUIContext().getHostContext(), params);
              }
            }, 500)
          })
      }
      .width('329vp')
      .height('28vp')
      .backgroundColor('#F2F4FF ')
      .margin({ left: TrajectoryCommonConstants.PADDING_L, top: TrajectoryCommonConstants.PADDING_SM })
      .borderRadius(TrajectoryCommonConstants.RADIUS_XXS)

      Button($r('app.string.startRun'))
        .margin(10)
        .fontSize($r('sys.float.Body_L'))
        .backgroundColor($r('app.color.app_theme'))
        .width(TrajectoryCommonConstants.PERCENT_90)
        .height($r('app.float.vp_40'))
        .margin({ left: TrajectoryCommonConstants.PERCENT_5, top: $r('app.float.vp_20') })
        .onClick(async () => {
          this.stack.pop(this.routeData)
        })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Image($r('app.media.ic_back'))
          .width($r('app.float.head_icon_width'))
          .aspectRatio(1)
          .draggable(false)
          .margin({ left: TrajectoryCommonConstants.SPACE_XL, top: TrajectoryCommonConstants.PADDING_36 })
          .borderRadius(TrajectoryCommonConstants.HALF_PERCENT)
          .stateStyles({
            normal: { .backgroundColor(Color.Transparent)
            },
            pressed: { .backgroundColor($r('sys.color.interactive_pressed'))
            },
          })
          .zIndex(3)
          .onClick(() => {
            this.stack.pop()
          })
        TrackMap({
          changeFactory: (mapControl: map.MapComponentController) => {
            this.mapController = mapControl
            if (this.routeData && this.routeData.locusPoints) {
              let zoom: number =
                this.queryDistancePointZoom(this.routeData.locusPoints)
              let firstPoint: Location = GpxFileProcessor.calculateCenterPointSimple(this.routeData.locusPoints)

              let markerOptions1: mapCommon.MarkerOptions = {
                position: {
                  latitude: this.routeData.locusPoints[0]?.latitude ?? this.defaultLatitude,
                  longitude: this.routeData.locusPoints[0]?.longitude ?? this.defaultLongitude
                },
                icon: $r('app.media.route_start')
              };
              // 新增marker1
              this.mapController?.addMarker(markerOptions1);

              this.mapController?.animateCamera(map.newLatLng({
                latitude: firstPoint.latitude,
                longitude: firstPoint.longitude
              }, zoom));

              let polylineOption: mapCommon.MapPolylineOptions = {
                points: this.routeData.locusPoints,
                clickable: true,
                visible: true,
                width: 10,
                zIndex: 0,
                gradient: false
              };
              this.mapController?.addPolyline(polylineOption).then((mapPolyline: map.MapPolyline) => {
                mapPolyline?.setColor(0xffFF0000)
              })
            }
          }
        })
          .bindSheet(!!this.isSheetShow, this.myBuilder(), {
            height: TrajectoryCommonConstants.BIND_SHEET_HEIGHT,
            dragBar: true,
            preferType: SheetType.CENTER,
            backgroundColor: Color.White,
            showClose: false,
            enableOutsideInteractive: true,
            onWillDismiss: ((dismissSheetAction: DismissSheetAction) => {
              // 允许用户通过手势（如下滑）或点击蒙层关闭弹窗
              if (dismissSheetAction.reason === DismissReason.PRESS_BACK) {
                // 这里可以添加一些关闭前的确认逻辑，如果需要的话
                this.isSheetShow = false
                this.stack.pop()
              }
              // 对于其他关闭原因，可以根据需要处理。默认返回 true 允许关闭通常是安全的。
              return true;
            })
          })
      }
      .width(TrajectoryCommonConstants.FULL_PERCENT)
      .height(TrajectoryCommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .onReady(async (context) => {
      this.stack = context.pathStack;
      this.routeData = this.stack.getParamByName(RouterMap.TRACK_MAP_PAGE)[0] as MonthItemModel
      if (this.routeData.locusPoints) {
        this.address =
          await MapPublicLogic.getPoi(this.routeData.locusPoints[0].latitude, this.routeData.locusPoints[0].longitude)
        this.distance = (await MapPublicLogic.distanceBetween(this.routeData.locusPoints[0].latitude,
          this.routeData.locusPoints[0].longitude) / 1000).toFixed(1)
      }
    })
  }
}