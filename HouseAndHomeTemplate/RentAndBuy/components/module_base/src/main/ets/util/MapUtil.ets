import { map, mapCommon, site } from '@kit.MapKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { ClusterOverlayParamsMore } from './AggregateClusterOverlayParams';
import { common } from '@kit.AbilityKit';
import { MakerCanvasUtil } from './MakerCanvasUtil';
import { AreaHouse, HouseDetailRouteParam, Location } from '../model/Index';
import { EventEmitName, FacilityType, HouseType } from '../constant/Enum';
import { Constant, DETAIL_MAP, FACILITY_ICON_MAP } from '../constant/Constant';

/**
 * 地图Utils
 */
export class MapUtil {
  private static _instance: MapUtil;
  mapOptions?: mapCommon.MapOptions;
  callback?: AsyncCallback<map.MapComponentController>;
  mapController: map.MapComponentController = new map.MapComponentController();
  mapEventManager?: map.MapEventManager;
  pointIds: string[] = [];
  initScale: number = 0;
  clusterOverlay?: map.ClusterOverlay;
  houseMakers: Location[] = [];
  housesByArea: AreaHouse[] = [];
  hasRedraw: boolean = false;
  hasDrawMaker: boolean = false;
  stack: NavPathStack = new NavPathStack();
  makerMap: Map<string, (string | HouseType)[]> = new Map();
  private context?: common.UIAbilityContext;;

  public static get instance() {
    if (!MapUtil._instance) {
      MapUtil._instance = new MapUtil();
    }
    return MapUtil._instance;
  }

  setMakers(makers: Location[]) {
    this.houseMakers = makers;
  }

  initMap(latitude: number, longitude: number, context: Context, zoom?: number, stack?: NavPathStack,) {
    this.context = context as common.UIAbilityContext;
    this.context.eventHub.on(EventEmitName.CLEAR_MAKER_STATUS,
      () => {
        this.hasDrawMaker = false;
      });

    this.stack = stack ?? new NavPathStack();
    let location = {
      target: {
        latitude: Number(latitude) ?? 0,
        longitude: Number(longitude) ?? 0,
      },
      zoom: zoom ? zoom : 10,
    } as mapCommon.CameraPosition;

    this.mapOptions = {
      position: location,
      myLocationControlsEnabled: false,
      compassControlsEnabled: false,
    };

    let locationButtonClick = () => {
      let cameraUpdate: map.CameraUpdate = map.newCameraPosition(location);
      // 1000ms内移动相机到mark点位置
      this.mapController?.animateCamera(cameraUpdate, 1000);
    };

    // 地图初始化的回调
    this.callback = async (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        this.mapController?.setMyLocationEnabled(true);
        this.mapEventManager = this.mapController.getEventManager();
        this.mapController.setMinZoom(2);
        this.mapController.setMaxZoom(20);
        this.mapEventManager?.on('myLocationButtonClick', locationButtonClick);
        // 获取初始像素长度
        this.initScale = this.mapController?.getScalePerPixel();
      }
    };
  }

  async addMakers() {
    let mcu: MakerCanvasUtil = MakerCanvasUtil.instance;
    this.houseMakers.forEach(async item => {
      let markerOptions: mapCommon.MarkerOptions = {
        position: {
          latitude: item.latitude,
          longitude: item.longitude,
        },
        clickable: true,
        icon: mcu.getMakerIcon(item.title + ' ' + item.unit),
      };
      this.mapController?.addMarker(markerOptions).then((marker) => {
        this.makerMap.set(marker.getId(), [item.type ?? '', item.houseId ?? '']);
      });
    });
    this.hasDrawMaker = true;
    this.createMakerListener();
  }

  createMakerListener() {
    let mapEventManager: map.MapEventManager = this.mapController.getEventManager();
    mapEventManager.on('markerClick', (marker) => {
      let info = this.makerMap.get(marker.getId()) ?? '';
      let navPathName = DETAIL_MAP.get(info[0]);

      if (info) {
        this.stack.pushPathByName(navPathName ?? '', {
          houseId: info[1],
          allowFollow: true,
        } as HouseDetailRouteParam,
        );
      }
    });
  }

  createCameraChangeListener(overlay: map.ClusterOverlay) {
    let mapEventManager: map.MapEventManager = this.mapController.getEventManager();

    mapEventManager.on('cameraChange', () => {
      let scaleAfterZoom = this.mapController?.getScalePerPixel();
      if (Number((this.initScale / scaleAfterZoom).toFixed(1)) > Constant.CLUSTER_MAX_ZOOM) {
        overlay.remove().then(() => {
          // 避免maker点的重复绘制对性能的影响
          if (!this.hasDrawMaker) {
            // 避免重复对maker点监听
            mapEventManager.off('markerClick');
            this.addMakers();
          }
        }).catch((e: BusinessError) => {
          hilog.info(0xff00, 'MapUtil', 'remove cluster failed' + JSON.stringify(e));
        });
      } else {
        // 先取消监听并清除图层, 重置maker点绘制状态
        this.hasDrawMaker = false;
        this.mapController.clear();
        mapEventManager.off('cameraChange');
        this.redrawCluster();
      }
    });
  }

  async clusterHouseByArea(areaHouse: AreaHouse) {
    let clusters: Array<mapCommon.ClusterItem> = [];
    areaHouse.locations.forEach(async (item: Location) => {
      let clusterItem: mapCommon.ClusterItem = {
        position: {
          latitude: item.latitude,
          longitude: item.longitude,
        },
      };
      clusters.push(clusterItem);
    });
    this.housesByArea.push(areaHouse);
    let clusterOverlayParams: ClusterOverlayParamsMore = new ClusterOverlayParamsMore(clusters, 100, areaHouse);
    this.mapController.addClusterOverlay(clusterOverlayParams).then((overlay) => {
      this.createCameraChangeListener(overlay);
    });
  }

  redrawCluster() {
    this.housesByArea.forEach(async (areaHouse: AreaHouse) => {
      let clusters: Array<mapCommon.ClusterItem> = [];
      areaHouse.locations.forEach(async (item: Location) => {
        let clusterItem: mapCommon.ClusterItem = {
          position: {
            latitude: item.latitude,
            longitude: item.longitude,
          },
        };
        clusters.push(clusterItem);
      });
      let clusterOverlayParams: ClusterOverlayParamsMore = new ClusterOverlayParamsMore(clusters, 100, areaHouse);
      this.mapController.addClusterOverlay(clusterOverlayParams).then((overlay) => {
        // 重绘添加监听
        this.createCameraChangeListener(overlay);
      });
    });
  }

  async drawFacility(sites: site.Site[], type: FacilityType) {
    // 先清空标记点
    this.mapController?.clear();
    this.pointIds = [];
    // 添加标记点
    sites.forEach(async (item: site.Site) => {
      let title: string = item.name ?? '';
      let pointAnnotationOptions: mapCommon.PointAnnotationParams = {
        position: {
          latitude: item.location?.latitude ?? 0,
          longitude: item.location?.longitude ?? 0,
        },
        repeatable: true,
        collisionRule: mapCommon.CollisionRule.NAME,
        titles: [{
          content: title,
          fontSize: 12,
          strokeColor: 0xFFFFFFFF,
          strokeWidth: 2,
          fontStyle: mapCommon.FontStyle.BOLD,
        }],
        icon: FACILITY_ICON_MAP.get(type),
        showIcon: true,
        forceVisible: false,
        minZoom: 2,
        maxZoom: 18,
        visible: true,
        zIndex: 5,
      };
      let pointAnnotation = await this.mapController?.addPointAnnotation(pointAnnotationOptions);
      this.pointIds.push(pointAnnotation?.getId() ?? '');
      this.mapController.on('pointAnnotationClick', (pointAnnotation: map.PointAnnotation) => {
        this.context!.eventHub.emit('point-click');
        hilog.info(0xff00, 'MapUtil', `on-PointAnnotationClick position = ${JSON.stringify(pointAnnotation)}`);
      });
    });
  }

  async drawHousePoint(title: string) {
    let pointAnnotationOptions: mapCommon.PointAnnotationParams = {
      position: {
        latitude: this.mapOptions?.position.target.latitude ?? 0,
        longitude: this.mapOptions?.position.target.longitude ?? 0,
      },
      repeatable: true,
      collisionRule: mapCommon.CollisionRule.NAME,
      titles: [{
        content: title,
        strokeColor: 0xFFFFFFFF,
        strokeWidth: 2,
        fontStyle: mapCommon.FontStyle.BOLD,
      },
      ],
      icon: $r('app.media.point'),
      showIcon: true,
      forceVisible: false,
      minZoom: 2,
      maxZoom: 18,
      visible: true,
      zIndex: 5,
    };
    let pointAnnotation = await this.mapController?.addPointAnnotation(pointAnnotationOptions);
    this.pointIds.push(pointAnnotation?.getId() ?? '');
  }

  calDistance(startLocation: mapCommon.LatLng, endLocation: mapCommon.LatLng) {
    return map.calculateDistance(startLocation, endLocation);
  }
}