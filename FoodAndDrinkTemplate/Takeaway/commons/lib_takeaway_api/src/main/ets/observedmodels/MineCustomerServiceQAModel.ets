import { MineCustomerServiceQAResponse } from '../params/response/MineCustomerServiceQAResponse';

@ObservedV2
export class MineCustomerServiceQAModel implements MineCustomerServiceQAResponse {
  @Trace id: string = ''
  @Trace question: string;
  @Trace createTime: number;
  @Trace title: string;
  @Trace image: string | Resource;
  @Trace content: string | Resource;

  constructor(v: MineCustomerServiceQAResponse) {
    this.id = v.id;
    this.question = v.question;
    this.createTime = v.createTime;
    this.title = v.title;
    this.image = v.image;
    this.content = v.content;
  }
}