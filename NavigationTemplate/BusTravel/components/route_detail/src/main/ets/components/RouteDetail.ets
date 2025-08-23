import { BusinessError } from '@kit.BasicServicesKit'
import { MapComponent, mapCommon, map } from '@kit.MapKit'
import { common } from '@kit.AbilityKit'
import { SearchSet } from '../types'
import { BreakpointConstants, CommonConstants } from '../constants'
import { BreakpointType, DeviceScreen, HWMap } from '../utils'
import { busLine, BusLineInfo } from './BusLine'
import { BusLineView } from './BusLineView'

const context = getContext(this) as common.UIAbilityContext

@ComponentV2
export struct RouteDetail {
  hwMap = new HWMap(context)
  // 站点
  @Param stationLocation: SearchSet[] = []
  /*
   * 公交路线信息
   * 车次、行车方向、首班时间、末班时间、票价、当前站点、具体路线、最近的三辆车
   * */
  @Param busLineInfo: BusLineInfo = new BusLineInfo()
  /*
   * 当前该路线的公交车
   * 在外部动态修改参数,监听整体变化和增删变化
   * */
  @Param busLocation: mapCommon.LatLng[] = []
  @Monitor('busLocation','busLocation.length')
  refreshBus() {
    // 公交位置发生变化，地图上重新绘制公交
    this.hwMap.refreshBus(this.busLocation)
  }
  // 横向图形，当前路线上的公交车索引数组
  @Param busIndex: number[] = []
  // 距离最近的公交的下标
  @Param nearToMe: number = -1
  // 控制手势滑动高度
  @Local columnMaxHeight: number = 0
  @Local tempColumnHeight: number = CommonConstants.HEIGHT_MIDDLE
  // 线路，经纬度数组，从站点信息中拿到
  @Local lineDots: mapCommon.LatLng[] = []
  @Local mapController?: map.MapComponentController | undefined = undefined
  @Local currentBreakpoint: string = BreakpointConstants.BREAKPOINT_MD
  @Local isShowBack: boolean = false
  @Local isShow: boolean = true
  @Local columnHeight: number = CommonConstants.HEIGHT_MIDDLE
  @Local left: number = CommonConstants.LEFT_MD
  @Local tempLeft: number = CommonConstants.LEFT_MD
  private smMaxHeight: number =
    DeviceScreen.getDeviceHeight() - 8 - (px2vp(AppStorage.get('topRectHeight') as number)) ?? 0
  private panOptionHeight: PanGestureOptions = new PanGestureOptions({
    direction: PanDirection.Up | PanDirection.Down
  })
  private panOptionPosition: PanGestureOptions = new PanGestureOptions({
    direction: PanDirection.Left | PanDirection.Right,
    distance: 10
  })

  getHeight() {
    this.columnMaxHeight =
      new BreakpointType(this.smMaxHeight, CommonConstants.HEIGHT_MD).getValue(this.currentBreakpoint)
    if (this.tempColumnHeight === this.smMaxHeight && this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD) {
      this.tempColumnHeight = CommonConstants.HEIGHT_MD
    }
    if (this.tempColumnHeight === CommonConstants.HEIGHT_MD &&
      this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM) {
      this.tempColumnHeight = this.smMaxHeight
    }
  }


  drawAll() {
    this.stationLocation.forEach((item: SearchSet) => {
      this.lineDots.push({
        longitude: item.coordX,
        latitude: item.coordY
      })
    })
    this.hwMap.drawAll(this.lineDots, this.stationLocation, this.busLocation)
  }

  aboutToAppear(): void {
    this.getHeight()
    if (this.stationLocation.length) {
      this.hwMap.firstLon = this.stationLocation[0].coordX
      this.hwMap.firstLat = this.stationLocation[0].coordY
    }
  }

  build() {
    Column() {
      // 地图展示
      MapComponent({
        mapOptions: this.hwMap.mapOptions,
        mapCallback: (err: BusinessError, mapController: map.MapComponentController) => {
          this.hwMap.getMapView(err, mapController, () => {
            this.drawAll()
            this.hwMap.moveCamera()
          })
        }
      })
        .height(780 - this.tempColumnHeight)
      // 公交信息
      Stack({ alignContent: Alignment.Top }) {
        Row()
          .backgroundColor('#62B42E')
          .height(this.tempColumnHeight)
          .width('100%')
          .borderRadius({ topLeft: '20vp', topRight: '20vp' })

        Column() {
          Row() {
            Divider()
              .strokeWidth('1px')
              .color($r('sys.color.ohos_id_color_list_separator'))
              .width('48vp')
              .lineCap(LineCapStyle.Round)
              .padding({ bottom: '16vp' })
          }
          .height('26vp')
          .width(CommonConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.Center)

          // 路线信息
          busLine({ busLineInfo: this.busLineInfo })
          // 路线图
          BusLineView({ busStationName: this.busLineInfo.line, busIndex: this.busIndex, nearToMe: this.nearToMe })
        }
        .gesture(
          PanGesture(this.panOptionHeight)
            .onActionUpdate((event?: GestureEvent) => {
              if (event) {
                let height = this.columnHeight - event.offsetY
                this.tempColumnHeight = height
                if (this.tempColumnHeight < CommonConstants.HEIGHT_LOW) {
                  this.tempColumnHeight = CommonConstants.HEIGHT_LOW
                }
                if (this.tempColumnHeight > this.columnMaxHeight) {
                  this.tempColumnHeight = this.columnMaxHeight
                }
              }
            })
            .onActionEnd(() => {
              if (this.tempColumnHeight >
                (this.columnMaxHeight - CommonConstants.HEIGHT_MIDDLE) / 2 + CommonConstants.HEIGHT_MIDDLE) {
                this.columnHeight = this.columnMaxHeight
                this.isShowBack = false
              } else if (this.tempColumnHeight <
                (CommonConstants.HEIGHT_MIDDLE - CommonConstants.HEIGHT_LOW) / 2 + CommonConstants.HEIGHT_LOW) {
                this.columnHeight = CommonConstants.HEIGHT_LOW
                this.isShowBack = true
              } else {
                this.columnHeight = CommonConstants.HEIGHT_MIDDLE
                this.isShowBack = true
              }
              this.tempColumnHeight = this.columnHeight
            })
        )
      }
      .height(this.tempColumnHeight)
      .width('100%')
      .expandSafeArea((this.tempColumnHeight === this.columnMaxHeight ? [SafeAreaType.KEYBOARD] : []),
        (this.tempColumnHeight === this.columnMaxHeight ? [SafeAreaEdge.BOTTOM] : []))
      .backgroundColor($r('app.color.background_color_white'))
      .visibility(this.isShow ? Visibility.Visible : Visibility.None)
      .borderRadius({
        topLeft: '15vp',
        topRight: '15vp',
        bottomLeft: new BreakpointType('0vp',
          '15vp').getValue(this.currentBreakpoint),
        bottomRight: new BreakpointType('0vp',
          '15vp').getValue(this.currentBreakpoint)
      })
      .gesture(
        PanGesture(this.panOptionPosition)
          .onActionUpdate((event?: GestureEvent) => {
            if (event) {
              let position = this.left + event.offsetX
              this.tempLeft = position
              if (this.tempLeft < CommonConstants.LEFT_MD) {
                this.tempLeft = CommonConstants.LEFT_MD
              }
              if (this.tempLeft > CommonConstants.RIGHT_MD) {
                this.tempLeft = CommonConstants.RIGHT_MD
              }
            }
          })
          .onActionEnd(() => {
            if (this.tempLeft < CommonConstants.CHANGE) {
              this.left = CommonConstants.LEFT_MD
            } else {
              this.left = CommonConstants.RIGHT_MD
            }
            this.tempLeft = this.left
          })
      )
    }
  }
}
