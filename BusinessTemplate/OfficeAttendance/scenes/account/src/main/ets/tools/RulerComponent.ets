import { RulerController, Ruler, CrossPointer } from 'ruler'

@Builder
function rulerBuilder() {
  RulerComponent()
}

@ComponentV2
struct RulerComponent {
  private canvasContext:CanvasRenderingContext2D = new CanvasRenderingContext2D();
  crossPointer:CrossPointer = {
    pointerX: 20,
    pointerY: 20,
  }
  private  rulerController:RulerController = new RulerController(
    this.canvasContext,
    {
      crossPointer:this.crossPointer,
      extraScaleLength: 10,
      lineColor:'#000000'
    }
  )

  build() {
    NavDestination() {
      Column() {
        Ruler({
          canvasContext: this.canvasContext,
          rulerController: this.rulerController,
          onReady:() => {
            this.rulerController.setRulerPointers(
              [
                [0, this.crossPointer.pointerY, this.canvasContext.width, this.crossPointer.pointerY],
                [this.crossPointer.pointerX, 0, this.crossPointer.pointerX, this.canvasContext.height]
              ]
            );
            this.rulerController.drawRuler();
          }
        })
      }
      .width('100%')
      .height('100%')

    }.title({ builder: this.titleBuilder(), height: 56 })
    .padding({ top: 36, bottom: 28 }).backgroundColor($r('app.color.about_background'))
  }

  @Builder
  titleBuilder() {
    Row() {
      Text($r('app.string.ruler'))
        .fontWeight(FontWeight.Bold)
        .fontColor('rgba(0,0,0,0.90)')
        .fontSize(24)
        .margin({ left: 16, top: 36 })
        .height(56)
    }
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
    .alignItems(VerticalAlign.Bottom)
  }
}