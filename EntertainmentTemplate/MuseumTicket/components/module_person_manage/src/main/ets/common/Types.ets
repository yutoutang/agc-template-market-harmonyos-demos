
// 常用人
@ObservedV2
export class Contact {
  @Trace personID: string
  @Trace cardType: string;
  @Trace name: string;
  @Trace phone: string;
  @Trace cardID: string;

  constructor(personID: string, cardType: string, name: string, phone: string, cardID: string) {
    this.personID = personID;
    this.cardType = cardType;
    this.name = name;
    this.phone = phone;
    this.cardID = cardID;
  }
}


// 选择模式
export enum SelectMode{
  NO_SELECT = '1',
  SINGLE_SELECT = '2',
  MORE_SELECT='3'
}


@ObservedV2
export class Context {
  @Trace
  public navPathStack: NavPathStack = new NavPathStack();
  @Trace
  public selectMode: SelectMode = SelectMode.NO_SELECT;
  @Trace
  public onSelect: (data: Contact | Contact[]) => void = () => {
  }
  @Trace
  public contact: Contact = new Contact('', '', '', '', '')
  @Trace
  public disableId:string[]=[]
}


