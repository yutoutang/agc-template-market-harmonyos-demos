import { CommonConstants, Logger } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingAutoSportRecordVM } from '../viewmodels/SettingAutoSportRecordVM';

const TAG = '[SettingPersonal]';

@Builder
export function SettingAutoSportRecordBuilder() {
  SettingAutoSportRecord()
}

@ComponentV2
struct SettingAutoSportRecord {
  @Local vm: SettingAutoSportRecordVM = new SettingAutoSportRecordVM();
  private selectIndex: number = this.vm.settingInfo.autoSportsRecordSelectIndex
  private selectValue: string = this.vm.settingInfo.autoSportsRecordMinValue

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '自动生成运动记录',
        })
        Scroll() {
          Column({ space: CommonConstants.SPACE_M }) {
            List() {
              ListItem() {
                Row({ space: CommonConstants.SPACE_M }) {
                  Column() {
                    Text('自动生成运动记录')
                      .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
                      .fontColor($r('sys.color.font_primary'))
                      .fontWeight(FontWeight.Medium)
                      .textAlign(TextAlign.Start)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  Toggle({ type: ToggleType.Switch, isOn: this.vm.settingInfo.autoSportsRecordSwitch })
                    .hitTestBehavior(HitTestMode.Block)
                    // .selectedColor($r('sys.color.comp_background_emphasize'))
                    .onChange((isOn: boolean) => {
                      this.vm.settingInfo.autoSportsRecordSwitch = isOn;
                    })
                }
                .padding({
                  top: CommonConstants.PADDING_M,
                  bottom: CommonConstants.PADDING_M,
                  left: CommonConstants.PADDING_S,
                  right: CommonConstants.PADDING_S,
                })
                .borderRadius($r('app.float.large_radius'))
                .stateStyles({
                  normal: this.normalStyles,
                  pressed: this.pressedStyles,
                })

              }

              this.sportRecordMinValueBuilder()
            }
            .width(CommonConstants.FULL_PERCENT)
            .borderRadius($r('app.float.large_radius'))
            .padding(CommonConstants.PADDING_XS)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
            .backgroundColor($r('sys.color.comp_background_primary'))
            .divider({
              strokeWidth: 0.5,
              color: $r('sys.color.comp_divider'),
              startMargin: CommonConstants.PADDING_M,
              endMargin: CommonConstants.PADDING_M,
            })

          }
          .alignItems(HorizontalAlign.Start)
          .padding({
            left: CommonConstants.PADDING_PAGE,
            right: CommonConstants.PADDING_PAGE,
            top: CommonConstants.PADDING_M,
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  sportRecordMinValueBuilder() {
    Row() {
      Row() {
        Text('设置最短生成运动记录')
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Row({ space: CommonConstants.SPACE_XS }) {
          Text(this.vm.settingInfo.autoSportsRecordMinValue)
            .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_secondary'))
            .constraintSize({ maxWidth: '80%' })
          Image($r('app.media.ic_right'))
            .width($r('app.float.arrow_right_w'))
            .draggable(false)
        }
      }
      .innerCard()
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
    }
    .outerCard()
    .onClick(() => {
      if (this.vm.settingInfo.autoSportsRecordSwitch) {
        this.vm.showSportRecordSheet = true;
      }
    })
    .bindSheet($$this.vm.showSportRecordSheet, this.sportRecordMinValueSheetBuilder(), {
      detents: [SheetSize.FIT_CONTENT],
      blurStyle: BlurStyle.Regular,
      showClose: true,
      preferType: SheetType.CENTER,
      title: { title: '运动选择' },
    })
  }

  @Builder
  sportRecordMinValueSheetBuilder() {
    Column() {
      TextPicker({
        range: this.vm.item,
        selected: this.vm.settingInfo.autoSportsRecordSelectIndex,
      })
        .divider(null)
        .selectedTextStyle({ color: Color.Black })
        .onChange((value: string | string[], index: number | number[]) => {
          this.selectIndex = index as number;
          this.selectValue = value as string;
          Logger.info(TAG, 'Picker item changed, value: ' + value + ', index: ' + index);
        })
        .onScrollStop((value: string | string[], index: number | number[]) => {
          Logger.info(TAG, 'Picker scroll stopped, value: ' + value + ', index: ' + index);
        })
        .margin({ bottom: 50 })
        .canLoop(false)
        .align(Alignment.Center)
        .width('100%')

      Button('保存')
        .type(ButtonType.Capsule)
        .borderRadius($r('app.float.vp_20'))
        .width('100%')
        .height($r('app.float.vp_40'))
        .onClick(() => {
          this.vm.settingInfo.autoSportsRecordSelectIndex = this.selectIndex
          this.vm.settingInfo.autoSportsRecordMinValue = this.selectValue
          this.vm.showSportRecordSheet = false
        })
    }
    .width('100%')
    .padding({ bottom: $r('app.float.vp_40'), left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
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

@Extend(Row)
function innerCard(height: number | string = CommonConstants.FULL_PERCENT) {
  .width(CommonConstants.FULL_PERCENT)
  .height(height)
  .padding(CommonConstants.PADDING_S)
  .borderRadius($r('app.float.large_radius'))
  .justifyContent(FlexAlign.SpaceBetween)
}

@Extend(Row)
function outerCard(height: number = 56) {
  .width(CommonConstants.FULL_PERCENT)
  .height(height)
  .padding(CommonConstants.PADDING_XS)
  .borderRadius($r('app.float.large_radius'))
  .backgroundColor($r('sys.color.comp_background_primary'))
}