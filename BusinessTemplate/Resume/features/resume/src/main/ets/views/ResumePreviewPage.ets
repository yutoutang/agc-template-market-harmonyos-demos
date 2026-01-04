/**
 * 简历预览页面
 * 使用WebView展示简历的最终效果,支持导出为PDF
 */

import { phoneRouterControl } from 'oh_router'
import { ResumeModel } from '../viewsmodel/ResumeModel'
import { webview } from '@kit.ArkWeb'
import { image } from '@kit.ImageKit'
import { fileIo as fs, fileUri, picker } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit'
import { pdfService } from '@kit.PDFKit'
import { CommonHeader, GlobalContext } from 'common'
import { ResumePreviewUtil } from '../utils/ResumePreviewUtil'
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function ResumePreviewPageBuilder() {
  ResumePreviewPage()
}

const WEB_ID = 'WebPage';

@ComponentV2
export struct ResumePreviewPage {
  @Local vm: ResumeModel = ResumeModel.instance
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Local hasLoadWeb: boolean = false;
  @Local downLoadState: string = ''; //1下载中 2成功 3失败
  private webController: webview.WebviewController = new webview.WebviewController(); // 使用本地Controller
  private h5Width: number = 0
  private h5Height: number = 0
  private timer: number = 0
  private timeoutTimer: number = 0
  private documentPicker = new picker.DocumentViewPicker(this.context);

  aboutToAppear(): void {
    try {
      webview.WebviewController.initializeWebEngine();
      webview.WebviewController.enableWholeWebPageDrawing();
    } catch (err) {

    }
  }

  @Builder
  topBar() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.chevron_backward')).fontSize(24).fontColor([Color.Black])
      }
      .width(40)
      .height(40)
      .backgroundColor('#F3F4F5')
      .margin({ right: 8 })
      .border({ width: 1, color: '#E5E7E9' })
      .onClick(() => {
        if (this.downLoadState === '1') {
          GlobalContext.getUIContext().getPromptAction().showToast({ message: '下载中，请稍候...' })
          return
        }
        phoneRouterControl.popPage()
      })

      Text('预览')
        .size({ height: 27 })
        .fontWeight(700)
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
  }

  async getWebSize(): Promise<void> {
    const SCRIPT = '[document.documentElement.scrollWidth, document.documentElement.scrollHeight]';
    try {
      const result = await this.webController.runJavaScriptExt(SCRIPT)
      if (result.getType() === webview.JsMessageType.ARRAY) {
        this.h5Width = (result.getArray() as number[])[0];
        this.h5Height = (result.getArray() as number[])[1];
      }
    } catch (error) {
    }
  }

  /**
   * 创建pdf文件
   */
  async createPdf(pixelMap: image.PixelMap) {
    // 1、截图
    // 按图片实际高度设置 不然图片会变形，
    // 但是总体高度不满一页的时候，给一个默认的a4纸的高度，然后计算y，这样就可以了
    let imageInfo1 = pixelMap.getImageInfoSync()

    let imageH1 = px2vp(imageInfo1.size.height)

    //2、 把截图保存到本地路径
    let path1 = await this.saveImage('pdf_cache_01', pixelMap)
    ///3、创建PDF文档，参数为默认宽高 一英寸等于72Points，A4纸的尺寸描述为210 x 297毫米 (8.27 x 11.69英寸)
    let pdfDocument = new pdfService.PdfDocument();
    // pdfDocument.createDocument(this.h5Width, this.h5Height + this.listComponentHeight);
    let onePageH = 860 // 一页的默认高度
    let originY = 0 // 这个起始点要注意:是从页面底部算的，不是从顶部！！！
    let totalH = imageH1
    if (totalH < onePageH) {
      totalH = onePageH
      originY = totalH - imageH1
    }
    pdfDocument.createDocument(this.h5Width + 40.0, totalH);
    const page = pdfDocument.getPage(0); // 获取第一页

    ///4、添加图片到pdf，直接编码进文件。
    page.addImageObject(path1, 20.0, originY, this.h5Width, imageH1);

    setTimeout(async () => {
      const sandboxPath = getContext().filesDir;
      const docPath = sandboxPath + `/output.pdf`;
      let isSuc = pdfDocument.saveDocument(docPath);
      if (isSuc) {
        // 弹出文件选择器前清除超时，因为用户选择保存位置的时间不确定
        clearInterval(this.timeoutTimer)
        let documentSaveOptions = new picker.DocumentSaveOptions();
        documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
        let uri: string = '';
        this.documentPicker.save(documentSaveOptions)
          .then((documentSaveResult: string[]) => {
            if (documentSaveResult.length !== 0) {
              uri = documentSaveResult[0];
              const desFilePath = new fileUri.FileUri(uri).path + '/预览.pdf';
              this.copyFile(docPath, desFilePath);
            }
          })
          .catch((err: BusinessError) => {
            this.downLoadState = '3'
            GlobalContext.getUIContext().getPromptAction().showToast({ message: '下载失败' })
          })
          .finally(() => {
            this.vm.loadingState = 100
            clearInterval(this.timer)
          });
      } else {
        this.downLoadState = '3'
        this.vm.loadingState = 100
        clearInterval(this.timer)
        clearInterval(this.timeoutTimer)
        GlobalContext.getUIContext().getPromptAction().showToast({ message: 'PDF保存失败' })
      }
    }, 200)
  }

  //复制到沙箱
  copyFile(sourceUri: string, destinationPath: string) {
    let sourceFile: fs.File | null = null;
    let destFile: fs.File | null = null;

    try {
      sourceFile = fs.openSync(sourceUri, fs.OpenMode.READ_ONLY);
      destFile = fs.openSync(destinationPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.copyFileSync(sourceFile.fd, destFile.fd);
      this.downLoadState = '2'
      clearInterval(this.timeoutTimer)
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '下载成功' })
    } catch (err) {
      this.downLoadState = '3'
      clearInterval(this.timeoutTimer)
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '下载失败' })
    } finally {
      this.vm.loadingState = 100
      clearInterval(this.timer)
      if (sourceFile) {
        fs.closeSync(sourceFile);
      }
      if (destFile) {
        fs.closeSync(destFile);
      }
    }
  }

  //获取截屏后图片url
  async saveImage(fileName: string, pixelMap: image.PixelMap): Promise<string> {
    let context = getContext()
    const path: string = context.cacheDir + '/' + fileName + '.jpg';
    if (fs.accessSync(path)) {
      fs.unlinkSync(path)
    }
    let file: fs.File | undefined;
    try {
      file = fs.openSync(path, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      let packOpts: image.PackingOption = { format: 'image/png', quality: 100 }
      const imagePackerApi: image.ImagePacker = image.createImagePacker();
      await imagePackerApi.packToFile(pixelMap, file.fd, packOpts)
    } catch (e) {
    } finally {
      if (file) {
        fs.closeSync(file);
      }
    }
    return path
  }

  build() {
    NavDestination() {
      Column() {
        this.topBar()

        Scroll() {
          Column() {
            Stack() {
              Web({ src: this.vm.webUrl, controller: this.webController })
                .geolocationAccess(false)
                .fileAccess(false)
                .javaScriptAccess(true)
                .onControllerAttached(() => {
                  this.webController?.registerJavaScriptProxy(this.vm, 'appCall', ['initWebData'])
                })
                .id(WEB_ID)
                .onPageEnd(() => {
                  this.hasLoadWeb = true
                  // 立即获取页面尺寸
                  const SCRIPT = '[document.documentElement.scrollWidth, document.documentElement.scrollHeight]';
                  try {
                    this.webController.runJavaScriptExt(SCRIPT).then((result) => {
                      if (result.getType() === webview.JsMessageType.ARRAY) {
                        this.h5Width = (result.getArray() as number[])[0];
                        this.h5Height = (result.getArray() as number[])[1];
                      }
                    })
                  } catch (error) {
                  }
                })
            }
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

        Stack({ alignContent: Alignment.Start }) {
          Row() {
            Column() {
              Text(this.downLoadState === '1' ? '下载中...' : '下载')
                .fontSize(16)
                .fontColor($r('sys.color.comp_background_list_card'))
            }
            .height(44)
            .layoutWeight(1)
            .backgroundColor(this.downLoadState === '1' || !this.hasLoadWeb ? 'rgba(0,0,0,0.2)' : '#0A59F7')
            .borderRadius(22)
            .justifyContent(FlexAlign.Center)
            .onClick(async () => {
              if (!this.hasLoadWeb || this.downLoadState === '1') {
                return
              }
              this.downLoadState = '1'
              this.vm.loadingState = 5
              this.timer = setInterval(() => {
                this.vm.loadingState += 2.5
                if (this.vm.loadingState === 100) {
                  clearInterval(this.timer)
                }
              }, 30)

              // 5秒超时检测
              const startTime = Date.now()
              this.timeoutTimer = setInterval(() => {
                if (this.downLoadState !== '1') {
                  clearInterval(this.timeoutTimer)
                  return
                }
                if (Date.now() - startTime > 5000) {
                  this.downLoadState = '3'
                  this.vm.loadingState = 100
                  clearInterval(this.timer)
                  clearInterval(this.timeoutTimer)
                  GlobalContext.getUIContext().getPromptAction().showToast({ message: '下载超时' })
                }
              }, 500)

              await ResumePreviewUtil.sleep(2000)
              // 确保获取到正确的页面尺寸
              await this.getWebSize()
              if (this.h5Width === 0 || this.h5Height === 0) {
                clearInterval(this.timeoutTimer)
                this.downLoadState = '3'
                this.vm.loadingState = 100
                clearInterval(this.timer)
                GlobalContext.getUIContext().getPromptAction().showToast({ message: '获取页面尺寸失败' })
                return
              }
              try {
                this.webController.webPageSnapshot({
                  id: WEB_ID,
                  size: { width: this.h5Width, height: this.h5Height }
                },
                  async (error, result) => {
                    clearInterval(this.timeoutTimer)
                    if (error) {
                      this.downLoadState = '3'
                      this.vm.loadingState = 100
                      clearInterval(this.timer)
                      GlobalContext.getUIContext().getPromptAction().showToast({ message: '截图失败' })
                      return;
                    }
                    if (result && result.imagePixelMap) {
                      this.createPdf(result.imagePixelMap)
                    } else {
                      this.downLoadState = '3'
                      this.vm.loadingState = 100
                      clearInterval(this.timer)
                      GlobalContext.getUIContext().getPromptAction().showToast({ message: '截图失败' })
                    }
                  });
              } catch (err) {
                clearInterval(this.timeoutTimer)
                GlobalContext.getUIContext().getPromptAction().showToast({ message: '下载失败' })
                this.downLoadState = '3'
                this.vm.loadingState = 100
                clearInterval(this.timer)
              }
            })
          }
          .width('100%')
          .zIndex(2)

          if (this.downLoadState === '1') {
            Row() {
              Column() {
              }
              .height(44)
              .backgroundColor('#0A59F7')
              .width(this.vm.loadingState + '%')
              .borderRadius({
                topLeft: 22,
                bottomLeft: 22,
                topRight: this.vm.loadingState >= 95 ? 22 : 0,
                bottomRight: this.vm.loadingState >= 95 ? 22 : 0
              })
            }
            .width('100%')
            .zIndex(1)
          }
        }
        .padding({ left: 16, right: 16 })
        .margin({ top: 12 })
      }
      .width('100%')
      .height('100%')
    }
    .onReady((_ctx: NavDestinationContext) => {
    })
    .onBackPressed(() => {
      if (this.downLoadState === '1') {
        GlobalContext.getUIContext().getPromptAction().showToast({ message: '下载中，请稍候...' })
        return true
      }
      phoneRouterControl.popPage();
      return true
    })
    .hideTitleBar(true)
  }
}
