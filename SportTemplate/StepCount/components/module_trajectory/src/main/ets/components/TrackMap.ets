import { map, mapCommon, MapComponent } from '@kit.MapKit';
import { AsyncCallback, emitter } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { saveRouteData } from '../common/TrajectoryConstants';
import { GpxFileProcessor } from '../common/GpxManager';
import { MapStyle } from '../constants/MapStyle';
import { ChildSportType, MonthItemModel, SportItemTarget, SportType, TargetType } from '../model/SportModel';
import { TrajectoryCommonConstants } from '../constants/TrajectoryCommonConstants';

export enum runState {
  Start,
  Pause,
  Stop
}

@ComponentV2
export struct TrackMap {
  @Param tiltGesturesEnabled: boolean = false;
  @Param allDistance: number = 0;
  @Param isRun: runState = runState.Stop;
  @Param isTrack: boolean = false
  @Param locusPoints: mapCommon.LatLng[] = []
  @Local mapController?: map.MapComponentController
  @Local markerBoy: map.Marker | undefined
  @Local points: mapCommon.LatLng[] = [];
  @Local giveNotice: boolean = true
  private mapOption?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  @Local defaultLatitude: number = TrajectoryCommonConstants.defaultLatitude
  @Local defaultLongitude: number = TrajectoryCommonConstants.defaultLongitude
  resourceManager = getContext(this).resourceManager;
  gpxFile: GpxFileProcessor = new GpxFileProcessor(getContext(this) as common.UIAbilityContext)
  @Event changeFactory: (mapControl: map.MapComponentController) => void = (mapControl: map.MapComponentController) => {
    hilog.info(0x0000, 'testTag', '%{public}s', 'it begin');
  };
  @Event reportedDistance: (distance: number) => void = (distance: number) => {
    hilog.info(0x0000, 'testTag', '%{public}s', 'it begin');
  };
  @Event trackInfo: (isStandards: boolean, points?: mapCommon.LatLng[]) => void =
    (isStandards: boolean, points?: mapCommon.LatLng[]) => {
      hilog.info(0x0000, 'testTag', '%{public}s', 'it begin');
    };
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogExample({
      cancel: () => {
        this.dialogController?.close()
        this.trackInfo(true)
      },
      confirm: (saveMyRoute: boolean, outRouteFile: boolean) => {
        if (!saveMyRoute && !outRouteFile) {
          promptAction.showToast({ message: this.resourceManager.getStringSync($r('app.string.select').id) })
          return
        }
        if (saveMyRoute) {
          let nowData: Date = new Date()
          let month: MonthItemModel =
            new MonthItemModel(nowData.getMonth(), nowData.getDay(), SportType.JOGGING, ChildSportType.TARGET_JOGGING,
              12, 30,
              Math.trunc(this.allDistance), 660,
              {
                targetType: TargetType.DISTANCE,
                value: 11000
              } as SportItemTarget, Math.trunc(this.allDistance / 10), Math.trunc(this.allDistance) / 2, this.points,
              nowData.getFullYear())
          saveRouteData.push(month)
        }
        if (outRouteFile) {
          try {
            this.gpxFile.outGpxFile(this.points)
          } catch (e) {
          }
        }
        this.dialogController?.close()
        this.trackInfo(true, saveMyRoute ? this.points : undefined)
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    customStyle: false,
    cornerRadius: 20,
    width: 300,
    height: 180
  })
  shortDialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogShort({
      cancel: () => {
        try {
          emitter.emit('continueExercising')
        } catch (error) {
          hilog.error(0x0000, 'TrackMap', 'emitter emit continueExercising error');
        }
      },
      confirm: () => {
        this.trackInfo(false)
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    customStyle: false,
    cornerRadius: 20,
    width: 300,
    height: 150
  })

  @Monitor('isRun')
  onStrChange(monitor: IMonitor) {
    if (this.isRun === runState.Start) {
      this.startLocationListening()
    } else if (this.isRun === runState.Pause) {
      this.points.push({ latitude: 0.00, longitude: 0.00 })
    } else {
      this.stopLocationListening()
      this.endOperation()
    }
  }

  endOperation() {
    if (this.points.length < TrajectoryCommonConstants.number_66) {
      this.shortDialogController?.open()
      return
    }
    this.dialogController?.open()
  }

  async run() {
    this.onAddMarker()
    this.onAnimation()
  }

  onAddMarker() {
    if (this.locusPoints) {
      let polylineOption: mapCommon.MapPolylineOptions = {
        points: this.locusPoints,
        clickable: true,
        visible: true,
        width: 10,
        zIndex: 0,
        gradient: false
      };
      this.mapController?.addPolyline(polylineOption).then((mapPolyline: map.MapPolyline) => {
        mapPolyline?.setColor(0x33000000)
      })
      let markerOptions1: mapCommon.MarkerOptions = {
        position: {
          latitude: this.locusPoints[0]?.latitude ?? this.defaultLatitude,
          longitude: this.locusPoints[0]?.longitude ?? this.defaultLongitude
        },
        icon: $r('app.media.route_start')
      };
      // 新增marker1
      this.mapController?.addMarker(markerOptions1);
    }
  }

  async onAnimation() {
    let geoLocation: geoLocationManager.Location | null = await this.getLastLocation()
    let wgs84Position: mapCommon.LatLng = {
      latitude: geoLocation?.latitude ?? this.defaultLatitude,
      longitude: geoLocation?.longitude ?? this.defaultLongitude
    };
    let gcj02Position: mapCommon.LatLng =
      await map.convertCoordinate(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);
    let cameraPosition: mapCommon.CameraPosition = {
      target: {
        latitude: gcj02Position?.latitude ?? this.defaultLatitude,
        longitude: gcj02Position?.longitude ?? this.defaultLongitude
      },
      zoom: 18
    };
    this.mapController?.moveCamera(map.newCameraPosition(cameraPosition));
    // marker1的参数
    let markerOptions1: mapCommon.MarkerOptions = {
      position: {
        latitude: gcj02Position?.latitude ?? this.defaultLatitude,
        longitude: gcj02Position?.longitude ?? this.defaultLongitude
      }
    };
    // 新增marker1
    this.markerBoy = await this.mapController?.addMarker(markerOptions1);
    let boyImages1: map.PlayImageAnimation = new map.PlayImageAnimation();
    boyImages1.setDuration(1000);
    let resourceArray: Resource[] = [];
    resourceArray.push($r('app.media.local_fill'));
    await boyImages1.addImages(resourceArray);
    boyImages1.setRepeatCount(-1);

    // marker1添加动画
    this.markerBoy?.setAnimation(boyImages1);
    this.markerBoy?.startAnimation();
  }

  locationCallback = async (location: geoLocationManager.Location) => {
    if (this.isRun === runState.Pause) { // 当状态为暂停，则停止记录经纬度
      return
    }
    let wgs84Position: mapCommon.LatLng = {
      latitude: location?.latitude ?? TrajectoryCommonConstants.defaultLatitude,
      longitude: location?.longitude ?? TrajectoryCommonConstants.defaultLongitude
    };
    let gcj02Position: mapCommon.LatLng =
      await map.convertCoordinate(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);

    let point: mapCommon.LatLng = { latitude: gcj02Position.latitude, longitude: gcj02Position.longitude }
    if (this.locusPoints.length !== 0 && this.giveNotice) {
      let toDistance: number = map.calculateDistance(point, this.locusPoints[0])
      if (toDistance < 10) {
        this.giveNotice = false
        promptAction.showToast({ message: this.resourceManager.getStringSync($r('app.string.inRoute').id) })
      }
    }
    this.points.push(point)
    if (this.points.length < 2) {
      return
    }
    if (this.markerBoy) {
      // 提取数组的最后两个元素
      let twoPoints: mapCommon.LatLng[] = this.points.slice(-2)
      // 判断是否暂停后开始
      if (twoPoints[0].longitude === 0.00 || twoPoints[1].longitude === 0.00) {
        return
      }
      let distance: number = map.calculateDistance(twoPoints[0], twoPoints[1]);
      this.reportedDistance(distance)
      let markers: map.Marker[] = [];
      markers.push(this.markerBoy);
      // 动态轨迹的入参
      let tranceOptions: mapCommon.TraceOverlayParams = {
        // 轨迹点
        points: twoPoints,
        // 轨迹的动画时长
        animationDuration: 1000,
        // 相机是否跟随动画移动
        isMapMoving: true,
        // 轨迹的颜色
        color: 0xAAFFAA00,
        // 轨迹的宽度
        width: 20,
        // 轨迹的动画回调（回调轨迹点的index）
        animationCallback: (pointIndex) => {
          hilog.info(0x0000, 'testTag', '%{public}s', 'it begin');
        }
      };
      this.mapController?.addTraceOverlay(tranceOptions, markers);
    }
  };

  // 开始位置监听
  startLocationListening(): boolean {
    try {
      // 检查位置服务是否开启
      if (!geoLocationManager.isLocationEnabled()) {
        return false;
      }

      let requestInfo: geoLocationManager.LocationRequest = {
        'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
        'scenario': geoLocationManager.LocationRequestScenario.UNSET,
        // 关键修改：timeInterval 为 0，distanceInterval 设置为一个大于0的距离（单位：米）
        'timeInterval': 0, // 不按时间上报
        'distanceInterval': 3, // 当位置变化超过10米时上报一次
        'maxAccuracy': 0
      };

      // 开始监听位置
      geoLocationManager.on('locationChange', requestInfo, this.locationCallback);
      return true;
    } catch (error) {
      hilog.error(0x0000, 'stopLocationListening', 'location_service 启动位置监听失败: ' + JSON.stringify(error));
      return false;
    }
  }

  // 停止位置监听
  stopLocationListening() {
    try {
      geoLocationManager.off('locationChange', this.locationCallback);
    } catch (error) {
      hilog.error(0x0000, 'stopLocationListening', 'location_service 停止位置监听失败: ' + JSON.stringify(error));
    }
  }

  // 获取最后一次位置（保持不变）
  async getLastLocation(): Promise<geoLocationManager.Location | null> {
    try {
      return await geoLocationManager.getLastLocation();
    } catch (error) {
      return null;
    }
  }

  aboutToAppear() {
    this.mapOption = {
      position: {
        target: {
          latitude: 39.9056,
          longitude: 116.4247
        },
        zoom: 16
      },
      tiltGesturesEnabled: this.tiltGesturesEnabled
    };
    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController
        this.mapController?.setMyLocationEnabled(false); // '我的位置'图层功能开关
        this.mapController?.setMyLocationControlsEnabled(false); // 是否启用'我的位置'按钮
        this.mapController?.setTrafficEnabled(false); // 打开或关闭路况图层
        this.mapController?.setBuildingEnabled(false); // 打开或者关闭3D建筑图层
        this.mapController?.setZoomControlsEnabled(false); // 是否启用缩放控制器
        this.mapController.setCustomMapStyle(MapStyle.styleWhite).then().catch()

        if (this.isTrack) {
          this.run()
        } else {
          let geoLocation: geoLocationManager.Location | null = await this.getLastLocation()
          let wgs84Position: mapCommon.LatLng = {
            latitude: geoLocation?.latitude ?? this.defaultLatitude,
            longitude: geoLocation?.longitude ?? this.defaultLongitude
          };
          let gcj02Position: mapCommon.LatLng =
            await map.convertCoordinate(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);
          // marker1的参数
          let markerOptions1: mapCommon.MarkerOptions = {
            position: {
              latitude: gcj02Position?.latitude ?? this.defaultLatitude,
              longitude: gcj02Position?.longitude ?? this.defaultLongitude
            },
            icon: $r('app.media.my_location')
          };
          // 新增marker1
          await this.mapController?.addMarker(markerOptions1);
          this.changeFactory(mapController)
        }
      }
    };
  }

  build() {
    Column() {
      MapComponent({ mapOptions: this.mapOption, mapCallback: this.callback })
        .width('100%')
        .height('100%')
    }
  }
}

@CustomDialog
export struct CustomDialogShort {
  controller?: CustomDialogController;
  cancel: () => void = () => {
    hilog.info(0x0000, 'testTag', '%{public}s', 'it begin');
  }
  confirm: () => void = () => {
    hilog.info(0x0000, 'testTag', '%{public}s', 'it begin');
  }

  build() {
    Column() {
      Text($r('app.string.shortTip'))
        .fontSize(TrajectoryCommonConstants.PADDING_L)
        .height($r('app.float.vp_50'))
        .margin({ top: $r('app.float.vp_35'), left: $r('app.float.vp_25'), right: $r('app.float.vp_25') })
        .textAlign(TextAlign.Center)

      Row() {
        Text($r('app.string.ContinueExercising'))
          .fontColor($r('app.color.5a5a5a'))
          .dioTextStyles()
          .onClick(() => {
            this.controller?.close()
            this.cancel()
          })
        Divider()
          .vertical(true)
          .height(24)
          .color($r('sys.color.comp_divider'))
          .opacity(0.6)
          .margin({ left: 8, right: 8 })
        Text($r('app.string.EndExercising'))
          .fontColor($r('app.color.FF6017'))
          .dioTextStyles()
          .onClick(() => {
            this.controller?.close()
            this.confirm()
          })
      }
      .height($r('app.float.vp_70'))
    }
  }
}

@CustomDialog
export struct CustomDialogExample {
  saveMyRoute: boolean = false;
  outRouteFile: boolean = false;
  controller?: CustomDialogController;
  cancel: () => void = () => {
    hilog.info(0x0000, 'testTag', '%{public}s', 'it begin');
  }
  confirm: (saveMyRoute: boolean, outRouteFile: boolean) => void = (saveMyRoute: boolean, outRouteFile: boolean) => {
    hilog.info(0x0000, 'testTag', '%{public}s', 'it begin');
  }

  build() {
    Column() {
      Text($r('app.string.route'))
        .fontSize(TrajectoryCommonConstants.PADDING_XL)
        .height($r('app.float.vp_50'))
      Row() {
        Text($r('app.string.saveMyRoute'))
          .width($r('app.float.vp_190'))
          .height($r('app.float.vp_25'))
        Radio({ value: 'radioOut', group: 'radioGroup' })
          .width(20)
          .align(Alignment.End)
          .checked(false)
          .onChange((value: boolean) => {
            this.saveMyRoute = value
          })
      }
      .justifyContent(FlexAlign.Start)
      .height($r('app.float.vp_35'))

      Divider()
        .strokeWidth('1px')
        .color($r('sys.color.comp_background_tertiary'))
        .width(TrajectoryCommonConstants.PERCENT_80)

      Row() {
        Text($r('app.string.outRouteFile'))
          .width($r('app.float.vp_190'))
          .height($r('app.float.vp_25'))
        Radio({ value: 'radioOut', group: 'radioGroup' })
          .checked(false)
          .width(20)
          .align(Alignment.End)
          .onChange((value: boolean) => {
            this.outRouteFile = value
          })
      }
      .justifyContent(FlexAlign.Start)
      .height($r('app.float.vp_35'))

      Row() {
        Text($r('app.string.cancel'))
          .fontColor($r('app.color.C3B6B0'))
          .dioTextStyles()
          .onClick(() => {
            this.cancel()
            this.controller?.close()
          })
        Text($r('app.string.enter'))
          .fontColor($r('app.color.black'))
          .dioTextStyles()
          .onClick(() => {
            this.confirm(this.saveMyRoute, this.outRouteFile)
          })
      }
      .height($r('app.float.vp_70'))
    }
  }
}

@Extend(Text)
function dioTextStyles() {
  .width(TrajectoryCommonConstants.HALF_PERCENT)
  .textAlign(TextAlign.Center)
}

@Extend(Radio)
function checkboxStyles() {
  .checked(false)
  .radioStyle({
    checkedBackgroundColor: '#FF6016'
  })
  .width(20)
  .align(Alignment.End)
}