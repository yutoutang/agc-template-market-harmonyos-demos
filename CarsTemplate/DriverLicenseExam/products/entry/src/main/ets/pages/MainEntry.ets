import { TAB_LIST } from '../constants/Constants';
import { HomeView } from './home/HomeView';
import { MineView } from './mine/MineView';
import { TabListItem } from '../types/Types';
import { CommonModel, CommonConstants } from '@ohos_agcit/driver_license_exam_commonlib';
import { GuideService } from '@ohos_agcit/driver_license_exam_guide';
import { ExamService } from '@ohos_agcit/driver_license_exam_datasource'
import { notificationManager } from '@kit.NotificationKit';
import { PushUtils , PushActionParams } from '@ohos_agcit/driver_license_exam_commonlib'
import common from '@ohos.app.ability.common';

@Entry
@ComponentV2
struct MainEntry {
  vm: CommonModel = CommonModel.instance;
  bottomRectHeight: number = 0;
  guideService: GuideService = GuideService.instance;
  examService: ExamService = ExamService.instance(this.getUIContext().getHostContext() as Context);
  @Local totalCount:number = 0;
  @Local didCount: number = 0;
  @Local accuracyRate: number = 0;
  @Local averageScore: number = 0;

  aboutToAppear(): void {
    this.bottomRectHeight = AppStorage.get('bottomRectHeight') || 0;
    this.vm.navStack.pushPathByName('splashPage', true);
    this.sendPushNotice();
  }

  sendPushMessage() {
    let pushArticle:PushActionParams = {
      picVideoUrl: '',
      title: '驾考模板',
      id: '3445749589458989'
    }
    PushUtils.randomPushMessage(pushArticle, this.getUIContext().getHostContext() as Context)
  }

  sendPushNotice() {
    const isOn = notificationManager.isNotificationEnabledSync();
    if (isOn) {
      this.sendPushMessage();
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Navigation(this.vm.navStack) {
        Column() {
          Tabs({ barPosition: BarPosition.End, index: this.vm.curIndex }) {
            TabContent() {
              HomeView({
                didCount: this.didCount,
                totalCount: this.totalCount
              });
            }
            .tabBar(this.tabBarBuilder(TAB_LIST[0], 0));

            TabContent() {
              MineView({
                didCount: this.didCount,
                accuracyRate: this.accuracyRate,
                averageScore: this.averageScore
              });
            }
            .tabBar(this.tabBarBuilder(TAB_LIST[1], 1));
          }
          .scrollable(false)
          .height(CommonConstants.FULL_HEIGHT)
          .animationDuration(0)
          .barMode(BarMode.Fixed)
          .onChange((index: number) => {
            this.vm.curIndex = index;
          });
        }
        .backgroundColor(Color.White)
        .padding({
          bottom: this.getUIContext().px2vp(this.bottomRectHeight)
        })
      }

      .hideTitleBar(true)
      .hideToolBar(true)
      .hideBackButton(true)
      .mode(NavigationMode.Stack)
      .onNavBarStateChange(() => {
        this.totalCount = this.examService.getTotalCount();
        this.didCount = this.examService.getDidCount();
        this.accuracyRate = this.examService.calAccuracyRate();
        this.averageScore = this.examService.calculateAverageScore();
      })
    };

  }

  @Builder
  tabBarBuilder(item: TabListItem, index: number) {
    Column() {
      Image(this.vm.curIndex === index ? item.iconChecked : item.icon)
        .width(24)
        .height(24);
      Text(item.label)
        .fontColor(this.vm.curIndex === index ? $r('app.color.icon_color_highlight') :
          'rgba(0,0,0,0.6)')
        .fontSize($r('app.string.font_size_10'))
        .margin({ top: $r('app.string.margin_xs') });

    }.width(CommonConstants.FULL_WIDTH);
  }
}