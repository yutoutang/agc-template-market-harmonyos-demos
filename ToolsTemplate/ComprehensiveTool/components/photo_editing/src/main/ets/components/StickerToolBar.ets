import { JSON, util } from '@kit.ArkTS';
import { StickerShowModel } from '../model/PageParams';
import { Constants } from '../constant/Constants';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';

@ComponentV2
export struct StickerToolBar {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;
  @Local stickerTabIndex: number = 0;
  @Local currentStickerList: StickerShowModel[] = [];
  @Local stickerShowList: Map<string, StickerShowModel[]> = new Map<string, StickerShowModel[]>();

  async aboutToAppear(): Promise<void> {
    this.getCurrentStickerList();
  }

  async getCurrentStickerList() {
    this.currentStickerList =
      await this.getList(Constants.stickerTagListMap.get(Constants.stickerTagList[this.stickerTabIndex])!);
  }

  build() {
    Column({ space: 12 }) {
      Row({ space: 24 }) {
        ForEach(Constants.stickerTagList, (item: string, index: number) => {
          Text(item)
            .fontSize(16)
            .fontColor(this.stickerTabIndex === index ? '#ED6F21' : Color.Black)
            .onClick(() => {
              this.stickerTabIndex = index;
              this.getCurrentStickerList();
            });
        }, (item: string) => item);
      }.width('100%').justifyContent(FlexAlign.Start);

      this.stickerContentBuilder();

      Row() {
        Image($r('app.media.xmark'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.vm.barIndex = -1;
            this.cleanSticker();
          });
        Text('贴纸')
          .fontSize(16);
        Image($r('app.media.checkMark'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.vm.saveImage();
            this.cleanSticker();
          });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .padding(16)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius({ topLeft: 16, topRight: 16 });
  }

  @Builder
  stickerContentBuilder() {
    Grid() {
      ForEach(this.currentStickerList, (item: StickerShowModel) => {
        GridItem() {
          Stack() {
            Image(item.imageSource).size({ width: 48, height: 48 });
          }
          .backgroundColor('#F1F3F5')
          .borderRadius(8)
          .alignContent(Alignment.BottomStart)
          .onClick(() => {
            this.vm.stickerList.push({
              id: util.generateRandomUUID(),
              positionX: 0,
              positionY: 0,
              img: item.imageSource,
            });
          });
        };
      }, (item: StickerShowModel) => JSON.stringify(item));
    }
    .scrollBar(BarState.Off)
    .height(108)
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
    .rowsGap(12)
    .columnsGap(12);
  }

  async getList(item: string): Promise<StickerShowModel[]> {
    let result: StickerShowModel[] = [];
    let value = await this.getUIContext().getHostContext()?.resourceManager.getRawFileList('sticker');

    if (value) {
      for (let i = 0; i < value.length; i++) {
        if (value[i].toString().includes(item)) {
          let path = 'sticker/' + value[i];
          let stickerShow: StickerShowModel = {
            imageSource: $rawfile(path),
            tag: [item],
          };
          result.push(stickerShow);
        }
      }
    }
    return result;
  }

  cleanSticker() {
    this.stickerTabIndex = 0;
    this.vm.stickerList = [];
  }
}