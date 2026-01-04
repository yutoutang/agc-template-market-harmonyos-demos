import { CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { promptAction } from '@kit.ArkUI';
import { AddrMgtApi } from 'lib_takeaway_api';
import { IAddrInfo } from 'lib_takeaway_api/src/main/ets/database/IAddrType';
import { HomeViewModel } from './HomeViewModel';
import { SearchVM } from 'module_address_search';

@ComponentV2
export struct MyAddressSearch {
  // 初始文字
  @Param textInit: string = '';
  @Local addressText: string = '';
  // 点击回调
  @Event click: (address: IAddrInfo) => void;
  vm: SearchVM = SearchVM.instance;
  @Param homeVm: HomeViewModel = new HomeViewModel();
  @Local addressInfoList: IAddrInfo[] = AddrMgtApi.ADDRESS_LIST;

  aboutToAppear() {
    this.vm.resetSearchData(this.textInit);
    this.addressText = this.textInit;
  }

  build() {
    Column() {
      /** 搜索框 **/
      Search({ value: '', placeholder: '输入地址' })
        .margin({ bottom: 8 })
        .focusable(false)
        .onClick(() => {
          RouterUtils.pushPathByName(RouterMap.ADDRESS_SEARCH_PAGE, this.addressText)
        })
      Row() {
        Row() {
          Image($r('app.media.ic_location'))
            .width(20)
            .height(20)
            .margin({ left: 4 })
          Text('当前定位: ' + this.addressText)
            .fontSize(14)
            .maxLines(1)
            .fontColor('#FF979797')
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('70%')

        Blank().width('12%')
        Row() {
          Text('重新定位')
            .fontSize(14)
            .fontColor($r('app.color.app_theme'))
            .onClick(() => {
              this.addressText = this.addressText === '湖北省武汉市洪山区和平街道' ? '江苏省南京市江宁区德融科创中心' :
                '湖北省武汉市洪山区和平街道';
              this.homeVm.settingInfo.address = this.addressText;
              //提示
              promptAction.showToast({ message: '刷新定位,当前为mock数据' });
            })
        }.width('20%')

      }
      .margin({ top: 12, bottom: 12 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Scroll() {
        Column() {
          this.addressListBuilder()
          Blank().layoutWeight(1)
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  addressListBuilder() {
    Column() {
      Text('收货地址')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .alignSelf(ItemAlign.Start)
        .padding(12)
      List({ space: 16 }) {
        ForEach(this.addressInfoList, (item: IAddrInfo) => {
          this.searchItemBuilder(item)
        }, (item: IAddrInfo, index) => JSON.stringify(item) + '_' + index)
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .containerStyle()
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .containerStyle()
  }

  @Builder
  searchItemBuilder(address: IAddrInfo) {
    Row({ space: 8 }) {
      Column({ space: CommonConstants.SPACE_XS }) {
        Text(address.province + address.city + address.area + address.detailAddress)
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .textStyle()
        Row({ space: CommonConstants.SPACE_M }) {
          Text(address.name)
            .fontSize(14)
            .fontColor('#727272')
            .textStyle()
          Text(address.cellphone.substring(0, 3) + '****' + address.cellphone.substring(7, 11))
            .fontSize(14)
            .fontColor('#727272')
            .textStyle()
        }
      }.alignItems(HorizontalAlign.Start).layoutWeight(1)

    }
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .onClick(async () => {
      this.click(address);
    })
  }

  @Styles
  containerStyle(){
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('sys.color.white'))
    .width('100%')
  }
}

@Extend(Text)
function textStyle() {
  .maxLines(1)
  .fontWeight(400)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}