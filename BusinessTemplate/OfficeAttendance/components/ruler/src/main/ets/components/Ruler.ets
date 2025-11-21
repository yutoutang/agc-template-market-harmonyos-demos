import { RulerController } from '../utils/RulerController'

@ComponentV2
export struct Ruler {
  @Require @Param canvasContext:CanvasRenderingContext2D;
  @Require @Param rulerController:RulerController;
  @Event onReady:() => void = () => {}

  build() {
    Canvas(this.canvasContext)
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Transparent)
      .onReady(() => {
        this.onReady();
      })
      .onTouch((event) => {
        const x = event.touches[0].x;
        const y = event.touches[0].y;
        this.rulerController.moveLine(x, y)
      })
  }
}