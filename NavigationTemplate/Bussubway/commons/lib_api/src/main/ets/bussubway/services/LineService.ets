import { ComingBusMockData } from './mockdata/ComingBusMockData';
import { ComingBus, SubwayCarState } from 'module_station_line_detail';
import { CollectionLineTagModel, RandomUtils } from 'lib_common';
import { CollectionLineTagMockData } from './mockdata/CollecionLineTagMockData';
import { util } from '@kit.ArkTS';

export class LineService {
  public getComingBusList(): ComingBus[] {
    const comingBusList: ComingBus[] = []
    ComingBusMockData.comingBusList[RandomUtils.getRandomIndex(4)].forEach((bus: ComingBus) => {
      const comingBus = new ComingBus()
      comingBus.stations = bus.stations
      comingBus.time = bus.time
      comingBus.distance = bus.distance
      comingBus.numberplate = bus.numberplate
      comingBus.crowdState = bus.crowdState
      comingBusList.push(comingBus)
    })
    return comingBusList
  }

  public getCollectionLineTags(): CollectionLineTagModel {
    const tagModel: CollectionLineTagModel = new CollectionLineTagModel()
    tagModel.tagNames.push(...CollectionLineTagMockData.tagNames)
    return tagModel
  }

  /**
   * 获取最近地铁车厢状态
   * @returns 最近地铁车厢状态
   */
  public getComingSubwayCarList(): SubwayCarState[] {
    const comingSubwayCarList: SubwayCarState[] = []
    for (let index = 0; index < 6; index++) {
      const subwayCarState: SubwayCarState = new SubwayCarState()
      subwayCarState.crowdState = String(RandomUtils.getRandomIndex(3))
      subwayCarState.tempretureState = String(RandomUtils.getRandomIndex(3))
      comingSubwayCarList.push(subwayCarState)
    }
    return comingSubwayCarList
  }
}

const instance = new LineService();

export { instance as LineServiceApi };