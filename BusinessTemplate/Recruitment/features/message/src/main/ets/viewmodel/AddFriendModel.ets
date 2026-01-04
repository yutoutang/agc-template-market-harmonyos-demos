import { GlobalContext, MOCK_ACCOUNT_LIST, MockAccountSingleModel } from 'common';
import { scanBarcode, scanCore } from '@kit.ScanKit';

export interface AddFriendSingleModel {
  icon: Resource;
  title: ResourceStr;
  subtitle: ResourceStr;
  type: AddFriendTypeEnum;
}

/**
 * 添加好友类型
 */
export enum AddFriendTypeEnum {
  /**
   * 手机联系人添加
   */
  CHAT_TYPE_Contact = 1,
  /**
   * 扫一扫
   */
  CHAT_TYPE_Scan = 2,
}

/**
 * 搜索好友的类型
 */
export enum SearchContactTypeEnum {
  /**
   * 昵称
   */
  CHAT_TYPE_NICK_NAME = 1,
  /**
   * 手机号
   */
  CHAT_TYPE_PHONE = 2,
}

@ObservedV2
export class SearchContactModel extends MockAccountSingleModel {
  @Trace searchType: SearchContactTypeEnum = SearchContactTypeEnum.CHAT_TYPE_NICK_NAME;
  @Trace lightArr: string[] = [];
  @Trace normalArr: string[] = [];
}

@ObservedV2
export class SearchGroupInfoModel {
  @Trace lightArr: string[] = [];
  @Trace normalArr: string[] = [];
}

@ObservedV2
export class AddFriendModel {
  @Trace pageTitle: string = '添加好友';
  @Trace localContactList: MockAccountSingleModel[] = MOCK_ACCOUNT_LIST;
  @Trace searchGroupList: SearchGroupInfoModel[] = [];
  @Trace searchContactList: SearchContactModel[] = [];
  @Trace isPhoneInput: boolean = false;

  searchContentChange(content: string) {
    if (content.length === 0) {
      this.searchGroupList = [];
      this.searchContactList = [];
      return;
    }

    this.isPhoneInput = /^(\d+|\d+\.\d*|\.\d+|\d*\.?)$/.test(content);
    if (this.isPhoneInput) {
      // 纯数字按照手机号搜索
      this.searchPhone(content);
    } else {
      // 其他字符按照群名称和联系人昵称搜索
      this.searchNickName(content);
    }
  }

  splitSearchContent(str: string, searchContent: string) {
    let normalArr: string[] = str.split(searchContent);
    let lightArr: string[] = [];
    if (normalArr.length > 1) {
      for (let index = 0; index < normalArr.length - 1; index++) {
        lightArr.push(searchContent);
      }
    }
    return [normalArr, lightArr]
  }

  searchNickName(content: string) {
    this.searchContactList = [];
    for (let index = 0; index < this.localContactList.length; index++) {
      const element = this.localContactList[index];
      let splits = this.splitSearchContent(element.nickName, content);
      this.pushContact(splits, element, SearchContactTypeEnum.CHAT_TYPE_NICK_NAME);
    }
  }

  searchPhone(content: string) {
    this.searchContactList = [];
    for (let index = 0; index < this.localContactList.length; index++) {
      const element = this.localContactList[index];
      let splits = this.splitSearchContent(element.phone, content);
      this.pushContact(splits, element, SearchContactTypeEnum.CHAT_TYPE_PHONE);
    }
  }

  pushContact(splits: string[][], element: MockAccountSingleModel, searchType: SearchContactTypeEnum) {
    let normalArr = splits[0];
    let lightArr = splits[1];
    if (lightArr.length > 0) {
      let searchContact = new SearchContactModel();
      searchContact.userId = element.userId;
      searchContact.nickName = element.nickName;
      searchContact.phone = element.phone;
      searchContact.avatarUrl = element.avatarUrl;
      searchContact.searchType = searchType;
      searchContact.normalArr = normalArr;
      searchContact.lightArr = lightArr;
      this.searchContactList.push(searchContact);
    }
  }
}