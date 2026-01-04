import { StoreResponse } from 'lib_takeaway_api/src/main/ets/params/response/StoreResponse';
import { LabelPresetType } from './Enums';

export interface LabelItem {
  preset: LabelPresetType;
  data: string;
}

export interface ProductCardItem {
  productId: string;
  price: number;
  dashPrice?: number;
  title: string;
  banner: ResourceStr;
  promotion: string[];
  label: LabelItem[];
}

export interface ProductListResp {
  list: StoreResponse[];
  isFinal: boolean;
}
