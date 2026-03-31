import { BreakpointType, GlobalInfoModel } from '@ohos_agcit/notes_utils';
import { DarkModeToggle, MergeArrow, NoticeToggle, SingleArrow } from '../../components/SettingComponents';
import { AppStorageV2 } from '@kit.ArkUI';
import { checkUpdateAndShowDialog } from 'check_app_update';
import { ThemeController } from '../../controller/ThemeController';
import { UserInfo } from 'login';

@Builder
export function SettingBuilder() {
  Setting();
}
let themeController: ThemeController = ThemeController.instance;
@ComponentV2
export struct Setting {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private userInfo: UserInfo = UserInfo.instance;
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  build() {
    NavDestination() {
      Column(){
        Scroll(){
          Column({ space: 17 }) {
            SingleArrow({
              text: '保密设置',
            })
              .onClick(() => {
                this.appPathStack.pushPathByName('SecretSetting', undefined);
              });

            SingleArrow({
              text: '隐私设置',
            })
              .onClick(() => {
                this.appPathStack.pushPathByName('PrivacySetting', undefined);
              });

            NoticeToggle({
              text: '通知开关'
            });

            DarkModeToggle()

            MergeArrow({
              text1: '检测版本',
              text1Click: () => {
                checkUpdateAndShowDialog(this.getUIContext());
              },
              text2: '关于我们',
              text2Click: () => {
                this.appPathStack.pushPathByName('AboutUs', undefined);
              },
            });

            Blank()
              .layoutWeight(1)

            if (this.userInfo.isLogin){
              Button('退出登录')
                .width('100%')
                .height(40)
                .fontWeight(FontWeight.Medium)
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .fontColor($r('sys.color.font_primary'))
                .margin({
                  bottom: 44,
                })
                .onClick(() => {
                  this.appPathStack.pushPathByName('LogOutDialog', undefined);
                });
            }
          }
          .width('100%')
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .height('100%')
      .padding(new BreakpointType<Padding>({
        sm: {
          top: 10,
          left: $r('sys.float.padding_level8'),
          right: $r('sys.float.padding_level8'),
        },
        md: {
          top: 10,
          left: $r('sys.float.padding_level12'),
          right: $r('sys.float.padding_level12'),
        },
        lg: {
          top: 10,
          left: $r('sys.float.padding_level16'),
          right: $r('sys.float.padding_level16'),
        },
      }).getValue(this.globalInfo.currentBreakpoint))
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('设置');
  }
}


