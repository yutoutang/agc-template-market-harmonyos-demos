import { fileIo as fs, picker } from '@kit.CoreFileKit';
import { ResumeEntity } from '../model/ResumeEntity';
import { BusinessError } from '@kit.BasicServicesKit';
import { getCurrentLocalTime } from '../utils/DateUtil';
import { ResumeComponent } from './ResumeComponent';
import { AttachmentDatabase } from '../model/AttachmentDatabase';
import { PersistenceV2, promptAction } from '@kit.ArkUI';
import { FileDataSource } from '../model/FileDataSource';
import { DocumentType } from '../../../../Index';
import { JSON } from '@kit.ArkTS';

@ComponentV2
export struct FileManagement {
  @Local attachmentDatabase: AttachmentDatabase =
    PersistenceV2.connect(AttachmentDatabase, () => new AttachmentDatabase())!;
  @Param @Require resumeData: FileDataSource<ResumeEntity>;
  @Param @Require buttonText: string;
  @Param @Require documentTypeArray: Array<DocumentType>;
  @Param limitCount: number = 0;

  build() {
    Column() {
      List({ space: 15 }) {
        LazyForEach(this.resumeData, (item: ResumeEntity, index: number) => {
          ResumeComponent({
            resume: item,
            remove: () => {
              let index = this.getIndexByUri(this.resumeData.getDataArray(), item.uri);
              this.attachmentDatabase.attachmentList.splice(index, 1);
              this.resumeData.deleteOneData(index);
            },
          })
            .height(80)
            .width('100%');
        }, (item: ResumeEntity, index: number) => `${item.uri}_${index}}`);

        ListItem() {
          if (this.limitCount > 0 && this.resumeData.totalCount() > 0) {
            Row() {
              Text(`最多支持上传${this.limitCount}份文件`)
                .fontSize(12)
                .fontColor('rgba(0,0,0,0.60)')
            }
            .justifyContent(FlexAlign.Start)
            .width('100%')
          }
        }
      }
      .height('90%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

      Blank();

      Button(this.buttonText)
        .width('100%')
        .margin({ bottom: 10 })
        .backgroundColor('#376BFC')
        .onClick(() => {

          if (this.limitCount > 0 && this.resumeData.totalCount() >= this.limitCount) {
            promptAction.showToast({
              message: `最多上传${this.limitCount}份文件哦 ~`,
              alignment: Alignment.Center
            })
            return;
          }

          try {
            let documentPicker = new picker.DocumentViewPicker(getContext());

            documentPicker
              .select({
                maxSelectNumber: 1,
                fileSuffixFilters: this.getFileSuffixArray(),
              })
              .then((documentSelectResult: Array<string>) => {
                let uri: string = documentSelectResult[0];

                let fileArray = uri.split('/');
                let fileName = fileArray[fileArray.length - 1];
                let suffix = '.' + fileName.split('.')[fileName.split('.').length - 1];

                // 从公共目录拷贝到沙箱
                let srcFile: fs.File = null!;
                let dstFile: fs.File = null!;
                try {
                  srcFile = fs.openSync(uri, fs.OpenMode.READ_ONLY);
                  let timestamp = getCurrentLocalTime();
                  let dstPath =
                    getContext(this).filesDir + '/' + encodeURIComponent(timestamp.replace(/\D/g, '') + suffix);

                  // 先创建有读写权限的文件，再把不可读写的文件复制过来
                  dstFile = fs.openSync(dstPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);

                  fs.copyFileSync(srcFile.fd, dstPath);

                  let stat = fs.statSync(dstPath);

                  let name = decodeURIComponent(fileName.split(suffix)[0]);

                  let newResume: ResumeEntity = new ResumeEntity();
                  newResume.name = name;
                  newResume.suffix = suffix;
                  newResume.uri = dstPath;
                  newResume.size = bytesToKb(stat.size) + 'KB';
                  newResume.updateTime = timestamp;

                  this.attachmentDatabase.attachmentList.push(newResume);
                  this.resumeData.pushData(newResume);
                } catch (e) {
                } finally {
                  fs.close(srcFile.fd);
                  if (dstFile) {
                    fs.close(dstFile.fd);
                  }
                }

              }).catch((err: BusinessError) => {
            });
          } catch (error) {
            let err: BusinessError = error as BusinessError;
          }
        });
    }
    .justifyContent(FlexAlign.Start)
    .padding({ top: '5%', left: '6%', right: '6%' })
    .width('100%')
    .height('100%')
    .layoutWeight(1)
  }

  private getIndexByUri(resumeList: Array<ResumeEntity>, uri: string): number {
    // 遍历任务列表
    for (let i = 0; i < resumeList.length; i++) {
      // 如果任务id相等
      if (resumeList[i].uri === uri) {
        // 返回索引
        return i;
      }
    }
    // 如果没有找到，返回-1
    return -1;
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
}

function bytesToKb(bytes: number, decimalPlaces: number = 2): number {
  return parseFloat((bytes / 1024).toFixed(decimalPlaces));
}
