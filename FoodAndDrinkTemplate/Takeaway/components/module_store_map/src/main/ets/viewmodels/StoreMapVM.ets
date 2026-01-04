import { map, mapCommon } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { StoreMapInfo } from '../commons/Types';
import { PermissionUtil } from '../utils/PermissionUtil';
import { MapUtil } from '../utils/MapUtil';

const DEFAULT_LATITUDE = 32.043060;
const DEFAULT_LONGITUDE = 118.785017;

@ObservedV2
export class StoreMapVM {
  @Trace latitude: number = DEFAULT_LATITUDE;
  @Trace longitude: number = DEFAULT_LONGITUDE;
  @Trace mapOptions: mapCommon.MapOptions = {
    position: {
      target: {
        latitude: DEFAULT_LATITUDE,
        longitude: DEFAULT_LONGITUDE,
      },
      zoom: 15,
    },
    zoomControlsEnabled: false,
  };
  mapController?: map.MapComponentController;
  marker?: map.Marker;
  userMarker?: map.Marker;
  callback?: AsyncCallback<map.MapComponentController>;
  mapEventManager?: map.MapEventManager;

  public requestLocationPermission() {
    PermissionUtil.requestPermissions(['ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.LOCATION'])
      .then(() => {
        this.setUserLocation();
      });
  }

  public initController(storeInfo: StoreMapInfo, showUserLocation: boolean = false) {
    this.callback = async (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        this.mapEventManager = this.mapController?.getEventManager();
        await this.getLocationInfo();
        this.setMarker(storeInfo);
        if (showUserLocation) {
          this.requestLocationPermission();
        }
      }
    };
  }

  public async getLocationInfo() {
    let target: mapCommon.LatLng = {
      latitude: this.latitude + 0.002,
      longitude: this.longitude + 0.004,
    };
    let cameraPosition: mapCommon.CameraPosition = {
      target: target,
      zoom: 15,
    };
    // 新建CameraUpdate对象
    let cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
    // 在1000ms内以动画的形式移动相机
    this.mapController?.animateCamera?.(cameraUpdate, 1000);
  }

  public async setMarker(storeInfo: StoreMapInfo) {
    let markerOptions: mapCommon.MarkerOptions = {
      position: {
        latitude: this.latitude,
        longitude: this.longitude,
      },
      visible: true,
      clickable: true,
      icon: $r('app.media.ic_position'),
      zIndex: 99,
      infoWindowAnchorU: 1,

      title: storeInfo.shopName,
      snippet: storeInfo.address,
    };
    // 创建Marker
    this.marker = await this.mapController?.addMarker(markerOptions);
    this.marker?.setInfoWindowVisible(true);
  }

  public async setUserLocation() {
    if (this.mapController) {
      // 启用我的位置图层
      this.mapController.setMyLocationEnabled(true);
      // 启用我的位置按钮
      this.mapController.setMyLocationControlsEnabled(true);
      let style: mapCommon.MyLocationStyle = {
        anchorU: 0.5,
        anchorV: 0.5,
        icon: $r('app.media.ic_default_avatar'),
      };
      await this.mapController.setMyLocationStyle(style);
    }
  }

  public handleClickGuide() {
    MapUtil.handleClickGuide({
      latitude: this.latitude,
      longitude: this.longitude,
    });
  }
}
