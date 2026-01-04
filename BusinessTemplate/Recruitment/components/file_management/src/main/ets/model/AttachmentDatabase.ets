
import { Type } from '@kit.ArkUI';
import { ResumeEntity } from './ResumeEntity';


@ObservedV2
export class AttachmentDatabase {
  @Type(ResumeEntity)
  @Trace attachmentList: Array<ResumeEntity> = [];
}
