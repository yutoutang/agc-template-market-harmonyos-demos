import { Type } from '@kit.ArkUI';

@ObservedV2
export class TravelPeopleModel {
  // 证件号码,唯一标识
  @Trace idNumber: string = ''
  // 姓名
  @Trace name: string = ''
  // 手机号
  @Trace phone: string = ''
  // 加***号的身份证号
  @Trace maskedIdNumber?: string = ''
  // 加***手机号
  @Trace maskedPhone?: string = ''
  // 是否是选中状态
  @Trace isCheck: boolean = false;
  // 是否是本人
  @Trace isMyself?: boolean = false;
}

@ObservedV2
export class TravelPeopleListModel {
  @Type(TravelPeopleModel)
  @Trace list: TravelPeopleModel[] = [];
  @Trace myselfIdNumber: string = ''

  // 新增
  addList(data: TravelPeopleModel): void {
    data.maskedIdNumber = this.maskedIdCard(data.idNumber)
    data.maskedPhone = this.getEncryptionPhone(data.phone)
    data.isCheck = false
    this.list.unshift(data);
    this.setMyself(data)
    this.sortPersons()
  }

  // 删除
  removeList(idNumber: string): void {
    let index = this.list.findIndex((item: TravelPeopleModel) => item.idNumber === idNumber)
    this.list.splice(index, 1);
  }

  //更新check状态
  updateSelectStatus(isSelect: boolean, idNumber: string) {
    let index = this.list.findIndex((item: TravelPeopleModel) => item.idNumber === idNumber)
    this.list[index].isCheck = isSelect;
  }

  //编辑更新
  editList(data: TravelPeopleModel) {
    let index = this.list.findIndex((item: TravelPeopleModel) => item.idNumber === data.idNumber)
    data.maskedIdNumber = this.maskedIdCard(data.idNumber)
    data.maskedPhone = this.getEncryptionPhone(data.phone)
    this.list[index] = data
    this.setMyself(data)
    this.sortPersons()
  }

  //  身份证号加密
  maskedIdCard(idNumber: string) {
    return idNumber.replace(/^(\d{4})\d+(\d{3})$/, '$1******$2');
  }

  getEncryptionPhone(phone: string) {
    const reg = /(\d{3})\d{4}(\d{4})/;
    return phone.toString().replace(reg, '$1****$2')
  }

  //设置为本人,当前条数据isMyself设置true，其他数据isMyself就要为false
  setMyself(data: TravelPeopleModel) {
    if (data.isMyself) {
      this.myselfIdNumber = data.idNumber;
    } else if (!data.isMyself && data.idNumber === this.myselfIdNumber) {
      this.myselfIdNumber = '';
    }
    this.list.forEach((item) => {
      item.isMyself = this.myselfIdNumber === item.idNumber &&
        item?.idNumber !== ''
    })
  }

  // 将由本人的数据置顶
  sortPersons() {
    this.list = [...this.list].sort((a, b) => {
      return (b.isMyself && b.idNumber === this.myselfIdNumber ? 1 : 0) -
        (a.isMyself && a.idNumber === this.myselfIdNumber ? 1 : 0);
    });
  }
}



