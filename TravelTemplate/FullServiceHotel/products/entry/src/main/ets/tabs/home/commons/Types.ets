export interface BannerItem {
  image: string;
}

export interface PublicNoticeItem {
  title: string;
  contentList?: string[];
  noticeId: number;
  date: string;
}

export interface VIPMemberInfo {
  name: string;
  level: string;
  currentPoints: number;
  totalPoints: number;
}

export interface ServiceItem {
  link: string;
  image: string;
  title: string;
}

export interface ProductItemResp {
  text: string;
  image: string;
  price: string;
  oldPrice: string;
  id?: string;
  monthlySales?: string;
}

export interface ProductItem {
  label: string;
  image: ResourceStr;
  originalPrice: string;
  discountedPrice: string;
  id?: string;
  monthlySales?: string;
}
