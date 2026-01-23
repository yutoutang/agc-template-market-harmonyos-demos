import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { TopBar, WaterMark, PermissionUtil, Logger } from 'commonlib';
import { XComponentContext } from 'libentry.so';
import { LutCameraPageVM } from '../viewmodel/LutCameraPageVM';
import { abilityAccessCtrl } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { LutModel } from '../model/Index';

@Builder
export function LutCameraPageBuilder() {
  LutCameraPage();
}


@ComponentV2
export struct LutCameraPage {
  @Local pixel: PixelMap | undefined = undefined;
  @Local arraybuffer: ArrayBuffer | undefined = undefined;
  // 滤镜图片像素
  @Local h: number | undefined = undefined;
  @Local w: number | undefined = undefined;
  vm: LutCameraPageVM = LutCameraPageVM.instance;
  mXComponentController: XComponentController = new XComponentController();
  private xComponentContext: XComponentContext | undefined = undefined;
  private uiContext = this.getUIContext();
  private atManager = abilityAccessCtrl.createAtManager();

  doRandBySync() {
    let rand = cryptoFramework.createRandom();
    let len = 18;
    try {
      let randData = rand.generateRandomSync(len);
      return randData.data;
    } catch (error) {
      return null;
    }
  }

  aboutToDisappear(): void {
    if (this.xComponentContext) {
      this.xComponentContext.StopCamera();
      this.xComponentContext = undefined;
    }
  }

  async requestPermissionsFn() {
    try {
      this.atManager.requestPermissionsFromUser(this.uiContext.getHostContext(), [
        'ohos.permission.CAMERA',
      ]).then(() => {
        // 首次初始化相机
        if (this.xComponentContext) {
          this.xComponentContext.StartCamera();
        }
      });
    } catch (err) {
      Logger.error(JSON.stringify(err));
    }
  }

  // 添加滤镜
  async addLut(lut: Resource) {
    this.getUIContext().getHostContext()?.resourceManager.getMediaContent(lut.id).then((data) => {
      let arrayBuffer = data.buffer.slice(data.byteOffset, data.byteLength + data.byteOffset);
      try {
        let imageSource: image.ImageSource = image.createImageSource(arrayBuffer);
        imageSource.getImageInfo((err, value) => {
          if (err) {
            return;
          }
          let opts: image.DecodingOptions = {
            editable: true,
            desiredSize: {
              height: value.size.height,
              width: value.size.width,
            },
            desiredPixelFormat: 3,
          };
          imageSource.createPixelMap(opts, async (err, pixelMap) => {
            // 这个回调的pixelMap就是当前图片的pixelMap
            this.pixel = pixelMap;
            this.pixel.getImageInfo().then((data) => {
              this.h = data.size.height;
              this.w = data.size.width;
            });
            this.arraybuffer = new ArrayBuffer(pixelMap.getPixelBytesNumber());
            this.pixel.readPixelsToBuffer(this.arraybuffer).then(() => {
              if (this.xComponentContext) {
                if (this.h && this.w && this.arraybuffer) {
                  this.xComponentContext.Lut(this.arraybuffer, this.w, this.h);
                }
              }
            });
          });
        });
      } catch (e) {
        Logger.error(JSON.stringify(e));
      }
    });
  }

  build() {
    NavDestination() {
      Row() {
        TopBar({ title: '相机' });
      }.width('100%').padding({ left: 16 });

      Stack() {
        Stack() {
          XComponent({
            id: `xcomponentId${this.doRandBySync()}`,
            type: XComponentType.SURFACE,
            libraryname: 'nativerender',
            controller: this.mXComponentController,
          }).width(this.vm.preWidth)
            .height(this.vm.preHeight)
            .backgroundColor(Color.Black)
            .onLoad(async (xComponentContext) => {
              this.xComponentContext = xComponentContext as XComponentContext;
              if (this.xComponentContext) {
                this.mXComponentController.setXComponentSurfaceRect({
                  surfaceWidth: this.uiContext.vp2px(this.vm.preWidth),
                  surfaceHeight: this.uiContext.vp2px(this.vm.preHeight),
                });
              }
            });

          Column({ space: 16 }) {
            Text('拍照').fontSize($r('sys.float.Subtitle_M')).fontColor($r('sys.color.font_on_primary')).lineHeight(21);
            Row() {
              Column({ space: 8 }) {
                Row() {
                  SymbolGlyph($r('sys.symbol.line_below_seal'))
                    .fontColor(this.vm.isShowWatermark ? [$r('sys.color.icon_on_primary')] :
                      [$r('sys.color.icon_primary')])
                    .fontSize(24);

                }
                .backgroundColor(this.vm.isShowWatermark ? $r('sys.color.multi_color_aux_06') : '#FFFFFF')
                .width(40)
                .height(40)
                .justifyContent(FlexAlign.Center)
                .borderRadius(20);

                Text('水印').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_on_primary')).lineHeight(19);

              }.onClick(() => {
                this.vm.isShowWatermark = !this.vm.isShowWatermark;
              });


              Image($r('app.media.ic_picture_camera')).width(68).height(68).onClick(async () => {
                if (this.vm.isShowWatermark) {
                  this.vm.markPixelMap = await this.getUIContext()
                    .getComponentSnapshot()
                    .get(this.vm.markId, { scale: 1, waitUntilRenderFinished: true });
                }
                if (this.xComponentContext) {
                  let buffer = this.xComponentContext.Photo();
                  if (buffer.byteLength === 0) {
                    this.getUIContext().getPromptAction().showToast({ message: '相机还未准备好请稍后' });
                    return;
                  }
                  this.vm.handlePhoto(buffer, this.getUIContext());
                }
              });


              Column({ space: 8 }) {
                Row() {
                  SymbolGlyph($r('sys.symbol.camera_filters'))
                    .fontColor(this.vm.isLut ? [$r('sys.color.icon_on_primary')] : [$r('sys.color.icon_primary')])
                    .fontSize(24);
                }
                .backgroundColor(this.vm.isLut ? $r('sys.color.multi_color_aux_06') : '#FFFFFF')
                .width(40)
                .height(40)
                .justifyContent(FlexAlign.Center)
                .borderRadius(20);

                Text('滤镜').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_on_primary')).lineHeight(19);

              }.onClick(() => {
                this.vm.isLut = true;
              });

            }.height(84).padding({ left: 16, right: 16 }).justifyContent(FlexAlign.SpaceAround).width('100%');

          }.width('100%');


          if (this.vm.isShowWatermark) {
            WaterMark({ markId: this.vm.markId }).margin({ left: 16, right: 16, bottom: 176 });
          }
        }.width(this.vm.preWidth)
        .height(this.vm.preHeight)
        .alignContent(Alignment.Bottom)
        .position({ top: 0 });

      }.width(this.vm.preWidth)
      .height(this.vm.preHeight).layoutWeight(1).onSizeChange((oldSize, newSize) => {
        this.vm.containerWidth = newSize.width as number;
        this.vm.containerHeight = newSize.height as number;
        this.vm.handlePreSize();
        if (this.xComponentContext && this.vm.containerWidth > 0 && this.vm.containerHeight > 0) {
          this.mXComponentController.setXComponentSurfaceRect({
            surfaceWidth: this.uiContext.vp2px(this.vm.preWidth),
            surfaceHeight: this.uiContext.vp2px(this.vm.preHeight),
          });
          this.xComponentContext.RestartCamera();
        }
      });

      if (this.vm.isLut) {
        Column({ space: 16 }) {
          Image($r('app.media.xmark')).width(24).height(24).alignSelf(ItemAlign.End).onClick(() => {
            this.vm.isLut = false;
          });

          List({ space: 20 }) {
            ListItem() {
              Column({ space: 4 }) {
                Image($r('app.media.ic_origin')).width(50).height(68);
                Text('还原').fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'));
              };
            }.onClick(() => {
              if (this.xComponentContext) {
                this.xComponentContext.DeleteBW();
                this.vm.isLut = false;
                this.vm.lutIndex = -1;
              }
            });

            ForEach(this.vm.lutList, (item: LutModel, index) => {
              ListItem() {
                Stack() {
                  Column({ space: 4 }) {
                    Stack() {
                      Image(item.icon).width(50).height(68);
                      if (this.vm.lutIndex === index) {
                        Column() {
                          Image($r('app.media.checkmark_circle')).width(24);
                        }
                        .width('100%')
                        .height(68)
                        .justifyContent(FlexAlign.Center)
                        .backgroundColor('rgba(0, 0, 0, 0.3)')
                        .borderRadius(8);
                      }
                    }.width(50).height(68);

                    Text(item.label).fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'));
                  };

                };

              }.onClick(() => {
                this.addLut(item.lut);
                this.vm.lutIndex = index;
                this.vm.isLut = false;
              });
            }, (item: LutModel) => item.id);
          }.listDirection(Axis.Horizontal).width('100%').height(88)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true });

        }
        .width('100%')
        .borderRadius({ topLeft: 16, topRight: 16 })
        .padding({
          left: 16,
          right: 16,
          top: 12,
          bottom: 12,
        })
        .position({ bottom: 0 })
        .backgroundColor('#FFFFFF');
      }

    }.hideTitleBar(true)
    .onWillShow(async () => {
      this.vm.hasPermission = await PermissionUtil._checkPermissions('ohos.permission.CAMERA');
      if (!this.vm.hasPermission) {
        await this.requestPermissionsFn();
      } else {
        if (this.xComponentContext) {
          this.xComponentContext.StartCamera();
        }
      }
    });

  }
}