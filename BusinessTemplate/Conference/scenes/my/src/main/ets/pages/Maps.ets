import { MyConfig } from 'commons';
import { pasteboard } from '@kit.BasicServicesKit';
import {
  ItemRestriction,
  promptAction,
  SegmentButton,
  SegmentButtonOptions,
  SegmentButtonTextItem,
} from '@kit.ArkUI';
import { getMyMapJson } from '../service/myUniversalService';
import { MapAddressItem, MapTraffic, MyMap } from '../viewModel/MyUniversalModel';
import { ImagePreviewParam } from '../pages/ImagePreview';

@Builder
export function MapsBuilder() {
  Maps();
}


@Component
struct Maps {
  @Consume('pageStack') pageStack: NavPathStack;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('token') token: string = '';
  @StorageProp('deviceId') deviceId: string = '';
  @State loading: boolean = true;
  @State tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '篮球中心' }, { text: '大广场' }, { text: '小山村' }] as ItemRestriction<SegmentButtonTextItem>,
    textPadding: {
      top: 10,
      bottom: 10,
    },
  });
  @State tabSelectedIndexes: number[] = [0];
  @State mapList: MyMap[] = [];
  @State currentIndex: number = 0;

  aboutToAppear(): void {
    let index: string | undefined =
      this.pageStack.getParamByName('Maps')[this.pageStack.getParamByName('Maps').length-1] as string | undefined;
    if (index) {
      this.tabSelectedIndexes = [Number(index)];
      this.currentIndex = Number(index);
    } else {
      this.currentIndex = 0;
    }
    this.loadData();
  }

  loadData() {
    getMyMapJson().then((res) => {
      this.mapList = res.data;
      this.loading = false;
    });
  }

  copyText(text: string) {
    const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    const systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteboardData); // 将数据放入剪切板
    systemPasteboard.getData().then((data) => {
      if (data) {
        this.getUIContext().getPromptAction().showToast({ message: '复制成功' });
      } else {
        this.getUIContext().getPromptAction().showToast({ message: '复制失败' });
      }
    });
  }

  @Builder
  MapItem(item: MyMap) {
    Image(`${MyConfig.URL}${item.imagePreview}`)
      .width('100%')
      .onClick(() => {
        this.pageStack.pushPath({
          name: 'imagePreviewPage',
          param: {
            imageList: [`${MyConfig.URL}${item.imagePreview}`],
            active: 0,
          } as ImagePreviewParam,
        });
      });
    Column() {
      Row() {
        Column() {
          Text(item.address).fontSize(14).fontWeight(FontWeight.Bold).lineHeight(20).fontColor('#000000');
          Text(item.addressDesc)
            .fontSize(12)
            .lineHeight(18)
            .fontColor('#99000000')
            .maxLines(1)
            .textOverflow({
              overflow: TextOverflow.Ellipsis,
            });
        }.layoutWeight(1).margin({ right: 0 }).alignItems(HorizontalAlign.Start);
      }.width('100%').margin({ top: 12, bottom: 8 });

      Column() {
        ForEach(item.traffic, (subItem: MapTraffic, index: number) => {
          Row() {
            Text(subItem.name).fontSize(12).fontColor('#e6000000').lineHeight(18);
            Column({
              space: 12,
            }) {
              ForEach(subItem.address, (itemAddress: MapAddressItem, index1: number) => {
                Row() {
                  Text() {
                    Span(`${itemAddress.copyText}${itemAddress.desc}`)
                      .fontColor('#99000000');
                  }.fontSize(12).layoutWeight(1).margin({ right: 15 }).lineHeight(18);

                  Image(`${MyConfig.URL}my2%2Fmy_copy.svg?token=9272c2e3-0c1d-44a3-b695-d05c6f74a86d`)
                    .width(16)
                    .height(16)
                    .onClick(() => {
                      this.copyText(itemAddress.copyText);
                    });
                };
              }, (item: MapAddressItem) => JSON.stringify(item));
            }.layoutWeight(1);
          }
          .alignItems(VerticalAlign.Top)
          .padding({
            top: 12,
            bottom: 12,
          })
          .width('100%');

          if (index !== item.traffic.length - 1) {
            Divider()
              .width('100%');
          }
        }, (subItem: MapTraffic) => JSON.stringify(subItem));

      }.padding({
        left: 12,
        right: 12,
      })
      .backgroundColor('#F7F7F7')
      .borderRadius(14);
    };
  }

  build() {
    NavDestination() {
      Column() {
        SegmentButton({
          options: this.tabOptions,
          selectedIndexes: $tabSelectedIndexes,
          onItemClicked: (indexes) => {
            this.currentIndex = indexes;
          },
        });
      }
      .margin({
        left: 16,
        right: 16,
        top: 12,
        bottom: 16,
      });

      Scroll() {
        Column() {
          if (this.loading) {
            LoadingProgress()
              .layoutWeight(1)
              .width(80);
          } else {
            Column() {
              Column() {
                if (this.currentIndex === 0) {
                  this.MapItem(this.mapList[0]);
                }
                if (this.currentIndex === 1) {
                  this.MapItem(this.mapList[1]);
                }
                if (this.currentIndex === 2) {
                  this.MapItem(this.mapList[2]);
                }
              }
              .padding({
                left: 14,
                right: 14,
                top: 16,
                bottom: 16,
              })
              .backgroundColor(Color.White)
              .borderRadius(14);
            }
            .padding({ left: 16, right: 16, bottom: 12 })
            .margin({ bottom: 24 });
          }
        }
        .alignItems(HorizontalAlign.Start)
        .constraintSize({ minHeight: '100%' });
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring);
    }
    .title('大会地图')
    .padding({ top: px2vp(this.topRectHeight) })
    .backgroundColor('#F1F3F5');
  }
}