import { common } from '@kit.AbilityKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { BusinessError, pasteboard, request } from '@kit.BasicServicesKit';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { harmonyShare, systemShare } from '@kit.ShareKit';
import { PosterType } from '../commons/Enums';
import { ProductResource } from '../commons/Types';
import { posterDialogBuilder } from '../components/PosterDialog';
import { Logger } from './Logger';
import { PopViewUtil } from './PopViewUtil';
import { WindowUtil } from './WindowUtil';

const TAG: string = '[ShareOperationUtil]';

@ObservedV2
class ShareOperationUtil {
  @Trace
  private _fileUri: string = '';
  @Trace
  productResource: ProductResource | undefined = undefined;

  public initShareOperation(productResource: ProductResource) {
    this.productResource = productResource;
    this.copyImageToSandbox(productResource.image);
    this.startKnockShareListener();
  }

  public copyUrl(path: string) {
    const uiContext = WindowUtil.uiContext;
    const pasteData: pasteboard.PasteData = pasteboard.createData(
      pasteboard.MIMETYPE_TEXT_PLAIN,
      path,
    );
    let systemPasteboard: pasteboard.SystemPasteboard =
      pasteboard.getSystemPasteboard();
    systemPasteboard
      .setData(pasteData)
      .then(() => {
        uiContext.getPromptAction().showToast({ message: '商品链接复制成功~' });
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG, 'set pasteboard failed.error:' + JSON.stringify(err));
        uiContext
          .getPromptAction()
          .showToast({ message: '商品链接复制失败，请稍后重试' });
      });
  }

  public openPosterDialog(
    posterResource: ProductResource,
    posterType: PosterType = PosterType.DEFAULT,
  ) {
    PopViewUtil.openDialog(
      wrapBuilder(posterDialogBuilder),
      {
        isModal: false,
        autoCancel: true,
        alignment: DialogAlignment.Top,
        offset: {
          dy: 80,
          dx: 0,
        },
      },
      {
        posterResource,
        posterType,
      },
    );
  }

  public async systemShare(productResource?: ProductResource) {
    const contextFaker = WindowUtil.context;
    if (!productResource) {
      return;
    }
    if (contextFaker && this._fileUri) {
      let shareData: systemShare.SharedData = new systemShare.SharedData({
        utd: utd.UniformDataType.HYPERLINK,
        content: productResource.url ?? '',
        title: productResource.title ?? '',
        description: '¥' + productResource.price,
        label: productResource.title ?? '',
      });
      let controller: systemShare.ShareController =
        new systemShare.ShareController(shareData);
      controller
        .show(contextFaker as common.UIAbilityContext, {
          previewMode: systemShare.SharePreviewMode.DEFAULT,
          selectionMode: systemShare.SelectionMode.BATCH,
        })
        .then(() => {
          Logger.info(TAG, 'HuaweiShare show');
        })
        .catch((error: BusinessError) => {
          Logger.error(
            TAG,
            `HuaweiShare show error. Code: ${error.code}, message: ${error.message}`,
          );
        });
    } else {
      Logger.error(TAG, 'HuaweiShare show error. context or fileUri is null');
    }
  }

  public async copyImageToSandbox(image?: ResourceStr) {
    const context = WindowUtil.context;
    if (!context || !image) {
      return;
    }
    const parentDir = context.filesDir;
    if (typeof image === 'string') {
      // 下载网络图片存入缓存沙箱
      const fileName = image.split('/').pop() as string;
      const filePath = parentDir + '/' + `${Date.now()}_${fileName}`;
      request
        .downloadFile(context, {
          url: image,
          filePath: filePath,
        })
        .then(async (downloadTask: request.DownloadTask) => {
          downloadTask.on('fail', () => {
            Logger.error(TAG, 'file manager download failed.');
          });
          downloadTask.on('complete', async () => {
            Logger.info(TAG, 'file manager download success.');
            this._fileUri = filePath;
          });
        });
    } else {
      // 将资源文件存入缓存沙箱
      const mediaContent = context.resourceManager.getMediaContentSync(image);
      const filePath = parentDir + '/' + `${Date.now()}_local_image.jpg`;
      let file: fs.File | null = null;
      try {
        file = fs.openSync(
          filePath,
          fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE,
        );
        fs.writeSync(file.fd, (mediaContent as Uint8Array).buffer);
        Logger.info('write data to file success.');
        this._fileUri = filePath;
      } catch (err) {
        Logger.error(
          TAG,
          'write data to file failed. error: ' + JSON.stringify(err),
        );
      } finally {
        if (file) {
          fs.closeSync(file);
        }
      }
    }
  }

  public cleanCacheImage() {
    if (this._fileUri) {
      try {
        fs.unlinkSync(this._fileUri);
        this._fileUri = '';
        Logger.info(TAG, 'delete cache file success');
      } catch (err) {
        Logger.error(
          TAG,
          `delete cache file failed,uri:${this._fileUri},error:` + err,
        );
      }
    }
  }

  public startKnockShareListener() {
    harmonyShare.on('knockShare', this._knockCallback.bind(this));
  }

  public stopKnockShareListener() {
    harmonyShare.off('knockShare');
  }

  private _knockCallback(sharableTarget: harmonyShare.SharableTarget) {
    const contextFaker = WindowUtil.context;
    if (!contextFaker || !this._fileUri) {
      return;
    }
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.HYPERLINK,
      content: this.productResource?.url ?? '',
      thumbnailUri: fileUri.getUriFromPath(this._fileUri),
      title: this.productResource?.title ?? '',
      description: this.productResource?.price
        ? `¥${this.productResource.price}`
        : '',
    });
    sharableTarget.share(shareData);
  }
}

const util = new ShareOperationUtil();

export { util as ShareOperationUtil };
