import { LoginSheetUtils } from 'lib_account';
import { PreferencesHelper, RouterMap, RouterUtils } from 'lib_common';
import { ImageInfo, ImageInfos, NewWallpaperDetail, OnWallpaperDetailsListener } from 'module_wallpaper_details';
import { DataHelper } from '../data/mock/DataHelper';
import { NewWallpaperDetailVM } from '../viewmodels/NewWallpaperDetailVM';

@Builder
export function WallpaperDetailPageBuilder(): void {
  NewWallpaperDetailPage()
}

@ComponentV2
export struct NewWallpaperDetailPage {
  private vm: NewWallpaperDetailVM = new NewWallpaperDetailVM();
  private imageData: ImageInfos | undefined;
  @Local listener: OnWallpaperDetailsListener = {
    onFavorite: (imageInfo: ImageInfo): boolean => {
      return this.vm.handleFavorite(imageInfo);
    },
    onDownload: async (imageInfo: ImageInfo): Promise<void> => {

      if (!this.vm.userInfoModel.isLogin) {
        LoginSheetUtils.open();
      } else {
        if (!this.vm.userInfoModel.isVip && imageInfo.isVideo) {
          this.getUIContext().showAlertDialog(
            {
              title: '',
              message: '请先开通会员后操作',
              autoCancel: true,
              alignment: DialogAlignment.Center,
              height: 150,
              offset: { dx: 0, dy: -20 },
              width: 300,

              secondaryButton: {
                enabled: true,
                value: '去开通',
                action: () => {
                  RouterUtils.pushPathByName(RouterMap.VIPCENTER_PAGE)
                }
              },
              primaryButton: {
                value: '取消',
                fontColor: '#99000000',
                action: () => {
                }
              }
            })
        } else {
          await this.vm.handleDownload(imageInfo);
        }
      }
    },
    onSetWallpaper: async (imageInfo: ImageInfo): Promise<void> => {
      if (!this.vm.userInfoModel.isLogin) {
        LoginSheetUtils.open();
      } else {
        if (!this.vm.userInfoModel.isVip && imageInfo.isVideo) {
          this.getUIContext().showAlertDialog(
            {
              title: '',
              message: '请先开通会员后操作',
              alignment: DialogAlignment.Center,
              autoCancel: true,
              width: 300,
              height: 150,
              offset: { dx: 0, dy: -20 },
              secondaryButton: {
                enabled: true,
                value: '去开通',
                action: () => {
                  RouterUtils.pushPathByName(RouterMap.VIPCENTER_PAGE)
                }
              },
              primaryButton: {
                value: '取消',
                fontColor: '#99000000',
                action: () => {
                }
              }
            })
        } else {
          await this.vm.handleSetWallpaper();
        }
      }
    },
    onShare: async (): Promise<void> => {
      await this.vm.handleShare();
    },
    onPreview: async (isPreviewing: boolean): Promise<void> => {
      await this.vm.handlePreview(isPreviewing);
    },
    onBack: (): void => {
      RouterUtils.pop();
    },
    isFavorite: (imageInfo: ImageInfo): boolean => {
      return DataHelper.getInstance().hasFavoriteByUrl(imageInfo.url)
    }
  };

  aboutToAppear(): void {
    this.imageData =
      RouterUtils.getParamByName(RouterMap.NEW_ROUTER_MAP_WALLPAPER_DETAIL, 'main') as ImageInfos
  }

  build() {
    NavDestination() {
      NewWallpaperDetail({
        listener: this.listener,
        imageInfos: this.imageData,
        audio: PreferencesHelper.getInstance().checkAudioState(getContext())
      })
    }
    .hideTitleBar(true)
  }
}