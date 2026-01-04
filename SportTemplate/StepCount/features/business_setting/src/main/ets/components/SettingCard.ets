import { AlertDialog, PersistenceV2, promptAction } from '@kit.ArkUI';
import {
  CommonConstants,
  FileUtils,
  Logger,
  PermissionUtils,
  PopViewUtils,
  RouterUtils,
  SettingModel
} from 'lib_common';
import { SettingItem } from '../types/Types';
import { SettingSelectDialog } from './SettingSelectDialog';
import { SettingAuthorizationVM } from '../viewmodels/SettingAuthorizationVM';

const TAG = '[SettingCard]';

@ComponentV2
export struct SettingCard {
  @Param list: SettingItem[] = [];
  @Param labelSize: number = 16;
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
  @Local localItem: SettingItem = new SettingItem();
  @Local settingAuthorizationVM: SettingAuthorizationVM = new SettingAuthorizationVM();
  @Local showApplyLocation: boolean = false;
  dialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: '清理缓存',
      content: '您确定要清除缓存吗?',
      primaryButton: {
        value: '取消',
        fontColor: $r('app.color.cancel_font_color'),
        action: () => {
        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          FileUtils.clearCache();
          promptAction.showToast({ message: '清除缓存成功' });
          this.localItem.extraLabel = '0M';
        }
      },
    })
  })

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
                .fontColor(v.labelColor)
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
            } else if (v.typeBindSheet) {
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
            if (v.label === '清理缓存') {
              this.dialogController.open();
              this.localItem = v;
            }
          } else if (v.routerName) {
            RouterUtils.pushPathByName(v.routerName, v.routerParams);
          }
        })
      }, (v: SettingItem) => v.label as string)
    }
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .width(CommonConstants.FULL_PERCENT)
    .height('auto')
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
    .bindSheet($$this.showApplyLocation, this.applyLocationSheet(), {
      height: 476,
      showClose: false,
      dragBar: true,
      preferType: SheetType.CENTER
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
    Toggle({ type: ToggleType.Switch, isOn: v.switchV, })
    // .selectedColor($r('sys.color.comp_background_emphasize'))
      .hitTestBehavior(HitTestMode.Block)
      .onChange(async (isOn: boolean) => {
        Logger.info(TAG, 'Toggle status:' + isOn);
        const isAgreeLoaction: boolean =
          await PermissionUtils.checkPermissionsList(this.settingAuthorizationVM.locationPermissions)
        if (v.onClick) {
          v.onClick(isOn);
          //单就位置授权情况
          // 1- 外界已开启则会在init中给与这里的开关打开状-用户进行取消操作
          // 2- 外界没有拉起过授权，这里打开开关进行首次授权
          // 3- 外界拉起授权但没有接受，这里会是关闭状态，用户只有一种操作即开启授权，这时会提示去设置页
          if (v.label === '位置权限' && isOn && !isAgreeLoaction) {
            //进行到这里说明用户操作开关打开- 外界没有授权权限-则拉起授权结构-在结构中判断是首次拉起还是-二次拉起提醒去设置页手动授权
            this.showApplyLocation = true;
          } else if (v.label === '位置权限' && !isOn && isAgreeLoaction) {
            //进来时已经同意了位置权限-进行取消授权操作--跳去设置页
            this.settingAuthorizationVM.cancelPermissions()
            //在onshow中有刷新状态的逻辑，判断用户是否在设置页进行了禁止权限的操作
          }
        }
      })
  }

  @Builder
  applyLocationSheet() {
    Column() {
      Image($r('app.media.location_logo'))
        .size({ width: 152, height: 152 })
        .margin({ top: 75 })
      Column({ space: 8 }) {
        Text($r('app.string.begin_set'))
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 26 })
        Text($r('app.string.require_open_location_service'))
          .fontSize(18)
          .fontColor($r('app.color.color_999999'))
          .textAlign(TextAlign.Center)
          .lineHeight(20)
      }
      .width(CommonConstants.PERCENT_90)

      Text($r('app.string.open_service'))
        .width(CommonConstants.PERCENT_90)
        .height($r('app.float.vp_40'))
        .textAlign(TextAlign.Center)
        .fontColor(Color.White)
        .borderRadius(CommonConstants.NUMBER_20)
        .backgroundColor($r('app.color.FC7A17'))
        .margin({ top: CommonConstants.MARGIN_XXXXXL })
        .onClick(async () => {
          PermissionUtils.checkPermissionAndNeedShowDialog(this.settingAuthorizationVM.locationPermissions)
            .then((checkPermission) => {
              if (checkPermission[1]) {
                this.settingAuthorizationVM.goSettingToOpen()
              }
              this.showApplyLocation = false;
            })
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
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
        Blank()

        Text(v.extraLabel)
          .fontSize(14 * this.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_secondary'))
          .padding({ left: CommonConstants.PADDING_L })
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
