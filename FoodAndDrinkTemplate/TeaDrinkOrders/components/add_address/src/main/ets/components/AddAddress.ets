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
  @Event modifyAddressInfo: (addressInfo: AddressInfo) => void = () => {
  }

  @Styles
  cardStyle(){
    .width(Constants.FULL_SIZE)
    .margin({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .borderRadius(12)
    .padding(12)
    .backgroundColor(Color.White);
  }

  build() {
    Column({ space: 12 }) {
      Column() {
        Row() {
          Row() {
            Text($r('app.string.address'))
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .width(50)
            Text(this.addressInfo.addressPre || $r('app.string.select_address'))
              .fontSize(12)
              .fontColor('#486602')
              .margin({ left: 4 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }.layoutWeight(1)

          Image($r('app.media.ic_right')).width(16).margin({ left: 8 })
        }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween).onClick(() => {
          if (this.myLocation) {
            let locationChoosingOptions: sceneMap.LocationChoosingOptions = {
              location: {
                latitude: this.addressInfo.latitude || this.myLocation?.latitude,
                longitude: this.addressInfo.longitude || this.myLocation?.longitude,
              },
              language: 'zh',
              searchEnabled: true,
              showNearbyPoi: true,
            };
            sceneMap.chooseLocation(getContext(this) as common.UIAbilityContext, locationChoosingOptions)
              .then((data) => {
                this.addressInfo.addressPre = data.name || ''
                this.addressInfo.latitude = data.location.latitude
                this.addressInfo.longitude = data.location.longitude
                console.info('ChooseLocation', 'Succeeded in choosing location.');
              })
              .catch((err: BusinessError) => {
                console.error('ChooseLocation',
                  `Failed to choose Location, code: ${err.code}, message: ${err.message}`);
              });
          }
        })

        Divider().margin({ top: 10, bottom: 10 })
        Row() {
          Row() {
            Text($r('app.string.house_number'))
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .width(50)
            TextInput({ text: $$this.addressInfo.addressNum, placeholder: $r('app.string.address_num_tip') })
              .placeholderFont({ size: 12 })
              .placeholderColor($r('sys.color.mask_secondary'))
              .fontSize(12)
              .showUnderline(true)
              .underlineColor({
                normal: '#00000000',
                typing: '#00000000',
                error: '#00000000',
                disable: '#00000000',
              })
              .borderWidth(0)
              .fontColor($r('sys.color.mask_secondary'))
              .padding({
                top: 2,
                bottom: 2,
              })
              .layoutWeight(1)
              .margin({ left: 4 })
          }.layoutWeight(1)
        }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween)

        Divider().margin({ top: 10, bottom: 10 })
        Row() {
          Row() {
            Text($r('app.string.address_user'))
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .width(50)
            TextInput({ text: $$this.addressInfo.name })
              .placeholderFont({ size: 12 })
              .placeholderColor($r('sys.color.mask_secondary'))
              .fontSize(12)
              .fontColor($r('sys.color.mask_secondary'))
              .showUnderline(true)
              .underlineColor({
                normal: '#00000000',
                typing: '#00000000',
                error: '#00000000',
                disable: '#00000000',
              })
              .padding({
                top: 2,
                bottom: 2,
              })
              .layoutWeight(1)
              .margin({ left: 4 })
              .cancelButton({
                style: CancelButtonStyle.CONSTANT,
                icon: {
                  size: 16,
                  src: $r('app.media.ic_close'),
                },
              })
          }.layoutWeight(1)

          Row() {
            Radio({ value: '1', group: 'sexGroup', indicatorType: RadioIndicatorType.DOT })
              .checked(this.addressInfo.sex)
              .radioStyle({
                checkedBackgroundColor: $r('app.color.mainColor'),
              })
              .height(14)
              .width(14)
            Text($r('app.string.man')).fontSize(12).fontColor($r('sys.color.font_primary')).margin({ left: 8 })
            Radio({ value: '2', group: 'sexGroup', indicatorType: RadioIndicatorType.DOT })
              .checked(false)
              .radioStyle({
                checkedBackgroundColor: $r('app.color.mainColor'),
              })
              .height(14)
              .width(14)
              .margin({ left: 20 })
            Text($r('app.string.woman')).fontSize(12).fontColor($r('sys.color.font_primary')).margin({ left: 8 })
          }.margin({ left: 8 })
        }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween)

        Divider().margin({ top: 10, bottom: 10 })
        Row() {
          Text($r('app.string.address_tel'))
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .width(50)
          TextInput({ text: $$this.addressInfo.tel, placeholder: $r('app.string.address_tel_tip') })
            .placeholderFont({ size: 12 })
            .placeholderColor($r('sys.color.mask_secondary'))
            .fontSize(12)
            .fontColor($r('sys.color.mask_secondary'))
            .showUnderline(true)
            .underlineColor({
              normal: '#00000000',
              typing: '#00000000',
              error: '#00000000',
              disable: '#00000000',
            })
            .padding({
              top: 2,
              bottom: 2,
            })
            .layoutWeight(1)
            .margin({ left: 4 })
            .cancelButton({
              style: CancelButtonStyle.CONSTANT,
              icon: {
                size: 16,
                src: $r('app.media.ic_close'),
              },
            })
        }
      }.cardStyle().margin({ top: 12, left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })

      Column() {
        Row() {
          Text($r('app.string.address_tag'))
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .width(50)
          Row({ space: 8 }) {
            Text($r('app.string.address_home'))
              .fontSize(10)
              .fontColor(this.addressInfo.tag === AddressTagEnum.HOME ? '#486602' : $r('sys.color.font_primary'))
              .padding({
                left: 12,
                right: 12,
                top: 2,
                bottom: 2,
              })
              .backgroundColor(this.addressInfo.tag === AddressTagEnum.HOME ? '#339DC540' : Color.White)
              .border({
                width: 1,
                color: this.addressInfo.tag === AddressTagEnum.HOME ? '#486602' : '#80000000',
                radius: 4,
              })
              .onClick(() => {
                this.addressInfo.tag = AddressTagEnum.HOME
              })
            Text($r('app.string.address_company'))
              .fontSize(10)
              .fontColor(this.addressInfo.tag === AddressTagEnum.COMPANY ? '#486602' : $r('sys.color.font_primary'))
              .padding({
                left: 12,
                right: 12,
                top: 2,
                bottom: 2,
              })
              .backgroundColor(this.addressInfo.tag === AddressTagEnum.COMPANY ? '#339DC540' : Color.White)
              .border({
                width: 1,
                color: this.addressInfo.tag === AddressTagEnum.COMPANY ? '#486602' : '#80000000',
                radius: 4,
              })
              .onClick(() => {
                this.addressInfo.tag = AddressTagEnum.COMPANY
              })
            Text($r('app.string.address_school'))
              .fontSize(10)
              .fontColor(this.addressInfo.tag === AddressTagEnum.SCHOOL ? '#486602' : $r('sys.color.font_primary'))
              .padding({
                left: 12,
                right: 12,
                top: 2,
                bottom: 2,
              })
              .backgroundColor(this.addressInfo.tag === AddressTagEnum.SCHOOL ? '#339DC540' : Color.White)
              .border({
                width: 1,
                color: this.addressInfo.tag === AddressTagEnum.SCHOOL ? '#486602' : '#80000000',
                radius: 4,
              })
              .onClick(() => {
                this.addressInfo.tag = AddressTagEnum.SCHOOL
              })
          }
        }.width(Constants.FULL_SIZE)

        Row() {
          Text($r('app.string.save_address'))
            .fontSize(14)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .padding({ top: 6, bottom: 6 })
        }
        .width(Constants.FULL_SIZE)
        .height(40)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })
        .margin({ left: 4, right: 4, top: 32 })
        .backgroundColor('#486602')
        .borderRadius(16)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          if (!this.addressInfo.addressPre) {
            promptAction.showToast({ message: $r('app.string.select_address_pre') })
            return
          } else if (!this.addressInfo.addressNum) {
            promptAction.showToast({ message: $r('app.string.input_address_num') })
            return
          } else if (!this.addressInfo.name) {
            promptAction.showToast({ message: $r('app.string.input_address_user') })
            return
          } else if (!this.addressInfo.tel) {
            promptAction.showToast({ message: $r('app.string.input_address_tel') })
            return
          } else if (this.addressInfo.tel.length < Constants.TELEPHONE_LENGTH) {
            promptAction.showToast({ message: $r('app.string.address_tel_error') })
            return
          }
          this.modifyAddressInfo(this.addressInfo)
        })

      }.cardStyle()
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