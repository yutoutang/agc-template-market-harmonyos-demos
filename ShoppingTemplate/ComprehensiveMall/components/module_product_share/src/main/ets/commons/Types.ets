import { ShareType } from './Enums';

export interface ShareItem {
  label: string;
  type: ShareType;
  icon: ResourceStr;
}

export interface ProductResource {
  image: ResourceStr;
  title: string;
  price: number;
  url: string;
}
