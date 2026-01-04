import { BaseResponse } from './BaseResponse';
import { StoreResponse } from './StoreResponse';

export interface HomeConfigResp extends BaseResponse {
  categoryList: CategoryItem[];
  storeList: StoreResponse[];
}

export interface CategoryItem {
  id: string;
  label: string;
  iconUrl: ResourceStr;
  subCategory?: SubCategoryItem[];
}

export interface SubCategoryItem {
  id: string;
  label: string;
}