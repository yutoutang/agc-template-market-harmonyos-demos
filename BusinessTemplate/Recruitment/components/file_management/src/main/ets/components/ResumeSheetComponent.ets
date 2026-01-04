import { PersistenceV2, promptAction } from '@kit.ArkUI';
import { PositionInfo } from 'common';
import { ResumeDataManager } from '../manager/ResumeDataManager';
import { AttachmentDatabase } from '../model/AttachmentDatabase';
import { FileDataSource } from '../model/FileDataSource';
import { ResumeEntity } from '../model/ResumeEntity';
import { ResumeComponent } from './ResumeComponent';

@ComponentV2
export struct ResumeSheetComponent {
  private resumeManager = ResumeDataManager.getInstance();
  @Local resumeData: FileDataSource<ResumeEntity> = this.resumeManager.resumeData;
  @Local attachmentDatabase: AttachmentDatabase =
    PersistenceV2.connect(AttachmentDatabase, () => new AttachmentDatabase())!;
  @Param @Require positionData?: PositionInfo;
  @Param @Require onClose: () => void;
  @Param @Require onUpdateJobData: (resume?: ResumeEntity) => void;

  build() {
    Column() {
      Text('投递简历')
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding({
          left: 16,
          right: 16,
          top: 20,
          bottom: 16
        })

      Column() {
        // 在线简历
        ResumeComponent({
          pageContext: 'PositionDetailPage',
          resume: undefined,
          remove: () => {
          },
          submitResume: () => {
            if (this.positionData) {
              this.positionData.isApplied = true;
              promptAction.showToast({ message: '投递成功', duration: 2000 });
              this.onUpdateJobData();
              this.onClose();
            }
          },
          onClose: () => {
            this.onClose();
          }
        })
          .height(80)
          .margin({ bottom: 12 })
          .width('100%');
        List({ space: 12 }) {
          // 附件简历列表
          LazyForEach(this.resumeData, (item: ResumeEntity, index: number) => {
            ResumeComponent({
              pageContext: 'PositionDetailPage',
              resume: item,
              remove: () => {
                let index = this.getIndexByUri(this.resumeData.getDataArray(), item.uri);
                this.attachmentDatabase.attachmentList.splice(index, 1);
                this.resumeData.deleteOneData(index);
              },
              submitResume: (resume?: ResumeEntity) => {
                if (this.positionData) {
                  this.positionData.isApplied = true;
                  promptAction.showToast({ message: '投递成功', duration: 2000 });
                  this.onUpdateJobData(item);
                  this.onClose();
                }
              },
            })
              .height(80)
              .width('100%');
          }, (item: ResumeEntity, index: number) => `${JSON.stringify(item)}_${index}}`);
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }.width('100%').padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
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
}
