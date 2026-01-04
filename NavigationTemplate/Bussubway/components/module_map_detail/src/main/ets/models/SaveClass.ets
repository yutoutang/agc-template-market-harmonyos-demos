import { SaveOneClass } from './SaveOneClass';

@ObservedV2
export class SaveClass {
  @Trace tag?: string;
  // 收藏线路集合
  @Trace savePlanClass: SaveOneClass[] = []
}