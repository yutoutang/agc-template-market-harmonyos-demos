import { ACTIVITY_TYPE_LIST, CITY_LIST_ACTIVITY, TitleTop } from '@ohos_agcit/postpartum_care_center_uicomponents';
import { Logger } from '@ohos_agcit/postpartum_care_center_utils';
import { DoubleLayerTabs } from 'double_layer_tabs';
import { ActivityEntryVM } from '../viewmodel/ActivityEntryVM';


const TAG: string = 'ActivitiesEntry';

@ComponentV2
export struct Activities {
  vm: ActivityEntryVM = ActivityEntryVM.instance;

  async aboutToAppear() {
    Logger.info(TAG, '%{public}s', 'aboutToAppear');
    await this.vm.init();
  }

  build() {
    Column() {
      TitleTop({ title: $r('app.string.title_activity') })
        .margin({ bottom: $r('app.string.margin_xs') });
      
      DoubleLayerTabs({
        cityList: CITY_LIST_ACTIVITY,
        typeList: ACTIVITY_TYPE_LIST,
        activityList: this.vm.activityList,
        currentType: this.vm.type,
        currentCity: this.vm.cityName,
        onClickOuterTab: (cityName: string) => {
          this.vm.cityName = cityName;
        },
        onClickInnerTab: (type: string) => {
          this.vm.type = type;
        },
        onClickCard: (item: Object) => {
          this.vm.navStack.pushPathByName('ActivityDetail', item)
        }
      })
    }
    .backgroundColor('#F1F3F5')
    .clip(false)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
  }
}
