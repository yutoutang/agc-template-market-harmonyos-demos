import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';

@Builder
export function TutorialPageBuilder() {
  TutorialPage()
}

@ComponentV2
struct TutorialPage {
  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '新手教程',
        })

        Scroll() {
          Column() {
            Text('桌面小组件添加教程')
              .fontColor($r('app.color.title_color'))
              .fontSize($r('app.float.font_20'))
              .fontWeight(FontWeight.Bold)
              .margin({
                top: $r('app.float.margin_32'),
                bottom: $r('app.float.margin_32'),
              })
            Text('1 选择并保存小组件')
              .fontColor($r('app.color.title_color'))
              .fontSize($r('app.float.font_18'))
              .fontWeight(FontWeight.Bold)
              .margin({
                bottom: $r('app.float.margin_8'),
              })
            Text('在小组件页选择您想添加的桌面组件，点击组件进入组件编辑页面。在组件编辑页面，您可以自由编辑小组件的样式，' +
              '编辑完成后点击下方“保存到我的组件”按钮')
              .fontColor($r('app.color.title_color'))
              .fontSize($r('app.float.font_16'))
            Row() {
              Image($r('app.media.ic_tutorial1'))
                .width($r('app.float.width_104'))
                .height($r('app.float.height_229'))
              Image($r('app.media.ic_tutorial2'))
                .width($r('app.float.width_104'))
                .height($r('app.float.height_229'))
            }
            .justifyContent(FlexAlign.SpaceAround)
            .width(CommonConstants.FULL_PERCENT)
            .margin({
              top: $r('app.float.margin_24'),
              bottom: $r('app.float.margin_32'),
            })

            Text('2 管理小组件')
              .fontColor($r('app.color.title_color'))
              .fontSize($r('app.float.font_18'))
              .fontWeight(FontWeight.Bold)
              .margin({
                bottom: $r('app.float.margin_8'),
              })
            Text('进入我的组件页面，在这里您可以对已保存的小组件进行管理及编辑。找到您想要添加到桌面的小组件，点击“添加到桌面”，' +
              '即可弹出小组件添加视频教程，跟随引导进行添加。')
              .fontColor($r('app.color.title_color'))
              .fontSize($r('app.float.font_16'))
            Row() {
              Image($r('app.media.ic_tutorial3'))
                .width($r('app.float.width_104'))
                .height($r('app.float.height_229'))
              Image($r('app.media.ic_tutorial4'))
                .width($r('app.float.width_104'))
                .height($r('app.float.height_229'))
            }
            .justifyContent(FlexAlign.SpaceAround)
            .width(CommonConstants.FULL_PERCENT)
            .margin({
              top: $r('app.float.margin_24'),
              bottom: $r('app.float.margin_32'),
            })

            Text('3 添加组件到桌面教程详解')
              .fontColor($r('app.color.title_color'))
              .fontSize($r('app.float.font_18'))
              .fontWeight(FontWeight.Bold)
              .margin({
                bottom: $r('app.float.margin_8'),
              })
            Text('回到桌面，长按“壁纸”应用图标，点击“服务卡片”，弹出小组件型号选择界面，选择需要添加的小组件型号，点击“添加到桌面”，' +
              '添加至桌面后，点击小组件，选择对应大小的组件添加。')
              .fontColor($r('app.color.title_color'))
              .fontSize($r('app.float.font_16'))
            Row() {
              Image($r('app.media.ic_tutorial5'))
                .width($r('app.float.width_104'))
                .height($r('app.float.height_229'))
              Image($r('app.media.ic_tutorial6'))
                .width($r('app.float.width_104'))
                .height($r('app.float.height_229'))
              Image($r('app.media.ic_tutorial7'))
                .width($r('app.float.width_104'))
                .height($r('app.float.height_229'))
            }
            .justifyContent(FlexAlign.SpaceAround)
            .width(CommonConstants.FULL_PERCENT)
            .margin({
              top: $r('app.float.margin_24'),
              bottom: $r('app.float.margin_32'),
            })

            Text('选择需要添加到小组件，点击“添加到桌面”，小组件就设置成功啦!')
              .fontColor($r('app.color.title_color'))
              .fontSize($r('app.float.font_16'))
            Row() {
              Image($r('app.media.ic_tutorial8'))
                .width($r('app.float.width_104'))
                .height($r('app.float.height_229'))
              Image($r('app.media.ic_tutorial9'))
                .width($r('app.float.width_104'))
                .height($r('app.float.height_229'))
            }
            .justifyContent(FlexAlign.SpaceAround)
            .width(CommonConstants.FULL_PERCENT)
            .margin({
              top: $r('app.float.margin_24'),
              bottom: $r('app.float.margin_32'),
            })
          }
          .width(CommonConstants.FULL_PERCENT)
          .alignItems(HorizontalAlign.Start)
          .padding({
            left: CommonConstants.PADDING_L,
            right: CommonConstants.PADDING_L,
          })
        }
        .width(CommonConstants.FULL_PERCENT)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
    }
    .hideTitleBar(true)
  }
}