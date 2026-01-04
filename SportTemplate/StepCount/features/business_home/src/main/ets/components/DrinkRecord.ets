import { DrinkVM } from '../viewmodels/DrinkVM';

export interface DrinkParam {
  time: string,
  ml: number,
}

// 喝水记录
export class DrinkRecordModel {
  drinkedWater: number = 0; // 需要共享的字符串
  lackWater: number = 0;
  drinkGoal: number = 2000;
  myDrinkCup: number = 2000
  s: number[] = []
}

// 喝水历史记录页面，页面样式复刻DrinkPage
@ComponentV2
export struct DrinkRecord {
  @Param drinkVM: DrinkVM = new DrinkVM()
  @Local store: DrinkRecordModel = new DrinkRecordModel()

  build() {
    Column() {
      // 喝水量进度
      Column() {
        Row() {
          Row({ space: 10 }) {
            Text('喝水量')
              .fontColor('#e6333333')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Start)
          }

          // 日期切换
          Row({ space: 8 }) {
            Stack() {
              Column()
                .width(0)
                .height(0)
                .border({
                  width: {
                    left: 0,
                    right: 6,
                    top: 6,
                    bottom: 6
                  },
                  color: {
                    left: Color.Transparent,
                    right: '#979797',
                    top: Color.Transparent,
                    bottom: Color.Transparent
                  }
                })
              Column()
                .width(16)
                .height(16)
                .onClick(() => {
                  this.drinkVM.changeDate(true)!
                })
            }

            Text(this.drinkVM.currentDateStr)
              .fontSize(12)
              .fontColor('#000000')
            Stack() {
              Column()
                .width(0)
                .height(0)
                .border({
                  width: {
                    left: 6,
                    right: 0,
                    top: 6,
                    bottom: 6
                  },
                  color: {
                    left: '#979797',
                    right: Color.Transparent,
                    top: Color.Transparent,
                    bottom: Color.Transparent
                  }
                })
              Column()
                .width(16)
                .height(16)
                .onClick(() => {
                  this.drinkVM.changeDate(false)!
                })
            }
          }
          .margin({ left: 10 })

          Blank()
          Row({ space: 6 }) {
            Image($r('app.media.water_slice')).size({ width: 21, height: 21 })
            Image($r('app.media.water_plus')).size({ width: 21, height: 21 })
          }
          .visibility(Visibility.Hidden)
        }.width('100%')

        Stack() {
          Slider({
            style: SliderStyle.NONE,
            value: this.drinkVM.percent * this.drinkVM.store.drinkGoal,
            min: 0,
            max: this.drinkVM.store.drinkGoal,
          })
            .enabled(false)
            .trackThickness(8)
            .selectedBorderRadius(6)
            .width('100%')
            .onChange(val => this.drinkVM.percent = val / this.drinkVM.store.drinkGoal)

          // 2. 自己画的“滑块”
          Column() {
            Image($r('app.media.slider_block')).width(16)
            Row({ space: 1 }) {
              Text(this.drinkVM.store.drinkedWater?.toString() ?? '0')
                .fontColor('#333')
                .fontSize(12)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .textAlign(TextAlign.End)
              Text('ml').fontColor('#333').fontSize(10)
            }
            .offset({
              x: this.drinkVM.store.drinkedWater?.toString().length > 3 ?
                -this.drinkVM.store.drinkedWater?.toString().length * 6 : 0
            })
          }
          .layoutWeight(1)
          .borderRadius(16)
          .backgroundColor(Color.White)
          .offset({
            // 3. 跟随滑动
            // x: (this.drinkVM.sliderWidth - 32) * this.drinkVM.percent - 125,
            x: (() => {
              const p = Math.min(Math.max(this.drinkVM.percent, 0), 1);
              if (p <= 0) {
                return -this.drinkVM.sliderWidth / 2 + 5;
              }
              if (p >= 1) {
                return this.drinkVM.sliderWidth / 2 - 5;
              }
              return p * (this.drinkVM.sliderWidth - 32) - (this.drinkVM.sliderWidth / 2 - 16);
            })(),
            y: 20
          })
          .hitTestBehavior(HitTestMode.Transparent) // 4. 手势透传
        }.height(80)
        .onAreaChange((_, rect) => this.drinkVM.sliderWidth = Number(rect.width))

        Divider().strokeWidth('1px').color($r('sys.color.comp_background_tertiary'))
        Row() {
          Column({ space: 6 }) {
            Row({ space: 3 }) {
              Row() {
              }.backgroundColor('#3E78F7').width(3).height(11).borderRadius(1.5)

              Text('我的水杯').fontSize(12).lineHeight(16).fontColor('#999999')
              Image($r('app.media.edit_water')).size({ width: 11, height: 11 })
                .visibility(Visibility.Hidden)
            }

            Row({ space: 3 }) {
              Text(this.drinkVM.store.myDrinkCup?.toString())
                .fontSize(20)
                .fontColor('#333333')
                .fontWeight(FontWeight.Bold)
              Text('ml').fontSize(11).fontColor('#999999')
            }
          }

          Text(`还差${this.drinkVM.store.lackWater}ml`).fontColor('#999999').fontSize(12)
            .visibility(this.drinkVM.store.lackWater > 0 ? Visibility.Visible : Visibility.Hidden)
          Column({ space: 6 }) {
            Row({ space: 3 }) {
              Row() {
              }.backgroundColor('#0DBA72').width(3).height(11).borderRadius(1.5)

              Text('我的目标').fontSize(12).lineHeight(16).fontColor('#999999')
              Image($r('app.media.edit_water')).size({ width: 11, height: 11 })
                .visibility(Visibility.Hidden)
            }

            Row({ space: 3 }) {
              Text(this.drinkVM.store.drinkGoal?.toString())
                .fontSize(20)
                .fontColor('#333333')
                .fontWeight(FontWeight.Bold)
              Text('ml').fontSize(11).fontColor('#999999')
            }
          }
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ top: 19 })
      }
      .width('100%')
      .height(188)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding({
        top: 17,
        left: 20,
        right: 17,
        bottom: 19
      })

      // 喝水记录列表
      Text('喝水记录')
        .fontWeight(700)
        .lineHeight(22)
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ top: 16 })

      Column({ space: 10 }) {
        ForEach(this.drinkVM.drinkData, (item: DrinkParam) => {
          Row({ space: 16 }) {
            Image($r('app.media.water')).width(40).height(40)
            Column() {
              Text('水').fontColor('#333333').fontSize(16).fontWeight(FontWeight.Bold).width('100%')
              Row({ space: 4 }) {
                Image($r('app.media.ring')).size({ width: 8, height: 8 })
                Text(item.time).fontColor('#80000000').fontSize(10).fontWeight(FontWeight.Bold).lineHeight(11)
              }.width('100%')
            }.width(80).margin({ left: 12 })

            // Blank()
            Text(item.ml + 'ml')
              .fontColor('#333333')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.End)
              .layoutWeight(1)
          }.justifyContent(FlexAlign.SpaceBetween)
          .borderRadius(12)
          .border({ width: 1, color: '#E0E3EE' })
          .padding({
            right: 13,
            top: 12,
            bottom: 10,
            left: 13
          })
        }, (item: DrinkParam) => JSON.stringify(item))
      }
      .padding({ top: 18, bottom: 18 })
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)

      // 底部时间轴
      Column({ space: 8 }) {
        Row() {
          ForEach(this.drinkVM.drinkTimeData, (item: DrinkParam) => {
            Slider({
              value: item.ml,
              style: SliderStyle.NONE,
              direction: Axis.Vertical,
              reverse: true,
              max: this.drinkVM.store.drinkGoal// 竖向的Slider默认是上端是min值，下端是max值，因此想要从下往上滑动，需要设置reverse为true
            })
              .enabled(false)
              .selectedColor('#34A2F8')
              .width('4.3%')
              .trackThickness('8')// 滑轨粗细，单位 vp
              .selectedBorderRadius(4)
          }, (item: DrinkParam) => {
            return JSON.stringify(item)
          })
        }.justifyContent(FlexAlign.SpaceBetween).height(115)

        Row() {
          Text('00:00').fontColor('#809FB8').fontSize(12)
          Text('12:00').fontColor('#809FB8').fontSize(12)
          Text('24:00').fontColor('#809FB8').fontSize(12)
        }.justifyContent(FlexAlign.SpaceBetween).width('100%')
      }
      .width('100%')
      .height(162)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding({
        left: 14,
        right: 17,
        top: 14,
        bottom: 13
      })
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }
}