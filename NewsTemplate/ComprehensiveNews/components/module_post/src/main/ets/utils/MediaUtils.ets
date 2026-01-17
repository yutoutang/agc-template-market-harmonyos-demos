import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { media } from '@kit.MediaKit';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { MediaParams, VideoSizeData } from '../constants/Constants';

const TAG = '[MediaUtils]';
const BYTE_CONVERSION: number = 1024;

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
    if (params.maxSize) {
      photoSelectOptions.fileSizeFilter = {
        filterOperator: photoAccessHelper.FilterOperator.LESS_THAN_OR_EQUAL_TO,
        fileSize: params.maxSize * BYTE_CONVERSION * BYTE_CONVERSION,
      };
    }

    let uris: string[] = [];
    const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    return photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      uris = photoSelectResult.photoUris;
      UtilLog.info(TAG, 'photoViewPicker.select to file succeed and uris are:' + uris);
      return uris;
    }).catch((err: BusinessError) => {
      UtilLog.error(TAG,
        `Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
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
        UtilLog.error(TAG, 'Create AVImageGenerator failed!');
        return undefined;
      }
      const pixelMap = await avImageGenerator?.fetchFrameByTime(0,
        media.AVImageQueryOptions.AV_IMAGE_QUERY_CLOSEST_SYNC, videoSize.photoSize);
      return pixelMap;
    } catch (e) {
      UtilLog.error(TAG, ' fail, error: ' + JSON.stringify(e));
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
      UtilLog.error(TAG, ' fail, error: ' + JSON.stringify(e));
      return videoSize;
    }
  }
}
