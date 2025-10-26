import { common } from '@kit.AbilityKit';
import { FileVo } from '../model/FileVo';
import { FileUploadPageVM } from '../viewmodel/FileUploadPageVM';
import { ContentBlock } from '../components/ContentBlock';
import { registerFileSendTransferCallback, sendFileCount } from '../service/FileSendService';
import { TcpClient } from '../service/TcpClient';
import { MainFile, TransferState } from '../common/Constant';
import { getInstance } from '../common/CommonRoute';
import { TransferSuccess } from '../components/TransferSuccess';
import { TransferError } from '../components/TransferError';

@ComponentV2
export struct FileUploadPage {
  vm: FileUploadPageVM = FileUploadPageVM.instance
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext

  aboutToAppear(): void {
    this.vm.context = this.context
    this.vm.getCloneFiles()
    registerFileSendTransferCallback({
      onProgress: (fileVo: FileVo, progress: number) => {
      },
      onComplete: async (fileVo: FileVo, fileData?: ArrayBuffer) => {
      },
    })
  }

  aboutToDisappear(): void {
    this.vm.clear()
    TcpClient.close()
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          if (this.vm.contact.size !== 0) {
            ContentBlock({
              state: this.vm.stateList[0],
              title: '联系人',
              mainFile: this.vm.contact,
              img: $r('app.media.clone_contact'),
              count: this.vm.contact.size,
              progress: '100%',
              onChange: (value) => {
                if (value) {
                  this.vm.contact.isSelected = true
                } else {
                  this.vm.contact.isSelected = false
                }
                sendFileCount({
                  contact: this.vm.contact.isSelected ? this.vm.contact : new MainFile(),
                  image: this.vm.image,
                  video: this.vm.video,
                })
              },
            })
          }

          if (this.vm.image.size !== 0) {
            ContentBlock({
              state: this.vm.stateList[1],
              title: '图片',
              mainFile: this.vm.image,
              img: $r('app.media.clone_image'),
              count: this.vm.image.count,
              progress: Math.floor(this.vm.image.recvSize / this.vm.image.fileSize * 100) + '%',
              onChange: (value) => {
                if (value) {
                  this.vm.image.isSelected = true
                } else {
                  this.vm.image.isSelected = false
                }
                sendFileCount({
                  contact: this.vm.contact,
                  image: this.vm.image.isSelected ? this.vm.image : new MainFile(),
                  video: this.vm.video,
                })
              },
            })
          }

          if (this.vm.video.size !== 0) {
            ContentBlock({
              state: this.vm.stateList[2],
              title: '视频',
              mainFile: this.vm.video,
              img: $r('app.media.clone_video'),
              count: this.vm.video.count,
              progress: Math.floor(this.vm.video.recvSize / this.vm.video.fileSize * 100) + '%',
              onChange: (value) => {
                if (value) {
                  this.vm.video.isSelected = true
                } else {
                  this.vm.video.isSelected = false
                }
                sendFileCount({
                  contact: this.vm.contact,
                  image: this.vm.image,
                  video: this.vm.video.isSelected ? this.vm.video : new MainFile(),
                })
              },
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

        if (this.vm.state === TransferState.BEFORE) {
          Button('开始发送')
            .width('100%')
            .onClick(() => {
              this.vm.uploadFile()
            })
        } else if (this.vm.state === TransferState.AFTER || this.vm.state === TransferState.ERROR) {
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
    .title('选择要发送的资料')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

@Builder
export function FileUploadPageBuilder() {
  FileUploadPage()
}