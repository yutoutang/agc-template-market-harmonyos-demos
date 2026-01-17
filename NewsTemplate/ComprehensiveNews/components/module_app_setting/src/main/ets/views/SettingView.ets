import { common } from '@kit.AbilityKit';
import { CommonConstants } from '../constants/CommonConstants';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { LogoutBtn } from '../components/LogoutBtn';
import { SettingCard } from '../components/SettingCard';
import { SettingGroup } from '../types/SettingItem';
import { SettingViewModel } from '../viewmodels/SettingVM';
import { DisplayType } from '../types/SettingType';
import { ContextUtils } from '../common/ContextUtils';

@ComponentV2
export struct SettingView {
  // 设置列表
  @Param settingList: SettingGroup[] = [];
  // 路由栈
  @Param pathStack: NavPathStack = new NavPathStack();
  // 展示形式
  @Param displayType: DisplayType = DisplayType.PAGE;
  // 主题色
  @Param themeColor: ResourceColor = $r('sys.color.brand');
  // 字体大小缩放系数
  @Param fontSizeRatio: number = 1;
  // 开启多列模式
  @Param enableLaneSetting: boolean = false;
  // 开启边缘滑动效果
  @Param enableEdgeEffect: boolean = true;
  // 栅格是否占满全部GridRow
  @Param fullGridCol: boolean = false;
  // 页面内边距
  @Param pagePadding: Padding = {};
  // 自适应内容高度
  @Param autoHeight: boolean = false;
  // 是否已登录
  @Param isLogin: boolean = false;
  // 退出登录api
  @Event signOutApi: () => Promise<void> = () => new Promise((resolve) => resolve());
  // 退出登录成功的回调
  @Event signOutSuccessCb: () => void = () => {
  };
  @Local vm: SettingViewModel = new SettingViewModel();

  aboutToAppear(): void {
    ContextUtils.setUIContext(this.getUIContext());
    this.initParams();
    this.vm.handleSettingList(this.settingList);
    this.vm.onConfigurationUpdate();
    this.vm.windowModel.onAvoidAreaChange();
  }

  aboutToDisappear(): void {
    this.vm.offConfigurationUpdate();
    this.vm.windowModel.offAvoidAreaChange();
  }

  @Monitor('fontSizeRatio')
  onFontSizeRatioChange() {
    this.vm.fontModel.fontSizeRatio = this.fontSizeRatio;
  }

  build() {
    Column() {
      if (this.vm.configInfo.isSheet) {
        this.coreView()
      } else {
        GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
          GridCol({
            span: this.fullGridCol ? GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS :
              GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
            offset: this.fullGridCol ? 0 : GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
          }) {
            this.coreView()
          }
        }
        .layoutWeight(this.autoHeight ? 0 : 1)
        .onBreakpointChange((breakpoints: string) => {
          this.vm.breakPointModel.currentBreakpoint = breakpoints;
        })
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(this.autoHeight ? 'auto' : CommonConstants.FULL_PERCENT)
    .defaultFocus(true)
    .onFocus(() => {
      this.vm.getLatestPushStatus();
    })
  }

  initParams() {
    this.vm.uiContext = this.getUIContext();
    this.vm.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.setCoreInfo();
  }

  setCoreInfo() {
    this.vm.configInfo.pathStack = this.pathStack;
    this.vm.configInfo.displayType = this.displayType;
    this.vm.configInfo.themeColor = this.themeColor;
    this.vm.fontModel.fontSizeRatio = this.fontSizeRatio;
  }

  @Builder
  coreView() {
    Column() {
      Scroll() {
        Column({ space: CommonConstants.SPACE_M }) {
          ForEach(this.vm.settingList, (v: SettingGroup) => {
            SettingCard({
              title: v.title,
              list: v.list,
              enableLaneSetting: this.enableLaneSetting,
            })
          }, (v: SettingGroup) => v.id)
        }
        .padding({
          top: this.pagePadding.top ?? CommonConstants.PADDING_M,
        })
      }
      .attributeModifier(this.vm.scrollModifier)
      .layoutWeight(this.autoHeight ? 0 : 1)
      .edgeEffect(this.enableEdgeEffect ? EdgeEffect.Spring : EdgeEffect.None, { alwaysEnabled: true })
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.PARENT_FIRST,
      })

      LogoutBtn({
        visible: this.isLogin,
        signOutApi: this.signOutApi,
        signOutSuccessCb: this.signOutSuccessCb,
      })
    }
    .layoutWeight(this.autoHeight ? 0 : 1)
    .padding({
      left: this.pagePadding.left ?? GridRowColSetting.getPageMargin(this.vm.breakPointModel.currentBreakpoint),
      right: this.pagePadding.left ?? GridRowColSetting.getPageMargin(this.vm.breakPointModel.currentBreakpoint),
      bottom: this.pagePadding.bottom,
    })
  }
}