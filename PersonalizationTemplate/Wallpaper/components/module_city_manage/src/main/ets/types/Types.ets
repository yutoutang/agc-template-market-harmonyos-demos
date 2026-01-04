export interface Province {
  name: string;
  code: string;
  city?: City[];
}

export interface City {
  name: string;
  code: string;
  area?: Area[];
}

export interface Area {
  name: string;
  code: string;
}

export interface SearchInfo {
  province: string;
  city?: string;
  area?: string;
  code: string;
}

export interface IPosition {
  name: string;
  code: string;
}