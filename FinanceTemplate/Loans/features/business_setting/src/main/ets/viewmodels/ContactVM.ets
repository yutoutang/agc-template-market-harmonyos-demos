
import { BaseViewModel, RouterUtils } from 'lib_common';
import { MineGridItem, TabInfo,tabInfoList } from '../types/Types';

@ObservedV2
export class ContactViewModel extends BaseViewModel {
  @Trace currentIndex: number = 0
  @Trace onLinePhone: string = ''
  @Trace tabList: TabInfo[] = []

  init() {
    this.tabList = tabInfoList
    this.onLinePhone = '1001****000'
  }
  gridClick(v: MineGridItem) {
    RouterUtils.pushPathByName(v.routerName);
  }
  public currentIndexChange(index: number) {
    this.currentIndex = index
  }
}