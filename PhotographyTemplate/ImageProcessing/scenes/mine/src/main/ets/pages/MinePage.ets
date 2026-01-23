import { common } from '@kit.AbilityKit'
import { MyScrollModifier, RouterMap, RouterModule } from 'commonlib'
import { OpenVipCard } from '../views/OpenVipCard';
import { SettingAndHelpCard } from '../views/SettingAndHelpCard';
import { UserCard } from '../views/UserCard';


@ComponentV2
export struct MinePage {
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier()
  @Local isShow: boolean = false;
  @Local message: string = 'Hello World';
  context = this.getUIContext().getHostContext() as common.UIAbilityContext


  build() {
      Column() {
        this.titleBuilder()
        UserCard()
          .margin({ bottom: 16 })

        OpenVipCard()
          .margin({ bottom: 16 })

        SettingAndHelpCard()
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor($r('app.color.main_background_color'))
      .padding({
        left: 16,
        right: 16
      })
  }

  /**
   * 导航标题
   */
  @Builder
  titleBuilder() {
    Row() {
      Text($r('app.string.mine'))
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .height($r('app.float.vp_56'))
        .width('100%')
    }
  }
}

@Builder
export function MinePageBuilder() {
  MinePage();
}