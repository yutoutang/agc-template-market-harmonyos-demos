import { mapCommon } from '@kit.MapKit';

interface CartesianPoint {
  x: number
  y: number
  z: number
}

export class LocationUtils {
  /**
   * 计算经纬度数组的中心点坐标
   * @param points 经纬度数组 [[lat, lng], ...]
   * @returns 中心点坐标 [lat, lng]
   */
  static calculateGeographicCenter(points: mapCommon.LatLng[]): mapCommon.LatLng {
    if (points.length === 0) {
      throw new Error('坐标数组不能为空');
    }

    // 将经纬度转换为笛卡尔坐标
    const cartesianPoints = points.map(point => {
      const latRad = point.latitude * Math.PI / 180;
      const lngRad = point.longitude * Math.PI / 180;

      return {
        x: Math.cos(latRad) * Math.cos(lngRad),
        y: Math.cos(latRad) * Math.sin(lngRad),
        z: Math.sin(latRad)
      } as CartesianPoint
    });

    // 计算平均值
    const avg = cartesianPoints.reduce((acc, point) => {
      acc.x += point.x;
      acc.y += point.y;
      acc.z += point.z;
      return acc;
    }, { x: 0, y: 0, z: 0 });

    avg.x /= cartesianPoints.length;
    avg.y /= cartesianPoints.length;
    avg.z /= cartesianPoints.length;

    // 转换回经纬度
    const lngRad = Math.atan2(avg.y, avg.x);
    const hyp = Math.sqrt(avg.x * avg.x + avg.y * avg.y);
    const latRad = Math.atan2(avg.z, hyp);

    return {
      latitude: latRad * 180 / Math.PI,
      longitude: lngRad * 180 / Math.PI
    }
  }

  static calculateBounds(points: mapCommon.LatLng[]): mapCommon.LatLngBounds {
    let minLat = points[0].latitude
    let maxLat = points[0].latitude
    let minLng = points[0].longitude
    let maxLng = points[0].longitude

    points.forEach(point => {
      minLat = Math.min(minLat, point.latitude)
      maxLat = Math.max(maxLat, point.latitude)
      minLng = Math.min(minLng, point.longitude)
      maxLng = Math.max(maxLng, point.longitude)
    })
    //西北角是最大纬度和最小经度 东南角是最小纬度和最大经度
    return { northeast: { latitude: maxLat, longitude: maxLng }, southwest: { latitude: minLat, longitude: minLng } }
  }
}