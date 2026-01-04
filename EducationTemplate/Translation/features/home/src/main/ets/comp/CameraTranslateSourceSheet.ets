/**
 * 图片来源选择弹窗组件
 */
import { common } from '@kit.AbilityKit';
import { ImagePickerUtil } from '../utils/ImagePickerUtil';

export interface ImageSourceSheetCallbacks {
  onImageSelected: (imageUri: string, source: 'camera' | 'album') => void;
  onDismiss: () => void;
}

@ComponentV2
export struct CameraTranslateSourceSheet {
  @Param callbacks: ImageSourceSheetCallbacks = {
    onImageSelected: () => {
    },
    onDismiss: () => {
    }
  };

  build() {
    Column() {
      // 拍照按钮
      Row() {
        Text('拍照')
          .fontSize(16)
          .fontColor('#1A1A1A')
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .onClick(() => {
        this.callbacks.onDismiss();
        this.takePicture();
      })

      // 从相册选择按钮
      Row() {
        Text('从相册选择')
          .fontSize(16)
          .fontColor('#1A1A1A')
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 12 })
      .onClick(() => {
        this.callbacks.onDismiss();
        this.selectFromAlbum();
      })

      // 取消按钮
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#666666')
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 12 })
      .onClick(() => {
        this.callbacks.onDismiss();
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 20 })
  }

  /**
   * 拍照
   */
  private async takePicture() {
    const context = getContext(this) as common.UIAbilityContext;
    const imageUri = await ImagePickerUtil.takePicture(context);

    if (imageUri) {
      this.callbacks.onImageSelected(imageUri, 'camera');
    }
  }

  /**
   * 从相册选择
   */
  private async selectFromAlbum() {
    const context = getContext(this) as common.UIAbilityContext;
    const imageUri = await ImagePickerUtil.selectFromAlbum(context);

    if (imageUri) {
      this.callbacks.onImageSelected(imageUri, 'album');
    }
  }
}
