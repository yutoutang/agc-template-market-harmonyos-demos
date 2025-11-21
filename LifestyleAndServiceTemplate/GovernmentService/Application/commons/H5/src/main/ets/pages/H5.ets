import { AtomicServiceWeb, AtomicServiceWebController } from '@kit.ArkUI';

@Component
export struct H5 {
  @State title: string = '';
  @State loadUrl: string = '';
  @State controller: AtomicServiceWebController = new AtomicServiceWebController();

  build() {
    NavDestination() {
      Column() {
        AtomicServiceWeb({ src:'' , controller: this.controller,
          onControllerAttached:() => {
            this.controller.loadUrl($rawfile(this.loadUrl));
          },
        })
      }
      .width('100%')
      .height('100%')
    }
    .title(this.title)
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
  }
}