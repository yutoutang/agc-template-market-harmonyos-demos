export class ParamsType<T> {
  value: T

  constructor(value: T) {
    this.value = value
  }
}

export class WebViewParams {
  url: string | Resource

  constructor(url: string | Resource) {
    this.url = url;
  }
}

export class VideoParams {
  src: string
  url: string

  constructor(src: string, url: string) {
    this.src = src;
    this.url = url;
  }
}

export class TrafficParams {
  levelOneTap: string
  levelTwoTap: string

  constructor(levelOneTap: string, levelTwoTap: string) {
    this.levelOneTap = levelOneTap;
    this.levelTwoTap = levelTwoTap;
  }
}