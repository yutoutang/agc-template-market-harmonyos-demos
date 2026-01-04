import { map, mapCommon, navi } from '@kit.MapKit';

export class DrawRouteModel {
  async drawRoute(mapController: map.MapComponentController | undefined, steps: mapCommon.LatLng[],
    type?: string, colors?: number) {
    if (mapController === undefined) {
      return;
    }

    if (type === 'bus') {
      let polylineOption: mapCommon.MapPolylineOptions = {
        points: steps,
        color: 0xff00C427,
        jointType: mapCommon.JointType.ROUND,
        width: 40,
        customTexture: $r('app.media.router_row')
      };
      mapController.addPolyline(polylineOption)
    } else if (type === 'sub') {
      let polylineOption: mapCommon.MapPolylineOptions = {
        points: steps,
        color: colors,
        jointType: mapCommon.JointType.ROUND,
        width: 40,
        customTexture: $r('app.media.router_row')
      };
      mapController.addPolyline(polylineOption)
    } else if (type === 'walk') {
      let polylineOption: mapCommon.MapPolylineOptions = {
        points: steps,
        color: 0xff00a2e4,
        jointType: mapCommon.JointType.ROUND,
        startCap: mapCommon.CapStyle.ROUND,
        endCap: mapCommon.CapStyle.ROUND,
        width: 20,
        patterns: [{ type: 1, length: 10 }, { type: 2, length: 15 }]
      };
      mapController.addPolyline(polylineOption)
    }
  }

  async addMarker(mapController: map.MapComponentController, position: mapCommon.LatLng) {
    let markerOptions: mapCommon.MarkerOptions = {
      position: position,
      rotation: 0,
      visible: true,
      zIndex: 0,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 1,
      clickable: false,
      draggable: false,
      flat: false
    };
    await mapController.addMarker(markerOptions);
  }
}