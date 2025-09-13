import { util } from '@kit.ArkTS';
import { PersistenceV2 } from '@kit.ArkUI';
import { UserInfoModel } from '../models/UserInfoModel';

@ObservedV2
export class GlobalStateMgr {
  @Trace
  public rootPageActiveTabId: string = '';
  @Trace
  public isNavPathStackEmpty: boolean = true;
  @Trace
  public cartVersion: string = util.generateRandomUUID(false);
  @Trace
  public cartTotal: number = 0;
  @Trace
  public isLogin: boolean = false;
  @Trace
  public userInfo: UserInfoModel = new UserInfoModel();
}

@ObservedV2
export class Persistence {
  @Trace
  public userToken: string = '';
}

@ObservedV2
class IData {
  @Trace
  public readonly global: GlobalStateMgr = PersistenceV2.connect(
    GlobalStateMgr,
    () => new GlobalStateMgr(),
  )!;
  @Trace
  public readonly local: Persistence = PersistenceV2.connect(
    Persistence,
    () => new Persistence(),
  )!;
}

const iData: IData = new IData();

export { iData };
