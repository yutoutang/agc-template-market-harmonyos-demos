import { FormatUtil, RouterMap } from 'module_base';
import { OtherVM } from '../viewModels/OtherVM';
import { TipsDialog } from '@kit.ArkUI';

@Builder
export function OtherBuilder() {
  Other()
}

@Entry
@ComponentV2
struct Other {
  vm: OtherVM = OtherVM.instance
  dialogControllerLogout: CustomDialogController = new CustomDialogController({
    builder: TipsDialog({
      content: '是否确认退出登录?',
      primaryButton: {
        value: '取消',
        action: () => {

        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.logout()
        }
      },
    }),
  })

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Column() {
              this.contentBuilder('我的理财账号', () => {
                FormatUtil.jumpToNext(RouterMap.FINANCIAL_ACCOUNT)
              })

              Divider().color($r('sys.color.comp_divider'))

              this.contentBuilder('我的理财协议', () => {
                FormatUtil.jumpToNext(RouterMap.FINANCIAL_AGREEMENT)
              })
            }
            .borderRadius(16)
            .backgroundColor(Color.White)
            .padding({ left: 12, right: 12 })
            .margin({ bottom: 12 })

            Column() {
              this.contentBuilder('隐私协议', () => {
                FormatUtil.jumpToNext(RouterMap.PRIVACY, '隐私协议')
              })

              Divider().color($r('sys.color.comp_divider'))

              this.contentBuilder('个人信息', () => {
                FormatUtil.jumpToNext(RouterMap.PERSONAL_INFORMATION_PAGE)
              })
            }
            .borderRadius(16)
            .backgroundColor(Color.White)
            .padding({ left: 12, right: 12 })
            .margin({ bottom: 12 })
          }
          .padding({ left: 16, right: 16 })
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }
      .height('calc(100% - 40vp)')

      Row() {
        Button('退出登录')
          .fontColor('#E4480C')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .width('100%')
          .borderRadius(20)
          .onClick(() => {
            this.dialogControllerLogout.open()
          });
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .title('设置')
    .backgroundColor($r('sys.color.background_secondary'))
    .onShown(() => {
      this.vm.init()
    })
  }

  @Builder
  contentBuilder(label: string, func: Function) {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Text(label)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
      Image($r('app.media.icc_arrow_right'))
        .width(7)
        .height(14)
    }
    .width('100%')
    .height(48)
    .onClick(() => {
      func()
    })
  }
}