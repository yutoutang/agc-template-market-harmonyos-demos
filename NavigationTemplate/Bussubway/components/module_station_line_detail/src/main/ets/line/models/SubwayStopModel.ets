@ObservedV2
export class SubwayStopInfo {
  @Trace id?: string
  @Trace lnglat?: string
  @Trace name?: string
  @Trace poiid?: string
  @Trace referlines?: Referline[]
  @Trace status?: string
  @Trace distance?: string
}

@ObservedV2
export class Referline {
  @Trace color?: string
  @Trace id?: string
  @Trace name?: string
  @Trace shortname?: string
}

@ObservedV2
export class SubwayStopline {
  @Trace name?: string
  @Trace uicolor?: string
  @Trace lineDetails: SubwayStoplineDetail[] = []
}

@ObservedV2
export class SubwayStoplineDetail {
  // 首发站
  @Trace id?: string
  // 首发站
  @Trace startStop?: string
  // 末站
  @Trace endStop?: string
  // 首班车时间
  @Trace startTime?: string
  // 末班车时间
  @Trace endTime?: string
}