import { AsyncCallback } from '@kit.BasicServicesKit';
import { MapComponent as KitMapComponent, map, mapCommon } from '@kit.MapKit';
import { SameStopDetailModel } from '../models/SameStopDetailModel';
import { StopDetailModel } from '../models/StopDetailModel';

const TAG = '[MapComponent]';

@ComponentV2
export struct MapComponent {
  // 当前站点详情数据
  @Param @Require stopDetailModel: StopDetailModel
  @Param @Require sameStopDetailModel: SameStopDetailModel
  @Event showStopDetailPannel: () => void
  // 地图相关属性
  private mapController?: map.MapComponentController;
  private callback?: AsyncCallback<map.MapComponentController>;

  setEnabled() {
    this.mapController?.setMyLocationEnabled(true);
    this.mapController?.setMyLocationControlsEnabled(true)
    this.mapController?.setZoomControlsEnabled(false)
    this.mapController?.setCompassControlsEnabled(false)
  }

  // 监听选中站台ID变化
  @Monitor('sameStopDetailModel.mainStopId')
  onMainStopChange() {
    if (this.mapController) {
      if (this.sameStopDetailModel) {
        this.mapController?.clear()
        this.sameStopDetailModel.sameStopDetails.forEach(async (sameStopDetail) => {
          const sameMarker: mapCommon.MarkerOptions = {
            position: {
              latitude: Number(sameStopDetail.latitude),
              longitude: Number(sameStopDetail.longitude),
            },
            clickable: true,
            icon: sameStopDetail.id === this.sameStopDetailModel.mainStopId ? $r('app.media.stop_bus') :
            $r('app.media.otherStop_bus'),
            title: String(sameStopDetail.id),
            zIndex: sameStopDetail.id === this.sameStopDetailModel.mainStopId ? 1 : 0.5
          }
          if (sameStopDetail.id === this.sameStopDetailModel.mainStopId) {
            this.animateCameraCenter(sameStopDetail.longitude!, sameStopDetail.latitude!);
          }
          await this.mapController?.addMarker(sameMarker)
        })
      }
    }
  }

  aboutToAppear(): void {
    // 设置地图的回调函数
    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.mapController?.on('markerClick', async (map) => {
          this.showStopDetailPannel()
          // 仅在公交站点模式下更新同名主站台
          if (this.stopDetailModel.stopType !== 'subway_station') {
            const markerTitle = map.getTitle()
            this.sameStopDetailModel.mainStopId = markerTitle
          }
        })

        // 单站点模式：仅渲染选中站点并居中，相机移动到站点
        if (this.stopDetailModel.stopType === 'subway_station') {
          const singleMarker: mapCommon.MarkerOptions = {
            position: {
              latitude: Number(this.stopDetailModel.latitude),
              longitude: Number(this.stopDetailModel.longitude),
            },
            clickable: true,
            icon: $r('app.media.stop_sub'),
            title: String(this.stopDetailModel.siteId)
          };
          await this.mapController?.addMarker(singleMarker)
        } else {
          if (this.sameStopDetailModel) {
            this.mapController?.clear()
            this.sameStopDetailModel.sameStopDetails.forEach(async (sameStopDetail) => {
              const sameMarker: mapCommon.MarkerOptions = {
                position: {
                  latitude: Number(sameStopDetail.latitude),
                  longitude: Number(sameStopDetail.longitude),
                },
                clickable: true,
                icon: sameStopDetail.id === this.sameStopDetailModel.mainStopId ? $r('app.media.stop_bus') :
                $r('app.media.otherStop_bus'),
                title: String(sameStopDetail.id)
              }
              await this.mapController?.addMarker(sameMarker)
            })
          }
        }

        this.animateCameraCenter(this.stopDetailModel.longitude!, this.stopDetailModel.latitude!);
        this.setEnabled()

      }
    };
  }

  build() {
    Column() {
      if (canIUse('SystemCapability.Map.Core')) {
        KitMapComponent({
          mapOptions: {
            position: {
              target: { longitude: this.stopDetailModel.longitude!, latitude: this.stopDetailModel.latitude! },
              zoom: 15
            },
            scaleControlsEnabled: true
          },
          mapCallback: this.callback,
        })
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 移动相机到中心点
   * @param longitude
   * @param latitude
   */
  private animateCameraCenter(longitude: number, latitude: number) {
    const camera: mapCommon.CameraPosition = {
      target: {
        longitude: longitude,
        // 中心点向南偏移200米
        latitude: latitude - 100 / 111000,
      },
      zoom: 17,
    };
    const cameraUpdate = map.newCameraPosition(camera);
    this.mapController?.animateCamera(cameraUpdate, 100);
  }
}
