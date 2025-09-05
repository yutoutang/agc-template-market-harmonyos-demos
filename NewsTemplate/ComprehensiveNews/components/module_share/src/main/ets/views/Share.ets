import { image } from '@kit.ImageKit';
import { FirstPosterShareBuilder } from '../buider/FirstPosterShareBuilder'
import { PosterSharePop } from '../buider/PosterShareBuilder'
import { Screenshot } from '../componentscreenshot/Screenshot';
import { WxShareViewModel } from '../viewmodel/WxShareViewModel';
import { QqShareViewModel } from '../viewmodel/QqShareViewModel';
import { ShareOptions, ShareSheetParams } from '../model/Model';
import { PopViewUtils } from '../utils/PopViewUtils';
import { ImmersiveShare } from '../utils/ImmersiveShare';


@ComponentV2
export struct Share {
  @BuilderParam shareRenderBuilder: () => void;
  @Param qrCodeInfo: ShareOptions = new ShareOptions()
  @Local sharePopShow: boolean = false
  @Local pixmap: image.PixelMap | undefined = undefined
  @Event onClose: () => void = () => {
  }
  @Event onOpen: () => void = () => {
  }
  @Local wxShareViewModel: WxShareViewModel = WxShareViewModel.instance
  @Local qqShareViewModel: QqShareViewModel = QqShareViewModel.instance
  @Local immersiveShare: ImmersiveShare = new ImmersiveShare(this.getUIContext(), getContext(this))
  onPost = (isOpen: boolean, pixmap: image.PixelMap) => {
    this.sharePopShow = isOpen
    this.pixmap = pixmap
  }

  build() {
    Column() {
      if (this.shareRenderBuilder) {
        this.shareRenderBuilder()
      } else {
        Image($r('app.media.share_active')).width(21).height(21).fillColor($r('sys.color.font_primary'))
      }
      PosterSharePop({
        sharePopShow: this.sharePopShow,
        qrCodeInfo: this.qrCodeInfo,
        pixmap: this.pixmap,
        onClose: () => {
          this.sharePopShow = false
          this.onClose()
        },
        popClose: (isClose: boolean) => {
          this.sharePopShow = isClose
        },
      })
        .accessibilityGroup(true)
        .accessibilityLevel('no')
      Screenshot({
        qrCodeInfo: this.qrCodeInfo,
      })
        .position({ left: -2000, bottom: 0 })
        .visibility(Visibility.Hidden)
        .accessibilityGroup(true)
        .accessibilityLevel('no')
    }
    .onClick(() => {
      this.onOpen()
      this.immersiveShare.initShareOption(this.qrCodeInfo)
      this.qqShareViewModel.initQqShare()
      let params: ShareSheetParams = {
        onPost: this.onPost,
        qrCodeInfo: this.qrCodeInfo,
      }
      PopViewUtils.showSheet<ShareSheetParams>(wrapBuilder(FirstPosterShareBuilder), {
        showClose: true,
        height: 350,
        title: {
          title: '分享到',
        },
        onWillDisappear: () => {
          this.immersiveShare.offShareListening()
          this.onClose()
        },
        backgroundColor: $r('sys.color.background_secondary'),
      }, params);
    })
  }
}