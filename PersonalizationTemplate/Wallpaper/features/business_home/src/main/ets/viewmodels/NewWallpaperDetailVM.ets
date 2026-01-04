import { promptAction } from '@kit.ArkUI';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { Context } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { http } from '@kit.NetworkKit';
import { BaseViewModel, RouterMap, RouterUtils } from 'lib_common';
import { ImageInfo } from 'module_wallpaper_details';
import { DataHelper } from '../data/mock/DataHelper';
import { UploadRecipeData } from 'upload_recipe';
import { GlobalState } from '../utils/GlobalState';

interface LoginResult {
  isLoginSuccess?: boolean;
}

@ObservedV2
export class NewWallpaperDetailVM extends BaseViewModel {
  @Trace wallpaperData: UploadRecipeData | null = null;
  @Trace isLiked: boolean = false;
  private context: Context = getContext();
  private timerId: number = 0;
  private pendingImageInfo: ImageInfo | null = null;

  aboutToDisappear(): void {
    GlobalState.clearCurrentWallpaper();
    if (this.timerId) {
      clearInterval(this.timerId);
    }
  }

  async handleDownload(imageInfo: ImageInfo): Promise<void> {
    // 检查是否有可下载的资源
    const videoSource = this.getVideoSource(imageInfo);
    const hasDownloadableResource = imageInfo.url || videoSource;
    if (!hasDownloadableResource) {
      promptAction.showToast({ message: '没有可下载的资源' });
      return;
    }
    try {
      let resourceBuffer: ArrayBuffer;
      let fileExtension: string;
      let photoType: photoAccessHelper.PhotoType;
      // 判断资源类型并选择相应的处理方式
      const isVideo = this.isVideoFile(imageInfo);

      if (isVideo) {
        // 视频文件处理
        if (!videoSource) {
          promptAction.showToast({ message: '视频资源不可用' });
          return;
        }

        fileExtension = 'mp4';
        photoType = photoAccessHelper.PhotoType.VIDEO;

        if (this.isNetworkResource(videoSource)) {
          resourceBuffer = await this.downloadNetworkResource(videoSource);
        } else {
          // 对于本地视频，确保使用正确的路径
          let localVideoPath = videoSource;
          if (videoSource === 'first_wallpaper_video.mp4') {
            localVideoPath = this.getLocalFilePath('first_wallpaper_video.mp4');
          }
          resourceBuffer = await this.processLocalVideo(localVideoPath);
        }
      } else {
        // 图片文件处理
        if (!imageInfo.url) {
          promptAction.showToast({ message: '图片资源不可用' });
          return;
        }

        fileExtension = 'jpg';
        photoType = photoAccessHelper.PhotoType.IMAGE;

        if (this.isNetworkResource(imageInfo.url)) {
          resourceBuffer = await this.downloadNetworkResource(imageInfo.url);
        } else {
          resourceBuffer = await this.processLocalImage(imageInfo.url);
        }
      }

      // 保存到相册
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(this.context);
      const uri = await phAccessHelper.createAsset(photoType, fileExtension);
      const file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);

      await fileIo.write(file.fd, resourceBuffer);
      await fileIo.close(file.fd);

      const resourceType = isVideo ? '视频' : '图片';
      promptAction.showToast({ message: `${resourceType}已保存到相册` });

    } catch (error) {
      const errorMessage = (error as BusinessError).message || '未知错误';
      promptAction.showToast({ message: `下载失败: ${errorMessage}` });
    }
  }

  handleSetWallpaper(): void {
    promptAction.showToast({ message: '已设为桌面壁纸' });
  }

  handleFavorite(imageInfo: ImageInfo): boolean {
    if (!this.userInfoModel.isLogin) {
      this.pendingImageInfo = imageInfo || null;
      RouterUtils.pushPathByName(RouterMap.HUAWEI_LOGIN_PAGE, null, (popInfo) => {
        this.handleLoginCallback(popInfo);
      });
      return false;
    }
    if (!imageInfo) {
      promptAction.showToast({ message: '壁纸数据异常' });
      return false;
    }
    try {
      this.isLiked = DataHelper.getInstance().hasFavoriteByUrl(imageInfo.url);

      if (this.isLiked) {
        DataHelper.getInstance().removeFavoriteByUrl(imageInfo.url)
        promptAction.showToast({ message: '取消收藏成功' });
      } else {
        DataHelper.getInstance().addFavorite(imageInfo)
        promptAction.showToast({ message: '收藏成功' });
      }
      return true;
    } catch (error) {
      promptAction.showToast({ message: '收藏操作失败' });
      return false;
    }
  }

  handleShare(): void {
    promptAction.showToast({ message: '分享功能准备中' });
  }

  handlePreview(isPreviewing: boolean): void {
    if (isPreviewing) {
      promptAction.showToast({ message: '预览模式' });
    } else {
      clearInterval(this.timerId);
      promptAction.showToast({ message: '退出预览' });
    }
  }

  // 是否为网络资源URL
  private isNetworkResource(url: string): boolean {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  // 判断是否为视频文件
  private isVideoFile(imageInfo: ImageInfo): boolean {
    // 处理 isVideo 字段
    if (imageInfo.isVideo === true) {
      return true;
    }

    // 检查文件扩展名
    const checkVideoExtension = (path: string | undefined): boolean => {
      if (!path) {
        return false;
      }
      return path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.avi');
    };

    return checkVideoExtension(imageInfo.src) || checkVideoExtension(imageInfo.url);
  }

  // 获取视频资源路径（优先使用src，如果没有则使用url）
  private getVideoSource(imageInfo: ImageInfo): string | null {
    if (imageInfo.src) {
      return imageInfo.src;
    }
    if (imageInfo.url && this.isVideoFile(imageInfo)) {
      return imageInfo.url;
    }
    return null;
  }

  // 获取正确的本地文件路径
  private getLocalFilePath(fileName: string): string {
    return `resource://rawfile/${fileName}`;
  }

  // 网络资源下载
  private async downloadNetworkResource(url: string): Promise<ArrayBuffer> {
    const httpRequest = http.createHttp();
    const response = await httpRequest.request(
      url,
      {
        method: http.RequestMethod.GET,
        connectTimeout: 60000,
        readTimeout: 60000
      }
    );

    if (response.responseCode !== http.ResponseCode.OK) {
      throw new Error(`HTTP ${response.responseCode}`);
    }

    return response.result as ArrayBuffer;
  }

  // 本地视频文件处理
  private async processLocalVideo(filePath: string): Promise<ArrayBuffer> {
    try {
      // 如果是 rawfile 中的文件
      if (filePath.includes('rawfile/') || filePath === 'first_wallpaper_video.mp4') {
        return await this.processRawFileVideo(filePath);
      }

      // 是否存在
      try {
        await fileIo.access(filePath);
      } catch (accessError) {
        return await this.processRawFileVideo(filePath);
      }

      // 读取本地视频文件
      let file: fileIo.File | null = null;
      try {
        file = await fileIo.open(filePath, fileIo.OpenMode.READ_ONLY);
        const fileStat = await fileIo.stat(filePath);
        const buffer = new ArrayBuffer(fileStat.size);
        await fileIo.read(file.fd, buffer);
        await fileIo.close(file.fd);
        return buffer;
      } finally {
        if (file) {
          fileIo.closeSync(file.fd)
        }
      }

    } catch (error) {
      throw new Error('本地视频文件处理失败: ' + (error as Error).message);
    }
  }

  // 处理rawfile 中的视频文件
  private async processRawFileVideo(filePath: string): Promise<ArrayBuffer> {
    try {
      // 从 filePath 中提取文件名
      const fileName = filePath.split('/').pop() || 'first_wallpaper_video.mp4';

      // 使用 ResourceManager 获取 rawfile
      const resourceManager = this.context.resourceManager;
      const rawFileDescriptor = await resourceManager.getRawFileDescriptor(fileName);
      const buffer = new ArrayBuffer(rawFileDescriptor.length);
      const rawFile = await fileIo.open(`/proc/self/fd/${rawFileDescriptor.fd}`, fileIo.OpenMode.READ_ONLY);
      // 使用 lseek 设置读取位置
      await fileIo.lseek(rawFile.fd, rawFileDescriptor.offset, 0);
      await fileIo.read(rawFile.fd, buffer);
      await fileIo.close(rawFile.fd);
      return buffer;
    } catch (error) {
      throw new Error('rawfile 视频处理失败: ' + (error as Error).message);
    }
  }

  // 本地图片处理
  private async processLocalImage(url: string): Promise<ArrayBuffer> {
    try {
      const imageSource = image.createImageSource(url);
      const pixelMap = await imageSource.createPixelMap();
      const imagePacker = image.createImagePacker();
      const buffer = await imagePacker.packToData(pixelMap, {
        format: 'image/jpeg',
        quality: 98
      });
      pixelMap.release();
      return buffer;
    } catch (error) {
      throw new Error('本地图片处理失败');
    }
  }

  private handleLoginCallback(popInfo: PopInfo): void {
    const loginResult = popInfo.result as LoginResult;
    if (loginResult?.isLoginSuccess && this.pendingImageInfo) {
      this.handleFavorite(this.pendingImageInfo);
    }
  }
}