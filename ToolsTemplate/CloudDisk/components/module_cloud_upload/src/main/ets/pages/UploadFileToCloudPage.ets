import { UploadFileToComponent } from '../components/UploadFileComponent'
import { DocumentType } from '../model/DocumentTypeClass'

/**
 * @usage: 上传文件到云盘页面组件，提供文件上传到云端存储的完整界面。关键数据结构包括FileInfo文件信息、UploadFileStatus上传状态、
 * UploadFileStatusCode状态码。包含文件选择、上传进度、状态管理等逻辑。
 * @layout: 垂直布局，顶部为标题栏和返回按钮，中间为上传文件列表，每个文件项显示名称、大小、上传进度和状态，底部为操作按钮区域。
 * @constraints: fileList文件列表不能为空，上传状态必须正确更新，网络连接必须稳定，云盘存储空间必须充足
 * @isGen: true
 * @fileType: page
 * @zhName: 上传文件到云盘页面组件
 * @subPage:
 * @component: List,ListItem,Image,Text,Progress,Button,Row,Column
 * @modifiable: 上传进度样式可定制，文件列表项布局可调整，操作按钮样式可配置
 * @image:
 */
@ComponentV2
struct UploadFileToCloudPage {
  build() {
    Column() {
      UploadFileToComponent({
        documentTypeArray: [
          DocumentType.PDF,
          DocumentType.TXT,
          DocumentType.DOCX,
          DocumentType.PPTX,
          DocumentType.XLSX,
          DocumentType.DOC,
          DocumentType.DOCX,
        ]
      })
    }
    .padding({
      top: 100
    })
    .width('100%')
    .height('100%')
  }
}