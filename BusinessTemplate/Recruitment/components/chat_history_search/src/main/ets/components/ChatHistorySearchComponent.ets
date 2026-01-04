import { AppStorageV2 } from '@kit.ArkUI';
import { ChatBreakpoint } from 'chat_base';
import { SearchView } from './SearchView';

@ComponentV2
export struct ChatHistorySearchComponent {
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Local searchText: string = '';
  // 搜索点击回调
  @Local onSubmitSearch: (searchText: string) => void =
    (searchText: string) => {
      this.searchText = searchText;
    }

  build() {
    Column() {
      SearchView({ onSubmitSearch: this.onSubmitSearch })
      Text(this.searchText)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .lineHeight($r('app.float.vp_22'))
        .margin({
          top: $r('app.float.vp_12'),
          left: $r('app.float.vp_16'),
          bottom: $r('app.float.vp_8'),
        })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider')).padding({ left: 12, right: 12 })
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('sys.color.white'))
    .padding({
      left: this.chatBreakpoint.pagePadding,
      right: this.chatBreakpoint.pagePadding,
      bottom: this.chatBreakpoint.bottomValue,
      top: $r('app.float.vp_12')
    })
  }
}
