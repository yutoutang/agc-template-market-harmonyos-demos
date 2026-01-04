export interface TransferStep {
  type: 'walk' | 'bus' | 'metro'
  text: string
  badge?: string
}

export interface LineBusCardType {
  title: string;
  stopCount: number;
  stopTime: string;
  stationText: string;
  headingText: string
  category?: 'home' | 'work'
}

export interface LineMetroCardType {
  title: string;
  etaText: string;
  stationText: string;
  firstTime: string;
  lastTime: string;
  headingText: string
  category?: 'home' | 'work'
}

export interface TransferCardType {
  totalTimeText: string;
  distanceText: string;
  steps: TransferStep[];
  summaryText: string;
  summaryText2: string;
  category?: 'home' | 'work'
}

export interface StationMetroCardType {
  metroTitle: string
  title: string
  walkingText: string
  origin: string
  destination: string
  firstTime: string
  lastTime: string
  category?: 'home' | 'work'
}

export interface StationBusCardType {
  metroTitle: string
  title: string
  walkingText: string
  headingText: string
  stopCount: string
  stopTime: string
  statusPrefix: string
  statusSubTime: string
  category?: 'home' | 'work'
}




