import { AreaCalculateController } from '../utils/AreaCalculateController'

@ComponentV2
export struct AreaCalculate {
  @Require @Param canvasContext:CanvasRenderingContext2D;
  @Require @Param areaCalculateUtil:AreaCalculateController;

  build() {
    Canvas(this.canvasContext)
      .width('100%')
      .height('100%')
      .onClick((event) => {
        const x = event.x;
        const y = event.y;
        this.areaCalculateUtil.draw(x,y)
      })
  }
}