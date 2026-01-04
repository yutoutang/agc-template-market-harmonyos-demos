import { map, mapCommon, MapComponent } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { common } from '@kit.AbilityKit';
import { LocationUtils } from '../util/LocationUtils';
import { ResUtil } from 'lib_common';
import {
  ChildSportType,
  CustomDialogExample,
  GpxFileProcessor,
  MapStyle,
  MonthItemModel,
  SaveRouteData,
  SportItemTarget,
  SportType,
  TargetType
} from 'module_trajectory';
import { Logger } from 'ui_base';

@ComponentV2
export struct LocusMap {
  @Param @Require points: mapCommon.LatLng[]
  @Param mapOption: mapCommon.MapOptions = {
    position: {
      target: {
        latitude: 39.9,
        longitude: 116.4
      },
      zoom: 10
    },
    zoomControlsEnabled: false
  }
  gpxFile: GpxFileProcessor = new GpxFileProcessor(getContext(this) as common.UIAbilityContext)
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogExample({
      cancel: () => {
        // do nothing
      },
      confirm: (saveMyRoute: boolean, outRouteFile: boolean) => {
        if (!saveMyRoute && !outRouteFile) {
          this.getUIContext().getPromptAction().showToast({ message: ResUtil.getStringSync($r('app.string.select')) })
          return
        }
        if (saveMyRoute) {
          let nowData: Date = new Date()
          let allDistance: number = 0
          for (let index = 0; index < this.points.length - 1; index++) {
            let distance = map.calculateDistance(this.points[index], this.points[index + 1]);
            allDistance += distance
          }
          let month: MonthItemModel =
            new MonthItemModel(nowData.getMonth(), nowData.getDay(), SportType.JOGGING, ChildSportType.TARGET_JOGGING,
              12, 30,
              Math.trunc(allDistance), 660,
              {
                targetType: TargetType.DISTANCE,
                value: 11000
              } as SportItemTarget, Math.trunc(allDistance / 10), Math.trunc(allDistance) / 2, this.points,
              nowData.getFullYear())
          SaveRouteData.push(month)
        }
        if (outRouteFile) {
          this.gpxFile.outGpxFile(this.points)
        }
        this.dialogController?.close()
      }
    }),
    autoCancel: false,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
      }
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
      }
    },
    alignment: DialogAlignment.Center,
    customStyle: false,
    cornerRadius: 20,
    width: 300,
    height: 180
  })
  private mapController?: map.MapComponentController

  moveCameraToLocus() {
    try {
      this.mapController?.moveCamera(map.newLatLngBounds(LocationUtils.calculateBounds(this.points),
        { left: 200, right: 200, bottom: 500 }))
    } catch (error) {
      Logger.error('LocusMap', 'moveCameraToLocus error')
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      MapComponent({ mapOptions: this.mapOption, mapCallback: this.callback })
        .width('100%')
        .height('100%')

      Image($r('app.media.ic_location'))
        .width(50)
        .onClick(() => {
          this.moveCameraToLocus()
        })
        .margin({ top: $r('app.float.vp_100'), right: $r('app.float.vp_16') })

      Image($r('app.media.ic_export_line'))
        .width(50)
        .onClick(() => {
          this.dialogController?.open()
        })
        .margin({ top: $r('app.float.vp_148'), right: $r('app.float.vp_16') })
    }
  }

  private callback?: AsyncCallback<map.MapComponentController> = (err, mapController) => {
    if (!err) {
      this.mapController = mapController
      this.mapController.setCustomMapStyle(MapStyle.styleWhite).then().catch()
      // 动态轨迹的入参
      let tranceOptions: mapCommon.TraceOverlayParams = {
        // 轨迹点
        points: this.points,
        // 轨迹的动画时长
        animationDuration: 1500,
        // 相机是否跟随动画移动
        // isMapMoving: true,
        // 轨迹的颜色
        color: 0xFF00FF00,
        // 轨迹的宽度
        width: 16,
        // 轨迹的动画回调（回调轨迹点的index）
        animationCallback: (pointIndex) => {
          // do nothing
        }
      };
      this.moveCameraToLocus()
      this.mapController?.addTraceOverlay(tranceOptions).then().catch()

      this.mapController?.setMyLocationEnabled(true)
      this.mapController?.setMyLocationControlsEnabled(false)

    }
  };

  private async startLocation() {
    let request: geoLocationManager.SingleLocationRequest = {
      'locatingPriority': geoLocationManager.LocatingPriority.PRIORITY_LOCATING_SPEED,
      'locatingTimeoutMs': 10000
    }
    try {
      const location = await geoLocationManager.getCurrentLocation(request)
      let gcj02Position: mapCommon.LatLng =
        await map.convertCoordinate(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, {
          latitude: location.latitude,
          longitude: location.longitude
        });
      this.mapController?.moveCamera(map.newLatLng(gcj02Position))
    } catch (err) {

    }
  }
}
