import { util } from '@kit.ArkTS'
import { FileType } from '../common/Constant'

@ObservedV2
export class CompressedFile {
  @Trace id: string = util.generateRandomUUID(true)
  @Trace type: FileType = FileType.ZIP
  @Trace name: string = ''
  @Trace label: string = ''
  @Trace format: string = ''
  @Trace size: string = ''
  @Trace count: number = 0
  @Trace updatedTime: string = ''
  @Trace isSelected: boolean = false

  constructor(type: FileType, name: string, label: string, format: string, size: string, count: number,
    updatedTime: string) {
    this.type = type
    this.name = name
    this.label = label
    this.format = format
    this.size = size
    this.count = count
    this.updatedTime = updatedTime
  }
}