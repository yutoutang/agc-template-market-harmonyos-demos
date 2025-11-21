import { mapCommon, map, navi } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { OrderApis, OrderExpressInfo, OrderItem } from 'lib_network';
import { image } from '@kit.ImageKit';

const DEFAULT_LATITUDE = 31.97;
const DEFAULT_LONGITUDE = 118.75;

@ObservedV2
export class OrderExpressInfoVM {
  @Trace
  loading: boolean = false
  @Trace public offsetX: number = 0;
  @Trace public offsetY: number = 240;
  @Trace public positionX: number = 0;
  @Trace public positionY: number = 0;
  @Trace
  mapOptions?: mapCommon.MapOptions
  @Trace
  mapController?: map.MapComponentController;
  @Trace
  mapEventManager?: map.MapEventManager;
  @Trace
  callback?: AsyncCallback<map.MapComponentController>
  @Trace
  expressInfo?: OrderExpressInfo
  @Trace
  orderItem?: OrderItem
  private _uiContext: UIContext

  constructor(uiContext: UIContext) {
    this._uiContext = uiContext
  }

  public async initData(order: OrderItem) {
    this.orderItem = order;
    const res = await OrderApis.getExpressInfo(this.orderItem.orderInfo.orderNo)
    if (res.code === 0) {
      this.expressInfo = res.info;
    }
  }

  public initMap(func1: () => void, func2: () => void) {
    this.mapOptions = {
      position: {
        target: {
          latitude: DEFAULT_LATITUDE,
          longitude: DEFAULT_LONGITUDE,
        },
        zoom: 5,
      },
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
    };

    this.callback = async (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        this.mapEventManager = this.mapController.getEventManager();
        let callback = () => {
          console.info('on-mapLoad');
        }
        this.mapEventManager.on('mapLoad', callback);
        setTimeout(() => {
          this.testDrivingRoutes()
          this.addMarker()
          this.addMarkerCard(func1, func2)
        }, 500)
      }
    };
  }

  async testDrivingRoutes() {
    if (!this.expressInfo) {
      return
    }
    let params: navi.DrivingRouteParams = {
      // 起点的经纬度
      origins: [this.expressInfo.origins],
      // 终点的经纬度
      destination: this.expressInfo.destination,
      // 路径的途经点
      waypoints: this.expressInfo.waypoints,
      language: 'zh_CN',
    };
    const result = await navi.getDrivingRoutes(params);
    this.mapController?.addPolyline({
      points: result.routes[0].overviewPolyline,
      width: 16,
      color: 0xFFE64566,
    })
    console.info('Succeeded in getting driving routes.');
  }

  async addMarker() {
    let markerOptions1: mapCommon.MarkerOptions = {
      position: this.expressInfo!.origins,
      rotation: 0,
      visible: true,
      zIndex: 0,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 0,
      clickable: true,
      draggable: true,
      flat: false,
      icon: $r('app.media.ic_send_map'),
    };
    await this.mapController?.addMarker(markerOptions1)

    let markerOptions2: mapCommon.MarkerOptions = {
      position: this.expressInfo!.destination,
      rotation: 0,
      visible: true,
      zIndex: 0,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 0,
      clickable: true,
      draggable: true,
      flat: false,
      icon: $r('app.media.ic_get_map'),
    };
    await this.mapController?.addMarker(markerOptions2)
  }

  addMarkerCard(func1: () => void, func2: () => void) {
    this._uiContext.getComponentSnapshot().createFromBuilder(func1,
      async (error: Error, pixmap: image.PixelMap) => {
        if (error) {
          console.log('error: ' + JSON.stringify(error))
          return;
        }
        // Marker初始化参数
        let markerOptions: mapCommon.MarkerOptions = {
          position: this.expressInfo!.origins,
          rotation: 0,
          visible: true,
          zIndex: 0,
          alpha: 1,
          anchorU: 0.5,
          anchorV: 1,
          clickable: true,
          draggable: true,
          flat: false,
          icon: pixmap,
        };
        this.mapController?.addMarker(markerOptions);
      })

    this._uiContext.getComponentSnapshot().createFromBuilder(func2,
      async (error: Error, pixmap: image.PixelMap) => {
        if (error) {
          console.log('error: ' + JSON.stringify(error))
          return;
        }
        // Marker初始化参数
        let markerOptions: mapCommon.MarkerOptions = {
          position: this.expressInfo!.destination,
          rotation: 0,
          visible: true,
          zIndex: 0,
          alpha: 1,
          anchorU: 0.5,
          anchorV: 1,
          clickable: true,
          draggable: true,
          flat: false,
          icon: pixmap,
        };
        this.mapController?.addMarker(markerOptions);
      })
  }
}