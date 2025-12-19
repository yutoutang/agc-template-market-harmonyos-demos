import { ActivityCardModel } from '../model/ActivityCardModel';
import { ActivityCard } from './ActivityCard';

@ComponentV2
export struct ActivityList {
  @Param currentType: string = '全部'
  @Param currentCity: string = '全部'
  @Param activityList: Array<ActivityCardModel> = []
  @Param onClickCard: (activity: Object) => void = () => {
  };

  build() {

    Column() {
      List( /*{space: 10}*/) {
        ForEach(this.activityList, (item: ActivityCardModel) => {
          if (this.currentCity === '全部' && this.currentType === '全部') {
            ListItem() {
              ActivityCard({
                activity: item,
                onClickAction: () => {
                  this.onClickCard(item)
                }
              });
            }
          } else if (this.currentCity === '全部') {
            if (this.currentType === item.type) {
              ListItem() {
                ActivityCard({
                  activity: item,
                  onClickAction: () => {
                    this.onClickCard(item)
                  }
                });
              }
            }
          } else if (this.currentType === '全部') {
            if (this.currentCity === item.city) {
              ListItem() {
                ActivityCard({
                  activity: item,
                  onClickAction: () => {
                    this.onClickCard(item)
                  }
                });
              }
            }
          } else {
            if (this.currentCity === item.city && this.currentType === item.type) {
              ListItem() {
                ActivityCard({
                  activity: item,
                  onClickAction: () => {
                    this.onClickCard(item)
                  }
                });
              }
            }
          }
        }, (item: ActivityCardModel) => JSON.stringify(item));
      }
      .height('auto')
      .lanes(2)
      .width('100%')
      .scrollBar(BarState.Off)
      .scrollBarWidth('app.string.border_radius_16')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .padding({ left: 16 })
    }
    .width('100%')
    .height('100%')
  }
}