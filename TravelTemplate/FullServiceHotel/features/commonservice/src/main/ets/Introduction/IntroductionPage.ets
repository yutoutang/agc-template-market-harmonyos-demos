import { CommonButton, CommonScroll } from 'componentlib';
import { CommonConstants, FormatUtil, RouterMap, RouterModule } from 'commonlib';
import { MockImageMap } from 'network';
import { CallDialog } from 'module_call_dialog';

@Builder
export function introductionPageBuilder() {
  IntroductionPage();
}

@ComponentV2
export struct IntroductionPage {
  @Local title: string = '酒店介绍';
  @Local img: PixelMap | ResourceStr | undefined = undefined;

  build() {
    NavDestination() {
      CommonScroll() {
        Image(FormatUtil.getImgResource(MockImageMap.IMG_HOTEL_INTRODUCTION))
          .width($r('app.string.width_percent_full'));
      }

      Flex() {
        CallDialog({
          phoneNumber: CommonConstants.TEL_NUMBER,
        }) {
          CommonButton({
            containerPadding: 0,
            icon: $r('app.media.ic_phone'),
            title: '联系我们',
          })
        }

        Blank().width($r('app.string.margin_l'))

        CommonButton({
          containerPadding: 0,
          title: '公司地址',
          icon: $r('app.media.ic_address'),
          bgColor: $r('app.color.background_color_white'),
          fontColor: $r('app.color.theme_color'),
          handleClick: () => {
            RouterModule.push({
              url: RouterMap.COMMON_LOCATION,
            });
          },
        })
      }
      .padding({
        top: $r('app.string.padding_m'),
        left: $r('app.string.padding_l'),
        right: $r('app.string.padding_l'),
      })
      .width($r('app.string.width_percent_full'))
    }
    .backgroundColor($r('app.color.background_color_grey'))
    .height('100%')
    .title(this.title)
  }
}