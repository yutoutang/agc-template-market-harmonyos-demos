import { AppStorageV2, CircleShape } from '@kit.ArkUI';
import { BreakpointModel, BreakpointNameEnum, CommonConstants, Record } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { mineGridList } from '../constants/Constants';
import { MineGridItem } from '../types/Types';
import { MineViewModel } from '../viewmodels/MineVM';
import { emitter } from '@kit.BasicServicesKit';
import  EventData  from '@ohos.events.emitter';

@Builder
export function MinePageBuilder() {
  MinePage()
}

interface GridSettingInfo {
  template: string;
  colGap: number;
  rowGap: number;
}

@ComponentV2
struct MinePage {
  @Local vm: MineViewModel = new MineViewModel();
  @Local todayRecord: Record = { duration: 0, energy: 0 }
  @Local totalRecord: Record = { duration: 0, energy: 0 }
  @Local totalDays: number = 0
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear() {
    try {
      emitter.on('todayRecord', (data: EventData.EventData) => {
        if(data.data){
          let todayRecord: Record = data.data.todayRecord
          this.todayRecord = todayRecord
        }
      })
    } catch (e) {
      console.error(`emitter on failed. error: ${JSON.stringify(e)}`)
    }
    this.calculateYearToDateSum()
  }

  aboutToDisappear(): void {
    try {
      emitter.off('todayRecord')
    } catch (e) {
      console.error(`emitter off failed. error: ${JSON.stringify(e)}`)
    }
  }

  private getDateRangeFromStartOfYear(): string[] {
    const dates: string[] = [];
    const now = new Date();
    const startOfYear = new Date(now.getFullYear(), 0, 1); // 今年1月1日
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate()); // 今天，去除时分秒

    let currentDate = new Date(startOfYear);
    while (currentDate < today) {
      const year = currentDate.getFullYear();
      const month = String(currentDate.getMonth() + 1).padStart(2, '0'); // 月份从0开始，需+1
      const day = String(currentDate.getDate()).padStart(2, '0');
      dates.push(`${year}-${month}-${day}`);
      currentDate.setDate(currentDate.getDate() + 1); // 增加一天
    }
    return dates;
  }

  private calculateYearToDateSum() {
    const dateKeys = this.getDateRangeFromStartOfYear();
    dateKeys.forEach(dateKey => {
      // 从 AppStorage 获取数据，若不存在则使用默认值 0
      const dailyData: Record | undefined = AppStorage.get<Record>(dateKey);
      if (dailyData !== undefined) {
        this.totalDays++
        this.totalRecord.duration += dailyData.duration;
        this.totalRecord.energy += dailyData.energy;
      }
      // 如果 AppStorage 中不存在该日期键，或值非数字，则不计入（相当于加0）
    });
  }

  @Computed
  get gridSetting() {
    const gridSettingInfo: GridSettingInfo  = {
      template: '1fr',
      colGap: 12,
      rowGap: 12,
    }
    if (BreakpointNameEnum.MD === this.breakPointModel.currentBreakpoint) {
      gridSettingInfo.template = '1fr 1fr'
      gridSettingInfo.colGap = 24
    }
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes((this.breakPointModel.currentBreakpoint))) {
      gridSettingInfo.template = '1fr 1fr'
      gridSettingInfo.colGap = 16
    }
    return gridSettingInfo
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '我的',
          isSubTitle: false,
        })

        Scroll() {
          Column({ space: CommonConstants.SPACE_M }) {
            this.loginCard()
            this.gridCard()
            Grid() {
              GridItem() {
                this.todayCard()
              }
              GridItem() {
                this.recordCard()
              }
            }
            .columnsTemplate(this.gridSetting.template)
            .columnsGap(this.gridSetting.colGap)
            .rowsGap(this.gridSetting.rowGap)
          }
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .padding({
          left: this.vm.breakPointModel.pagePadding,
          right: this.vm.breakPointModel.pagePadding,
          top: CommonConstants.SPACE_M,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding({
        bottom: this.vm.pagePaddingBottom,
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  loginCard() {
    Column() {
      if (this.vm.userInfoModel.isLogin) {
        Row({ space: CommonConstants.SPACE_L }) {
          Image(this.vm.userIcon)
            .width($r('app.float.user_icon_width'))
            .clipShape(new CircleShape({ width: 48, height: 48 }))
            .draggable(false)
          Text(this.vm.userInfoModel.authorNickName)
            .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          if (this.vm.userInfoModel.isVIP) {
            Row() {
              Image($r('app.media.icon_vip'))
                .width(20)
                .draggable(false)
                .margin({ left: 8, right: 8, top: 4 })
              Text('VIP会员')
                .width(43)
                .height(16)
                .margin({ top: 6 })
                .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                .fontColor($r('app.color.VIP'))
                .fontWeight(FontWeight.Medium)
            }
            .backgroundColor($r('app.color.VIP_back'))
            .width(96)
            .height(28)
            .borderRadius(8)
          }
        }
      } else {
        Row({ space: CommonConstants.SPACE_L }) {
          Image($r('app.media.ic_user_unlogin'))
            .width($r('app.float.user_icon_width'))
            .draggable(false)
          Text('去登录')
            .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        }
        .stateStyles({
          normal: this.normalStyles,
          pressed: this.pressedStyles,
        })
        .onClick(() => {
          this.vm.jumpLogin();
        })
      }

      Row({ space: CommonConstants.SPACE_L }) {
        Image($r('app.media.ic_mine_vip'))
          .width(32)
          .height(32)
          .draggable(false)
          .margin({ right: 8 })

        Column() {
          Text('运动健身会员')
            .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('app.color.VIP'))
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 2 })
          Text('开通会员畅快训练')
            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('app.color.VIP'))
            .fontWeight(FontWeight.Medium)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        if (this.vm.userInfoModel.isLogin) {
          Text('会员中心')
            .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .borderRadius(14)
            .width(72)
            .height(28)
            .backgroundColor('#E3922F')
            .textAlign(TextAlign.Center)
        } else {
          Text('开通会员')
            .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .borderRadius(14)
            .width(72)
            .height(28)
            .backgroundColor('#E3922F')
            .textAlign(TextAlign.Center)
        }
      }
      .backgroundImage(this.vm.gridCount === 2 ? $r('app.media.background_vip') :
        (this.vm.gridCount === 4 ? $r('app.media.background_vip_middle') : $r('app.media.background_vip_large')))
      .backgroundImageSize(ImageSize.FILL)
      .borderRadius(12)
      .padding(12)
      .width('100%')
      .height(64)
      .margin({ top: 12 })
      .onClick(() => {
        this.vm.jumpVIP();
      })
    }
    .backgroundColor(Color.White)
    .width('100%')
    .padding(CommonConstants.PADDING_M)
    .borderRadius(12)
  }

  @Builder
  gridCard() {
    Column() {
      Grid() {
        ForEach(mineGridList, (v: MineGridItem) => {
          GridItem() {
            Column() {
              Image(v.icon)
                .width($r('app.float.grid_icon_width'))
                .draggable(false)
              Text(v.label)
                .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                .fontColor($r('sys.color.font_primary'))
            }
            .height(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .borderRadius($r('app.float.large_radius'))
          .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles,
          })
          .padding({
            top: CommonConstants.PADDING_S,
            bottom: CommonConstants.PADDING_S,
            left: CommonConstants.PADDING_XS,
            right: CommonConstants.PADDING_XS,
          })
          .onClick(() => {
            this.vm.gridClick(v);
          })
        }, (v: MineGridItem) => v.label as string)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(76)
      .columnsTemplate('1fr 1fr 1fr 1fr')
    }
    .padding({
      top: CommonConstants.PADDING_XS,
      bottom: CommonConstants.PADDING_XS,
      left: CommonConstants.PADDING_XS,
      right: CommonConstants.PADDING_XS,
    })
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius($r('app.float.large_radius'))
  }

  @Builder
  todayCard() {
    Column() {
      Row() {
        Image($r('app.media.ic_today'))
          .width(16)
          .margin({ right: 8 })
          .draggable(false)
        Text('今日运动')
          .width(64)
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Blank()
      }
      .width('100%')
      .height(24)
      .margin({ bottom: 12 })
      .justifyContent(FlexAlign.Start)

      Row() {
        Column() {
          Row() {
            Text(String(this.todayRecord.duration))
              .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
            Text('(分钟)')
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Medium)
          }
          .margin({ bottom: 8 })

          Text('运动时长')
            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)

        Column() {
          Row() {
            Text(String(this.todayRecord.energy))
              .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
            Text('(kcal)')
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Medium)
          }
          .margin({ bottom: 8 })

          Text('消耗热量')
            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding(12)
    .width('100%')
  }

  @Builder
  recordCard() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.ic_record'))
            .width(16)
            .margin({ right: 8 })
            .draggable(false)
          Text('运动记录')
            .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
          Blank()
        }
        .justifyContent(FlexAlign.Start)
        Blank()
        Image($r('app.media.ic_right'))
          .width($r('app.float.arrow_right_w'))
          .draggable(false)
          .onClick(() => {
            this.vm.jumpRecord();
          })
      }
      .margin({ bottom: 12 })
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height(24)

      Row() {
        Column() {
          Row() {
            Text(String(this.totalRecord.duration + this.todayRecord.duration))
              .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
            Text('(分钟)')
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Medium)
          }
          .margin({ bottom: 8 })

          Text('总时长')
            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)

        Column() {
          Row() {
            Text(String(this.totalRecord.energy + this.todayRecord.energy))
              .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
            Text('(kcal)')
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Medium)
          }
          .margin({ bottom: 8 })

          Text('总消耗')
            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)

        Column() {
          Row() {
            Text(this.todayRecord.duration !== 0 ? String(this.totalDays + 1) : String(this.totalDays))
              .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
            Text('(天)')
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Medium)
          }
          .margin({ bottom: 8 })

          Text('累计训练')
            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
      }
    }
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding(12)
    .width('100%')
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.interactive_pressed'))
  }
}