//地址信息
@ObservedV2
export class AddressInfo {
  @Trace id: number = 0
  @Trace addressPre: string = ''
  @Trace addressNum: string = ''
  @Trace name: string = ''
  @Trace sex: boolean = true
  @Trace tel: string = ''
  @Trace tag: number = 0
  @Trace latitude: number = 0
  @Trace longitude: number = 0

  init(address: AddressInfo) {
    this.id = address.id
    this.addressPre = address.addressPre
    this.addressNum = address.addressNum
    this.name = address.name
    this.sex = address.sex
    this.tel = address.tel
    this.tag = address.tag
    this.latitude = address.latitude
    this.longitude = address.longitude
  }
}