import { CommonConstants, Logger } from 'lib_common';
import { DesktopViewModel, WeatherCardInfo } from '../viewmodels/DeskTopVM';
import { Card } from './DesktopComponentsPage';
import { WallpaperServiceApi } from 'lib_wallpaper_api';
import { WeatherCard, WoodenFishCard } from 'module_waterflow';
import { NavHeaderBar } from 'lib_widget';
import formProvider from '@ohos.app.form.formProvider';
import { formBindingData } from '@kit.FormKit';
import { JSON } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';

@Builder
export function MyComponentPageBuilder() {
  MyComponentPage()
}

@ComponentV2
struct MyComponentPage {
  @Local vm: DesktopViewModel = new DesktopViewModel();
  @Local smallCardData: Card[] = [];
  @Local mediumCardData: Card[] = [];
  @Local largeCardData: Card[] = [];
  @Local isEdit: boolean = false;

  @Builder
  rightHeadPartBuilder() {
    Row() {
      if (!this.isEdit) {
        Image($r('app.media.icon_edit'))
          .width(40)
          .aspectRatio(1)
      } else {
        Text('完成')
          .height(24)
          .fontColor($r('sys.color.font_emphasize'))
          .lineHeight(24)
      }
    }
    .visibility(this.vm.formCardRouter.formId ? Visibility.None : Visibility.Visible)
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
    .onClick(() => {
      this.isEdit = !this.isEdit
    })
  }

  @Builder
  builderToTutorial(cardSize: string, item: Card) {
    if (!this.isEdit) {
      Button($r('app.string.add_desktop'))
        .onClick(() => {
          if (!this.vm.formCardRouter.formId) {
            this.vm.jumpTutorial()
          } else {
            if (item.type === 'weather') {
              const data: Record<string, Object | undefined> = {
                'formId': this.vm.formCardRouter.formId,
                'type': item.type,
                'cardId': item.id,
                'weatherData': item.data,
                'cardSize': item.cardSize,
              }
              const bindingData = formBindingData.createFormBindingData(data);
              formProvider.updateForm(this.vm.formCardRouter.formId, bindingData).then(() => {
              }).catch((err: string) => {
              });
              let context = this.getUIContext()?.getHostContext() as common.UIAbilityContext;
              context.terminateSelf();
            } else if (item.type === 'woodenFish') {
              const data: Record<string, Object | undefined> = {
                'formId': this.vm.formCardRouter.formId,
                'cardSize': item.cardSize,
                'cardId': item.id,
                'type': item.type,
                'woodenFishData': item.data
              }
              const bindingData = formBindingData.createFormBindingData(data);
              formProvider.updateForm(this.vm.formCardRouter.formId, bindingData).then(() => {
              }).catch((err: string) => {
              });
              let context = this.getUIContext()?.getHostContext() as common.UIAbilityContext;
              context.terminateSelf();
            }
          }
        })
        .width('94%')
        .height(30)
        .fontColor($r('sys.color.font_emphasize'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius(20)
        .margin({ top: 6, bottom: 12 })
    } else {
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Image($r('app.media.delete'))
          .width(16)
          .aspectRatio(1)
      }
      .onClick(() => {
        this.getUIContext().showAlertDialog(
          {
            title: '删除组件',
            message: '确定要删除该组件吗？',
            autoCancel: true,
            alignment: DialogAlignment.Center,
            gridCount: 4,
            primaryButton: {
              value: '取消',
              fontColor: '#99000000',
              action: () => {
              }
            },
            offset: { dx: 0, dy: -20 },
            secondaryButton: {
              enabled: true,
              value: '确定',
              action: () => {
                if (cardSize === 'small') {
                  this.smallCardData = WallpaperServiceApi.delSmallMyComponent(item.id)
                } else if (cardSize === 'medium') {
                  this.mediumCardData = WallpaperServiceApi.delMediumMyComponent(item.id)
                } else {
                  this.largeCardData = WallpaperServiceApi.delLargeMyComponent(item.id)
                }
              }
            }
          })
      })
      .margin({ top: 6, bottom: 12 })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .width(30)
      .height(30)
    }
  }

  @Builder
  componentCard(item: Card) {
    GridItem() {
      Column() {
        if (item.type === 'weather') {
          WeatherCard({
            cardSize: item.cardSize,
            location: (item.data as WeatherCardInfo).location,
            weather: (item.data as WeatherCardInfo).weather,
            highTemp: (item.data as WeatherCardInfo).highTemp,
            temp: (item.data as WeatherCardInfo).temp,
            lowTemp: (item.data as WeatherCardInfo).lowTemp,
            textColor: (item.data as WeatherCardInfo).textColor,
            futureWeatherColor: (item.data as WeatherCardInfo).futureWeatherColor,
            backgroundImg: (item.data as WeatherCardInfo).backgroundImg,
            backgroundColorInfo: (item.data as WeatherCardInfo).backgroundColorInfo,
            futureWeather: (item.data as WeatherCardInfo).futureWeather
          })
            .onClick(() => {
              if (!this.isEdit && !this.vm.formCardRouter.formId) {
                this.vm.jumpComponentDetail({
                  type: item.type,
                  isMyComponent: true,
                  size: item.cardSize,
                  componentInfo: item.data,
                  id: item.id
                })
              } else if (this.vm.formCardRouter.formId) {
                const data: Record<string, Object | undefined> = {
                  'formId': this.vm.formCardRouter.formId,
                  'cardSize': item.cardSize,
                  'cardId': item.id,
                  'type': item.type,
                  'weatherData': item.data
                }
                const bindingData = formBindingData.createFormBindingData(data);
                formProvider.updateForm(this.vm.formCardRouter.formId, bindingData).then(() => {
                }).catch((err: string) => {
                });
                let context = this.getUIContext()?.getHostContext() as common.UIAbilityContext;
                context.terminateSelf();
              }
            })
          Text(`天气-${item.cardSize === 'small' ? '小' : item.cardSize === 'medium' ? '中' : '大'}`)
            .height(30)
            .fontColor($r('sys.color.font_tertiary'))
            .lineHeight(30)
        } else if (item.type === 'woodenFish') {
          WoodenFishCard({
            backgroundColorInfo: (item.data as WoodenFishCard).backgroundColorInfo,
            textColor: (item.data as WoodenFishCard).textColor,
            cardSize: item.cardSize,
            luckValue: (item.data as WoodenFishCard).luckValue,
            woodenFishTitle: (item.data as WoodenFishCard).woodenFishTitle,
            backgroundImg: (item.data as WoodenFishCard).backgroundImg
          })
            .onClick(() => {
              if (!this.isEdit && !this.vm.formCardRouter.formId) {
                this.vm.jumpComponentDetail({
                  type: item.type,
                  componentInfo: item.data,
                  size: item.cardSize,
                  isMyComponent: true,
                  id: item.id
                })
              } else if (this.vm.formCardRouter.formId) {
                const data: Record<string, Object | undefined> = {
                  'formId': this.vm.formCardRouter.formId,
                  'cardSize': item.cardSize,
                  'type': item.type,
                  'cardId': item.id,
                  'woodenFishData': item.data
                }
                const bindingData = formBindingData.createFormBindingData(data);
                formProvider.updateForm(this.vm.formCardRouter.formId, bindingData).then(() => {
                }).catch((err: string) => {
                });
                let context = this.getUIContext()?.getHostContext() as common.UIAbilityContext;
                context.terminateSelf();
              }
            })
          Text(`木鱼-${item.cardSize === 'small' ? '小' : item.cardSize === 'medium' ? '中' : '大'}`)
            .fontColor($r('sys.color.font_tertiary'))
            .height(30)
            .lineHeight(30)
        }
        this.builderToTutorial(item.cardSize, item)
      }
    }
    .columnEnd(item.cardSize === 'medium' ? 0 : item.cardSize === 'large' ? 2 : 3)
    .columnStart(item.cardSize === 'medium' ? 0 : item.cardSize === 'large' ? 2 : 3)
  }

  isVisibility(length: number, cardSize: string) {
    if (!this.vm.formCardRouter.formId) {
      if (length > 0) {
        return Visibility.Visible
      } else {
        return Visibility.None
      }
    } else {
      if (this.vm.formCardRouter.cardSize === cardSize) {
        return Visibility.Visible
      } else {
        return Visibility.None
      }
    }
  }

  aboutToAppear(): void {
    this.mediumCardData = WallpaperServiceApi.getMyComponentMediumCard()
    this.smallCardData = WallpaperServiceApi.getMyComponentSmallCard()
    this.largeCardData = WallpaperServiceApi.getMyComponentLargeCard()
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '我的组件',
          rightPartBuilder: () => {
            this.rightHeadPartBuilder()
          }
        })

        Scroll() {
          Column() {
            Column() {
              Text('小组件')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .lineHeight(20)
                .height(20)
              Grid() {
                ForEach(this.smallCardData, (item: Card) => {
                  this.componentCard(item)
                }, (item: Card, index: number) => item.id + '_' + index)
              }
              .columnsTemplate('1fr 1fr 1fr')
              .columnsGap(10)
              .rowsGap(10)
              .margin({
                top: 12,
                bottom: 12
              })
            }
            .alignItems(HorizontalAlign.Start)
            .width(CommonConstants.FULL_PERCENT)
            .visibility(this.isVisibility(this.smallCardData.length, 'small'))

            Column() {
              Text('中组件')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .lineHeight(20)
                .height(20)
              Grid() {
                ForEach(this.mediumCardData, (item: Card) => {
                  this.componentCard(item)
                }, (item: Card, index: number) => item.id + '_' + index)
              }
              .columnsTemplate('4fr 1fr 1fr')
              .rowsGap(10)
              .margin({
                top: 12,
                bottom: 12
              })
            }
            .width(CommonConstants.FULL_PERCENT)
            .alignItems(HorizontalAlign.Start)
            .visibility(this.isVisibility(this.mediumCardData.length, 'medium'))

            Column() {
              Text('大组件')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .lineHeight(20)
                .height(20)
              Grid() {
                ForEach(this.largeCardData, (item: Card) => {
                  this.componentCard(item)
                }, (item: Card, index: number) => item.id + '_' + index)
              }
              .columnsTemplate('1fr 1fr')
              .columnsGap(10)
              .rowsGap(10)
              .margin({
                top: 12,
                bottom: 12
              })
            }
            .width(CommonConstants.FULL_PERCENT)
            .alignItems(HorizontalAlign.Start)
            .visibility(this.isVisibility(this.largeCardData.length, 'large'))
          }
          .width(CommonConstants.FULL_PERCENT)
          .padding(12)
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        Text('暂无组件数据')
          .visibility(this.smallCardData.length <= 0 && this.mediumCardData.length <= 0 &&
            this.largeCardData.length <= 0 ? Visibility.Visible : Visibility.None)
      }
      .padding({ bottom: this.vm.windowModel.windowBottomPadding })
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .hideTitleBar(true)
    .onHidden(() => {
      this.vm.formCardRouter.formId = ''
    })
    .onWillShow(() => {
      this.largeCardData = WallpaperServiceApi.getMyComponentLargeCard()
      this.smallCardData = WallpaperServiceApi.getMyComponentSmallCard()
      this.mediumCardData = WallpaperServiceApi.getMyComponentMediumCard()
    })

  }
}