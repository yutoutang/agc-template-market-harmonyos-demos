import { curves } from '@kit.ArkUI';
import { ClockInComponent } from './components/ClockInComponent';
import { ClockInHistory } from './components/ClockInHistory'
import { DataManager } from './controller/DataManagerController';
import { AddressParam } from './util/LocationUtil';

@Entry
@ComponentV2
export struct ClockInView {
  @Local checkinFirstTime: string = '';
  @Local checkinLastTime: string = '';
  @Local imageOpacity: number = 1;
  @Local showHistory:boolean = false;
  @Require @Param latitude: number;
  @Require @Param longitude: number;
  @Require @Param distance: number;
  @Param onSuccess: (address:AddressParam) => void = () => {
  };
  @Param onFailed: () => void = () => {
  };

  aboutToAppear() {
    this.refreshCheckDetail();  }

  private refreshCheckDetail() {
    const value = DataManager.getTodayCheckInDetail();
    this.checkinFirstTime = value[0].time;
    this.checkinLastTime = value[value.length - 1].time;
  }

  aboutToDisappear(): void {
  }

  @Builder
  clockHistory() {
    ClockInHistory()
  }

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
      ClockInComponent({
        latitude:this.latitude,
        longitude:this.longitude,
        distance: this.distance,
        onSuccess: (address:AddressParam) => {
          this.onSuccess(address)
          this.refreshCheckDetail()
        },
        onFailed:() => {
          this.onFailed();
        }
      }).flexGrow(1)

      Column() {
        Image($r('app.media.double_arrow_up'))
          .height(16)
          .width(80)
          .opacity(this.imageOpacity)
          .animation({ duration: 800, curve: curves.springMotion() })
          .margin({ top: 4 })
          .onClick(() => {
            this.showHistory = true;
          })
        Row() {
          Column() {
            Text($r('app.string.checkin_first_time')).fontSize(14).fontColor($r('app.string.white_60')).height(20)
            Text(this.checkinFirstTime).fontSize(18).fontColor(Color.White).height(24)
          }.alignItems(HorizontalAlign.Start)

          Column() {
            Text($r('app.string.checkin_last_time')).fontSize(14).fontColor($r('app.string.white_60')).height(20)
            Text(this.checkinLastTime).fontSize(18).fontColor(Color.White).height(24)
          }.alignItems(HorizontalAlign.Start)
        }
        .margin({ top: 24 })
        .justifyContent(FlexAlign.SpaceAround)
        .width('100%')
      }
      .flexShrink(0)
      .height(113)
      .width('100%')
      .borderRadius({ topLeft: 36, topRight: 36 })
      .backgroundColor($r('app.color.checkin_background'))
      .align(Alignment.Top)
      .bindSheet(this.showHistory, this.clockHistory, {
        detents: [SheetSize.MEDIUM, SheetSize.LARGE, 200],
        backgroundColor: $r('app.string.white_90'),
        blurStyle: BlurStyle.Thick,
        title:{title:'打卡记录'},
        onDisappear: () => {
          this.showHistory = !this.showHistory;
        }
      })
      .gesture(
        PanGesture({ direction: PanDirection.Up }).onActionEnd(() => {
          this.showHistory = true;
        })
      )
    }.height('100%')
  }
}