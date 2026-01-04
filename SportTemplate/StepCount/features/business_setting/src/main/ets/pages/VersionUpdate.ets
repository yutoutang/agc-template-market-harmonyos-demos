import { AppGalleryUtils, CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingAboutVM } from '../viewmodels/SettingAboutVM';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';

@Builder
export function versionUpdateBuilder() {
  VersionUpdate()
}

@ComponentV2
struct VersionUpdate {
  vm: SettingAboutVM = new SettingAboutVM();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({ title: '版本更新' })

        Column() {
          Image($r('app.media.start_icon'))
            .width(72)
            .aspectRatio(1)
            .borderRadius($r('app.float.large_radius'))
            .draggable(false)

          Text('版本v' + this.vm.appVersionName)
            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
            .fontColor('#E6000000')
            .margin({ top: $r('app.float.vp_16') })

          Text(this.vm.appVersionDesc)
            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ top: $r('app.float.vp_16') })

          Blank()

          Button('检查更新')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor($r('app.color.app_theme'))
            .width('100%')
            .onClick(() => {
              const context = getContext(this) as common.UIAbilityContext;
              AppGalleryUtils.checkAppUpdate(context).then((resp: boolean) => {
                if (resp) {
                  AppGalleryUtils.showUpdateDialog(context);
                } else {
                  promptAction.showToast({ message: '当前已是最新版本' });
                }
              })
            })
        }
        .layoutWeight(1)
        .width('100%')
        .padding({
          top: $r('app.float.vp_32'),
          left: CommonConstants.PADDING_PAGE,
          right: CommonConstants.PADDING_PAGE,
          bottom: this.vm.windowModel.windowBottomPadding,
        })
      }.width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}