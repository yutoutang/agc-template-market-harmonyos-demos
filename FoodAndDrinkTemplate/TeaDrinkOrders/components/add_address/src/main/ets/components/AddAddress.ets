import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { sceneMap } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { common } from '@kit.AbilityKit';
import { AddressInfo } from '../models/Index';
import { AddressTagEnum, Constants } from '../constants/Index';

@ComponentV2
export struct AddAddress {
  @Param addressInfo: AddressInfo = new AddressInfo()
  @Param @Require myLocation: geoLocationManager.Location
  @Local currentAddress: AddressInfo = new AddressInfo()
  @Event modifyAddressInfo: (addressInfo: AddressInfo) => void = () => {
  }

  aboutToAppear(): void {
    this.currentAddress.init(this.addressInfo)
  }

  @Styles
  cardStyle(){
    .width(Constants.FULL_SIZE)
    .margin({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .borderRadius(12)
    .backgroundColor($r('sys.color.background_primary'));
  }

  build() {
    Column({ space: 12 }) {
      Column() {
        Row() {
          Row({ space: 24 }) {
            Text($r('app.string.address')).labelStyle()
            Text(this.currentAddress.addressPre || $r('app.string.select_address'))
              .fontSize($r('sys.float.Body_L'))
              .fontColor(this.currentAddress.addressPre ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }.layoutWeight(1)

          Image($r('app.media.ic_address_right')).width(16).margin({ left: 8 })
        }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween).onClick(() => {
          if (this.myLocation) {
            let locationChoosingOptions: sceneMap.LocationChoosingOptions = {
              location: {
                latitude: this.currentAddress.latitude || this.myLocation?.latitude,
                longitude: this.currentAddress.longitude || this.myLocation?.longitude,
              },
              language: 'zh',
              searchEnabled: true,
              showNearbyPoi: true,
            };
            sceneMap.chooseLocation(getContext(this) as common.UIAbilityContext, locationChoosingOptions)
              .then((data) => {
                this.currentAddress.addressPre = data.name || ''
                this.currentAddress.latitude = data.location.latitude
                this.currentAddress.longitude = data.location.longitude
                console.info('ChooseLocation', 'Succeeded in choosing location.');
              })
              .catch((err: BusinessError) => {
                console.error('ChooseLocation',
                  `Failed to choose Location, code: ${err.code}, message: ${err.message}`);
              });
          }
        })

        Divider().margin({ top: 12, bottom: 12 })
        Row() {
          Row({ space: 24 }) {
            Text($r('app.string.house_number')).labelStyle()
            TextInput({ text: $$this.currentAddress.addressNum, placeholder: $r('app.string.address_num_tip') })
              .inputStyle()
          }.layoutWeight(1)
        }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween)

        Divider().margin({ top: 12, bottom: 12 })
        Row() {
          Row({ space: 24 }) {
            Text($r('app.string.address_user')).labelStyle()
            TextInput({ text: $$this.currentAddress.name, placeholder: '输入收货人' }).inputStyle()
              .cancelButton({
                style: CancelButtonStyle.INPUT,
                icon: {
                  size: 16,
                  src: $r('app.media.ic_close'),
                },
              })
          }.layoutWeight(1)
        }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween)

        Divider().margin({ top: 12, bottom: 12 })
        Row({ space: 24 }) {
          Text($r('app.string.address_tel')).labelStyle()
          TextInput({ text: $$this.currentAddress.tel, placeholder: $r('app.string.address_tel_tip') }).inputStyle()
            .cancelButton({
              style: CancelButtonStyle.INPUT,
              icon: {
                size: 16,
                src: $r('app.media.ic_close'),
              },
            })
        }
      }
      .cardStyle()
      .padding({
        top: 18,
        bottom: 18,
        left: 12,
        right: 12,
      })
      .margin({ top: 12, left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })

      Column() {
        Row({ space: 12 }) {
          Text($r('app.string.address_tag')).labelStyle()
          Row({ space: 12 }) {
            Text($r('app.string.address_home')).tagStyle(this.currentAddress.tag === AddressTagEnum.HOME)
              .onClick(() => {
                this.currentAddress.tag = AddressTagEnum.HOME
              })
            Text($r('app.string.address_company')).tagStyle(this.currentAddress.tag === AddressTagEnum.COMPANY)
              .onClick(() => {
                this.currentAddress.tag = AddressTagEnum.COMPANY
              })
            Text($r('app.string.address_school')).tagStyle(this.currentAddress.tag === AddressTagEnum.SCHOOL)
              .onClick(() => {
                this.currentAddress.tag = AddressTagEnum.SCHOOL
              })
          }
        }.width(Constants.FULL_SIZE)

        Button($r('app.string.save_address'))
          .width(Constants.FULL_SIZE)
          .constraintSize({ maxWidth: Constants.FULL_SIZE })
          .margin({ left: 12, right: 12, top: 24 })
          .backgroundColor('#486602')
          .onClick(() => {
            if (!this.currentAddress.addressPre) {
              promptAction.showToast({ message: $r('app.string.select_address_pre') })
              return
            } else if (!this.currentAddress.addressNum) {
              promptAction.showToast({ message: $r('app.string.input_address_num') })
              return
            } else if (!this.currentAddress.name) {
              promptAction.showToast({ message: $r('app.string.input_address_user') })
              return
            } else if (!this.currentAddress.tel) {
              promptAction.showToast({ message: $r('app.string.input_address_tel') })
              return
            } else if (this.currentAddress.tel.length < Constants.TELEPHONE_LENGTH) {
              promptAction.showToast({ message: $r('app.string.address_tel_error') })
              return
            }
            this.modifyAddressInfo(this.currentAddress)
          })

      }.cardStyle().padding(12)
    }
    .layoutWeight(1)
  }

  getTagFontColor(tag: number) {
    if (tag === AddressTagEnum.DEFAULT) {
      return '#486602'
    } else {
      return '#FFC62F'
    }
  }

  getTagBgColor(tag: number) {
    if (tag === AddressTagEnum.DEFAULT) {
      return '#6686AD2B'
    } else {
      return '#33FFC62F'
    }
  }
}

@Extend(Text)
function labelStyle() {
  .fontSize($r('sys.float.Subtitle_M'))
  .fontColor($r('sys.color.font_primary'))
  .fontWeight(FontWeight.Medium)
  .width(48)
}

@Extend(Text)
function tagStyle(isCheck: boolean) {
  .fontSize($r('sys.float.Body_M'))
  .fontWeight(FontWeight.Medium)
  .fontColor(isCheck ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
  .padding({
    left: 12,
    right: 12,
    top: 4,
    bottom: 4,
  })
  .backgroundColor(isCheck ? '#486602' : $r('sys.color.comp_background_tertiary'))
  .borderRadius(14)
}

@Extend(TextInput)
function inputStyle() {
  .placeholderColor($r('sys.color.font_secondary'))
  .fontSize($r('sys.float.Body_L'))
  .fontColor($r('sys.color.font_primary'))
  .fontSize($r('sys.float.Body_L'))
  .caretColor('#486602')
  .showUnderline(true)
  .underlineColor({
    normal: '#00000000',
    typing: '#00000000',
    error: '#00000000',
    disable: '#00000000',
  })
  .borderWidth(0)
  .padding({ top: 2, bottom: 2 })
  .layoutWeight(1)
}