
import { BaseViewModel } from 'lib_common';
import { MediaUtils } from 'module_feedback';
import { Constants } from '../constants/Constants';

@ObservedV2
export class FraudReportViewModel extends BaseViewModel {

  @Trace imgArr: string[] = [];
  @Trace reportDescription: string = '';
  @Trace currentIndex :number = 0
  @Trace maxSelectNumber: number = Constants.MAX_IMG_COUNT;
  async selectPhoto() {
    const uriList = await MediaUtils.selectMedia(this.maxSelectNumber);
    this.imgArr.push(...uriList);
  }
  public currentIndexChange(index: number) {
    this.currentIndex = index
  }
}