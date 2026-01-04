import { UIBase } from '../common/UIBase';
import { AvoidAreaInfo } from '../common/AvoidAreaInfo';
import { AvoidAreaCallback, PaddingType } from '../common/Model';

@ComponentV2
export struct LayoutFull {
  // 当前窗口是否为沉浸式
  @Param isLayoutFullScreen: boolean = true;
  // 需要计算避让区域的情况
  @Param needCalcPadding: boolean = false;
  // 自定义窗口背景颜色
  @Param customBgColor: ResourceColor = $r('sys.color.ohos_id_color_background');
  @Local paddingTop: number = 0;
  @Local paddingBottom: number = 0;
  @BuilderParam buildContent: () => void;

  needOnAvoidAreaChange() {
    return this.isLayoutFullScreen || this.needCalcPadding;
  }

  avoidAreaChangeWatch = (data: AvoidAreaCallback) => {
    const resp = AvoidAreaInfo.handle(data);
    this.handlePadding(resp);
  };

  handlePadding(data: PaddingType | undefined) {
    if (!data) {
      return;
    }
    // 窗口设置全屏，需要额外避让状态栏、底部导航条等
    if (this.isLayoutFullScreen) {
      this.paddingTop = data.top;
      this.paddingBottom = data.bottom;
    } else {
      // 窗口未设置全屏，不需要额外避让状态栏等
      this.paddingTop = 0;
      this.paddingBottom = 0;
    }
  }

  aboutToAppear(): void {
    if (this.needOnAvoidAreaChange()) {
      // 首次进来不会执行on('avoidAreaChange', callback)监听，需要主动获取避让区域
      const data = AvoidAreaInfo.getAvoidAreaOnce();
      this.handlePadding(data);
      UIBase.onAvoidAreaChange(this.avoidAreaChangeWatch);
    }
  }

  aboutToDisappear(): void {
    if (this.needOnAvoidAreaChange()) {
      UIBase.offAvoidAreaChange(this.avoidAreaChangeWatch);
    }
  }

  build() {
    Column() {
      if (this.buildContent) {
        this.buildContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.customBgColor)
    .padding({
      top: this.paddingTop,
      bottom: this.paddingBottom,
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}