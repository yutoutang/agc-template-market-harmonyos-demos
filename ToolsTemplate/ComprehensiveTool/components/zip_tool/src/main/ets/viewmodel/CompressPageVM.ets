import { promptAction } from '@kit.ArkUI';
import { getInstance } from '../common/CommonRoute';
import { CompressedFile } from '../model/ZipModel';
import { compress, decompress, getFolderList, readCompressedFile, writeToSandbox } from '../utils/CompressUtil';
import { common } from '@kit.AbilityKit';
import { fileUri, picker } from '@kit.CoreFileKit';
import { filePreview } from '@kit.PreviewKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { formatFullDate } from '../utils/BaseUtil';

@ObservedV2
export class CompressPageVM {
  private static _instance: CompressPageVM
  @Trace context: common.UIAbilityContext | null = null
  @Trace titleBarName: string = ''
  @Trace originFolderPath: string = ''
  @Trace currentFolderPath: string = ''
  @Trace directory: string[] = []
  @Trace fileList: CompressedFile[] = []
  @Trace fileName: string = ''
  @Trace isShow: boolean = false
  @Trace isEdit: boolean = false
  @Trace showSetting: boolean = false
  @Trace needFreshCount: number = 0
  @Trace selectedIdList: string[] = []
  @Trace folderName: string = ''
  @Trace selectedFolderPath: string = ''
  @Trace documentSelectResult: string[] = []
  @Trace folderList: CompressedFile[] = []
  @Trace directoryStructure: string = '...'
  @Trace moveDirectory: string[] = []
  @Trace moveDialogPath: string = ''
  @Trace selectedCompressedFormat: string = 'zip'
  @Trace loading: boolean = false

  public static get instance() {
    if (!CompressPageVM._instance) {
      CompressPageVM._instance = new CompressPageVM();
    }
    return CompressPageVM._instance;
  }

  init(context: common.UIAbilityContext) {
    this.context = this.context
    let params = getInstance().getParamByName('CompressPage')[0] as string
    if (params && params === 'CompressPage') {
      this.currentFolderPath = context?.filesDir + '/zipDir'
      this.titleBarName = '压缩'
    } else {
      this.currentFolderPath = context?.filesDir + '/unzipDir'
      this.titleBarName = '解压'
    }
    this.originFolderPath = this.currentFolderPath
    this.fileList = readCompressedFile(this.currentFolderPath)
  }

  clear() {
    this.currentFolderPath = ''
    this.directory = []
    this.fileList = []
    this.fileName = ''
    this.isShow = false
    this.isEdit = false
    this.showSetting = false
    this.needFreshCount = 0
    this.selectedIdList = []
    this.selectedCompressedFormat = 'zip'
  }

  clearSelected() {
    this.needFreshCount = 0
    this.selectedIdList = []
    this.fileList = []
  }

  // 压缩
  async compressFile() {
    let filePath = ''
    if (this.selectedFolderPath) {
      filePath = `${this.selectedFolderPath}/${this.fileName}`
    } else {
      filePath = `${this.currentFolderPath}/${this.fileName}`
    }
    await writeToSandbox(filePath, this.documentSelectResult)
    this.fileList = await compress(filePath, this.currentFolderPath, this.selectedCompressedFormat)
    this.folderName = ''
    this.loading = false
  }

  // 解压
  async decompressFile() {
    let filePath = ''
    if (this.selectedFolderPath) {
      filePath = this.fileName ? `${this.selectedFolderPath}/${this.fileName}` : this.selectedFolderPath
    } else {
      filePath = this.fileName ? `${this.currentFolderPath}/${this.fileName}` : this.currentFolderPath
    }
    await writeToSandbox(filePath, this.documentSelectResult)
    const arr = this.documentSelectResult[0].split('/')
    const name = arr[arr.length - 1]
    this.fileList = await decompress(filePath, this.currentFolderPath, name)
    this.folderName = ''
    this.loading = false
  }

  // 检查文件名
  checkName(name: string) {
    if (!name) {
      promptAction.showToast({ message: '请输入文件名！' })
      return false
    }
    return true
  }

  // 目录返回
  goPageBack() {
    this.clearSelected()
    const index = this.currentFolderPath.lastIndexOf('/')
    if (index !== -1) {
      this.currentFolderPath = this.currentFolderPath.slice(0, index)
      this.fileList = readCompressedFile(this.currentFolderPath)
      this.directory.pop()
    }
  }

  // 目录跳转
  toPageDirectory(name: string) {
    this.clearSelected()
    this.directory.push(name)
    this.currentFolderPath = `${this.currentFolderPath}/${name}`
    this.fileList = readCompressedFile(this.currentFolderPath)
  }

  // 目录返回
  goBack() {
    const directoryIndex = this.directoryStructure.lastIndexOf('/')
    if (directoryIndex !== -1) {
      this.directoryStructure = this.directoryStructure.slice(0, directoryIndex)
    }
    const index = this.moveDialogPath.lastIndexOf('/')
    if (index !== -1) {
      this.moveDialogPath = this.moveDialogPath.slice(0, index)
      this.folderList = getFolderList(this.moveDialogPath)
      this.moveDirectory.pop()
    }
  }

  // 目录跳转
  toDirectory(name: string) {
    this.directoryStructure += `/${name}`
    this.moveDirectory.push(name)
    this.moveDialogPath = `${this.moveDialogPath}/${name}`
    this.folderList = getFolderList(this.moveDialogPath)
  }

  // 预览
  async preview(context: common.UIAbilityContext, data: CompressedFile) {
    let uri = fileUri.getUriFromPath(`${this.currentFolderPath}/${data.name}`)
    const res = await filePreview.canPreview(context, uri)
    if (!res) {
      promptAction.showToast({ message: '文件不可预览！' })
      return
    }
    let fileInfo: filePreview.PreviewInfo = {
      title: data.name,
      uri: uri,
      mimeType: '',
    };
    filePreview.openPreview(context, fileInfo).then(() => {
      console.info('Succeeded in opening preview');
    }).catch((err: BusinessError) => {
      console.error(`Failed to open preview, err.code = ${err.code}, err.message = ${err.message}`);
    });
  }

  // 选择
  pickerSelect() {
    const docSel = new picker.DocumentSelectOptions();
    const docPic = new picker.DocumentViewPicker();
    if (this.titleBarName === '压缩') {
      docPic.select(docSel).then(async (documentSelectResult: Array<string>) => {
        if (documentSelectResult.length <= 0) {
          return
        }
        this.documentSelectResult = documentSelectResult
        this.fileName = formatFullDate(new Date())
        this.selectedCompressedFormat = 'zip'
        this.isShow = true
      })
    } else {
      docSel.maxSelectNumber = 1
      docSel.fileSuffixFilters = ['.zip', '.rar', '.war', '.7z'];
      docPic.select(docSel).then(async (documentSelectResult: Array<string>) => {
        if (documentSelectResult.length <= 0) {
          return
        }
        const arr = documentSelectResult[0].split('.')
        if (!(arr[arr.length-1] === 'zip' || arr[arr.length-1] === 'rar' || arr[arr.length-1] === 'war' ||
          arr[arr.length-1] === '7z')) {
          promptAction.showToast({ message: '请选择后缀为zip、rar、war、7z的文件！' })
          return
        }
        this.documentSelectResult = documentSelectResult
        this.isShow = true
      })
    }
  }
}
