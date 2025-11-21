import { AreaCalculateController, AreaCalculate } from 'area_calculate'

@Builder
export function areaCalculateBuilder() {
  CalculateComponent()
}

@ComponentV2
struct CalculateComponent {
  private canvasContext:CanvasRenderingContext2D = new CanvasRenderingContext2D();
  @Local area: number = 0;
  @Local markLength: number = 0;
  @Local unit: string = 'mm';
  @Local dialogIds:number[] = [];
  // 点击多边形的边回调，后调后需要写入边长markLength;
  borderClick = () => {
    this.getUIContext().getPromptAction().openCustomDialog({
      builder:() => {
        this.setMark();
      }
    }).then((dialogId: number) => {
      this.dialogIds.push(dialogId); // 保存dialogId
    })
  }
  private  areaCalculateController:AreaCalculateController =
    new AreaCalculateController(this.canvasContext, this.borderClick)

  setMarkLength() {
    this.areaCalculateController.markLength = this.markLength;
    this.areaCalculateController.unit = this.unit;
    this.areaCalculateController.setLabels();
  }

  closeDialog() {
    const targetIds = this.dialogIds.pop();
    this.getUIContext().getPromptAction().closeCustomDialog(targetIds)
  }

  @Builder
  setMark() {
    Column({space:12}) {
      Row() {
        Text('长度：')
          .margin({
            right:10
          })
        TextInput()
          .layoutWeight(1)
          .onChange((value) => {
            this.markLength = Number(value);
          })
      }
      .width('100%')
      Row() {
        Text('单位：')
          .margin({
            right:10
          })
        TextInput()
          .layoutWeight(1)
          .onChange((value) => {
            this.unit = value;
          })
      }
      .width('100%')
      Row() {
        Button('取消')
          .width(100)
          .margin({
            right:10
          })
          .onClick(() => {
            this.closeDialog()
          })
        Button('确定')
          .width(100)
          .onClick(() => {
            this.setMarkLength();
            this.closeDialog()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .padding(20)
  }

  @Builder
  titleBuilder() {
    Row() {
      Text($r('app.string.area_measure'))
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

  build() {
    NavDestination() {
      Column() {
        AreaCalculate({
          canvasContext: this.canvasContext,
          areaCalculateUtil: this.areaCalculateController
        })
          .layoutWeight(1)

        Text(`面积：${this.area}`)
        Row() {
          Button('重置')
            .width(100)
            .onClick(() => {
              this.areaCalculateController.reset()
            })

          Button('计算面积')
            .width(100)
            .onClick(() => {
              if (this.markLength === 0 || this.markLength === undefined) {
                this.getUIContext().getPromptAction().showToast({
                  duration: 1500,
                  message: '请单击某一条边并填写该边的真实长度'
                })
              } else {
                this.area = this.areaCalculateController.calculatePolygonArea();
              }
            })
        }
        .justifyContent(FlexAlign.SpaceEvenly)
        .width('100%')
        .height(100)
      }
      .width('100%')
      .height('100%')
    }
    .title({ builder: this.titleBuilder(), height: 56 })
    .padding({ top: 36, bottom: 28 }).backgroundColor($r('app.color.about_background'))
  }
}