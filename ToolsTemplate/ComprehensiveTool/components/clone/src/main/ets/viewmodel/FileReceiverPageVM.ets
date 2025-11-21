import { MainFile, TransferState } from '../common/Constant';

@ObservedV2
export class FileReceiverPageVM {
  private static _instance: FileReceiverPageVM
  @Trace contact: MainFile = new MainFile()
  @Trace image: MainFile = new MainFile()
  @Trace video: MainFile = new MainFile()
  @Trace progressList: number[] = [0, 0, 0]
  @Trace stateList: TransferState[] = [TransferState.BEFORE, TransferState.BEFORE, TransferState.BEFORE]
  @Trace state: TransferState = TransferState.BEFORE

  public static get instance() {
    if (!FileReceiverPageVM._instance) {
      FileReceiverPageVM._instance = new FileReceiverPageVM();
    }
    return FileReceiverPageVM._instance;
  }

  clear() {
    this.contact = new MainFile()
    this.image = new MainFile()
    this.video = new MainFile()
    this.progressList = [0, 0, 0]
    this.stateList = [TransferState.BEFORE, TransferState.BEFORE, TransferState.BEFORE]
    this.state = TransferState.BEFORE
  }

  checkIsTransferAll() {
    if (this.image.recvSize === this.image.fileSize && this.video.recvSize === this.video.fileSize) {
      this.state = TransferState.AFTER
    }
  }
}
