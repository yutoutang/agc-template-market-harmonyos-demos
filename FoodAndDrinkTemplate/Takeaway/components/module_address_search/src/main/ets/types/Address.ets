import { mapCommon } from '@kit.MapKit';

export interface IAddressInfo {
  siteId: string;
  name: string;
  addr: string;
  location: mapCommon.LatLng;
}

@ObservedV2
export class AddressModel implements IAddressInfo {
  @Trace siteId: string = '';
  @Trace name: string = '';
  @Trace addr: string = '';
  @Trace location: mapCommon.LatLng = { latitude: 39.9, longitude: 116.4 };
}