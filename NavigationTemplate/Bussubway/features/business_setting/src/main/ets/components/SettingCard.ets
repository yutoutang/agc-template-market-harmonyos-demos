import { PersistenceV2 } from '@kit.ArkUI';
import { CommonConstants, Logger, PopViewUtils, RouterUtils, SettingModel } from 'lib_common';
import { SettingItem } from '../types/Types';
import { SettingSelectDialog } from './SettingSelectDialog';

const TAG = '[SettingCard]';

@ComponentV2
export struct SettingCard {
  @Param list: SettingItem[] = [];
  @Param labelSize: number = 16;
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;

  build() {
    List() {
      ForEach(this.list, (v: SettingItem) => {
        ListItem() {
          Row({ space: CommonConstants.SPACE_M }) {
            if (v.icon) {
              Image(v.icon)
                .width($r('app.float.normal_img_size'))
                .fillColor($r('sys.color.font_primary'))
                .draggable(false)
            }
            Column() {
              Text(v.label)
                .fontSize(this.labelSize * this.settingInfo.fontSizeRatio)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start)
              Text(v.subLabel)
                .fontSize(12 * this.settingInfo.fontSizeRatio)
                .fontColor($r('sys.color.font_secondary'))
                .visibility(v.subLabel ? Visibility.Visible : Visibility.None)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            if (v.typeSwitch) {
              this.toggleScene(v)
            } else if (v.typeSelect) {
              this.selectScene(v)
            } else {
              this.normalScene(v)
            }
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
        .onClick(() => {
          if (v.onClick) {
            v.onClick();
          } else if (v.routerName) {
            RouterUtils.pushPathByName(v.routerName, v.routerParams);
          }
        })
      }, (v: SettingItem) => v.label as string)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height('auto')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .padding({
      left: CommonConstants.PADDING_XS,
      right: CommonConstants.PADDING_XS,
      top: CommonConstants.PADDING_XS,
      bottom: CommonConstants.PADDING_XS,
    })
    .borderRadius($r('app.float.large_radius'))
    .backgroundColor($r('sys.color.comp_background_primary'))
    .divider({
      strokeWidth: 0.5,
      color: $r('sys.color.comp_divider'),
      startMargin: CommonConstants.PADDING_M,
      endMargin: CommonConstants.PADDING_M,
    })
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.interactive_pressed'))
  }

  @Builder
  toggleScene(v: SettingItem) {
    Toggle({ type: ToggleType.Switch, isOn: v.switchV })
      .hitTestBehavior(HitTestMode.Block)
      .onChange((isOn: boolean) => {
        Logger.info(TAG, 'Toggle status:' + isOn);
        if (v.onClick) {
          v.onClick(isOn);
        }
      })
  }

  @Builder
  selectScene(v: SettingItem) {
    Row({ space: CommonConstants.SPACE_XS }) {
      Text(this.getSelectLabel(v))
        .fontSize(12 * this.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_secondary'))
      Image($r('app.media.ic_right'))
        .width($r('app.float.arrow_right_w'))
        .draggable(false)
    }
    .onClick(() => {
      PopViewUtils.showPopView(wrapBuilder(SettingSelectDialog), {}, v);
    })
  }

  @Builder
  normalScene(v: SettingItem) {
    Row({ space: CommonConstants.SPACE_XS }) {
      if (v.extraLabel) {
        Text(v.extraLabel)
          .fontSize(14 * this.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_secondary'))
          .width(150)

      }
      Image($r('app.media.ic_right'))
        .width($r('app.float.arrow_right_w'))
        .draggable(false)
    }
  }

  getSelectLabel(v: SettingItem) {
    const option = v.selectOptions?.find(option => option.id === v.selectV);
    return option?.label || '';
  }
}
