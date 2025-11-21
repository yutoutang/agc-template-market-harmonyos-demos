import { CommonButton, CommonConstants, CommonHeader, RouterMap, RouterModule, WindowUtil } from 'common';
import { AssociateUtil } from 'network';
import { MyLicenseCard } from '../components/MyLicenseCard';
import { LicensePageVM } from '../viewmodels/LicensePageVM';

@ComponentV2
export struct MyLicensePage {
  vm: LicensePageVM = LicensePageVM.instance;

  build() {
    NavDestination() {
      /** 标题栏 **/
      CommonHeader({ title: '我的车牌' })

      if (this.vm.licenseInfo.all.length) {
        /** 列表内容 **/
        this.myLicenseListBuilder()
      } else {
        /** 为空占位 **/
        this.nullBuilder()
      }
      /** 添加按钮 **/
      CommonButton({
        title: '+新增车牌',
        handleClick: () => {
          AssociateUtil.checkBindPhone(() => {
            RouterModule.push({ url: RouterMap.ADD_LICENSE }, false);
          });
        },
      }).margin({ top: $r('app.string.margin_8') })
    }
    .hideTitleBar(true)
    .padding({ bottom: WindowUtil.getAvoidArea().bottom })
    .backgroundColor($r('app.color.system_color_background_gray'))
  }

  @Builder
  myLicenseListBuilder() {
    List({ space: 12 }) {
      ForEach(this.vm.licenseInfo.all, (item: string) => {
        ListItem() {
          MyLicenseCard({
            license: item,
            isDefault: item === this.vm.licenseInfo.default,
          })
        }
      }, (item: string) => item)
    }
    .scrollBar(BarState.Off)
    .padding({ left: $r('app.string.padding_16'), right: $r('app.string.padding_16') })
    .layoutWeight(1)
    .bindSheet($$this.vm.showOpt, this.optionBuilder, { height: SheetSize.FIT_CONTENT, preferType: SheetType.CENTER })
  }

  @Builder
  nullBuilder() {
    Column() {
      Image($r('app.media.ic_null_license')).width(120).onClick(() => {
        RouterModule.push({ url: RouterMap.ADD_LICENSE }, false);
      })
      Text('暂无车牌')
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_tertiary'))
    }
    .margin({ top: $r('app.string.margin_48') })
    .justifyContent(FlexAlign.Start)
    .layoutWeight(1)
  }

  @Builder
  optionBuilder() {
    Column({ space: 22 }) {
      Text('车辆设置')
        .fontWeight(FontWeight.Medium)
        .width(CommonConstants.FULL_WIDTH)
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))

      Column({ space: 12 }) {
        Text('设为默认车辆')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Medium)
          .width(CommonConstants.FULL_WIDTH)
          .onClick(() => {
            this.vm.setNewDefaultLicense();
            this.vm.showOpt = false;
          })
        Text('删除车辆')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Medium)
          .width(CommonConstants.FULL_WIDTH)
          .fontColor($r('app.color.delete_red'))
          .backgroundColor($r('app.color.system_color_background_gray'))
          .borderRadius($r('app.string.border_radius_20'))
          .padding({ top: $r('app.string.padding_8'), bottom: $r('app.string.padding_8') })
          .onClick(() => {
            AssociateUtil.checkBindPhone(() => {
              this.vm.deleteLicense();
            });
            this.vm.showOpt = false;
          })
      }
      .padding({
        left: 12,
        right: 12,
        top: 16,
        bottom: 16,
      })
      .borderRadius($r('app.string.border_radius_16'))
      .backgroundColor($r('app.color.system_color_background_white'))
    }
    .padding({
      left: 16,
      right: 16,
      top: 30,
      bottom: WindowUtil.getAvoidArea().bottom,
    })
    .backgroundColor($r('app.color.system_color_background_gray'))
  }
}

@Builder
export function myLicensePageBuilder() {
  MyLicensePage()
}