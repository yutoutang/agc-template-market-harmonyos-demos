import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router'
import { webview } from '@kit.ArkWeb'
import { MyResumeDetailPageVM, MyResumeRouterParams } from '../viewmodel/MyResumeDetailModel'
import { GlobalContext, TValueType } from 'common'
import { image } from '@kit.ImageKit'
import { fileIo as fs, fileUri, picker } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import { pdfService } from '@kit.PDFKit'
import { BusinessError } from '@kit.BasicServicesKit'

@Builder
export function MyResumeDetailPageBuilder(params: TValueType) {
  MyResumeDetailPage({ pageParams: params })
}

const WEB_ID = 'MyResumeWebPage';

@ComponentV2
export struct MyResumeDetailPage {
  @Local vm: MyResumeDetailPageVM = MyResumeDetailPageVM.instance
  webController: webview.WebviewController = new webview.WebviewController();
  @Local templateName: string = 'template'
  @Param pageParams: TValueType = null
  @Local hasLoadWeb: boolean = false
  @Local downLoadState: string = ''
  private h5Width: number = 0
  private h5Height: number = 0
  private timer: number = 0
  private timeoutTimer: number = 0
  private context: common.UIAbilityContext | null = null
  private documentPicker: picker.DocumentViewPicker | null = null

  aboutToAppear(): void {
    try {
      webview.WebviewController.initializeWebEngine();
      webview.WebviewController.enableWholeWebPageDrawing();
    } catch (err) {
    }
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext
    this.documentPicker = new picker.DocumentViewPicker(this.context)
    // 从 AppStorage 获取参数
    const name = AppStorage.get<string>('currentResumeName')
    const id = AppStorage.get<string>('currentResumeId')

    let type: string = (this.pageParams as MyResumeRouterParams).type
    if (type === '简约') {
      this.vm.webUrl = $rawfile('simple.html')
    } else {
      this.vm.webUrl = $rawfile('huge.html')
    }
    if (name) {
      this.vm.resumeName = name
    }
    if (id) {
      this.vm.resumeId = id
      this.vm.loadResumeSnapshot()
    }
  }

  private resetWebZoom() {
    try {
      this.webController.zoom(1.0)
    } catch (err) {
    }

    const RESET_ZOOM_SCRIPT = `
      (function() {
        var meta = document.querySelector('meta[name="viewport"]');
        if (!meta) {
          meta = document.createElement('meta');
          meta.name = 'viewport';
          document.head.appendChild(meta);
        }
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
        document.body.style.zoom = '1.0';
        document.documentElement.style.zoom = '1.0';
      })();
    `;

    try {
      this.webController.runJavaScript(RESET_ZOOM_SCRIPT)
    } catch (err) {
    }

    setTimeout(() => {
      try {
        this.webController.zoom(1.0)
      } catch (err) {
      }
    }, 100)

    setTimeout(() => {
      try {
        this.webController.zoom(1.0)
      } catch (err) {
      }
    }, 300)
  }

  async getWebSize(): Promise<void> {
    const SCRIPT = `
      [document.documentElement.scrollWidth, document.documentElement.scrollHeight]
    `;
    try {
      const result = await this.webController.runJavaScriptExt(SCRIPT)
      if (result.getType() === webview.JsMessageType.ARRAY) {
        this.h5Width = (result.getArray() as number[])[0];
        // 增加 2vp 缓冲，防止因精度问题导致快照高度略小于内容高度而产生压缩
        this.h5Height = Math.max((result.getArray() as number[])[1], this.h5Width * 1.414) + 2;
      }
    } catch (error) {
    }
  }

  async createPdf(pixelMap: image.PixelMap) {
    let imageInfo1 = pixelMap.getImageInfoSync()

    // A4标准宽度 (210mm) 对应 72dpi 下的点数 ≈ 595.28
    const A4_WIDTH = 595.28
    // 根据图片宽高比计算对应的PDF高度，确保不变形
    const contentRatio = imageInfo1.size.height / imageInfo1.size.width
    const pdfHeight = A4_WIDTH * contentRatio

    let path1 = await this.saveImage('pdf_cache_01', pixelMap)
    let pdfDocument = new pdfService.PdfDocument();

    // 使用 A4 宽度和计算出的自适应高度创建 PDF
    pdfDocument.createDocument(A4_WIDTH, pdfHeight);
    const page = pdfDocument.getPage(0);
    page.addImageObject(path1, 0, 0, A4_WIDTH, pdfHeight);

    setTimeout(async () => {
      const sandboxPath = getContext().filesDir;
      const docPath = sandboxPath + `/output.pdf`;
      let isSuc = pdfDocument.saveDocument(docPath);
      if (isSuc) {
        let documentSaveOptions = new picker.DocumentSaveOptions();
        documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
        let uri: string = '';
        this.documentPicker?.save(documentSaveOptions)
          .then((documentSaveResult: string[]) => {
            if (documentSaveResult.length !== 0) {
              uri = documentSaveResult[0];
              const desFilePath = new fileUri.FileUri(uri).path + '/' + this.vm.resumeName + '.pdf';

              this.copyFile(docPath, desFilePath);
            }
          })
          .catch((err: BusinessError) => {
            this.downLoadState = '3'
            clearTimeout(this.timeoutTimer)
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
        clearTimeout(this.timeoutTimer)
        GlobalContext.getUIContext().getPromptAction().showToast({ message: 'PDF保存失败' })
      }
    }, 200)
  }

  copyFile(sourceUri: string, destinationPath: string) {
    let sourceFile: fs.File | null = null;
    let destFile: fs.File | null = null;
    try {
      sourceFile = fs.openSync(sourceUri, fs.OpenMode.READ_ONLY);
      destFile = fs.openSync(destinationPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.copyFileSync(sourceFile.fd, destFile.fd);
      this.downLoadState = '2'
      clearTimeout(this.timeoutTimer)
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '下载成功' })
    } catch (err) {
      this.downLoadState = '3'
      clearTimeout(this.timeoutTimer)
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

  async sleep(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms))
  }

  build() {
    OHPage({
      pageConfig: new OHPageConfig({
        onBackPress: (): boolean => {
          if (this.downLoadState === '1') {
            GlobalContext.getUIContext().getPromptAction().showToast({ message: '下载中，请稍候...' })
            return true // 拦截返回
          }
          phoneRouterControl.popPage()
          return true
        }
      }),
      childBuilder: () => {
        this.render()
      },
      useSafePadding: true
    })
  }

  @Builder
  render() {
    Column() {
      // 导航栏
      Row() {
        Row() {
          Image($r('app.media.chevron_backward'))
            .width(24)
            .height(24)
            .onClick(() => {
              if (this.downLoadState === '1') {
                GlobalContext.getUIContext().getPromptAction().showToast({ message: '下载中，请稍候...' })
                return
              }
              phoneRouterControl.popPage()
            })
        }
        .width(40)
        .height(40)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .padding(8)
        .borderRadius(40)

        Text(this.vm.resumeName)
          .fontSize(20)
          .fontWeight(700)
          .fontColor($r('sys.color.font_primary'))
          .margin({ left: 8 })
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(56)

      // 内容区域
      Web({ src: this.vm.webUrl, controller: this.webController })
        .layoutWeight(1)
        .width('100%')
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .databaseAccess(true)
        .zoomAccess(false)
        .initialScale(1.0)
        .fileAccess(false)
        .geolocationAccess(false)
        .verticalScrollBarAccess(false) // 保持无滚动条样式
        .onControllerAttached(() => {
          this.webController?.registerJavaScriptProxy(this.vm, 'appCall', ['initWebData'])
          // 显式加载URL以确保在VM单例模式下页面能正确刷新，防止白屏
          this.webController.loadUrl(this.vm.webUrl)
        })
        .id(WEB_ID)
        .onPageEnd(() => {
          this.hasLoadWeb = true
          this.getWebSize()
          this.resetWebZoom()
        })
        .onPageVisible(() => {
          if (this.hasLoadWeb) {
            this.resetWebZoom()
          }
        })

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
            this.timeoutTimer = setTimeout(() => {
              if (this.downLoadState === '1') {
                this.downLoadState = '3'
                this.vm.loadingState = 100
                clearInterval(this.timer)
                GlobalContext.getUIContext().getPromptAction().showToast({ message: '下载失败' })
              }
            }, 5000)

            await this.sleep(2000)
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
                  clearTimeout(this.timeoutTimer)
                  if (error) {
                    this.downLoadState = '3'
                    this.vm.loadingState = 100
                    clearInterval(this.timer)
                    GlobalContext.getUIContext().getPromptAction().showToast({ message: '截图失败' })
                    return;
                  }
                  if (result) {
                    this.createPdf(result.imagePixelMap!)
                  }
                });
            } catch (err) {
              clearTimeout(this.timeoutTimer)
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
