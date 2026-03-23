import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { media } from '@kit.MediaKit';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { dataSharePredicates } from '@kit.ArkData';
import { UtilLog } from '@hw-agconnect/util-log';
import { ImageContent, MediaParams, VideoSizeData } from '../constants/Constants';

const TAG = '[MediaUtils]';
const BYTE_CONVERSION: number = 1024;

export class MediaUtils {
  /**
   * 用系统picker，拉起相册或者相机
   * @param context
   * @param params
   * @returns
   */
  public static selectMedia(context: Context, params: MediaParams): Promise<ImageContent[]> {
    return new Promise((resolve, reject) => {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = params.type;
      photoSelectOptions.maxSelectNumber = params.maxLimit;
      if (params.maxSize) {
        photoSelectOptions.fileSizeFilter = {
          filterOperator: photoAccessHelper.FilterOperator.LESS_THAN_OR_EQUAL_TO,
          fileSize: params.maxSize * BYTE_CONVERSION * BYTE_CONVERSION,
        };
      }

      let list: ImageContent[] = [];
      const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      photoViewPicker.select(photoSelectOptions)
        .then(async (photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
          UtilLog.info(TAG, 'photoViewPicker.select to file succeed and uris are:' + photoSelectResult.photoUris);
          if (params.type !== photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE) {
            for (const uri of photoSelectResult.photoUris) {
              const item = await MediaUtils.getMovingPhoto(context, uri);
              list.push(item);
            }
          } else {
            list = photoSelectResult.photoUris.map(uri => ({ src: uri } as ImageContent))
          }
          resolve(list);
        })
        .catch((err: BusinessError) => {
          UtilLog.error(TAG,
            `Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
          reject();
        })
    })
  }

  /**
   * 获取动态图片对象
   * @param context
   * @param uri
   * @returns
   */
  public static getMovingPhoto(context: Context, uri: string): Promise<ImageContent> {
    return new Promise(async (resolve, reject) => {
      try {
        const item: ImageContent = {
          src: uri,
        };
        // 获取uri对应的PhotoAsset资产。
        let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
        predicates.equalTo(photoAccessHelper.PhotoKeys.URI, uri);
        let fetchOption: photoAccessHelper.FetchOptions = {
          fetchColumns: [],
          predicates: predicates,
        };
        let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
          await photoAccessHelper.getPhotoAccessHelper(context).getAssets(fetchOption);
        let photoAsset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
        const imageType = photoAsset.get(photoAccessHelper.PhotoKeys.PHOTO_SUBTYPE) as number;
        if (imageType === photoAccessHelper.PhotoSubtype.MOVING_PHOTO) {
          // 获取PhotoAsset对应的动态照片对象。
          await photoAccessHelper.MediaAssetManager.requestMovingPhoto(context, photoAsset, {
            deliveryMode: photoAccessHelper.DeliveryMode.FAST_MODE,
          }, {
            async onDataPrepared(movingPhoto: photoAccessHelper.MovingPhoto) {
              if (movingPhoto !== undefined) {
                item.movingPhoto = movingPhoto;
              }
              resolve(item);
            },
          })
        } else {
          resolve(item);
        }
      } catch (err) {
        UtilLog.error(TAG, `handlePhoto failed, code is ${err.code}, message is ${err.message}`);
        reject();
      }
    });
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
      UtilLog.error(TAG, 'getVideoThumbnail fail, error: ' + JSON.stringify(e));
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
