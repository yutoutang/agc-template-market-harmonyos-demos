import { ImageInfo } from './ImageInfo';


export interface OnWallpaperDetailsListener {

  /**
   * 判断是否收藏(网络数据可忽略本回调)
   * @param imageInfo
   */
  isFavorite: (imageInfo: ImageInfo) => boolean;

  /**
   * 收藏/取消收藏
   * @param imageInfo
   */
  onFavorite: (imageInfo: ImageInfo) => boolean;

  /**
   * 下载
   * @param imageInfo
   */
  onDownload: (imageInfo: ImageInfo) => void;

  /**
   * 设置壁纸
   */
  onSetWallpaper: (imageInfo: ImageInfo) => void;

  /**
   * 预览
   * @param isPreviewing
   */
  onPreview: (isPreviewing: boolean) => void;

  /**
   * 分享
   */
  onShare: () => void;

  /**
   * 返回
   */
  onBack: () => void;
}
