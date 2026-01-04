import { CanvasController, PointWithTemp } from '../utils/CanvasUtil';

@ComponentV2
export struct CustomCanvas {
  @Require @Param controller: CanvasController;
  @Require @Param list: number[];
  @Param max: number = 44;
  @Param min: number = 22;
  @Param canvasHeight: number = 200;
  @Param index: number = 0;
  @Param itemWidth: number = 48;
  context: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  points: PointWithTemp[] = [];

  @Monitor('list')
  drawAgainWhenListChange() {
    this.points = this.controller.generateTemperaturePoints(
      this.list,
      this.itemWidth,
      this.canvasHeight,
      this.min,
      this.max,
    );
    this.controller.draw(this.context, this.points, this.index);
  }

  @Monitor('index')
  drawAgainWhenIndexChange() {
    this.controller.draw(this.context, this.points, this.index);
  }

  build() {
    Canvas(this.context)
      .width(this.itemWidth * this.list.length)
      .height(this.canvasHeight)
      .onReady(() => {
        this.drawAgainWhenListChange();
      })
  }
}

