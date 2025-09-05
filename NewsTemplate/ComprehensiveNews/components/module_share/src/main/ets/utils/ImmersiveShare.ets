import { harmonyShare, systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { request } from '@kit.BasicServicesKit';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { ShareOptions } from '../model/Model';

const TAG = 'IMMERSIVE_SHARE'

/*
 * 碰一碰分享
 * */

export class ImmersiveShare {
  uiContext: UIContext
  context: Context
  private qrCodeInfo: ShareOptions = new ShareOptions();
  private _fileUri: string = '';

  constructor(uiContext: UIContext, context: Context) {
    this.uiContext = uiContext
    this.context = context
  }

  public initShareOption(qrCodeInfo: ShareOptions) {
    this.qrCodeInfo = qrCodeInfo
    this.copyImageToSandbox(this.qrCodeInfo.coverUrl)
    this.immersiveListening()
  }

  public offShareListening() {
    this.cleanCacheImage()
    this.immersiveDisablingListening()
  }

  public async copyImageToSandbox(image?: string) {
    if (!this.uiContext || !image) {
      return;
    }
    const parentDir = this.context.filesDir;
    if (image.startsWith('https://')) {
      // 下载网络图片存入缓存沙箱
      const fileName = image.split('/').pop() as string;
      const filePath = parentDir + '/' + `${Date.now()}_${fileName}`;
      request.downloadFile(this.context, {
        url: image,
        filePath: filePath,
      }).then(async (downloadTask: request.DownloadTask) => {
        downloadTask.on('fail', () => {
          console.error(TAG, 'file manager download failed.');
        });
        downloadTask.on('complete', async () => {
          console.info(TAG, 'file manager download success.');
          this._fileUri = filePath;
        });
      });
    } else {
      // 本地沙箱文件
      this._fileUri = image.split('file://')[1]
    }
  }

  public cleanCacheImage() {
    if (this._fileUri) {
      try {
        fs.unlinkSync(this._fileUri);
        this._fileUri = '';
        console.info(TAG, 'delete cache file success');
      } catch (err) {
        console.error(TAG, `delete cache file failed,uri:${this._fileUri},error:` + err);
      }
    }
  }

  public immersiveCallback = (sharableTarget: harmonyShare.SharableTarget) => {
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.HYPERLINK,
      // 需要开发者填入业务链接
      content: this.qrCodeInfo.coverUrl,
      thumbnailUri: fileUri.getUriFromPath(this._fileUri),
      title: this.qrCodeInfo.title,
      description: this.qrCodeInfo.createTime,
    });
    sharableTarget.share(shareData);
  }

  public immersiveListening() {
    harmonyShare.on('knockShare', this.immersiveCallback);
  }

  public immersiveDisablingListening() {
    harmonyShare.off('knockShare', this.immersiveCallback);
  }
}