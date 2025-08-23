import { promptAction } from '@kit.ArkUI';
import { PersonApi } from '../http/Api';
import { CommonUtil } from '../common/CommonUtil';
import { Contact } from '../common/Types';

const TAG = '[CommonPersonPageVM]';


@ObservedV2
export class CommonPersonPageVM {
  @Trace personList: Contact[] = [];
  @Trace selectList: Contact[] = [];
  @Trace delId: string = '';
  private static _instance: CommonPersonPageVM;

  public static get instance() {
    if (!CommonPersonPageVM._instance) {
      CommonPersonPageVM._instance = new CommonPersonPageVM();
    }
    return CommonPersonPageVM._instance;
  }

  public async getPersonList() {
    this.personList = await PersonApi.getPersonList();
  }

  public cloneContact(data: Contact): Contact {
    const _bak: Contact = new Contact('', '', '', '', '');
    CommonUtil.assign(_bak, data);
    return _bak;
  }

  public cloneContactList(data: Contact[]): Contact[] {
    const list: Contact[] = data.map((item: Contact) => {
        return this.cloneContact(item)
    });
    return list;
  }

  public async delContact() {
    const res = await PersonApi.delContacts(this.delId);
    if (res) {
      promptAction.showToast({ message: '删除成功！' });
      this.getPersonList();
    }
  }

  public selectContact(data: Contact) {
    const _bak: Contact = new Contact('', '', '', '', '');
    CommonUtil.assign(_bak, data);
    this.selectList.push(_bak);
  }

  public cancelContact(data: Contact) {
    this.selectList = this.selectList.filter((item: Contact) => item.personID !== data.personID);
  }
}
