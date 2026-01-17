import { PersistenceV2 } from '@kit.ArkUI';
import {
  CommonUtils, GetUserInfoResp,
  RouterModule,
  updateUserInfo,
} from 'foundation';
import { ApiHandler, FormGroup, FormType,
  GenderType,
  ObservedInfoItem, PersonalInfo, SwitchInfo } from 'collect_personal_info';

@ObservedV2
export class EditPersonalInfoVM {
  @Trace userInfo: GetUserInfoResp = PersistenceV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
  @Trace avatarItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.CHOOSE_AVATAR,
    label: '头像',
    value: this.userInfo.avatar ? this.userInfo.avatar : $r('app.media.ic_user_default'),
    onChange: (param?: Object) => {
      const avatarUri = param as string;
      this.avatarItem.value = avatarUri;
      this.userInfo.avatar = avatarUri;
      updateUserInfo({ avatarUrl: avatarUri });
    },
  });
  @Trace nickNameItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXT_INPUT,
    label: '昵称',
    value: this.userInfo.nickName,
    minLength: 2,
    maxLength: 20,
    placeholderText: '昵称',
    invocation: (param: Object) => {
      return Promise.resolve();
    },
    validMessageText: '昵称不能为空',
    onChange: (param?: Object) => {
      const nickName = param as string;
      this.nickNameItem.value = nickName;
      this.userInfo.nickName = nickName;
      updateUserInfo({ nickName: nickName });
    },
  })
  @Trace genderItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.DROP_SELECT,
    label: '性别',
    selectOptions: [
      {
        id: 0,
        value: 0,
        label: '男',
      },
      {
        id: 1,
        value: 1,
        label: '女',
      },
      {
        id: 2,
        value: 2,
        label: '保密',
      },
    ],
    value: this.userInfo.gender,
    onChange: (param?: Object) => {
      const gender = param as number;
      this.genderItem.value = param as number;
      this.userInfo.gender = gender;
      updateUserInfo({ gender: gender });
    },
  });

  @Trace fullNameItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXT_INPUT,
    label: '姓名',
    minLength: 2,
    maxLength: 10,
    placeholderText: '姓名',
    validMessageText: '姓名不能为空',
    value: this.userInfo.fullName,
    onChange: (param?: Object) => {
      const fullName = param as string;
      this.fullNameItem.value = fullName;
      this.userInfo.fullName = fullName;
      updateUserInfo({ fullName: fullName });
    },
  })

  @Trace birthItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.DATE_SELECT,
    label: '出生日期',
    sheetTitle: '出生日期',
    sheetOptions: {
      height: 440,
    },
    value: this.userInfo.birthDate ? new Date(this.userInfo.birthDate) : undefined,
    onChange: (param?: Object) => {
      this.birthItem.value = param as Date;
      const birthDate = CommonUtils.formatDate(param as Date)
      this.userInfo.birthDate = birthDate;
      updateUserInfo({ birthDate: birthDate });
    },
  });
  @Trace phoneItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.PHONE_INPUT,
    label: '手机号码',
    maxLength: 11,
    validMessageText: '手机号码不能为空',
    value: this.userInfo.mobile,
    onChange: (param?: Object) => {
      const mobile = param as string;
      this.phoneItem.value = mobile;
      this.userInfo.mobile = mobile
      updateUserInfo({ mobile: mobile });
    },
  })

  @Trace list: FormGroup[] = [
    {
      list: [this.avatarItem],
    },
    {
      list: [
        this.nickNameItem,
        this.genderItem,
        this.birthItem
      ],
    },
    {
      list: [
        this.fullNameItem,
        this.phoneItem,
      ],
    },
  ];

  customBack() {
    RouterModule.pop();
    return true;
  }
}