import { CityItem } from '../model/CityItem';
import { ActivityTypeItem } from '../model/ActivityTypeItem';
import { ActivityList } from './ActivityList';
import { ActivityCardModel } from '../model/ActivityCardModel';

@ComponentV2
export struct DoubleLayerTabs {
  private outerTabsController: TabsController = new TabsController();
  private innerTabsController: TabsController = new TabsController();
  @Local outerCurrentIndex: number = 0;
  @Local innerCurrentIndex: number = 0;
  @Param cityList: CityItem[] = []
  @Param typeList: ActivityTypeItem[] = []
  @Param activityList: ActivityCardModel[] = []
  @Param currentType: string = ''
  @Param currentCity: string = ''
  @Param onClickOuterTab: (city: string) => void = () => {
  };
  @Param onClickInnerTab: (type: string) => void = () => {
  };
  @Param onClickCard: (activity: Object) => void = () => {
  };

  build() {
    Tabs({ barPosition: BarPosition.Start, controller: this.outerTabsController }) {
      ForEach(this.cityList, (item: CityItem) => {
        TabContent() {
          Tabs({ barPosition: BarPosition.Start, controller: this.innerTabsController }) {
            ForEach(this.typeList, (type: ActivityTypeItem) => {
              TabContent() {
                ActivityList({
                  currentType: this.currentType,
                  currentCity: this.currentCity,
                  activityList: this.activityList,
                  onClickCard: this.onClickCard
                });
              }
              .tabBar(this.innerTabBarBuilder(type.name, type.id));
            }, (type: string) => JSON.stringify(type));
          }
          .vertical(false)
          .barWidth('100%') //横向Tabs的barWidth的宽度
          .backgroundColor('#F1F3F5')
          .barMode(BarMode.Scrollable)
          .scrollable(false)
          .layoutWeight(1);
        }
        .tabBar(this.outerTabBarBuilder(item.name, item.id));
      }, (item: string) => JSON.stringify(item));
    }
    .vertical(false)
    .barWidth('100%') //横向Tabs的barWidth的宽度
    .backgroundColor('#F1F3F5')
    .barMode(BarMode.Scrollable)
    .scrollable(false)
    .layoutWeight(1);
  }

  @Builder
  outerTabBarBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(this.outerCurrentIndex === targetIndex ? FontWeight.Bold : FontWeight.Regular)
        .fontSize($r('app.string.font_size_14'))
        .fontColor(this.outerCurrentIndex === targetIndex ? 'rgba(0,0,0,0.90)' : 'rgba(0,0,0,0.60)')
        .margin({ bottom: $r('app.string.margin_9') });
      Divider()
        .width(28)
        .strokeWidth(2)
        .color(this.outerCurrentIndex === targetIndex ? $r('sys.color.comp_divider') : 'transparent')
        .opacity(this.outerCurrentIndex === targetIndex ? 1 : 0);
    }
    .margin(targetIndex === 0 ?
      {
        left: $r('app.string.margin_ms'),
        right: $r('app.string.margin_s'),
      } :
      {
        left: $r('app.string.margin_s'),
        right: $r('app.string.margin_s'),
      },
    )
    .padding({ top: $r('app.string.padding_14'), bottom: $r('app.string.padding_4') })
    .height(48)
    .onClick(() => {
      this.outerCurrentIndex = targetIndex;
      this.outerTabsController.changeIndex(targetIndex); // 切换页签 页签在Tabs里的索引值，索引值从0开始。
      this.onClickOuterTab(title)
    });
  }

  @Builder
  innerTabBarBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(this.innerCurrentIndex === targetIndex ? FontWeight.Medium : FontWeight.Regular)
        .fontSize($r('app.string.font_size_12'))
        .fontColor(this.innerCurrentIndex === targetIndex ? 'rgba(0,0,0,0.90)' : 'rgba(0,0,0,0.60)')
        .margin({ bottom: $r('app.string.margin_9') });
    }
    .margin(targetIndex === 0 ?
      {
        left: $r('app.string.margin_ms'),
        right: $r('app.string.margin_s'),
      } :
      {
        left: $r('app.string.margin_s'),
        right: $r('app.string.margin_s'),
      },
    )
    .padding({ top: $r('app.string.padding_12'), bottom: $r('app.string.padding_12') })
    .height(40)
    .onClick(() => {
      this.innerCurrentIndex = targetIndex;
      this.innerTabsController.changeIndex(targetIndex); // 切换页签 页签在Tabs里的索引值，索引值从0开始。
      this.onClickInnerTab(title)
    });
  }
}