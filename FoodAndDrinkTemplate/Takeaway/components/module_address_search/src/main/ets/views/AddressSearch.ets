import { IAddressInfo } from '../types/Address';
import { CommonUtil } from '../utils/CommonUtil';
import { HistoryUtil } from '../utils/HistoryUtil';
import { SearchVM } from '../viewmodels/SearchVM';

@ComponentV2
export struct AddressSearch {
  // 初始文字
  @Param textInit: string = '';
  // 点击回调
  @Event click: (address: IAddressInfo) => void;
  vm: SearchVM = SearchVM.instance;

  aboutToAppear() {
    this.vm.resetSearchData(this.textInit);
  }

  build() {
    Column() {
      /** 搜索框 **/
      Search({ value: this.vm.text, placeholder: '输入地址' })
        .margin({ bottom: 8 })
        .searchButton('搜索')
        .onChange(CommonUtil.debounce((res: string) => {
          this.vm.text = res.trim();
          this.vm.autoCompleteAddress();
        }, 200))

      Scroll() {
        Column() {
          if (!this.vm.text) {
            /** 搜索历史 **/
            this.historyBuilder()
          } else if (this.vm.searchList.length) {
            /** 补全列表 **/
            this.searchListBuilder()
          } else if (!this.vm.searching) {
            /** 搜索为空 **/
            this.nullBuilder()
          }
          Blank().layoutWeight(1)
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  searchListBuilder() {
    if (this.vm.searchList.length) {
      Column() {
        List({ space: 16 }) {
          ForEach(this.vm.searchList, (item: IAddressInfo) => {
            this.searchItemBuilder(item)
          }, (item: IAddressInfo) => JSON.stringify(item))
        }
        .containerStyle()
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .scrollBar(BarState.Off)
      }
    }
  }

  @Builder
  nullBuilder() {
    Column() {
      Text('搜索结果')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))

      Divider()
        .color($r('sys.color.comp_divider'))
        .margin({ top: 12, bottom: 12 })

      Image($r('app.media.ic_null_history')).width(120).aspectRatio(1)
      Text('未搜索到相关地址')
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_tertiary'))
        .margin({ top: 4, bottom: 10 })
    }
    .containerStyle()
  }

  @Builder
  historyBuilder() {
    Column() {
      Text('搜索记录')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))

      Divider()
        .color($r('sys.color.comp_divider'))
        .margin({ top: 12, bottom: 12 })

      if (this.vm.historyList.list.length) {
        List({ space: 16 }) {
          ForEach(this.vm.historyList.list, (item: IAddressInfo) => {
            this.searchItemBuilder(item)
          }, (item: IAddressInfo) => JSON.stringify(item))
        }
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .scrollBar(BarState.Off)

        Text('清空历史记录')
          .fontSize($r('sys.float.Caption_L'))
          .fontColor($r('sys.color.font_tertiary'))
          .margin({ top: 24 })
          .onClick(() => {
            HistoryUtil.clearList();
          })
      } else {
        Image($r('app.media.ic_null_history')).width(120).aspectRatio(1)
        Text('暂无搜索记录')
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_tertiary'))
          .margin({ top: 4, bottom: 10 })
      }
    }
    .containerStyle()
  }

  @Builder
  searchItemBuilder(address: IAddressInfo) {
    Row({ space: 8 }) {
      Image($r('app.media.ic_location')).width(16)
      Column({ space: 4 }) {
        Text(address.name)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
          .textStyle()
        Text(address.addr)
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_tertiary'))
          .textStyle()
      }.alignItems(HorizontalAlign.Start).layoutWeight(1)
    }
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .onClick(async () => {
      this.click(address);
      HistoryUtil.addOne(address);
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
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}