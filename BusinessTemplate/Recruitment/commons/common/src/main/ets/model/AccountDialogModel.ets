import { OHDialogModel } from '../dialog/OHDialogModel';
import { MOCK_ACCOUNT_LIST } from '../constant/Constants';

@ObservedV2
export class AccountDialogModel extends OHDialogModel {
  @Trace title: ResourceStr = $r('app.string.mock_account_title');
  @Trace value: MockAccountSingleModel[] = MOCK_ACCOUNT_LIST;
  @Trace currentUser: MockAccountSingleModel = new MockAccountSingleModel();
}

@ObservedV2
export class MockAccountSingleModel {
  @Trace userId: string = '';
  @Trace nickName: string = ''; // 昵称
  @Trace phone: string = ''; // 手机号
  @Trace avatarUrl: string = ''; // 头像
  @Trace userSig: string = '';
  @Trace companyName?:string=''
}