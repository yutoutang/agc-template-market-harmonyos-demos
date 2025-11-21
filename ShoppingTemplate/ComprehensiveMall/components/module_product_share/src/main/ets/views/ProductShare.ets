import { Constants } from '../commons/Constants';
import { PosterType, ShareType } from '../commons/Enums';
import { ProductResource, ShareItem } from '../commons/Types';
import { PopViewUtil } from '../utils/PopViewUtil';
import { ShareOperationUtil } from '../utils/ShareOperationUtil';
import { WindowUtil } from '../utils/WindowUtil';

@ComponentV2
export struct ProductShare {
  @BuilderParam
  customUI: () => void = this.defaultIconBuilder;
  @Param
  panelHeight: SheetSize | Length = 260;
  @Param @Require
  productResource: ProductResource;
  @Local
  showPanel: boolean = false;

  aboutToAppear(): void {
    WindowUtil.initWindowUtil(this.getUIContext());
    ShareOperationUtil.initShareOperation(this.productResource);
  }

  aboutToDisappear(): void {
    ShareOperationUtil.cleanCacheImage();
    ShareOperationUtil.stopKnockShareListener();
  }

  build() {
    Column() {
      this.customUI();
    }
    .bindSheet($$this.showPanel, this.sharePanelBuilder(), {
      height: this.panelHeight,
      title: { title: '分享' },
      preferType:SheetType.CENTER,
      onWillDismiss: (action) => {
        PopViewUtil.closeAllDialog();
        action.dismiss();
      },
    })
    .onClick(() => {
      this.showPanel = true;
    });
  }

  @Builder
  sharePanelBuilder() {
    Column() {
      Row() {
        ForEach(Constants.SHARE_OPTION_LIST, (item: ShareItem) => {
          Column() {
            Row() {
              Image(item.icon)
                .width(24)
                .height(24)
                .borderRadius(Constants.BORDER_RADIUS_CAPSULE);
            }
            .width(48)
            .height(48)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .backgroundColor(Constants.BACKGROUND_COLOR)
            .borderRadius(Constants.BORDER_RADIUS_4);

            Text(item.label)
              .margin({ top: Constants.SPACE_M })
              .fontSize(12)
              .fontColor(Constants.FONT_COLOR_LEVEL2);
          }
          .margin({ right: Constants.SPACE_L })
          .onClick(() => {
            this.handleShareSelection(item.type);
          });
        }, (item: ShareItem) => item.label);

        Column() {
          Column() {
            SymbolGlyph($r('sys.symbol.share'))
              .fontSize(24);
          }
          .width(48)
          .height(48)
          .borderRadius(Constants.BORDER_RADIUS_4)
          .backgroundColor(Color.White)
          .justifyContent(FlexAlign.Center);

          Text('系统分享')
            .margin({ top: Constants.SPACE_M })
            .fontSize(12)
            .fontColor(Constants.FONT_COLOR_LEVEL2);
        }
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.handleShareSelection(ShareType.SYSTEM_SHARE);
        });
      }
      .width('100%')
      .justifyContent(FlexAlign.Start);

      Blank();
      Button('取消')
        .backgroundColor(Constants.BACKGROUND_COLOR_GREY_2)
        .fontColor($r('sys.color.font_primary'))
        .width('100%')
        .onClick(() => {
          this.showPanel = false;
        })
        .margin({bottom:Constants.SPACE_L})
    }
    .height('100%')
    .width('100%')
    .padding(Constants.SPACE_L);
  }

  @Builder
  defaultIconBuilder() {
    Button('分享')
  }

  handleShareSelection(type: ShareType) {
    switch (type) {
      case ShareType.SAVE_POSTER:
        ShareOperationUtil.openPosterDialog(this.productResource);
        break;
      case ShareType.COPY_URL:
        ShareOperationUtil.copyUrl(this.productResource.url);
        break;
      case ShareType.GET_QR_CODE:
        ShareOperationUtil.openPosterDialog(this.productResource, PosterType.QR_CODE);
        break;
      case ShareType.SYSTEM_SHARE:
        ShareOperationUtil.systemShare(this.productResource);
        break;
      default:
        break;
    }
  }
}