import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { MyConfig, UserInfoDetail, initCardData } from 'commons';
import { RouterType } from '../widget/model/FormCardConstant';
import { insightIntent } from '@kit.IntentsKit';
import { url } from '@kit.ArkTS';


const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private currentWindowStage: window.WindowStage | null = null;

  private updateInfo(want: Want) {
    try {
      if (want?.parameters?.params) {
        let params: Record<string, Object> = JSON.parse(want.parameters.params as string);
        let type = params.type as string;
        if (type === RouterType.COUNTDOWN) {
          AppStorage.setOrCreate('mainTabIndex', 0);
          AppStorage.setOrCreate('isToCountdown', true);
        }
        if (type === RouterType.TICKET) {
          AppStorage.setOrCreate('isToTicket', true);
        }
        if (type === RouterType.AGENDA) {
          AppStorage.setOrCreate('mainTabIndex', 1);
          AppStorage.setOrCreate('isToAgenda', true);
        }
        if (type === RouterType.AGENDADETAIL) {
          AppStorage.setOrCreate('isToAgendaDetail', true);
          AppStorage.setOrCreate('agendaDetailId', params.agendaId || '');
        }
      }
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Failed to parse params: %{public}s', error.message);
    }
  }

  getDpLink(want: Want) {
    let uri = want?.uri;
    if (uri) {
      let action = '';
      try {
        let urlObject = url.URL.parseURL(want?.uri);
        action = urlObject.params.get('action') || '';
      } catch (e) {

      }
      if (!action) {
        action = want.parameters?.action as string;
      }
      switch (action) {
        case 'traffic':
          AppStorage.setOrCreate('isToTraffic', true);
          break;
        case 'agenda':
          AppStorage.setOrCreate('isToAgenda', true);
          break;
        case 'home':
          AppStorage.setOrCreate('isToHome', true);
          break;
        case 'myAgenda':
          AppStorage.setOrCreate('isToMyAgenda', true);
          break;
        case 'ticket':
          AppStorage.setOrCreate('isToTicket', true);
          break;
        default:
          break;
      }
    }
  }

  getNfc(want: Want) {
    if (want.parameters) {
      const param = want.parameters.tagParam as string;
      if (param) {
        try {
          let data = JSON.parse(param) as Record<string, string>;
          AppStorage.setOrCreate('nfcT', data.t);
          AppStorage.setOrCreate('nfcP', data.p);
        } catch (error) {
          console.log(error);
        }
      }
    }
  }


  private async getSid(): Promise<void> {
    try {
      const sid = await insightIntent.getSid(this.context, false);
      console.info('getSid succeed!', sid);
      AppStorage.setOrCreate('sid', sid);
    } catch (error) {
      console.error(`getSid failed! error=${error.code} reason=${error.message}`);
      AppStorage.setOrCreate('sid', '');
    }
  }


  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    new MyConfig(this.context);
    initCardData(this.context);
    this.updateInfo(want);
    this.getSid();
    this.getDpLink(want);
    this.getNfc(want);
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    } catch (error) {

    }
  }

  // 如果UIAbility已在后台运行，在收到Router事件后会触发onNewWant生命周期回调
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.getNfc(want);
    this.updateInfo(want);
    this.getDpLink(want);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    if (this.currentWindowStage === null) {
      this.currentWindowStage = windowStage;
    }
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }

      PersistentStorage.persistProp('deviceId', '');
      PersistentStorage.persistProp('token', '');
      PersistentStorage.persistProp('mobile', '');
      PersistentStorage.persistProp('isShowTagDialog', '');
      PersistentStorage.persistProp('userInfo', new UserInfoDetail());
      PersistentStorage.persistProp('firstEnter', true);
      PersistentStorage.persistProp('addCalcIds', []);
      PersistentStorage.persistProp('isRecommendation', true);
      let windowClass: window.Window = windowStage.getMainWindowSync(); // 获取应用主窗口
      // // 1. 设置窗口全屏
      let isLayoutFullScreen = true;
      windowClass.setWindowLayoutFullScreen(isLayoutFullScreen);
      // 2. 获取布局避让遮挡的区域
      let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // 以导航条避让为例
      let avoidArea = windowClass.getWindowAvoidArea(type);
      let bottomRectHeight = avoidArea.bottomRect.height; // 获取到导航条区域的高度
      AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight);

      type = window.AvoidAreaType.TYPE_SYSTEM; // 以状态栏避让为例
      avoidArea = windowClass.getWindowAvoidArea(type);
      let topRectHeight = avoidArea.topRect.height; // 获取状态栏区域高度
      AppStorage.setOrCreate('topRectHeight', topRectHeight);
      // 3. 注册监听函数，动态获取避让区域数据
      windowClass.on('avoidAreaChange', (data) => {
        if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
          let topRectHeight = data.area.topRect.height;
          AppStorage.setOrCreate('topRectHeight', topRectHeight);
        } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          let bottomRectHeight = data.area.bottomRect.height;
          AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight);
        }
      });
      // 设置全窗颜色和应用元素颜色一致
      windowStage.getMainWindowSync().setWindowBackgroundColor('#ffffff');

      try {
        windowStage.setDefaultDensityEnabled(true);
      } catch (exception) {
      }
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
};
