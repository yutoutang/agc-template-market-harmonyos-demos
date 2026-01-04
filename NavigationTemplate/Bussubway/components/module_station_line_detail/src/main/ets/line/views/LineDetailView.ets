import { AppStorageV2 } from '@kit.ArkUI'
import { AsyncCallback } from '@kit.BasicServicesKit'
import { map, mapCommon, MapComponent } from '@kit.MapKit'
import { LineCommonConstants } from '../common/LineCommonConstants'
import { BuslineOverview } from '../components/BuslineOverview'
import { LineDetailModel } from '../models/LineDetailModel'
import { BusSubwayMap } from '../common/Enums'
import { SubwaylineOverview } from '../components/SubwaylineOverview'
import { BuslineStation } from '../components/BuslineStation'
import { BottomTools } from '../components/BottomTools'
import { LineWindowModel } from '../models/LineWindowModel'
import { SubwaylineStation } from '../components/SubwaylineStation'
import { BusSubwaySetting } from '../models/BusSubwaySetting'
import { LineLogger } from '../common/LineLogger'
import { CommentEventDispatcher } from '../utils/EventDispatcher'

@ComponentV2
export struct LineDetailView {
  @Param @Require lineDetailModel: LineDetailModel
  // 收藏路线标签
  @Param @Require collectionLineTags?: string[]
  @Param @Require setting: BusSubwaySetting
  @Event onBack: () => void
  @Event addCollectionLineTag: (tagName: string) => void
  @Event collectLine: (tag: string) => void
  @Event opeArrivalReminder: (isArrivalReminder: boolean) => void
  @Event routeSameStop: (id: string) => void
  @Event switchDirec: () => void
  @Event routeSettingPage: () => void
  @Consumer() isLineDetailSheetShow: boolean = true
  private windowModel: LineWindowModel = AppStorageV2.connect(LineWindowModel, () => new LineWindowModel())!;
  private mapOptions?: mapCommon.MapOptions;
  private mapCallback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private busMarkers: map.Marker[] = [];
  @Event onInterceptLogin: (cb: (isLogin: boolean) => void) => void = () => {
  };

  @Monitor('lineDetailModel.currentStop.comingBusList.0.stations')
  onStrChange() {
    this.busMarkers.forEach((marker, index) => {
      const currentStop = this.lineDetailModel.currentStop;
      if (!currentStop || !currentStop.comingBusList) {
        return;
      }

      const comingBus = currentStop.comingBusList[index];
      if (!comingBus || comingBus.stations === undefined) {
        return;
      }

      const stations: number = comingBus.stations;
      const stopOffsetIndex: number | undefined = currentStop.stopOffsetIndex;
      if (stopOffsetIndex === undefined) {
        return;
      }

      const busStops = this.lineDetailModel.busstops;
      const targetIndex = stopOffsetIndex - stations;
      if (!busStops || targetIndex < 0 || targetIndex >= busStops.length) {
        return;
      }

      const locationStr = busStops[targetIndex]?.location;
      if (!locationStr) {
        return;
      }

      const location = locationStr.split(',');
      if (location.length < 2) {
        return;
      }

      const position: mapCommon.LatLng = {
        latitude: Number(location[1]),
        longitude: Number(location[0])
      }

      // 检查转换结果是否有效
      if (isNaN(position.latitude) || isNaN(position.longitude)) {
        return;
      }

      marker.setPosition(position);
    })

  }

  @Builder
  lineDetailSheet() {
    Column() {
      // 线路详情
      if (this.lineDetailModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_BUS) {
        BuslineOverview({
          name: this.lineDetailModel.name,
          startStop: this.lineDetailModel.startStop,
          endStop: this.lineDetailModel.endStop,
          startTime: this.lineDetailModel.startTime,
          endTime: this.lineDetailModel.endTime,
          basicPrice: this.lineDetailModel.basicPrice,
          totalPrice: this.lineDetailModel.totalPrice,
          interval: this.lineDetailModel.interval,
        }).margin({ top: $r('app.float.widget_vertical_space') })
      } else {
        SubwaylineOverview({
          name: this.lineDetailModel.name,
          startStop: this.lineDetailModel.startStop,
          endStop: this.lineDetailModel.endStop,
          startTime: this.lineDetailModel.startTime,
          endTime: this.lineDetailModel.endTime,
          basicPrice: this.lineDetailModel.basicPrice,
          totalPrice: this.lineDetailModel.totalPrice,
          interval: this.lineDetailModel.interval,
          switchDirec: this.switchDirec
        }).margin({ top: $r('app.float.widget_vertical_space') })
      }

      // 线路站点
      if (this.lineDetailModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_BUS) {
        BuslineStation({
          busstops: this.lineDetailModel.busstops,
          currentStop: this.lineDetailModel.currentStop,
          setting: this.setting
        })
          .margin({ top: 8 })
      } else {
        SubwaylineStation({
          busstops: this.lineDetailModel.busstops,
          currentStop: this.lineDetailModel.currentStop
        })
          .margin({ top: 8 })
      }

      BottomTools({
        busSubwayType: this.lineDetailModel.busSubwayType,
        currentStop: this.lineDetailModel.currentStop,
        lineId: this.lineDetailModel.id,
        collectionLineTags: this.collectionLineTags,
        addCollectionLineTag: this.addCollectionLineTag,
        collectLine: this.collectLine,
        opeArrivalReminder: this.opeArrivalReminder,
        setting: this.setting,
        routeSameStop: this.routeSameStop,
        routeSettingPage: this.routeSettingPage
      }).height(48)
        .margin({ top: 4 })

    }
    .width(LineCommonConstants.FULL_PERCENT)
    .padding({ left: 16, right: 16, bottom: this.windowModel.windowBottomPadding })
    .backgroundColor($r('app.color.index_background'))
  }

  aboutToAppear(): void {
    CommentEventDispatcher.interceptLogin = (cb: (isLogin: boolean) => void) => {
      this.onInterceptLogin(cb)
    }

    // 地图初始化参数，设置地图中心点坐标及层级
    const location = this.lineDetailModel.currentStop?.location?.split(',')!
    this.mapOptions = {
      position: {
        target: {
          latitude: (Number(location[1]) - 800 / 111000),
          longitude: Number(location[0])
        },
        zoom: 15
      }
    };

    // 地图初始化的回调
    this.mapCallback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.mapController.setMyLocationEnabled(true);
        // 缩放控制器的启用状态
        this.mapController.setZoomControlsEnabled(false)
        this.mapController.setCompassControlsEnabled(false)
        // 当前站点
        const location = this.lineDetailModel.currentStop?.location?.split(',')!
        let markerOptions: mapCommon.MarkerOptions = {
          position: {
            latitude: Number(location[1]),
            longitude: Number(location[0])
          },
          clickable: true,
          // 设置标点
          icon: this.lineDetailModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_BUS ? $r('app.media.stop_bus') :
            $r('app.media.stop_sub'),
          // title: String(this.lineDetailModel.currentStop?.name),
        };
        await this.mapController?.addMarker(markerOptions)
        // 绘制路线
        let polylines: string[] = this.lineDetailModel.polyline!.split(';')
        let points: mapCommon.LatLng[] = polylines.map(item => {
          let pointItems = item.split(',')
          let point: mapCommon.LatLng = {
            latitude: Number(pointItems[1]),
            longitude: Number(pointItems[0])
          }
          return point
        })

        let polylineOption: mapCommon.MapPolylineOptions = {
          // 折线坐标点，必传
          points: points,
          width: 30,
          jointType: mapCommon.JointType.ROUND,
          startCap: mapCommon.CapStyle.ROUND,
          endCap: mapCommon.CapStyle.ROUND,
          customTexture: $r('app.media.router_row')
        };
        if (this.lineDetailModel.uicolor) {
          const rgbHex: string = this.lineDetailModel.uicolor.substring(1);
          const argbHex: string = 'FF' + rgbHex;
          polylineOption.color = parseInt(argbHex, 16);
        } else {
          polylineOption.color = 0xff02A500
        }
        // 在地图上添加一条折线
        await this.mapController.addPolyline(polylineOption);
        // 车辆maker
        if (this.lineDetailModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_BUS) {
          this.lineDetailModel.currentStop?.comingBusList.forEach(async item => {
            const stations: number = item.stations!
            const stopOffsetIndex: number = this.lineDetailModel.currentStop?.stopOffsetIndex!
            const busLocation = this.lineDetailModel.busstops![stopOffsetIndex - stations]?.location?.split(',')!
            let markerOptions: mapCommon.MarkerOptions = {
              position: {
                latitude: Number(busLocation[1]),
                longitude: Number(busLocation[0])
              },
              // 设置标点
              icon: $r('app.media.bus_marker')
            }
            this.busMarkers.push(await this.mapController!.addMarker(markerOptions))
          })
        }
      } else {
        LineLogger.error('map init failed')
      }

      this.mapController?.on('markerClick', async (map) => {
        this.isLineDetailSheetShow = true
      });
    };
  }

  build() {
    Stack() {
      MapComponent({ mapOptions: this.mapOptions, mapCallback: this.mapCallback })
      Row() {
        Image($r('app.media.ic_back'))
          .width(40)
          .height(40)
          .aspectRatio(1)
          .onClick(() => {
            this.isLineDetailSheetShow = false
            this.onBack()
          })
      }
      .margin({ top: 44 })
      .padding({ left: 16, right: 16 })
      .height(56)
      .width(LineCommonConstants.FULL_PERCENT)
    }.bindSheet(
      $$this.isLineDetailSheetShow, this.lineDetailSheet, {
      height: SheetSize.FIT_CONTENT,
      dragBar: true,
      showClose: true,
      enableOutsideInteractive: true,
      preferType: SheetType.CENTER
    })
    .alignContent(Alignment.Top)
    .gesture(
      // 解决长按存在长按属性的控件超过800ms，长按手势无对应事件响应
      LongPressGesture({ duration: 400 })
        .onAction(() => {
        })
    )
  }
}