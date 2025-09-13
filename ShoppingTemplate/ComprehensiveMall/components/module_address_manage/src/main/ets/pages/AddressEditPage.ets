import { Context } from '../common/Context';
import { TitleBar } from '../common/TitleBar';
import { buildLoadingMask } from '../common/CommonBuilders';
import { parseAddressByText } from '../common/AddressManageUtil';
import { ParsedAddressDTO } from '../model/ParsedAddressDTO';
import { AddressDTO } from '../model/AddressDTO';
import { AddressVM } from '../viewmodel/AddressVM';
import { Config, IColor, IFontSize, IStyle, Operation, ShippingAddressErrorCode } from '../common/CommonConst';

import shippingAddress from '@hms.core.account.shippingAddress';
import pasteboard from '@ohos.pasteboard';
import i18n from '@ohos.i18n';
import { PromptAction, MeasureUtils } from '@ohos.arkui.UIContext';
import { sceneMap } from '@kit.MapKit';
import { BusinessError } from '@ohos.base';

@ComponentV2
struct AddressEditPage {
  @Param
  public ctx: Context = new Context();
  @Local
  private address: AddressVM = new AddressVM();
  @Local
  private clipboardText: string = '';
  @Local
  private isSelectingDistrict: boolean = false;
  @Local
  private isSelectingAddress: boolean = false;
  @Local
  private isResolvingClipboardText: boolean = false;

  @Computed
  private get isFocusable(): boolean {
    return !this.isSelectingDistrict && !this.isSelectingAddress;
  }

  @Computed
  private get showLoadingMask(): boolean {
    return this.ctx.addressMgr.isLoading ||
    this.isSelectingDistrict ||
    this.isSelectingAddress ||
    this.isResolvingClipboardText;
  }

  private promptAction: PromptAction = this.getUIContext().getPromptAction();
  private systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
  private formatNational: i18n.PhoneNumberFormat = new i18n.PhoneNumberFormat('CN', { type: 'NATIONAL' });
  private measure: MeasureUtils = this.getUIContext().getMeasureUtils();

  public aboutToAppear(): void {
    if (this.ctx.operation === Operation.EDIT && this.ctx.editingAddressDTO) {
      this.address.assignFromDTO(this.ctx.editingAddressDTO);
    }
  }

  public build(): void {
    NavDestination() {
      Column() {
        TitleBar({
          onBackButtonClick: () => this.ctx.navPathStack.pop(),
          barColor: IColor.WHITE,
        }) {
          Text(this.ctx.operation === Operation.EDIT ? '编辑地址' : '新增地址')
            .fontSize(IFontSize.TITLE)
            .fontColor(IColor.BLACK_TRANSPARENT_90)
            .fontWeight(500)
        }

        Stack() {
          this.buildMainContent();
          if (this.showLoadingMask) {
            buildLoadingMask(this.ctx.addressMgr.isLoading || this.isResolvingClipboardText);
          }
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .backgroundColor(IColor.BACKGROUND)
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    }
    .hideTitleBar(true)
  }

  @Builder
  private buildMainContent(): void {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Text('获取华为账号地址')
              .layoutWeight(1)
              .fontSize(IFontSize.BODY)
              .fontColor(IColor.BLACK_TRANSPARENT_60)
              .maxLines(1)
            Image($r('app.media.ic_left_arrow'))
              .height(16)
              .objectFit(ImageFit.Contain)
              .rotate({ angle: -180 })
              .fillColor(IColor.BLACK_TRANSPARENT_40)
              .draggable(false)
          }
          .width('100%')
          .height(48)
          .backgroundColor(IColor.WHITE)
          .borderRadius(8)
          .padding({ left: 16, right: 16 })
          .margin({ bottom: IStyle.CARD_GAP })
          .onClick(() => this.handleSelectAddress())

          // 地址解析
          Column() {
            TextArea({ text: this.clipboardText, placeholder: '在此粘贴复制的地址信息，自动拆分姓名，电话和地址' })
              .width('100%')
              .height(105)
              .placeholderColor(IColor.BLACK_TRANSPARENT_40)
              .placeholderFont({ size: 14 })
              .caretColor(IColor.THEME_PRIMARY)
              .fontColor(IColor.BLACK_TRANSPARENT_90)
              .fontSize(IFontSize.BODY)
              .maxLength(Config.ADDRESS_PARSE_TEXT_CHAR_LIMIT)
              .showCounter(true, { thresholdPercentage: 50, highlightBorder: false })
              .barState(BarState.Off)
              .onChange((value: string) => this.clipboardText = value)
              .borderRadius(8)
              .padding(10)
              .backgroundColor('#FFF1F3F5')
              .focusable(this.isFocusable)
            Text('示例：唐小虎，112xxxxxxxx，江苏省南京市鼓楼区美景雅苑xxx号')
              .width('100%')
              .fontSize(IFontSize.BODY)
              .fontColor(IColor.THEME_PRIMARY)
              .margin({ top: 12 })
            Row() {
              PasteButton({
                icon: PasteIconStyle.LINES,
                text: PasteDescription.PASTE,
                buttonType: ButtonType.Normal,
              })
                .width(80)
                .height(28)
                .borderRadius(16)
                .fontSize(IFontSize.BODY)
                .fontColor(IColor.WHITE)
                .backgroundColor(IColor.THEME_PRIMARY)
                .onClick((_: ClickEvent, result: PasteButtonOnClickResult) => {
                  this.handlePasteButtonOnClickResult(result);
                })
              Button('识别')
                .width(80)
                .height(28)
                .fontWeight(400)
                .backgroundColor(IColor.THEME_PRIMARY)
                .margin({ left: 16 })
                .onClick(() => {
                  this.handleResolvingClipboardText();
                })
            }
          }
          .width('100%')
          .backgroundColor(IColor.WHITE)
          .alignItems(HorizontalAlign.End)
          .borderRadius(8)
          .padding({
            left: 10,
            right: 10,
            top: 12,
            bottom: 12,
          })
          .margin({ bottom: IStyle.CARD_GAP })

          // 收货人 & 手机号码
          Column() {
            Row() {
              Text('收货人')
                .width(56)
                .fontSize(14)
                .fontColor(IColor.BLACK_TRANSPARENT_60)
                .textAlign(TextAlign.Start)
                .margin({ right: 24 })
              TextInput({ text: this.address.name, placeholder: '请填写收货人姓名' })
                .layoutWeight(1)
                .placeholderColor(IColor.BLACK_TRANSPARENT_40)
                .caretColor(IColor.THEME_PRIMARY)
                .maxLength(25)
                .fontColor(IColor.BLACK_TRANSPARENT_90)
                .fontSize(14)
                .placeholderFont({ size: 14 })
                .borderRadius(0)
                .padding(0)
                .maxLines(1)
                .backgroundColor(IColor.WHITE)
                .onChange((value: string) => this.address.name = value)
                .focusable(this.isFocusable)
            }
            .width('100%')
            .height(48)
            .alignItems(VerticalAlign.Center)

            Divider()
              .height(IStyle.DIVIDER_HEIGHT)
              .backgroundColor(IColor.BACKGROUND)
            Row() {
              Text('手机号码')
                .width(56)
                .fontSize(14)
                .fontColor(IColor.BLACK_TRANSPARENT_60)
                .textAlign(TextAlign.Start)
                .margin({ right: 24 })
              TextInput({ text: this.address.phone, placeholder: '请填写收货人手机号' })
                .layoutWeight(1)
                .type(InputType.PhoneNumber)
                .placeholderColor(IColor.BLACK_TRANSPARENT_40)
                .caretColor(IColor.THEME_PRIMARY)
                .maxLength(30)
                .fontColor(IColor.BLACK_TRANSPARENT_90)
                .fontSize(14)
                .placeholderFont({ size: 14 })
                .borderRadius(0)
                .padding(0)
                .maxLines(1)
                .backgroundColor(IColor.WHITE)
                .onChange((value: string) => this.address.phone = value)
                .focusable(this.isFocusable)
            }
            .width('100%')
            .height(48)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .backgroundColor(IColor.WHITE)
          .borderRadius(8)
          .padding({ left: 16, right: 16 })

          // 所在区域 & 详细地址
          Column() {
            Row() {
              Text('所在区域')
                .width(56)
                .fontSize(14)
                .fontColor(IColor.BLACK_TRANSPARENT_60)
                .textAlign(TextAlign.Start)
                .margin({ right: 24 })
              Row() {
                if (this.address.region) {
                  Text(this.address.region)
                    .layoutWeight(1)
                    .fontSize(14)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontColor(IColor.BLACK_TRANSPARENT_90)
                    .textAlign(TextAlign.Start)
                } else {
                  Text('省市区县、乡镇等')
                    .layoutWeight(1)
                    .fontSize(14)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontColor(IColor.BLACK_TRANSPARENT_40)
                    .textAlign(TextAlign.Start)
                }
                Image($r('app.media.ic_left_arrow'))
                  .height(16)
                  .objectFit(ImageFit.Contain)
                  .rotate({ angle: -180 })
                  .fillColor(IColor.BLACK_TRANSPARENT_40)
                  .draggable(false)
              }
              .layoutWeight(1)
              .height('100%')
              .onClick(() => this.handleSelectDistrict())
            }
            .width('100%')
            .height(48)
            .alignItems(VerticalAlign.Center)

            Divider()
              .height(IStyle.DIVIDER_HEIGHT)
              .backgroundColor(IColor.BACKGROUND)
            Row() {
              Text('详细地址')
                .width(56)
                .height(48)
                .fontSize(14)
                .fontColor(IColor.BLACK_TRANSPARENT_60)
                .textAlign(TextAlign.Start)
                .margin({ right: 24 })
              TextArea({ text: this.address.detail, placeholder: '小区、写字楼、门牌号等' })
                .layoutWeight(1)
                .placeholderColor(IColor.BLACK_TRANSPARENT_40)
                .placeholderFont({ size: 14 })
                .caretColor(IColor.THEME_PRIMARY)
                .fontColor(IColor.BLACK_TRANSPARENT_90)
                .fontSize(14)
                .maxLength(60)
                .showCounter(true, { thresholdPercentage: 50, highlightBorder: false })
                .barState(BarState.Off)
                .onChange((value: string) => this.address.detail = value)
                .borderRadius(0)
                .padding({
                  top: (48 - this.measureTextHeight('详细地址', 14)) / 2,
                  bottom: 12,
                  left: 0,
                  right: 0,
                })
                .backgroundColor(IColor.WHITE)
                .height(80)
                .focusable(this.isFocusable)
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)
          }
          .width('100%')
          .backgroundColor(IColor.WHITE)
          .borderRadius(8)
          .padding({ left: 16, right: 16 })
          .margin({ top: IStyle.CARD_GAP })

          // 设为默认地址
          Row() {
            Text('设为默认地址')
              .fontSize(14)
              .fontColor(IColor.BLACK_TRANSPARENT_60)
            Toggle({ type: ToggleType.Switch, isOn: this.address.isDefault })
              .selectedColor(IColor.THEME_PRIMARY)
              .switchPointColor(IColor.WHITE)
              .onChange((isOn: boolean) => {
                this.address.isDefault = isOn;
              })
          }
          .width('100%')
          .height(48)
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween)
          .backgroundColor(IColor.WHITE)
          .borderRadius(8)
          .padding({ left: 16, right: 16 })
          .margin({ top: IStyle.CARD_GAP })
        }
        .width('100%')
        .constraintSize({ minHeight: '100%' })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .padding(IStyle.CARD_GAP)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.None)

      this.buildSaveButton();
    }
    .height('100%')
  }

  @Builder
  private buildSaveButton(): void {
    Column() {
      Row() {
        Button('保存')
          .width('80%')
          .height(40)
          .fontWeight(500)
          .backgroundColor(IColor.THEME_PRIMARY)
          .onClick(() => {
            if (this.verify()) {
              const address: AddressDTO = this.address.toDTO();
              this.ctx.operation === Operation.CREATE ?
                this.ctx.addressMgr.create(address, () => this.ctx.navPathStack.pop()) :
                this.ctx.addressMgr.update(address, () => this.ctx.navPathStack.pop());
            }
          })
      }
      .width('100%')
      .height(52)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .backgroundColor(IColor.WHITE)
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
  }

  private handleSelectDistrict(): void {
    if (this.isSelectingDistrict || this.isSelectingAddress) {
      return;
    }
    this.isSelectingDistrict = true;
    this.getUIContext().getFocusController().clearFocus();
    const options: sceneMap.DistrictSelectOptions = {
      countryCode: 'CN',
      language: 'zh',
      cancelCallback: () => this.isSelectingDistrict = false,
    };
    sceneMap.selectDistrict(this.getUIContext().getHostContext(), options)
      .then((result: sceneMap.DistrictSelectResult) => {
        this.address.clearRegion();
        for (let district of result.districts) {
          switch (district.adminLevel) {
            case 'COUNTRY':
              this.address.countryCode = district.countryCode ?? '';
              this.address.country = district.name ?? '';
              break;
            case 'ADMINISTRATIVE_AREA_LEVEL_1':
              this.address.province = district.name ?? '';
              break;
            case 'ADMINISTRATIVE_AREA_LEVEL_2':
              this.address.city = district.name ?? '';
              break;
            case 'ADMINISTRATIVE_AREA_LEVEL_3':
              this.address.district = district.name ?? '';
              break;
            case 'ADMINISTRATIVE_AREA_LEVEL_4':
              this.address.street = district.name ?? '';
              break;
          }
        }
      })
      .catch((e: BusinessError<void>) => this.showErrorToast(e))
      .finally(() => this.isSelectingDistrict = false);
  }

  private handleSelectAddress(): void {
    if (this.isSelectingDistrict || this.isSelectingAddress) {
      return;
    }
    this.isSelectingAddress = true;
    this.getUIContext().getFocusController().clearFocus();
    shippingAddress.chooseAddress(this.getUIContext().getHostContext())
      .then((info: shippingAddress.AddressInfo) => {
        // 根据官方文档，当前收货地址仅支持中国境内
        this.address.countryCode = 'CN';
        this.address.country = '中国';
        this.address.name = info.userName;
        this.address.phone = this.formatNational.format(info.mobileNumber).replace(/\s+/g, '');
        this.address.detail = info.detailedAddress ?? '';
        this.address.province = info.provinceName;
        this.address.city = info.cityName;
        this.address.district = info.districtName;
        this.address.street = info.streetName ?? '';
        this.promptAction.showToast({ message: '获取华为账号地址成功' });
      })
      .catch((e: BusinessError<void>) => {
        // 用户未完成操作就退出了地址管理服务
        if (e.code === ShippingAddressErrorCode.USER_CANCELED) {
          return;
        }
        this.showErrorToast(e)
      })
      .finally(() => this.isSelectingAddress = false);
  }

  private async handlePasteButtonOnClickResult(result: PasteButtonOnClickResult): Promise<void> {
    try {
      if (!this.isResolvingClipboardText && this.systemPasteboard.hasDataSync()) {
        const data: pasteboard.PasteData = this.systemPasteboard.getDataSync();
        const text: string | undefined = data.getPrimaryText()?.slice(0, Config.ADDRESS_PARSE_TEXT_CHAR_LIMIT);
        if (text) {
          this.clipboardText = text;
        } else if (result !== PasteButtonOnClickResult.SUCCESS) {
          this.getUIContext().getFocusController().clearFocus();
          this.showErrorToast('Failed to obtain temporary clipboard permission.');
        }
      }
    } catch (e) {
      this.showErrorToast(e);
    }
  }

  private handleResolvingClipboardText(): void {
    if (!this.clipboardText || this.isResolvingClipboardText) {
      return;
    }
    this.isResolvingClipboardText = true;
    this.getUIContext().getFocusController().clearFocus();
    parseAddressByText(this.clipboardText)
      .then((result: ParsedAddressDTO) => {
        let isSuccess: boolean = false;
        if (result.name) {
          this.address.name = result.name;
          isSuccess = true;
        }
        if (result.phone) {
          this.address.phone = result.phone;
          isSuccess = true;
        }
        if (result.hasCompleteLocation()) {
          this.address.countryCode = result.countryCode;
          this.address.country = result.country;
          this.address.province = result.province;
          this.address.city = result.city;
          this.address.district = result.district;
          this.address.street = result.street;
          this.address.detail = result.detail;
          isSuccess = true;
        }
        this.promptAction.showToast({ message: isSuccess ? '识别成功' : '识别失败' });
      })
      .catch((e: BusinessError<void>) => {
        this.showErrorToast(e);
      })
      .finally(() => this.isResolvingClipboardText = false);
  }

  private showErrorToast(error: BusinessError<void> | string): void {
    if (!Config.IS_DEV) {
      return;
    }
    let message: string = '';
    if (typeof error === 'string') {
      message = 'error: ' + error;
    } else if (!error.code) {
      message = 'error: ' + error.message;
    } else {
      message = `code: ${error.code}, msg: ${error.message}`;
    }
    this.promptAction.showToast({
      message: message,
      backgroundBlurStyle: BlurStyle.NONE,
      backgroundColor: IColor.DEV_TOAST_BG_COLOR,
      textColor: IColor.BLACK_TRANSPARENT_90,
    });
  }

  private measureTextHeight(text: string, fontSizeVP: number): number {
    const size: SizeOptions = this.measure.measureTextSize({ textContent: text, fontSize: fontSizeVP });
    const heightPX: number = size.height as number;
    return heightPX ? this.getUIContext().px2vp(heightPX) : 0;
  }

  private verify(): boolean {
    if (!this.address.name) {
      this.promptAction.showToast({ message: '请输入收货人姓名' });
      return false;
    }
    if (!this.address.phone) {
      this.promptAction.showToast({ message: '请输入手机号码' });
      return false;
    }
    if (!this.formatNational.isValidNumber(this.address.phone)) {
      this.promptAction.showToast({ message: '手机号码不正确' });
      return false;
    }
    if (!this.address.region) {
      this.promptAction.showToast({ message: '请选择所在地区' });
      return false;
    }
    if (!this.address.detail) {
      this.promptAction.showToast({ message: '请输入详细地址' });
      return false;
    }
    return true;
  }
}

@Builder
export function buildAddressEditPage(_: string, context: Context) {
  AddressEditPage({ ctx: context })
}
