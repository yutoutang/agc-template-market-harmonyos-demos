import { StopDetailModel } from './StopDetailModel';

@ObservedV2
export class StopNavigation {
  chooseType: string = ''
  stopDetail?: StopDetailModel
}