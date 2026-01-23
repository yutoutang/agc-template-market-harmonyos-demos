import { getMedia } from '@agctemplate/resources';
import { Logger } from '@agctemplate/utils';
import { MinePageVM } from '@agctemplate/widgets';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import fs from '@ohos.file.fs';

const TAG = '[AvatarButton]';

@ComponentV2
export struct AvatarButton {
  vm: MinePageVM = MinePageVM.instance;
  bundleName: string = AppStorage.get('bundleName')!

  build() {
    FunctionalButton({
      params: {
        openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
        label: '',
        styleOption: {
          styleConfig: new functionalButtonComponentManager.ButtonConfig()
            .type(ButtonType.Normal)
            .backgroundImage(this.vm.localInfo.avatar ? this.vm.localInfo.avatar :
              this.vm.userInfo.avatar === '' ? getMedia('app.media.user_login_img') :
                this.vm.userInfo.avatar)
            .backgroundImageSize(ImageSize.Cover)
            .backgroundColor(Color.Transparent)
            .width(80)
            .height(80)
            .borderRadius('50%'),
        },
      },
      controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((err, data) => {
        if (err) {
          Logger.error(TAG, err.code + '', err.message);
          return;
        }
        if (data.avatarUri) {
          let pathDir = this.getUIContext().getHostContext()!.filesDir;
          let file: fs.File = null!
          let file2: fs.File = null!
          try {
            file = fs.openSync(data.avatarUri, fs.OpenMode.READ_ONLY)
            file2 = fs.openSync(`${pathDir}/picture${data.avatarUri.slice(-9, -4)}.jpg`,
              fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
            fs.copyFileSync(file.fd, file2.fd)
          } catch (e) {
          } finally {
            fs.closeSync(file);
            fs.closeSync(file2);
          }
          this.vm.updateAvatar(`file://${this.bundleName}${pathDir}/picture${data.avatarUri.slice(-9, -4)}.jpg`);
          Logger.info(TAG, 'succeeded in choosing avatar');
        } else {
          Logger.error(TAG, 'Failed: the uri is empty.');
        }
      }),
    })
  }
}