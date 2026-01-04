import { MapOptionType } from './Enums';

export interface StoreMapInfo {
  shopName: string;
  latitude: number;
  longitude: number;
  address: string;
}

export interface MapOptionDialogItem {
  type: MapOptionType;
  label: string;
}

export interface MapMarkerLocation {
  latitude: number;
  longitude: number;
}