import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { media } from '@kit.MediaKit';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { MediaParams, VideoSizeData } from '../models/MediaModel';
import { GlobalContextUtils } from './ContextUtils';
import { Logger } from './Logger';

const TAG = '[MediaUtils]';

export class MediaUtils {
  /**
   * 用系统picker，拉起相册或者相机
   * @param params
   * @returns
   */
  public static selectMedia(params: MediaParams): Promise<string[]> {
    const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = params.type;
    photoSelectOptions.maxSelectNumber = params.maxLimit;

    let uris: string[] = [];
    const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    return photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      uris = photoSelectResult.photoUris;
      Logger.info(TAG, 'photoViewPicker.select to file succeed and uris are:' + uris);
      return uris;
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
      return uris;
    })
  }

  /**
   * 获取视频缩略图
   * @param uri
   * @returns
   */
  public static async getVideoThumbnail(uri: string): Promise<image.PixelMap | undefined> {
    if (!uri) {
      return undefined;
    }
    try {
      let avImageGenerator: media.AVImageGenerator = await media.createAVImageGenerator();
      const fileAlbum = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
      const avFileDescriptor = { fd: fileAlbum.fd } as media.AVFileDescriptor;
      const videoSize = await MediaUtils.getVideoData(avFileDescriptor);
      if (avImageGenerator) {
        avImageGenerator.fdSrc = avFileDescriptor;
      } else {
        Logger.error(TAG, 'Create AVImageGenerator failed!');
        return undefined;
      }
      const pixelMap = await avImageGenerator?.fetchFrameByTime(0,
        media.AVImageQueryOptions.AV_IMAGE_QUERY_CLOSEST_SYNC, videoSize.photoSize);
      return pixelMap;
    } catch (e) {
      Logger.error(TAG, 'getVideoThumbnail fail, error: ' + JSON.stringify(e));
      return undefined;
    }
  }

  /**
   * 获取视频信息
   * @param avFileDescriptor
   * @returns
   */
  public static async getVideoData(avFileDescriptor: media.AVFileDescriptor): Promise<VideoSizeData> {
    let videoSize: VideoSizeData = new VideoSizeData();
    try {
      let avMetaDataExtractor: media.AVMetadataExtractor = await media.createAVMetadataExtractor();
      avMetaDataExtractor.fdSrc = avFileDescriptor;
      let metadata = await avMetaDataExtractor.fetchMetadata();
      videoSize.photoSize.width = parseInt(metadata.videoWidth as string);
      videoSize.photoSize.height = parseInt(metadata.videoHeight as string);
      if (metadata.duration) {
        videoSize.totalTime = parseInt(metadata.duration);
      }
      await avMetaDataExtractor.release();
      return videoSize;
    } catch (e) {
      Logger.error(TAG, 'getVideoData fail, error: ' + JSON.stringify(e));
      return videoSize;
    }
  }

  /**
   * pixelMap写入沙箱
   * @param pixelMap
   * @returns
   */
  public static async writePixelMap(pixelMap?: image.PixelMap): Promise<string> {
    if (!pixelMap) {
      return '';
    }
    let file: fs.File | null = null;
    try {
      const newPath: string = GlobalContextUtils.globalContext.cacheDir + `/${util.generateRandomUUID(false)}.png`;
      file = fs.openSync(newPath, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE);
      let imagePacker: image.ImagePacker = image.createImagePacker();
      let packOpts: image.PackingOption = { format: 'image/png', quality: 100 };
      await imagePacker.packToFile(pixelMap, file.fd, packOpts);
      return 'file://' + newPath;
    } catch (e) {
      Logger.error(TAG, 'writePixelMap fail, error: ' + JSON.stringify(e));
      return '';
    } finally {
      try {
        if (file) {
          fs.closeSync(file);
        }
      } catch (e) {
        Logger.error(TAG, 'fs.closeSync error: ' + JSON.stringify(e));
      }
    }
  }
}