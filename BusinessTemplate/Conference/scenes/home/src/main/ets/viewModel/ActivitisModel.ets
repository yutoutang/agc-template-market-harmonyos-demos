export class ActivityDetailsParams {
  type?: string

  constructor(type?: string) {
    this.type = type
  }
}

export interface ActivityListItem {
  type: string,
  name: string,
  image: string,
  address: string,
  longitude: string,
  latitude: string,
  desc: string
}



