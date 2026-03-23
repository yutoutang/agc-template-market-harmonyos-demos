import { PreferenceUtils, RouterMap, RouterUtils } from 'lib_common';
import { skipGuide } from '../common/Constants';
import { CommonGuidePage } from '../components/CommonGuidePage';
import { GuidePageVM } from '../viewmodels/GuidePageVM';

@Builder
export function GuidePageStartBuilder() {
  GuidePage()
}

@ComponentV2
struct GuidePage {
  vm: GuidePageVM = new GuidePageVM();

  onNextButtonClick() {
    PreferenceUtils.getInstance().put(skipGuide, true);
    RouterUtils.pushPathByName(RouterMap.INDEX_PAGE)
  }

  @Builder
  contentBuilder() {
    Image($r('app.media.running'))
      .width(350)
      .height(350)
      .draggable(false)
      .margin({
        left: 9,
        right: 9,
        top: 58,
      })
  }
  build() {
    CommonGuidePage({
      guideTitle: '',
      guideDesc: '',
      nextButtonDesc: '开启您的运动之旅',
      isShowSkipButton: false,
      customBuilderParam: () => this.contentBuilder(),
      onNextButtonClick: (): void => this.onNextButtonClick(),
      backColor: '#FFFFFF'
    })
  }
}
