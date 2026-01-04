import { BarVM, CommonHeader } from 'common';
import { DocumentType, FileDataSource, FileManagement, ResumeDataManager, ResumeEntity } from 'file_management';
import { phoneRouterControl } from 'oh_router';

@Builder
export function ResumeAttachmentPageBuilder() {
  ResumeAttachmentPage()
}

@Entry
@ComponentV2
struct ResumeAttachmentPage {
  // 使用单例模式，确保数据不会在页面销毁时丢失
  private resumeManager = ResumeDataManager.getInstance();
  @Local resumeData: FileDataSource<ResumeEntity> = this.resumeManager.resumeData;

  build() {
    NavDestination() {
      Column() {
        CommonHeader({
          title: '附件简历',
          backgroundColorParam: '#F1F3F5',
          onReturnClick: () => {
            phoneRouterControl.popPage();
          },
        }).padding({ left: 16, right: 16 })
        FileManagement({
          resumeData: this.resumeData,
          buttonText: '上传附件简历',
          documentTypeArray: [DocumentType.PDF, DocumentType.DOC, DocumentType.DOCX],
        })
      }
      .backgroundColor('#F1F3F5')
      .padding({
        top: BarVM.instance.staBarH,
        bottom: BarVM.instance.aiBarH,
      })
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}

