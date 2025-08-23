import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { map, mapCommon } from '@kit.MapKit';
import { Decimal } from '@kit.ArkTS';

export function copyString(param: string = '') {
  let pasteData: pasteboard.PasteData =
    pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, param)
  let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
  systemPasteboard.setData(pasteData)
    .then(() => {
      console.info('succeeded in setting PasteData. ')
      promptAction.showToast({
        message: $r('app.string.copy_success'),
        duration: 2000,
      });
    })
    .catch((err: BusinessError) => {
      console.error(`faild to set PasteData, ${JSON.stringify(err)}`)
    })
}

export function getDistanceByLocation(fromLatLng: mapCommon.LatLng, toLatLng: mapCommon.LatLng): string {
  return getDistance(map.calculateDistance(fromLatLng, toLatLng));
}

export function getDistance(distance: number = 0) {
  if (distance > 1000) {
    return `${new Decimal(distance).div(1000).toFixed(2)}KM`
  } else {
    return `${new Decimal(distance).toFixed(2)}M`;
  }
}

export function getAnonymousTel(userTel: string = '') {
  if (userTel.length >= 8) {
    return `${userTel.substring(0, userTel.length - 8)}****${userTel.substring(userTel.length - 4)}`
  } else {
    return '****';
  }
}