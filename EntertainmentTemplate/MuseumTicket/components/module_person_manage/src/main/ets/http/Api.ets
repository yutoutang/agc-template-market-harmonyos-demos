import { util } from '@kit.ArkTS';
import { Contact } from '../common/Types';

export class PersonApi {
  static PERSON_LIST: Contact[] = [
    new Contact('1', '身份证', '张三', '12011111111', '110293190102291111'),
    new Contact('2', '身份证', '李四', '12011111112', '110293190102291112'),
    new Contact('3', '身份证', '王五', '12011111113', '110293190102291113'),
  ];

  public static getPersonList(): Promise<Contact[]> {
    const personListBak: Contact[] = PersonApi.PERSON_LIST.map((item) => {
      const obj = new Contact(item.personID, item.cardType, item.name, item.phone, item.cardID);
      return obj;
    });
    return Promise.resolve(personListBak);
  }

  public static updatePerson(data: Contact): Promise<boolean> {
    PersonApi.PERSON_LIST =
      PersonApi.PERSON_LIST.filter((item) => item.personID !== data.personID);
    const obj: Contact = new Contact(data.personID, data.cardType, data.name, data.phone, data.cardID);
    PersonApi.PERSON_LIST.push(obj);
    return Promise.resolve(true);
  }


  public static delContacts(personID: string): Promise<boolean> {
    PersonApi.PERSON_LIST =
      PersonApi.PERSON_LIST.filter((item) => item.personID !== personID);
    return Promise.resolve(true);
  }
}