import { SubwayStopInfo, SubwayStopline } from '../models/SubwayStopModel'

@ObservedV2
export class SubwayViewModel {
  @Trace isShowStopSheet: boolean = false
  @Trace subwayStopInfo: SubwayStopInfo = new SubwayStopInfo()
  @Trace subwayStoplines: SubwayStopline[] = []
  searchSubwayStopline?: (id: string[]) => Promise<SubwayStopline[]>
  searchSubwayStopDistance: (lnglat: string) =>  Promise<number> = () => new Promise((resolve) => resolve(0))

  async showStopSheet(info: SubwayStopInfo) {
    if (this.isShowStopSheet) {
      this.isShowStopSheet = false
    }
    this.subwayStoplines = []
    if (this.searchSubwayStopline && info.referlines) {
      const ids = info.referlines.map(referline => referline.id!)
      this.subwayStoplines = await this.searchSubwayStopline(ids)
    }
    const distance = await this.searchSubwayStopDistance(info.lnglat!)
    const distanceStr = this.convertWalkDistance(distance)
    info.distance = distanceStr
    this.isShowStopSheet = true
    this.subwayStopInfo = info
  }

  private convertWalkDistance(distance: number) {
    if (distance < 1000) {
      return distance + '米'
    } else {
      return Number((distance / 1000).toFixed(1)) + '公里'
    }
  }
}