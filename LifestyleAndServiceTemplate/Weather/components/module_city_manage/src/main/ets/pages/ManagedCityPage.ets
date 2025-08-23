import { WeatherUtils } from 'module_weather_core';
import { CommonHeader } from '../components/CommonHeader';
import { DragList } from '../components/DragList';
import { CityPage } from '../constants/Constants';
import { IPosition } from '../types/Types';
import { Loading } from '../utils/Loading';
import { PositionUtl } from '../utils/PostionUtil';
import { CityManager } from '../utils/Utils';
import { WindowUtil } from '../utils/WindowUtil';
import { ManagedVM } from '../viewmodels/ManagedVM';

@ComponentV2
export struct ManagedCityPage {
  @Local stack: NavPathStack | undefined;
  vm: ManagedVM = ManagedVM.instance;

  aboutToAppear() {
    this.vm.init(this.getUIContext());
  }

  aboutToDisappear(): void {
    PositionUtl.update(this.vm.postionList);
  }

  build() {
    NavDestination() {
      CommonHeader({ title: '城市管理', stack: this.stack }).margin({ bottom: 8 })

      Scroll() {
        Column() {
          this.topInfoBuilder()

          this.midInfoBuilder()

          Blank().layoutWeight(1)
        }
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      this.bottomBtn()
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_primary'))
    .padding({ bottom: WindowUtil.getAvoidArea().bottom })
    .onReady(res => {
      this.stack = res.pathStack;
    })
  }

  @Builder
  topInfoBuilder() {
    if (this.vm.mineWeather) {
      Column({ space: 12 }) {
        Row() {
          Text('当前位置')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Subtitle_M'))

          Text('（自动定位）')
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Caption_L'))
        }
        .width('100%')

        this.itemBuilder(-1)

      }.margin({ bottom: 24 })
    }
  }

  @Builder
  midInfoBuilder() {
    if (this.vm.otherWeathers.length) {
      Column({ space: 12 }) {
        Row() {
          Text('关注城市')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Subtitle_M'))

          Text('（拖动排序）')
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Caption_L'))
        }
        .width('100%')

        DragList({
          arr: this.vm.postionList,
          itemHeight: 72,
          exchangeNext: (pre) => {
            const temp = this.vm.otherWeathers.splice(pre, 1);
            this.vm.otherWeathers.splice(pre + 1, 0, temp[0]);
          },
          itemUi: (index) => {
            this.itemBuilder(index)
          },
        })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  itemBuilder(index: number) {
    Row() {
      if (this.vm.edit) {
        if (index === -1) {
          Image($r('app.media.refresh'))
            .width(22).height(22)
            .transition(TransitionEffect.translate({ x: -40 }).animation({ duration: 300, curve: Curve.Ease }))
            .onClick(() => {
              // 刷新
              Loading.open();
              CityManager.applyLocationPermission().then(res => {
                Loading.close();
                this.stack?.pop(res);
              }).catch(() => {
                Loading.close();
              });
            })
        } else {
          Row() {
            Blank().width(10).height(1).backgroundColor($r('sys.color.white'))
          }
          .width(20)
          .height(20)
          .borderRadius('50%')
          .backgroundColor($r('sys.color.warning'))
          .justifyContent(FlexAlign.Center)
          .transition(TransitionEffect.translate({ x: -40 }).animation({ duration: 300, curve: Curve.Ease }))
          .onClick(() => {
            // 删除
            this.vm.postionList.splice(index, 1);
            this.vm.otherWeathers.splice(index, 1);
          })
        }
      }

      Row() {
        if (index === -1) {
          Image($r('app.media.location'))
            .width(18)
            .height(22)
            .fillColor($r('sys.color.icon_on_secondary'))
            .margin({ right: 11 })
        }
        Text(index === -1 ? this.vm.minePosition.name : this.vm.postionList[index].name).textStyle1(index)
        Blank().layoutWeight(1)
        if (!this.vm.edit) {
          Row({ space: 18 }) {
            Image($r(`app.media.${index === -1 ? this.vm.mineWeather!.icon : this.vm.otherWeathers[index].icon}`))
              .width(44)
              .aspectRatio(1)
            Column({ space: 2 }) {
              Text(index === -1 ? this.vm.mineWeather!.temp.toFixed(0) + '°' :
                this.vm.otherWeathers[index].temp.toFixed(0) + '°')
                .fontWeight(FontWeight.Medium)
                .fontColor(index === -1 ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
                .fontSize($r('sys.float.Title_M'))
              Text(index === -1 ? this.vm.mineWeather!.maxTemp + '°/' + this.vm.mineWeather!.minTemp + '°' :
                this.vm.otherWeathers[index].maxTemp + '°/' + this.vm.otherWeathers[index].minTemp + '°')
                .fontColor(index === -1 ? $r('sys.color.font_on_primary') : $r('sys.color.font_secondary'))
                .fontSize($r('sys.float.Body_M'))
            }
          }
        }
      }
      .containerStyle()
      .margin({ left: this.vm.edit ? 14 : 0 })
      .backgroundColor(index === -1 ? 'rgba(63, 126, 247, 1)' : $r('sys.color.comp_background_tertiary'))
      .animation({ duration: 300, curve: Curve.Ease })
      .onClick(() => {
        this.stack?.pop(index === -1 ? this.vm.minePosition : this.vm.postionList[index]);
      })
    }
    .width('100%')
  }

  @Builder
  bottomBtn() {
    Row({ space: 12 }) {
      if (this.vm.edit) {
        Text('完成')
          .layoutWeight(1)
          .backgroundColor('#3F7EF7')
          .height(40)
          .borderRadius('50%')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Body_L'))
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.vm.edit = false;
          })
      } else {
        Text('编辑城市')
          .layoutWeight(1)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .height(40)
          .borderRadius('50%')
          .fontWeight(FontWeight.Medium)
          .fontColor('#3F7EF7')
          .fontSize($r('sys.float.Body_L'))
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.vm.edit = true;
          })

        Text('添加城市')
          .layoutWeight(1)
          .backgroundColor('#3F7EF7')
          .height(40)
          .borderRadius('50%')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Body_L'))
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.stack?.pushPathByName(CityPage.SEARCH, this.vm.minePosition, (popRes) => {
              const newPostion = popRes.result as IPosition;
              if (this.vm.postionList.findIndex(item => item.code === newPostion.code) === -1) {
                WeatherUtils.getRealTimeWeathers([newPostion.code]).then(res => {
                  this.vm.postionList.push(newPostion);
                  this.vm.otherWeathers.push(res[0]);
                });
              }
            }, true);
          })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .height(56)
    .alignItems(VerticalAlign.Center)
  }
}


@Builder
export function managedCityPageBuilder() {
  ManagedCityPage()
}

@Extend(Row)
function containerStyle() {
  .layoutWeight(1)
  .height(72)
  .borderRadius(16)
  .padding({ left: 12, right: 12 })
  .alignItems(VerticalAlign.Center)
}

@Extend(Text)
function textStyle1(index: number) {
  .fontWeight(FontWeight.Medium)
  .fontColor(index === -1 ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
  .fontSize($r('sys.float.Subtitle_L'))
}