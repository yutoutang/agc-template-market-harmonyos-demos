import dayJs from 'dayjs';
import { MyConfig } from 'commons';

@Extend(Text)
function timeExtend(color: ResourceColor, fontWeight: number) {
  .fontColor(color)
  .fontWeight(fontWeight)
  .fontSize(24)
  .width(36)
  .height(36)
  .textAlign(TextAlign.Center)
}

@Extend(Text)
function dateExtend() {
  .fontColor('#999')
  .fontSize(10)
  .width(14)
  .textAlign(TextAlign.Center)
  .margin({ top: 8 })
}


@Component
export default struct Countdown {
  @State days: number = 0;
  @State hours: string = '';
  @State minutes: string = '';
  @State seconds: string = '';
  private intervalId: number | undefined = undefined;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'

  aboutToAppear() {
    this.startCountdown();
  }

  onDisappear() {
    this.stopCountdown();
  }

  mySetInterval() {
    const targetDate = dayJs('2025-09-26'); // 设置目标日期
    const now = dayJs();
    const diff = targetDate.diff(now);

    if (diff <= 0) {
      clearInterval(this.intervalId!);
      this.intervalId = undefined;
      this.days = 0;
      this.hours = '0'
      this.minutes = '0'
      this.seconds = '0'
      return;
    }
    this.days = Math.floor(diff / (24 * 60 * 60 * 1000));
    let hours = Math.floor((diff % (24 * 60 * 60 * 1000)) / (60 * 60 * 1000));
    let minutes = Math.floor((diff % (60 * 60 * 1000)) / (60 * 1000));
    let seconds = Math.floor((diff % (60 * 1000)) / 1000);
    this.hours = hours < 10 ? `0${hours}` : `${hours}`;
    this.minutes = minutes < 10 ? `0${minutes}` : `${minutes}`;
    this.seconds = seconds < 10 ? `0${seconds}` : `${seconds}`;
  }

  startCountdown() {
    this.mySetInterval()
    this.intervalId = setInterval(() => {
      this.mySetInterval()
    }, 1000);
  }

  stopCountdown() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = undefined;
    }
  }

  build() {
    Row() {
      Column() {
        Row() {
          Column() {
            Text('距离大会').fontColor('#99000000').fontSize(10).lineHeight(14)
            Text('开始还有').fontColor('#99000000').fontSize(10).lineHeight(14)
          }.margin({ right: 18 })

          Row() {
            Stack() {
              Text(this.days.toString()).timeExtend('#F2403D', 700)
            }
            .width(40)
            .height(40)
            .backgroundImageSize(ImageSize.Contain)

            Text('天').dateExtend()
            Stack() {
              Text(this.hours).timeExtend('#000', 500)
            }
            .width(40)
            .height(40)
            .backgroundImageSize(ImageSize.Contain)

            Text('时').dateExtend()
            Stack() {
              Text(this.minutes).timeExtend('#000', 500)
            }
            .width(40)
            .height(40)
            .backgroundImageSize(ImageSize.Contain)

            Text('分').dateExtend()
            Stack() {
              Text(this.seconds).timeExtend('#000', 500)
            }
            .width(40)
            .height(40)
            .backgroundImageSize(ImageSize.Contain)

            Text('秒').dateExtend()
          }
        }.margin({ top: this.currentBreakpoint === 'sm' ? '102lpx' : 51 })
      }
      .width('94%')
      .height(this.currentBreakpoint === 'sm' ? '238lpx' : 119)
      .backgroundImage(`${MyConfig.URL}%E9%A6%96%E9%A1%B5%2Fbg_countdown.png?token=2d949a78-5c72-432b-b018-64842d96ba57`)
      .backgroundImageSize(ImageSize.FILL)
      .alignItems(HorizontalAlign.Center)
      .margin({
        bottom: -18
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({
      top: 48
    })
  }
}