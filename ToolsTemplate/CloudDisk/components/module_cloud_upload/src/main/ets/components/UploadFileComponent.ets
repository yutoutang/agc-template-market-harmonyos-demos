import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo as fs, picker } from '@kit.CoreFileKit';
import { promptAction } from '@kit.ArkUI';
import { GlobalContext, TCLogger, TimeUtil } from 'common';
import { DocumentType, UploadFileStatus } from '../model/DocumentTypeClass';
import { FileOperationUtil } from '../utils/FileOperationUtil';

/**
 * @usage: 用于文件上传到云存储场景。提供文档文件上传、媒体文件上传、云端文件列表获取、文件删除等功能。
 * 关键数据结构：FileOperationUtil（文件操作工具类）、DocumentType（文档类型枚举，包含PDF、TXT、DOCX、
 * PPTX、XLSX等）、UploadFileStatus（上传文件状态）、documentTypeArray（支持的文档类型数组）、
 * localFiles（本地文件列表）、initSuccess（初始化成功标志）。
 * 包含if逻辑：根据文档类型生成文件后缀过滤数组，根据初始化状态显示提示信息。
 * @layout: 垂直布局。顶部为三个操作按钮（上传文档文件、上传媒体文件、获取云端文件列表垂直排列），
 * 下方为文件列表（每行包含文件URI和删除按钮）。
 * @constraints: documentTypeArray文档类型数组不能为空，FileOperationUtil必须正确初始化（需配置bucket名称），
 * 上传文件前必须先初始化成功
 * @isGen: true
 * @fileType: component
 * @zhName: 文件上传组件
 * @subPage:
 * @component:
 * @modifiable: 支持的文档类型可扩展，上传目录可定制（当前为media和document），
 * 按钮样式可定制，文件列表样式可定制
 * @image:
 */
@ComponentV2
export struct UploadFileToComponent {
  private logTag: string = 'UploadFileToComponent'
  @Local localUploadFileUtil: FileOperationUtil = new FileOperationUtil();
  @Param @Require documentTypeArray: Array<DocumentType> =
    [DocumentType.PDF, DocumentType.TXT, DocumentType.DOCX, DocumentType.PPTX, DocumentType.XLSX];
  @Local localFiles: string[] = []
  @Local initSuccess: boolean = false

  aboutToAppear(): void {
    this.localUploadFileUtil.init().then(res => {
      this.initSuccess = res
      promptAction.showToast({
        message: this.initSuccess ? '初始化成功' : '初始化失败'
      })
    })
  }

  build() {
    Column() {
      Button('上传文档文件')
        .onClick(() => {
          this.uploadDocumentFile();
        })

      Button('上传媒体文件')
        .onClick(() => {
          this.upload();
        })

      Button('获取云端文件列表')
        .onClick(() => {
          this.getFileList();
        })

      ForEach(this.localFiles, (fileUri: string, index: number) => {
        Row() {
          Text(fileUri).layoutWeight(1)
          Button('删除').borderRadius(4).backgroundColor(Color.Red).fontColor($r('sys.color.font_on_primary'))

            .onClick(() => {
              this.deleteFile(fileUri)
            })
        }
      })
    }
    .margin({
      top: 100
    })
  }

  // 删除文件
  deleteFile(fileName: string) {
    this.localUploadFileUtil.deleteFile(fileName).then(() => {
      TCLogger.info(this.logTag, `delete file ${fileName} success`);
      this.localFiles = this.localFiles.filter(fileName1 => fileName1 !== fileName)
    }).catch((error: BusinessError) => {
      TCLogger.info(this.logTag, `delete file ${fileName} failed, code: ${error.code}, message: ${error.message}`);
    })
  }

  // 云端文件列表
  getFileList() {
    // 获取云存储默认实例中根路径下的文件列表
    this.localUploadFileUtil.getDirList().then((result: string[]) => {
      TCLogger.info(this.logTag, `Succeeded in listing files, result: ${JSON.stringify(result)}`);
      // 先删除列表
      this.localFiles = []
      result.forEach(directory => {
        this.localUploadFileUtil.getFileList(directory).then((res: string[]) => {
          TCLogger.info(this.logTag, `Succeeded in ${directory} listing files, result: ${JSON.stringify(res)}`);
          this.localFiles.push(...res)
        }).catch((err: BusinessError) => {
          TCLogger.info(this.logTag, `Failed to ${directory} list files, code: ${err.code}, message: ${err.message}`);
        })
      })
    }).catch((err: BusinessError) => {
      TCLogger.info(this.logTag, `Failed to list files, code: ${err.code}, message: ${err.message}`);
    })
  }

  // 上传指定文件至云侧
  upload() {
    this.selectPhoto().then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      let fileUri = photoSelectResult.photoUris[0];
      // 解决中文文件名乱码
      fileUri = decodeURIComponent(fileUri)
      TCLogger.info(this.logTag, `pick file ${fileUri}`);
      let fileName = fileUri.split('/').pop() as string;
      TCLogger.info(this.logTag, `file name ${fileName}`);
      let cacheFile = GlobalContext.getUIAbilityContext().cacheDir + '/' + fileName;
      TCLogger.info(this.logTag, `cacheFile ${cacheFile}`);
      // 将选中文件copy至cache目录下
      this.localUploadFileUtil.copyFile(fileUri, cacheFile);
      // 上传至云存储默认实例
      this.localUploadFileUtil.uploadFile(cacheFile, `media/${fileName}`, fileUri).then((res: UploadFileStatus) => {
        TCLogger.info(this.logTag, `Succeeded in uploading file, result: ${JSON.stringify(res)}`);
        // 删除cache目录临时文件
        fs.unlink(cacheFile).catch((err: BusinessError) => {
          TCLogger.info(this.logTag, `Failed to unlink, code: ${err.code}, message: ${err.message}.`);
        });
      });
    }).catch((err: BusinessError) => {
      TCLogger.info(this.logTag, `Failed to upload file, code: ${err.code}, message: ${err.message}`);
    })
  }

  uploadDocumentFile() {
    let documentPicker = new picker.DocumentViewPicker(getContext());

    documentPicker
      .select({
        maxSelectNumber: 1,
        fileSuffixFilters: this.getFileSuffixArray(),
      })
      .then((documentSelectResult: Array<string>) => {
        TCLogger.info(this.logTag,
          'DocumentViewPicker.select successfully, uri: ' + JSON.stringify(documentSelectResult));
        let filePath: string = documentSelectResult[0];
        // 解决中文文件名乱码
        filePath = decodeURIComponent(filePath)
        TCLogger.info(this.logTag, `pick document file ${filePath}`);
        let fileName: string = filePath.split('/').pop() as string;
        TCLogger.info(this.logTag, `document file name ${fileName}`);
        let fileType: string = fileName.split('.')[fileName.split('.').length - 1];
        let cacheFile: string = GlobalContext.getUIAbilityContext().cacheDir + '/cache_document.' + fileType;
        TCLogger.info(this.logTag, `cacheFile document ${cacheFile}`);
        let timestamp: string =
          `${TimeUtil.getCurDate(TimeUtil.PATTERN_DATE_DEFAULT)}_${TimeUtil.getCurTime(TimeUtil.PATTERN_TIME_MS)}`;
        cacheFile = `${GlobalContext.getUIAbilityContext().cacheDir}/Document_${timestamp}.${fileType}`
        // fileName = `${fileName.split('.' + fileType)[0]}_${timestamp}.${fileType}`
        // 将选中文件copy至cache目录下
        this.localUploadFileUtil.copyFile(filePath, cacheFile).then(res => {
          if (res) {
            // 判断缓存文件是否存在
            this.localUploadFileUtil.isFileExist(cacheFile).then((res: boolean) => {
              if (res) {
                // 上传至云存储默认实例
                // this.uploadFile(cacheFile, `document/${fileName}`);
                this.localUploadFileUtil.uploadFile(cacheFile, `document/${fileName}`, filePath)
                  .then((res: UploadFileStatus) => {
                    TCLogger.info(this.logTag, `Succeeded in uploading document file, result: ${JSON.stringify(res)}`);
                    // 删除cache目录临时文件
                    fs.unlink(cacheFile).catch((err: BusinessError) => {
                      TCLogger.info(this.logTag, `Failed to unlink, code: ${err.code}, message: ${err.message}.`);
                    });
                  });
                TCLogger.info(this.logTag, 'Upload document To Server');
              } else {
                promptAction.showToast({
                  message: '上传失败，缓存文件不存在',
                })
              }
            })

          } else {
            promptAction.showToast({
              message: '上传失败，文件为空',
            })
          }
        });

      }).catch((err: BusinessError) => {
      TCLogger.error(this.logTag, 'DocumentViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  }

  getFileSuffixArray(): Array<string> {
    let fileSuffixArray: Array<string> = [];
    for (let documentType of this.documentTypeArray) {
      switch (documentType) {
        case DocumentType.PDF: {
          fileSuffixArray.push('文档|.pdf');
          break;
        }
        case DocumentType.TXT: {
          fileSuffixArray.push('文档|.txt');
          break;
        }
        case DocumentType.DOC: {
          fileSuffixArray.push('文档|.doc');
          break;
        }
        case DocumentType.DOCX: {
          fileSuffixArray.push('文档|.docx');
          break;
        }

        case DocumentType.XLS: {
          fileSuffixArray.push('文档|.xls');
          break;
        }
        case DocumentType.XLSX: {
          fileSuffixArray.push('文档|.xlsx');
          break;
        }
        case DocumentType.PPT: {
          fileSuffixArray.push('文档|.ppt');
          break;
        }
        case DocumentType.PPTX: {
          fileSuffixArray.push('文档|.pptx');
          break;
        }
        default: {
          break;
        }
      }
    }
    return fileSuffixArray;
  }

  /**
   * @throws photoViewPicker select throws
   */
  selectPhoto(): Promise<photoAccessHelper.PhotoSelectResult> {
    // 使用photoAccessHelper选择指定的文件
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE; // 过滤选择媒体文件类型为IMAGE_VIDEO_TYPE
    photoSelectOptions.maxSelectNumber = 1; // 选择媒体文件的最大数目
    let photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    return photoViewPicker.select(photoSelectOptions);
  }
}