import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { systemShare } from '@kit.ShareKit';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { Logger } from '@hw-agconnect/ui-base';
import { BookInfo } from 'common';
import { hilog } from '@kit.PerformanceAnalysisKit';

@ComponentV2
export struct ShareBookCard {
  @Param @Require book: BookInfo;
  @Param isShelf?: boolean = false;
  setShareData() {
    const contextFaker: Context = this.getUIContext().getHostContext() as Context;
    let bookUri = `${this.book.id}.png`
    let filePath = contextFaker.filesDir + `/${bookUri}`;

    let utdTypeId = utd.getUniformDataTypeByFilenameExtension('.png', utd.UniformDataType.IMAGE);

    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utdTypeId,
      uri: fileUri.getUriFromPath(filePath),
      title: 'Picture Title',
      description: 'Picture Description',
    });

    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    controller.show(context, {
      selectionMode: systemShare.SelectionMode.SINGLE,
      previewMode: systemShare.SharePreviewMode.DETAIL,
    }).then(() => {
      Logger.info('ShareController show success.');
    }).catch((error: BusinessError) => {
      Logger.error(`ShareController show error. code: ${error.code}, message: ${error.message}`);
    });
  }

  async aboutToAppear(): Promise<void> {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const filesDir = context.filesDir;
    let bookUri = `${this.book.id.toString()}.png`
    // 用图片名称获取资源
    let book = this.book.coverUrl?.toString().substring(10)
    let resUri = context.resourceManager.getMediaByNameSync(book)
    let file = fs.openSync(filesDir + `/${bookUri}`, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
    try {
      let writeLen = fs.writeSync(file.fd, (resUri as Uint8Array).buffer);
      Logger.info('write data to file succeed and size is:' + writeLen);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      hilog.error(0x0000, 'testTag', 'catch error: %{public}d %{public}s', e.code, e.message);
    } finally {
      fs.closeSync(file);
    }
  }

  build() {
    if (this.isShelf) {
      Column({space:5}){
        Image($r('app.media.ic_share'))
          .height(24)
          .width(24)
          .margin({ top: 5 })

        Text($r('app.string.share'))
          .fontSize($r('sys.float.Caption_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
      }
      .onClick(()=>{
        this.setShareData()
      })
    } else {
      Image($r('app.media.ic_share'))
        .width(35)
        .height(35)
        .onClick(() => {
          this.setShareData()
        })
    }



  }
}