import { LoginSheetUtils } from 'lib_account';
import { CommonConstants, Logger, RouterUtils, WindowModel } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import {
  CardSize,
  ComponentDetailTitle,
  DesktopViewModel,
  FutureWeatherInfo,
  WeatherCardInfo,
  WeatherCardParams,
  WoodenFishCardInfo,
  WoodenFishCardParams
} from '../viewmodels/DeskTopVM';
import { AppStorageV2, window } from '@kit.ArkUI';
import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { MockWallpaper, WallpaperServiceApi } from 'lib_wallpaper_api';
import { CityPage } from 'module_city_manage';
import { formBindingData, formProvider } from '@kit.FormKit';
import { common } from '@kit.AbilityKit';
import { CleanData } from '../utils';
import { util } from '@kit.ArkTS';
import { DecompressionToolPageVM, WeatherCard, WoodenFishCard } from 'module_waterflow';

const TAG = 0x0000;

@Builder
export function ComponentDetailPageBuilder() {
  ComponentDetailPage()
}

@ComponentV2
struct ComponentDetailPage {
  @Local title: string = '组件详情'
  stack: NavPathStack = RouterUtils.getStack();
  @Local vm: DesktopViewModel = new DesktopViewModel();
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local cardSize: CardSize = { type: 'weather', size: 'small' };
  @Local cardWeatherInfo: WeatherCardInfo =
    new WeatherCardInfo({
      location: '南京',
      weather: '晴',
      temp: '19',
      highTemp: '23',
      lowTemp: '15',
      futureWeather: [({
        date: MockWallpaper.getFutureDates()[0],
        weather: '晴',
        lowTemp: '24',
        highTemp: '28'
      } as FutureWeatherInfo),
        ({
          date: MockWallpaper.getFutureDates()[1],
          weather: '多云',
          lowTemp: '18',
          highTemp: '25'
        } as FutureWeatherInfo),
        ({
          date: MockWallpaper.getFutureDates()[2],
          weather: '雨',
          lowTemp: '15',
          highTemp: '23'
        } as FutureWeatherInfo),
        ({
          date: MockWallpaper.getFutureDates()[3],
          weather: '多云',
          lowTemp: '20',
          highTemp: '26'
        } as FutureWeatherInfo)
      ]
    })
  @Local cardWoodenFishInfo: WoodenFishCardInfo = new WoodenFishCardInfo({ luckValue: 0, woodenFishTitle: '好运' })
  @Local backgroundIndex: number = -1;
  @Local textColorIndex: number = -1;
  @Local selectUris: string[] = [];
  @Local currentUri: string = '';
  @Local isPreviewVisible: boolean = false
  @Local isEditMyComponent: boolean = false
  @Local myComponentId: undefined | number = undefined
  @Local fullScreen: boolean = false;
  @Local isPlaySound: boolean = false
  @Local isFormId: boolean = false
  @Local tempFormId: string = '';
  @Local tempBase64: string = '';
  private context: Context = this.getUIContext().getHostContext()!;
  private backgroundColors: ResourceColor[] = [
    '#FFFFFF', '#000000', '#FFE52424', '#FFE56224', '#FFF6C800', '#FF63B959', '#FF48ADDD'
  ];
  private textColors: ResourceColor[] = [
    '#FFFFFF', '#000000', '#FFE52424', '#FFE56224', '#FFF6C800', '#FF63B959', '#FF48ADDD', '#5445EF'
  ];
  private soundController: DecompressionToolPageVM = DecompressionToolPageVM.instance;

  @Builder
  ComponentCard() {
    if (this.cardSize.type === 'weather') {
      WeatherCard({
        cardSize: this.cardSize.size,
        location: this.cardWeatherInfo.location,
        temp: this.cardWeatherInfo.temp,
        weather: this.cardWeatherInfo.weather,
        backgroundColorInfo: this.cardWeatherInfo.backgroundColorInfo,
        textColor: this.cardWeatherInfo.textColor,
        futureWeatherColor: this.cardWeatherInfo.futureWeatherColor,
        highTemp: this.cardWeatherInfo.highTemp,
        lowTemp: this.cardWeatherInfo.lowTemp,
        backgroundImg: this.cardWeatherInfo.backgroundImg,
        futureWeather: this.cardWeatherInfo.futureWeather
      })
    } else if (this.cardSize.type === 'woodenFish') {
      WoodenFishCard({
        cardSize: this.cardSize.size,
        woodenFishTitle: this.cardWoodenFishInfo.woodenFishTitle,
        luckValue: this.cardWoodenFishInfo.luckValue,
        backgroundColorInfo: this.cardWoodenFishInfo.backgroundColorInfo,
        textColor: this.cardWoodenFishInfo.textColor,
        backgroundImg: this.cardWoodenFishInfo.backgroundImg,
        controller: this.soundController,
      })
        .onClick(() => {
          this.cardWoodenFishInfo.luckValue++
          this.soundController.knock();
          if (this.cardWoodenFishInfo.soundEffect) {
            this.soundController.playSound()
          }
        })
    }
  }

  async readUserPhoto2base64(url: string, baseCallBack: (base64String: string) => void) {
    let file: fs.File | null = null;
    try {
      file = fs.openSync(url, fs.OpenMode.READ_ONLY)
      let stat = fs.statSync(file.fd)
      let arrayBuffer = new ArrayBuffer(stat.size)
      fs.readSync(file.fd, arrayBuffer)
      let base64Helper = new util.Base64Helper();
      let base64String = base64Helper.encodeToStringSync(new Uint8Array(arrayBuffer));
      baseCallBack(base64String)
    } finally {
      if (file) {
        fs.closeSync(file);
      }
    }
  }

  getUri() {
    this.tempFormId = this.vm.formCardRouter.formId
    try {
      let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.isEditSupported = false;
      photoSelectOptions.maxSelectNumber = 1;
      photoSelectOptions.isEditSupported = true;
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select(photoSelectOptions).then(async (photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
        if (photoSelectResult.photoUris.length > 0) {
          this.selectUris.push(photoSelectResult.photoUris[0]);
          this.currentUri = photoSelectResult.photoUris[0];
          if (this.selectUris.length > 0) {
            let file: fs.File | null = null;
            let file2: fs.File | null = null;
            try {
              // 存入沙箱
              file = fs.openSync(this.currentUri, fs.OpenMode.READ_ONLY)

              let fileName = this.context.filesDir + '/' + Date.now() + 'picture.jpg'

              file2 = fs.openSync(fileName, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)

              fs.copyFileSync(file.fd, file2.fd)

              fileName = 'file://' + fileName;
              if (this.cardSize.type === 'weather') {
                this.cardWeatherInfo.backgroundColorInfo = ''
                this.cardWeatherInfo.backgroundImg = fileName
                this.readUserPhoto2base64(fileName, (base64String: string) => {
                  this.cardWeatherInfo.backgroundImgBase64 = base64String
                })
              } else if (this.cardSize.type === 'woodenFish') {
                this.cardWoodenFishInfo.backgroundImg = fileName
                this.cardWoodenFishInfo.backgroundColorInfo = ''
                this.readUserPhoto2base64(fileName, (base64String: string) => {
                  this.cardWoodenFishInfo.backgroundImgBase64 = base64String
                })
              }

              this.vm.formCardRouter.formId = this.tempFormId
              this.backgroundIndex = -1
              hilog.info(TAG, 'fileName', fileName)
            } catch (error) {
              let err: BusinessError = error as BusinessError;
              hilog.error(TAG, 'PhotoViewPicker', `PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
            } finally {
              if (file) {
                fs.closeSync(file);
              }
              if (file2) {
                fs.closeSync(file2);
              }
            }
          }
        }
      }).catch((err: BusinessError) => {
        hilog.error(TAG, 'PhotoViewPicker', `PhotoViewPicker.select failed with err: ${err.code}, ${err.message}`);
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      hilog.error(TAG, 'PhotoViewPicker', `PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
    }
  }

  getPreviewImage() {
    switch (`${this.cardSize.type},${this.cardSize.size}`) {
      case 'weather,small':
        return $r('app.media.small_weather')
      case 'weather,medium':
        return $r('app.media.medium_weather')
      case 'weather,large':
        return $r('app.media.large_weather')
      case 'woodenFish,small':
        return $r('app.media.small_woodenfish')
      case 'woodenFish,medium':
        return $r('app.media.medium_woodenfish')
      case 'woodenFish,large':
        return $r('app.media.large_woodenfish')
      default:
        return '';
    }
  }

  addMyComponent() {
    if (!this.isEditMyComponent) {
      if (this.cardSize.size === 'small') {
        WallpaperServiceApi.addSmallMyComponent({
          type: this.cardSize.type,
          cardSize: this.cardSize.size,
          data: this.cardSize.type === 'weather' ? JSON.parse(CleanData.stringifyTraceObj(this.cardWeatherInfo)) :
          JSON.parse(CleanData.stringifyTraceObj(this.cardWoodenFishInfo))
        })
      } else if (this.cardSize.size === 'medium') {
        WallpaperServiceApi.addMediumMyComponent({
          type: this.cardSize.type,
          cardSize: this.cardSize.size,
          data: this.cardSize.type === 'weather' ? JSON.parse(CleanData.stringifyTraceObj(this.cardWeatherInfo)) :
          JSON.parse(CleanData.stringifyTraceObj(this.cardWoodenFishInfo))
        })
      } else if (this.cardSize.size === 'large') {
        WallpaperServiceApi.addLargeMyComponent({
          type: this.cardSize.type,
          cardSize: this.cardSize.size,
          data: this.cardSize.type === 'weather' ? JSON.parse(CleanData.stringifyTraceObj(this.cardWeatherInfo)) :
          JSON.parse(CleanData.stringifyTraceObj(this.cardWoodenFishInfo))
        })
      }
      this.getUIContext().getPromptAction().showToast({ message: '已保存到我的组件', alignment: Alignment.Center })
    } else {
      this.updateComponent()
      this.getUIContext().getPromptAction().showToast({ message: '已保存编辑', alignment: Alignment.Center })
    }
    this.vm.editJumpMyComponent()
  }

  updateComponent() {
    if (this.cardSize.size === 'small') {
      WallpaperServiceApi.updateSmallMyComponent(
        this.myComponentId!,
        {
          type: this.cardSize.type,
          cardSize:
          this.cardSize.size,
          data:
          this.cardSize.type === 'weather' ? JSON.parse(CleanData.stringifyTraceObj(this.cardWeatherInfo)) :
          JSON.parse(CleanData.stringifyTraceObj(this.cardWoodenFishInfo))
        })

    } else if (this.cardSize.size === 'medium') {
      WallpaperServiceApi.updateMediumMyComponent(
        this.myComponentId!,
        {
          type: this.cardSize.type,
          cardSize:
          this.cardSize.size,
          data:
          this.cardSize.type === 'weather' ? JSON.parse(CleanData.stringifyTraceObj(this.cardWeatherInfo)) :
          JSON.parse(CleanData.stringifyTraceObj(this.cardWoodenFishInfo))
        })
    } else if (this.cardSize.size === 'large') {
      WallpaperServiceApi.updateLargeMyComponent(
        this.myComponentId!,
        {
          type: this.cardSize.type,
          cardSize:
          this.cardSize.size,
          data:
          this.cardSize.type === 'weather' ? JSON.parse(CleanData.stringifyTraceObj(this.cardWeatherInfo)) :
          JSON.parse(CleanData.stringifyTraceObj(this.cardWoodenFishInfo))
        }
      )
    }
  }

  async aboutToAppear() {
    try {
      this.soundController.init()
      const win = await window.getLastWindow(this.context);
      win.setWindowLayoutFullScreen(true);
      this.fullScreen = true;
    } catch (error) {
      Logger.error('[ComponentDetailPage]', 'open dialog failed. error:' + JSON.stringify(error));
    }
  }

  aboutToDisappear(): void {
    this.soundController.clear()
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          this.buildTitle()
          this.buildComponentCard()
          this.buildPreview()
          this.buildButton()
        }
        .padding({
          bottom: this.windowModel.windowBottomPadding
        })
        .height(CommonConstants.FULL_PERCENT)
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor($r('sys.color.background_secondary'))

        this.buildPreviewImage()
      }
    }
    .hideTitleBar(true)
    .onHidden(() => {
      this.vm.formCardRouter.formId = ''
    })
    .onWillShow(() => {
      if (this.vm.formCardRouter.formId && !this.isFormId) {
        this.cardSize = { type: this.vm.formCardRouter.cardType, size: this.vm.formCardRouter.cardSize };
        this.title =
          `${this.vm.formCardRouter.cardType === 'weather' ? '天气' : '木鱼'} - ${this.vm.formCardRouter.cardSize ===
            'small' ? '小' :
            this.vm.formCardRouter.cardSize === 'large' ? '大' : '中'}`;
        this.myComponentId = Number(this.vm.formCardRouter.cardId)
        if (this.vm.formCardRouter.cardType === 'weather') {
          this.cardWeatherInfo = new WeatherCardInfo(JSON.parse(this.vm.formCardRouter.cardInfo) as WeatherCardParams);
        }
      }
    })
    .onReady((context: NavDestinationContext) => {
      this.stack = context.pathStack;
      if (context?.pathInfo?.param) {
        const params = context.pathInfo.param as ComponentDetailTitle;
        this.cardSize = { type: params.type, size: params.size };
        this.isEditMyComponent = params.isMyComponent || false;
        if (params.isMyComponent) {
          this.myComponentId = params.id;
          if (params.type === 'weather' && params.componentInfo) {
            this.cardWeatherInfo = new WeatherCardInfo(params.componentInfo as WeatherCardParams);
          }
          if (params.type === 'woodenFish' && params.componentInfo) {
            this.cardWoodenFishInfo = new WoodenFishCardInfo(params.componentInfo as WoodenFishCardParams);
          }
        }
        this.title = `${params.type === 'weather' ? '天气' : '木鱼'} - ${params.size === 'small' ? '小' :
          params.size === 'large' ? '大' : '中'}`;
      }
    })
    .onBackPressed(() => {
      if (this.isPreviewVisible) {
        this.isPreviewVisible = false;
        return true;
      } else {
        return false;
      }
    })
  }

  @Builder
  buildComponentCard() {
    Column({ space: CommonConstants.SPACE_M }) {
      Column() {
        Row() {
          Row()
            .layoutWeight(1)
          Row() {
            this.ComponentCard()
          }
          .layoutWeight(this.cardSize.size === 'small' ? 1 : this.cardSize.size === 'medium' ? 4 : 2)
          .aspectRatio(this.cardSize.size === 'medium' ? 2 : 1)

          Row()
            .layoutWeight(1)
        }
        .width(CommonConstants.FULL_PERCENT)
        .padding({
          top: 32,
          bottom: 24
        })
      }

      Scroll() {
        Column() {
          Column() {
            Text('自定义内容')
              .fontColor($r('sys.color.font_tertiary'))
              .fontWeight(FontWeight.Bold)
              .lineHeight(22)
              .height(22)
            Stack({ alignContent: Alignment.End }) {
              TextInput({ text: $$this.cardWoodenFishInfo.woodenFishTitle })
                .maxLength(6)
                .height(40)
                .borderRadius(20)
              Image($r('app.media.ic_woodenfish_text'))
                .width(24)
                .aspectRatio(1)
                .margin({
                  right: 16
                })
            }
            .margin({
              top: 20,
              bottom: 20
            })

            Row() {
              Text('点击音效')
                .fontColor($r('sys.color.font_tertiary'))
                .fontWeight(FontWeight.Bold)
                .lineHeight(22)
                .height(22)
              Toggle({ type: ToggleType.Switch, isOn: this.cardWoodenFishInfo.soundEffect })
                .selectedColor($r('sys.color.comp_background_emphasize'))
                .switchPointColor('#FFFFFF')
                .onChange((isOn: boolean) => {
                  this.cardWoodenFishInfo.soundEffect = isOn;
                })
            }
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .visibility(this.cardSize.type === 'woodenFish' ? Visibility.Visible : Visibility.None)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .padding(16)
          .width(CommonConstants.FULL_PERCENT)
          .alignItems(HorizontalAlign.Start)


          Row() {
            Text('地区')
              .fontSize(16)
              .lineHeight(19)
              .fontWeight(FontWeight.Bold)
            Row() {
              Text(this.cardWeatherInfo.location)
                .fontSize(16)
                .lineHeight(19)
                .margin({ right: 12 })
              Image($r('app.media.ic_public_arrow_right'))
                .width(16)
                .aspectRatio(1)
            }
            .onClick(() => {
              this.stack.pushPathByName(
                CityPage.MANAGED,
                { formId: this.vm.formCardRouter.formId, isFormId: this.vm.formCardRouter.formId ? true : false },
                (popRes: ESObject) => {
                  this.vm.formCardRouter.formId = popRes.result.formId;
                  this.cardWeatherInfo.location = popRes.result.name;
                  this.isFormId = popRes.result.isFormId;
                },
                true,
              )
            })
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(48)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween)
          .visibility(this.cardSize.type === 'weather' ? Visibility.Visible : Visibility.None)

          Row()
            .width(CommonConstants.FULL_PERCENT)
            .height(4)
            .backgroundColor($r('sys.color.background_fourth'))
            .visibility(this.cardSize.type === 'woodenFish' ? Visibility.Visible : Visibility.None)
          Column() {
            Text('背景')
              .fontSize(16)
              .lineHeight(19)
              .fontWeight(FontWeight.Bold)
              .height(48)
            Scroll() {
              Row({ space: CommonConstants.SPACE_XS }) {
                Button({ type: ButtonType.Normal, stateEffect: true }) {
                  Row({ space: CommonConstants.SPACE_XS }) {
                    Image($r('app.media.photo'))
                      .width(16)
                      .aspectRatio(1)
                    Text('相册')
                      .fontSize(10)
                  }
                }
                .backgroundColor($r('sys.color.comp_background_gray'))
                .borderRadius(6)
                .width(56)
                .height(36)
                .margin({ right: 4 })
                .onClick(() => this.getUri())

                ForEach(this.backgroundColors, (color: string, index) => {
                  Row() {
                    Row()
                      .borderRadius(4)
                      .width(30)
                      .aspectRatio(1)
                      .backgroundColor(color)
                      .border(index === 0 ? { width: 2, color: '#33000000' } : { width: 0 })
                  }
                  .onClick(() => {
                    this.backgroundIndex = index;
                    if (this.cardSize.type === 'weather') {
                      this.cardWeatherInfo.backgroundColorInfo = color;
                      this.cardWeatherInfo.backgroundImgBase64 = ''
                      this.cardWeatherInfo.backgroundImg = '';
                    } else if (this.cardSize.type === 'woodenFish') {
                      this.cardWoodenFishInfo.backgroundImg = '';
                      this.cardWoodenFishInfo.backgroundImgBase64 = '';
                      this.cardWoodenFishInfo.backgroundColorInfo = color;
                    }
                  })
                  .borderRadius(4)
                  .padding(2)
                  .border(this.backgroundIndex === index ? { width: 2, color: '#FF0A59F7' } : { width: 0 })
                }, (color: string, index) => color + '_' + index)

              }
              .margin({ top: 8 })
            }
            .width(CommonConstants.FULL_PERCENT)
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
          }
          .padding({ left: 16, right: 16 })
          .width(CommonConstants.FULL_PERCENT)
          .margin({ top: 10 })
          .alignItems(HorizontalAlign.Start)

          Column() {
            Text('字体颜色')
              .fontSize(16)
              .lineHeight(19)
              .fontWeight(FontWeight.Bold)
              .height(48)
            Scroll() {
              Row({ space: CommonConstants.SPACE_XS }) {
                ForEach(this.textColors, (color: string, index) => {
                  Row() {
                    Row()
                      .borderRadius(20)
                      .width(32)
                      .aspectRatio(1)
                      .backgroundColor(color)
                      .border(index === 0 ? { width: 2, color: '#33000000' } : { width: 0 })
                  }
                  .onClick(() => {
                    this.textColorIndex = index;
                    if (this.cardSize.type === 'weather') {
                      this.cardWeatherInfo.futureWeatherColor = color;
                      this.cardWeatherInfo.textColor = color;
                    } else if (this.cardSize.type === 'woodenFish') {
                      this.cardWoodenFishInfo.textColor = color;
                    }

                  })
                  .borderRadius(30)
                  .padding(2)
                  .border(this.textColorIndex === index ? { width: 2, color: '#FF0A59F7' } : { width: 0 })
                }, (color: string, index) => color + '_' + index)

              }
              .margin({ top: 8 })
            }
            .width(CommonConstants.FULL_PERCENT)
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
          }
          .width(CommonConstants.FULL_PERCENT)
          .padding(16)
          .margin({ top: 20 })
          .alignItems(HorizontalAlign.Start)
        }
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.Start)
        .backgroundColor($r('sys.color.comp_background_primary'))
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .align(Alignment.Top)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  buildPreview() {
    Row() {
      Column() {
        Image($r('app.media.preview'))
          .width(24)
          .aspectRatio(1)
        Text('预览')
      }
      .onClick(() => {
        this.isPreviewVisible = true;
      })

      Column() {
        Image($r('app.media.add_component'))
          .width(24)
          .aspectRatio(1)
        Text('添加到我的组件')
      }
      .onClick(() => {
        if (!this.vm.userInfoModel.isLogin) {
          LoginSheetUtils.open();
        } else {
          this.addMyComponent()
        }
      })
    }
    .visibility(this.vm.formCardRouter.formId ? Visibility.None : Visibility.Visible)
    .justifyContent(FlexAlign.SpaceAround)
    .width(CommonConstants.FULL_PERCENT)
    .height(48)
  }

  @Builder
  buildButton() {
    Row() {
      Button('保存编辑')
        .onClick(() => {
          if (!this.vm.userInfoModel.isLogin) {
            LoginSheetUtils.open();
          } else {
            this.updateComponent()
            if (this.cardSize.type === 'weather') {
              const data: Record<string, Object | undefined> = {
                'formId': this.vm.formCardRouter.formId,
                'cardId': this.myComponentId,
                'type': this.cardSize.type,
                'cardSize': this.cardSize.size,
                'weatherData': JSON.parse(CleanData.stringifyTraceObj(this.cardWeatherInfo))
              }
              const bindingData = formBindingData.createFormBindingData(data);
              Logger.info('this.vm.formCardRouter', this.vm.formCardRouter.formId, JSON.stringify(data))
              formProvider.updateForm(this.vm.formCardRouter.formId, bindingData).then(() => {
              }).catch((err: string) => {
              });
              let context = this.getUIContext()?.getHostContext() as common.UIAbilityContext;
              context.terminateSelf();
            } else if (this.cardSize.type === 'woodenFish') {
              const data: Record<string, Object | undefined> = {
                'formId': this.vm.formCardRouter.formId,
                'cardId': this.myComponentId,
                'type': this.cardSize.type,
                'cardSize': this.cardSize.size,
                'woodenFishData': JSON.parse(CleanData.stringifyTraceObj(this.cardWoodenFishInfo))
              }
              const bindingData = formBindingData.createFormBindingData(data);
              formProvider.updateForm(this.vm.formCardRouter.formId, bindingData).then(() => {
              }).catch((err: string) => {
              });
            }
          }
        })
    }
    .visibility(this.vm.formCardRouter.formId ? Visibility.Visible : Visibility.None)
    .justifyContent(FlexAlign.SpaceAround)
    .width(CommonConstants.FULL_PERCENT)
    .height(48)
  }

  @Builder
  buildTitle() {
    NavHeaderBar({
      title: this.title,
    })
  }

  @Builder
  buildPreviewImage() {
    if (this.isPreviewVisible) {
      Column() {
        Image(this.getPreviewImage())
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .backgroundColor(Color.Black)
          .onClick(() => {
            this.isPreviewVisible = false
          })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .backgroundColor(Color.Black)
    }
  }
}