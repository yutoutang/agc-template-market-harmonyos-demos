import { MockAccountSingleModel } from '../model/AccountDialogModel';

// 泛型类型
export type TValueType = string | boolean | number | null | Array<TValueType> | Object | Object[] | (() => void)

export class Constants {
  public static readonly FULL_SIZE = '100%';
  public static readonly TAB_INDEX_ZERO: number = 0;
  public static readonly TAB_INDEX_ONE: number = 1;
  public static readonly TAB_INDEX_TWO: number = 2;
  public static readonly TAB_INDEX_THREE: number = 3;
  public static readonly onMessagePageShowChange: string = 'eventMessagePageShow'
  public static readonly onMessagePageHideChange: string = 'eventMessagePageHide'

  public static getMockNickName(userId: string) {
    const targetUser: MockAccountSingleModel | undefined = MOCK_ACCOUNT_LIST.find(user => user.userId === userId);
    if (targetUser !== undefined) {
      return targetUser.nickName;
    }
    return '';
  }
  public static getMockCompanyName(userId: string) {
    const targetUser: MockAccountSingleModel | undefined = MOCK_ACCOUNT_LIST.find(user => user.userId === userId);
    if (targetUser !== undefined) {
      return targetUser.companyName;
    }
    return '';
  }
  public static getMockAvatar(userId: string) {
    const targetUser: MockAccountSingleModel | undefined = MOCK_ACCOUNT_LIST.find(user => user.userId === userId);
    if (targetUser !== undefined) {
      return targetUser.avatarUrl;
    }
    return '';
  }
}

export const MOCK_ACCOUNT_LIST: MockAccountSingleModel[] = [
  {
    userId: 'user_one',
    nickName: '应聘者',
    phone: '139****567',
    avatarUrl: 'user_one_avatar',
    userSig: 'eJwtzE8LgjAcxvH3snPYZuw3FDp48WJ0qAQZQVSb8ktca-4hjd57ph6fzwPfDzntjl6nHQmJ71GymjYqbRrMceK21u7yNHr5al' +
      'VerUVFQgaUMgbgw-zot0WnR*ec*5TSWRus-iaAM7FhIlgqWIzpLCq7KN5nN5PzIh4e53Ul5Cs5tH3ZyLtLezFI1RpuIEi35PsDSHs0Ig__'
  },
  {
    userId: 'user_two',
    nickName: 'James',
    phone: '158****5672',
    avatarUrl: 'user_two_avatar',
    userSig: 'eJyrVgrxCdYrSy1SslIy0jNQ0gHzM1NS80oy0zLBwqXFqUXxJeX5ULnilOzEgoLMFCUrQzMDA0NDMzMjM4hMakVBZlEqUNzU1N' +
      'TIwMAAIlqSmQsSMzczNTQ3NjaygJqSmQ402sIvQ9vcozjD3SnLOMMyPcc4K988zNPJLS1G398xI7s4N7QoO8DU2CMw0zTUVqkWACihMpo_'
  },
  {
    userId: 'user_three',
    companyName:'B软件·HR',
    nickName: '赵女士',
    phone: '158****5673',
    avatarUrl: 'user_two_avatar',
    userSig: 'eJwtzMEKgkAUheF3mXXIHXVGElooFIHSIqNtCHN1rlLozFhJ9O6Zujzfgf-DLnnhPdGwmPkesM28SeHDUUUzDxbNzWmDuL5WtWX' +
      'XkWIxlwCcS*nL5cF3RwYnF0L4ALCoo-vfIimCQMKWrxWqp3ietWib3mVRUqFxRzWESXoee6tbfbo2h33VpEFZ1OH42rHvD6LYNLE_'
  },
  {
    userId: 'user_four',
    companyName:'C软件·HR',
    nickName: '刘先生',
    phone: '158****5674',
    avatarUrl: 'user_two_avatar',
    userSig: 'eJwtzNsKgkAUheF3mdvC9ozNFoRuKsIywkiCQIhkRtsdZTygRO*eqZfrW-B-WLg9WJU2zGXCAjbuNin9Kiihjstcm3PyLs1w5up' +
      '*yTJSzOUIwDmiwP7RdUZGty6lFADQa0HPvzkobRu5EEOF0ratNroKg5U3SuN186gDexfMneXeq-R1cZs20cSPSSCdfDjCjH1-dx8zCQ__'
  },
  {
    userId: 'user_five',
    nickName: '孙女士',
    companyName:'D软件·HR',
    phone: '158****5675',
    avatarUrl: 'user_two_avatar',
    userSig: 'eJwtzEsLgkAUBeD-MuuweThjCC1MKghXpRERRDRXu-YSZxyE6L9n6vJ853A*JE12noOahIR7lEz6jBpeFnPsuTFQn3N0MJZG3y9' +
      'VhZqETFHKmFJcDQ20FdbQuZSSU0oHtfj8W6CkEIqJcWuw6L6vpV1Gm3Stzb507WmqXPYubARNsDj6Bx6zxH*s4vgmtrNsTr4-eq4zIA__'
  },
  {
    userId: 'user_six',
    nickName: '张女士',
    companyName:'A软件·HR',
    phone: '158****5676',
    avatarUrl: 'user_two_avatar',
    userSig: 'eJwtzFELgjAUhuH-stvC5tZOKHQRSGAYXRiEEIS0kx0slWljFP33TL38ng-eDzsmqWfRsJAJj7P5sElj1dGNBn61aC4tuelrdZk3' +
      'DWkW*sC57wMIGB90DRnsXSklOOejdvT82wqUlLAM1FShok9nyklT4uN6txZqGQXb9z7O64OIYkxsNtNpVLjzQlen3WbNvj9FaDNk'
  }
];

