import { StoreEnum } from '../constants/Constants'
import { StoreResponse } from '../params/response/StoreResponse'

@ObservedV2
export class StoreModel implements StoreResponse {
  @Trace id: string = ''
  @Trace type: StoreEnum
  @Trace name: string
  @Trace score: number
  @Trace monthlySales: number
  @Trace followCount: number
  @Trace startingPrice: number
  @Trace deliveryFee: number
  @Trace deliveryTime: number
  @Trace distance: number
  @Trace createTime: number
  @Trace shareCount: number
  @Trace coverUrl?: string | undefined
  @Trace address?: string
  @Trace openTime?: string
  @Trace introduction?: string
  @Trace latitude?: number
  @Trace longitude?: number

  constructor(v: StoreResponse) {
    this.id = v.id;
    this.type = v.type;
    this.name = v.name;
    this.score = v.score;
    this.monthlySales = v.monthlySales;
    this.followCount = v.followCount;
    this.startingPrice = v.startingPrice;
    this.deliveryFee = v.deliveryFee;
    this.deliveryTime = v.deliveryTime;
    this.distance = v.distance;
    this.createTime = v.createTime;
    this.shareCount = v.shareCount;
    this.coverUrl = v.coverUrl;
    this.address = v.address
    this.openTime = v.openTime
    this.introduction = v.introduction
    this.latitude = v.latitude
    this.longitude = v.longitude
  }
}