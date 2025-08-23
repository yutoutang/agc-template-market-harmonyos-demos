import { IUserInfo } from './IResponse'
import { AppStorageV2 } from '@kit.ArkUI'

/**
 * 签到
 */
@ObservedV2
export class CheckIn {
  @Trace id: number = 0
  @Trace isChecked: boolean = false
  @Trace value: number = 0

  constructor(id: number, isChecked: boolean, value: number) {
    this.id = id
    this.isChecked = isChecked
    this.value = value
  }
}

/**
 * 优惠券
 */
@ObservedV2
export class Coupon {
  @Trace id: number = 0
  @Trace name: string = ''
  @Trace type: number = 0
  @Trace promotion: number = 0
  @Trace promotionsLimit: string = ''
  @Trace goodsLimit: string = ''
  @Trace time: string = ''
  @Trace isAvailable: boolean = true
  @Trace isShow: boolean = false
  @Trace instructionList?: string[]

  constructor(id: number, name: string, type: number, promotion: number, promotionsLimit: string, goodsLimit: string,
    time: string, isAvailable: boolean, isShow: boolean, instructionList?: string[]) {
    this.id = id
    this.name = name
    this.type = type
    this.promotion = promotion
    this.promotionsLimit = promotionsLimit
    this.goodsLimit = goodsLimit
    this.time = time
    this.isAvailable = isAvailable
    this.isShow = isShow
    this.instructionList = instructionList
  }
}