import { AppStorageV2, PersistenceV2, window } from '@kit.ArkUI'
import { LoginSheetUtils } from 'lib_account'
import { BreakpointModel, BreakpointNameEnum, RouterMap, RouterUtils, UserInfoModel } from 'lib_common'

@ComponentV2
export struct FloatingPublishBtn {
  @Local positionX: number = 0
  @Local positionY: number = 0
  @Local startX: number = 0
  @Local startY: number = 0
  @Local startLeft: number = 0
  @Local startTop: number = 0
  @Local statusHeight: number = 0
  @Local bottomAvoidAreaHeight: number = 0
  @Local winWidth: number = 0
  @Local winHeight: number = 0
  @Local imageSize: number = 48
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;

  @Monitor('breakpointModel.currentBreakpoint')
  getNewWindowInfo() {
    this.getWindowInfo()
  }

  aboutToAppear() {
    this.getWindowInfo()
  }

  getWindowInfo() {
    // 根据断点决定按钮大小
    if (this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM) {
      this.imageSize = 48
    } else {
      this.imageSize = 68
    }
    window.getLastWindow(getContext(this), (err, windowClass) => {
      if (!err.code) {
        this.statusHeight = px2vp(windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height)
        this.bottomAvoidAreaHeight =
          px2vp(windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
            .bottomRect
            .height)
        let windowProperties = windowClass.getWindowProperties()
        this.winWidth = px2vp(windowProperties.windowRect.width)
        this.winHeight = px2vp(windowProperties.windowRect.height)
        this.positionX = this.winWidth - this.imageSize - this.breakpointModel.pagePadding
        this.positionY = this.winHeight * 0.8
      }
    })
  }

  build() {
    Column() {
      Image($r('app.media.publish_news'))
        .width(this.imageSize)
        .height(this.imageSize)
    }
    .position({ x: this.positionX, y: this.positionY })
    .onClick(() => {
      if (!this.userInfoModel.isLogin) {
        LoginSheetUtils.open()
        return
      }
      RouterUtils.pushPathByName(RouterMap.NEWS_POST)
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.startX = event.touches[0].windowX
        this.startY = event.touches[0].windowY
        this.startLeft = this.positionX
        this.startTop = this.positionY
      }
      //手指拖动
      else if (event.type === TouchType.Move) {
        let touch = event.touches[0]
        let curLeft = this.startLeft + (touch.windowX - this.startX)
        //限制悬浮球不能移除屏幕左边
        curLeft = Math.max(0, curLeft)
        //限制悬浮球不能移除屏幕右边
        this.positionX = Math.min(this.winWidth * this.imageSize, curLeft)
        let curTop = this.startTop + (touch.windowY - this.startY)
        //限制悬浮球不能移除屏幕上边
        curTop = Math.max(0, curTop)
        //限制悬浮球不能移除屏幕下边
        this.positionY =
          Math.min(this.winHeight * this.imageSize - this.bottomAvoidAreaHeight - this.statusHeight, curTop)
      } else if (event.type === TouchType.Up) {
        if (this.positionX < (this.winWidth / 2)) {
          // 小球固定到左边
          this.getUIContext()?.animateTo({
            duration: 200,
            curve: Curve.EaseOut,
          }, () => {
            this.positionX = this.breakpointModel.pagePadding
          })
        } else {
          // 小球固定到右边
          this.getUIContext()?.animateTo({
            duration: 200,
            curve: Curve.EaseOut,
          }, () => {
            this.positionX = this.winWidth - this.imageSize - this.breakpointModel.pagePadding
          })
        }
      }
    })
  }
}