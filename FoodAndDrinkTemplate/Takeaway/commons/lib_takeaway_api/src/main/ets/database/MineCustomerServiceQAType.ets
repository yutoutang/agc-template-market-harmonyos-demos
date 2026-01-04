/**
 * 客服问答
 */
export interface BaseMineCustomerServiceQA {
  id: string;
  question: string;
  createTime: number;
  title: string;
  image: string | Resource;
  content: string | Resource;
  isRichText: boolean;
}
