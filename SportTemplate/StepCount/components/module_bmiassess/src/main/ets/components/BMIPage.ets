import { BMINavBar } from './BMINavBar';
import { BmiStore, UserInfo } from '../viewmodels/EditPersonVM';
import { PersistenceV2 } from '@kit.ArkUI';
import { bmiToPercent } from '../models/Utils';
import { BmiRouterMap } from '../constants/BmiRouterMap';

@ComponentV2
export struct BMIPage {
  @Param navBarFontSize?: number = 16;
  @Param navBarLineHeight?: number = 22;
  @Param navBarColor: string = '#4F412E';
  @Param sliderSelectedColor: string = '#8667FC'
  @BuilderParam rightPartBuilder?: () => void;
  @BuilderParam bgImageBuilder?: () => void
  @Local bmiInfo: BmiStore = PersistenceV2.connect(BmiStore, 'bmi', () => new BmiStore())!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, 'userInfo', () => new UserInfo())!;
  @Param isLogin: boolean = false
  @Param stack:NavPathStack = new NavPathStack()
  @Event onNeedLogin?: () => void

  build() {
    Stack() {
      if (this.bgImageBuilder) {
        this.bgImageBuilder()
      } else {
        Column() {
          Blank()
          Image($r('app.media.bmi'))
            .size({ width: '100%'})
            .objectFit(ImageFit.Fill)
            .align(Alignment.Bottom) // 底部对齐
        }
        .width('100%')
        .height('100%')
        .borderRadius(12)
        .padding({left: 7, right: 7})
        .backgroundColor(Color.Transparent)
      }
      Column() {
        Stack({ alignContent: Alignment.BottomEnd }) {
          BMINavBar({
            title: 'BMI',
            typeface: this.navBarFontSize,
            fontLineHeight: this.navBarLineHeight,
            fonthue: this.navBarColor,
            paddingLeft: 0,
            paddingRight: 0,
          }).position({ top: 0 })
          if (this.rightPartBuilder) {
            this.rightPartBuilder()
          } else {
            Image($r('app.media.bmi_more')).size({ width: 35, height: 35 })
          }
        }

        Column() {
          Text('今日').textAlign(TextAlign.Start).fontColor('#555').fontSize(12).lineHeight(17)
          Row({ space: 5 }) {
            Text(this.isLogin && Number(this.userInfo.weight) > 0 ? this.userInfo.weight : '--')
              .fontColor('#333')
              .fontSize(32)
              .lineHeight(38)
              .fontWeight(500)
            Text('kg').fontColor('#888').fontSize(12).lineHeight(38)
          }.alignItems(VerticalAlign.Bottom)
        }.width('100%').alignItems(HorizontalAlign.Start)

        Column() {
          Row() {
            Text(this.isLogin && this.bmiInfo.bmiValue > 0 ? `当前BMI: ${this.bmiInfo.bmiValue}` : '当前BMI: --')
              .textAlign(TextAlign.Start)
              .fontColor('#8667FC')
              .fontSize(10)
              .lineHeight(14)
            Blank()
            Text(this.isLogin ? this.bmiInfo.physicalState : '')
              .textAlign(TextAlign.Start)
              .fontColor('#8667FC')
              .fontSize(10)
              .lineHeight(14)
          }
          .width('100%')
          .margin({ left: -1 })

          Slider({
            value: this.isLogin ? bmiToPercent(this.bmiInfo.bmiValue) : 0,
            min: 0,
            max: 100,
          })
            .enabled(false)
            .blockSize({ width: '5vp', height: '5vp' })
            .trackThickness('4vp')
            .width('107%')
            .selectedColor($r('sys.color.comp_background_emphasize')) //设置滑轨的已滑动部分颜色
            .trackColor($r('sys.color.comp_background_secondary'))
            .margin({ left: -4 })
            .offset({ y: -9 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .borderRadius({
          topLeft: 0,
          topRight: 0,
          bottomLeft: 12,
          bottomRight: 12
        })
        .padding({
          bottom: 7
        })
      }
      .padding({ left: 13, right: 13, top: 12 })
      .width('100%')
      .height('100%')
      .borderRadius(12)
      .backgroundColor(Color.Transparent)
      .onClick(()=>{
        if (this.isLogin) {
          // 已登录，直接跳转到编辑页面
          this.stack.pushPath({
            name: BmiRouterMap.EDIT_USER_INFO, param: ''
          })
        } else {
          // 未登录，触发事件让外部处理跳转到登录页面
          if (this.onNeedLogin) {
            this.onNeedLogin()
          }
        }
      })
    }
    .borderRadius(12)
    .backgroundColor(Color.White)
  }
}
