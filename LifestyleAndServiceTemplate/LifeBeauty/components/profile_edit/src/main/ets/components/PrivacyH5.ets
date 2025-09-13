import { AtomicServiceWeb, AtomicServiceWebController } from '@kit.ArkUI';

@Builder
export function PrivacyH5Builder() {
  PrivacyH5()
}

@Component
struct PrivacyH5 {
  @State controller: AtomicServiceWebController = new AtomicServiceWebController();

  build() {
    NavDestination() {
      AtomicServiceWeb({
        src: $rawfile('agreement_web.html'),
        controller: this.controller,
        nestedScroll: {
          scrollForward: NestedScrollMode.SELF_ONLY,
          scrollBackward: NestedScrollMode.SELF_ONLY,
        },
      })
    }
    .title('用户授权协议')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}