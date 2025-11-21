import { Protractor, ProtractorController } from 'protractor'

@Builder
export function protractorBuilder() {
  ProtractorComponent();
}

@ComponentV2
struct ProtractorComponent {
  @Local angle:number = 0;
  @Local radius: number = 180;
  @Local startAngle: number = 180;
  @Local endAngle: number = 360;
  @Local startValue: number = 0;
  @Local endValue: number = 180;
  @Local protractorController: ProtractorController = new ProtractorController({
    radius: this.radius,
    startAngle: this.startAngle,
    endAngle: this.endAngle,
    startValue: this.startValue,
    endValue: this.endValue,
    step: 10,
  });

  build() {
    NavDestination() {
      Column() {
        Protractor({
          protractorController: this.protractorController,
          angleChange:(angle) => {
            this.angle = angle;
          }
        })
          .layoutWeight(1)

        Column({space:16}) {
          Row() {
            Text('半径:')
            TextInput()
              .layoutWeight(1)
              .onChange((value) => {
                  this.radius = Number(value);
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)

          Row() {
            Text('起始角度:')
            TextInput()
              .layoutWeight(1)
              .onChange((value) => {
                this.startAngle = Number(value);
              })
            Blank()
            Text('终止角度:')
            TextInput()
              .layoutWeight(1)
              .onChange((value) => {
                this.endAngle = Number(value);
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)

          Row() {
            Text('起始刻度:')
            TextInput()
              .layoutWeight(1)
              .onChange((value) => {
                this.startValue = Number(value);
              })
            Blank()
            Text('终止刻度:')
            TextInput()
              .layoutWeight(1)
              .onChange((value) => {
                this.endValue = Number(value);
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)


          Button('更新')
            .onClick(() => {
              this.protractorController.updateParam({
                radius: this.radius,
                startAngle: this.startAngle,
                endAngle: this.endAngle,
                startValue: this.startValue,
                endValue: this.endValue,
              })
              this.protractorController.drawProtractor();
            })
        }
        .padding(16)
        Text(`测量值${String(this.angle)}`)
          .height(60)
      }.width('100%').height('100%')
    }.title({ builder: this.titleBuilder(), height: 56 })
    .padding({ top: 36, bottom: 28 }).backgroundColor($r('app.color.about_background'))
  }

  @Builder
  titleBuilder() {
    Row() {
      Text($r('app.string.protractor'))
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