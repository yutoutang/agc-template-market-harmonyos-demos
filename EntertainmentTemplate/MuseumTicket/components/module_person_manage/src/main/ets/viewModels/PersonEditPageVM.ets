import { promptAction } from '@kit.ArkUI';
import { CommonUtil } from '../common/CommonUtil';
import { Contact } from '../common/Types';
import { PersonApi } from '../http/Api';


const TAG = '[PersonEditPageVM]';


@ObservedV2
export class PersonEditPageVM {
  @Trace contact: Contact = new Contact('', '', '', '', '');
  private static _instance: PersonEditPageVM;

  public static get instance() {
    if (!PersonEditPageVM._instance) {
      PersonEditPageVM._instance = new PersonEditPageVM();
    }
    return PersonEditPageVM._instance;
  }


  public cloneContact(data: Contact) {
    CommonUtil.assign(this.contact, data);
  }


  public async updatePersonInfo(data: Contact, onSuccess?: () => void) {
    const res = await PersonApi.updatePerson(data);
    if (res && onSuccess) {
      onSuccess();
    }
  }


  isContactInfoValid(): boolean {
    if (!this.contact.name) {
      promptAction.showToast({ message: '请填写姓名！' });
      return false;
    }
    if (!this.contact.cardID) {
      promptAction.showToast({ message: '请填写证件号！' });
      return false;
    }
    const idRegex = /^[1-9]\d{5}(18|19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}[\dXx]$/i;
    if (!idRegex.test(this.contact.cardID)) {
      promptAction.showToast({ message: '证件号格式不正确！' });
      return false;
    }

    if (!this.contact.phone) {
      promptAction.showToast({ message: '请填写联系电话！' });
      return false;
    }
    const reg = /^[1][2,3,4,5,6,7,8,9][0-9]{9}$/;
    if (!reg.test(this.contact.phone)) {
      promptAction.showToast({ message: '联系电话格式不正确！' });
      return false;
    }
    return true;
  }
}
