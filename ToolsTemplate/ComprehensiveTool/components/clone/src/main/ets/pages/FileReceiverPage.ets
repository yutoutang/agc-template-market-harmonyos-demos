import { common } from '@kit.AbilityKit';
import { FileVo, SendType } from '../model/FileVo';
import { FileTransferCallback } from '../model/FileTransferCallback';
import { registerFileRecvTransferCallback } from '../service/FileReceiverService';
import { ContentBlock } from '../components/ContentBlock';
import { FileCountMessage } from '../model/BinaryProtocol';
import { FileReceiverPageVM } from '../viewmodel/FileReceiverPageVM';
import { FileType, TransferState, TransferType } from '../common/Constant';
import { BufferUtil } from '../utils/BufferUtil';
import { TransferSuccess } from '../components/TransferSuccess';
import { TransferError } from '../components/TransferError';
import { getInstance } from '../common/CommonRoute';

@ComponentV2
struct FileReceiverPage {
  vm: FileReceiverPageVM = FileReceiverPageVM.instance

  aboutToAppear(): void {
    registerFileRecvTransferCallback(this.getUIContext().getHostContext() as common.UIAbilityContext, {
      onBefore: (fileCount: FileCountMessage) => {
        this.vm.contact = fileCount.contact
        this.vm.image = fileCount.image
        this.vm.video = fileCount.video
      },
      onStart: (fileType) => {
        switch (fileType) {
          case FileType.CONTACT:
            this.vm.stateList[0] = TransferState.MIDDLE
            this.vm.contact.count = this.vm.contact.size
            break
          case FileType.IMAGE:
            this.vm.stateList[1] = TransferState.MIDDLE
            this.vm.image.count += 1
            break
          case FileType.VIDEO:
            this.vm.stateList[2] = TransferState.MIDDLE
            this.vm.video.count += 1
            break
        }
      },
      onProgress: (fileVo: FileVo, progress: number) => {
        const sendType: SendType = {
          type: fileVo.type,
          size: 0,
          count: 0,
        }
        switch (fileVo.type) {
          case FileType.CONTACT:
            this.vm.contact.recvSize = 0
            sendType.size = 0
            sendType.count = this.vm.contact.size
            this.vm.contact.count = this.vm.contact.size
            this.vm.stateList[0] = TransferState.AFTER
            break
          case FileType.IMAGE:
            this.vm.progressList[1] += progress
            this.vm.image.recvSize = this.vm.progressList[1]
            sendType.size = this.vm.progressList[1]
            sendType.count = this.vm.image.count
            if (this.vm.progressList[1] === this.vm.image.fileSize) {
              this.vm.stateList[1] = TransferState.AFTER
            }
            break
          case FileType.VIDEO:
            this.vm.progressList[2] += progress
            this.vm.video.recvSize = this.vm.progressList[2]
            sendType.size = this.vm.progressList[2]
            sendType.count = this.vm.video.count
            if (this.vm.progressList[2] === this.vm.video.fileSize) {
              this.vm.stateList[2] = TransferState.AFTER
            }
        }

        const sendTypeBuffer = BufferUtil.stringToArrayBuffer(JSON.stringify(sendType))
      },
      onComplete: async (fileVo: FileVo, fileData?: ArrayBuffer) => {
        this.vm.checkIsTransferAll()
      },
    } as FileTransferCallback)
  }

  aboutToDisappear(): void {
    this.vm.clear()
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          if (this.vm.contact.size !== 0) {
            ContentBlock({
              type: TransferType.Receive,
              state: this.vm.stateList[0],
              title: '联系人',
              mainFile: this.vm.contact,
              count: this.vm.contact.size,
              progress: '100%',
              img: $r('app.media.clone_contact'),
            })
          }

          if (this.vm.image.size !== 0) {
            ContentBlock({
              type: TransferType.Receive,
              state: this.vm.stateList[1],
              title: '图片',
              mainFile: this.vm.image,
              count: this.vm.image.count,
              progress: Math.floor(this.vm.progressList[1] / this.vm.image.fileSize * 100) + '%',
              img: $r('app.media.clone_image'),
            })
          }

          if (this.vm.video.size !== 0) {
            ContentBlock({
              type: TransferType.Receive,
              state: this.vm.stateList[2],
              title: '视频',
              mainFile: this.vm.video,
              count: this.vm.video.count,
              progress: Math.floor(this.vm.progressList[2] / this.vm.video.fileSize * 100) + '%',
              img: $r('app.media.clone_video'),
            })
          }

          if (this.vm.state === TransferState.AFTER) {
            TransferSuccess()
          }

          if (this.vm.state === TransferState.ERROR) {
            TransferError()
          }
        }
        .height(`calc(100% - 56vp)`)

        if (this.vm.state === TransferState.AFTER || this.vm.state === TransferState.ERROR) {
          Button('完成')
            .width('100%')
            .onClick(() => {
              getInstance().pop()
            })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })
    }
    .title('接收的资料')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

@Builder
export function FileReceiverPageBuilder() {
  FileReceiverPage();
}