import { common } from '@kit.AbilityKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { LoadingDialog } from '@kit.ArkUI';
import { MyScrollModifier, RouterMap, RouterModule, Logger } from 'commonlib';
import { PRESETS, CustomFilter, BeautyParam } from 'photo_editing';


@ComponentV2
export struct HomePage {
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier();
  @Local isShow: boolean = false;
  @Local photoSelectOptions: photoAccessHelper.PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
  @Local photoViewPicker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
  context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  loadingController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      content: '图片加载中...',
    }),
    autoCancel: false,
  });

  aboutToAppear(): void {
    AppStorage.setOrCreate('id_x', '1');
    this.photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    this.photoSelectOptions.isEditSupported = false;
    this.photoSelectOptions.maxSelectNumber = 1;
  }

  beautyRouterByIndex(index: number, filterName?: string) {
    try {
      // 选择图片并获取图片URI
      this.photoViewPicker.select(this.photoSelectOptions)
        .then((result: photoAccessHelper.PhotoSelectResult) => {
          if (result.photoUris.length > 0) {
            this.loadingController.open();
            let resFile: fs.File = fs.openSync(result.photoUris[0], fs.OpenMode.READ_ONLY);
            try {
              const imageSource: image.ImageSource = image.createImageSource(resFile.fd);
              imageSource.createPixelMap().then((result: PixelMap) => {
                this.loadingController.close();
                let param: BeautyParam = {
                  pixelMap: result,
                  uris: [],
                  barIndex: index,
                  filterName: filterName,
                };
                RouterModule.push({ url: RouterMap.PICTURE_BEAUTIFICATION, param: param });
              });
            } catch (err) {
              Logger.error('init data failed with error message: ' + err.message + ', error code: ' + err.code);
            } finally {
              fs.closeSync(resFile);
            }
          }
        })
        .catch((err: BusinessError) => {
          Logger.error(`PhotoViewPicker.select failed with err: ${err.code}, ${err.message}`);
        });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
    }
  }

  build() {
    Column({ space: 12 }) {
      this.titleBuilder();
      Row({ space: 8 }) {
        Image($r('app.media.ic_editing')).size({ height: 48, width: 48 });
        Text('图片美化')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Body_L'));
      }
      .onClick(() => {
        this.beautyRouterByIndex(-1);
      })
      .padding(24)
      .borderRadius(16)
      .backgroundColor($r('sys.color.multi_color_aux_01'))
      .width('100%')
      .height(104)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center);

      Row({ space: 8 }) {
        Image($r('app.media.ic_camera_beautify')).size({ height: 48, width: 48 });
        Text('相机')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Body_L'));
      }
      .width('100%')
      .height(104)
      .borderRadius(16)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('sys.color.multi_color_02'))
      .onClick(() => {
        if (deviceInfo.productModel === 'emulator') {
          this.getUIContext().getPromptAction().showToast({ message: '本功能不支持模拟器！' });
        } else {
          RouterModule.push({ url: RouterMap.LUT_CAMERA_PAGE });
        }
      });

      Text('热门滤镜').fontSize(18).fontWeight(FontWeight.Bold).width('100%').textAlign(TextAlign.Start);

      Grid() {
        ForEach(PRESETS.filter(item => item.isHot), (item: CustomFilter) => {
          GridItem() {
            Stack({ alignContent: Alignment.Bottom }) {
              Image(item.image).height(138).width('100%').borderRadius(16);
              Text(item.name)
                .padding({ bottom: 12 })
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_on_primary'));
            }.onClick(() => {
              this.beautyRouterByIndex(0, item.name);
            });
          };
        }, (item: CustomFilter) => item.name);
      }
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .height(138);
    }
    .width('100%').height('100%').padding(16)
    .height('100%');

  }

  /**
   * 导航标题
   */
  @Builder
  titleBuilder() {
    Row() {
      Text($r('app.string.home'))
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .height($r('app.float.vp_56'))
        .width('100%');
    };
  }
}

@Builder
export function HomePageBuilder() {
  HomePage();
}
