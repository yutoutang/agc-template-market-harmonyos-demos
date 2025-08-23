export interface MyMapArr {
  items: MyMap[],
}

@Observed
export class MyMap {
  image: string;
  imagePreview: string;
  title: string;
  address: string;
  addressDesc: string;
  longitude: string;
  latitude: string;
  traffic: MapTraffic[];

  constructor(data?: MyMap) {
    this.image = '';
    this.imagePreview = '';
    this.title = '';
    this.address = '';
    this.addressDesc = '';
    this.longitude = '';
    this.latitude = '';
    this.traffic = [];
    if (data) {
      this.image = data.image;
      this.imagePreview = data.imagePreview;
      this.title = data.title;
      this.address = data.address;
      this.addressDesc = data.addressDesc;
      this.longitude = data.longitude;
      this.latitude = data.latitude;
      this.traffic = data.traffic || [];
    }
  }
}

export interface Traffic {
  name: string,
  address: string[],
}

export interface MapTraffic {
  name: string,
  address: MapAddressItem[],
}

export interface MapAddressItem {
  copyText: string;
  desc: string;
}

export interface CateringArr {
  items: MyCatering[],
}

export interface MyCatering {
  icon: string,
  title: string,
  image: string,
  time: string,
  address: string,
  list: MyCaterItem[]
}

export interface MyCaterItem {
  image: string,
  name: string,
  tag: string[],
  order: number,
  address: string,
  longitude: string,
  latitude: string,
  desc: string
}


export interface MyTrafficArr {
  items: MyTrafficItem[],
}

export interface MyTrafficItem {
  tapName?: string,
  tapNameList?: string[]
  list?: MyTrafficList[],
  childList?: MyTrafficChildList[],
  desc: string,
  optionalVehicleModels: string,
  reservationChannel: string,
  tip: string,
  traffic: MyTrafficTraffic [],
  ziZhuMapList: MyTrafficZiZhuMapList[],
}

export interface MyTrafficTraffic {

  name: string,
  address: string,
}

export interface MyTrafficZiZhuMapList {
  title: string,
  traffic: MyTrafficZiZhuMapListChild[],
}

export interface MyTrafficZiZhuMapListChild {
  name: string,
  children: MyTrafficZiZhuMapListChildItem[]
}

export interface MyTrafficZiZhuMapListChildItem {
  copyText: string,
  desc: string
}

export interface MyTrafficList {
  title: string,
  icon: string,
  href: string,
  list: MyTrafficListChildList[],
}

export interface MyTrafficListChildList {
  date: string,
  lineList: MyTrafficListLineList[],
}

export interface MyTrafficListLineList {
  name: string,
  line: string,
  time: string
  desc: string
}

export interface MyTrafficChildList {
  title: string,
  fileName: string,
  childLineList: MyTrafficListChildList[] | MyTrafficListLineList[],
}

