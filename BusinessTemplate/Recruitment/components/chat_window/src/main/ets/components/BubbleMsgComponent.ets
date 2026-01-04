import { ChatContentSingleModel } from 'chat_base';
import { BubbleMsgItem, BubbleMsgModel } from '../model/BubbleMsgModel';
import { PromptActionClass } from '../utils/PromptActionClass';
import { popMenuItemComponent } from './popMenuItemComponent';

@ComponentV2
export struct BubbleMsgComponent {
  @Local handlePopup: boolean = true;
  @Param @Require chatVM: ChatContentSingleModel
  @Local menuData: BubbleMsgItem[] = []
  closePop = () => {
    this.handlePopup = false
  }

  aboutToAppear(): void {
    this.menuData = BubbleMsgModel.getMenuData(this.chatVM.chatType)
    PromptActionClass.closePop = this.closePop
  }

  @Builder
  popBuilder() {
    Column() {
      PopMsgComponet({
        menuData: this.menuData,
        chatVM: this.chatVM
      })
    }
  }

  build() {
    Column() {
    }
    .width('100%').height('100%')
    .bindPopup(this.handlePopup!!, {
      builder: this.popBuilder,
      placement: Placement.Top,
      popupColor: '#CC000000',
      backgroundBlurStyle: BlurStyle.NONE,
      radius: $r('sys.float.corner_radius_level4'),
      onWillDismiss: (
        (dismissPopupAction: DismissPopupAction) => {
          dismissPopupAction.dismiss();
          PromptActionClass.closeDialog()
        }
      )
    })
  }
}


@ComponentV2
export struct PopMsgComponet {
  @Param @Require menuData: BubbleMsgItem[]
  @Param @Require chatVM: ChatContentSingleModel

  build() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceAround }) {
      ForEach(this.menuData, (item: BubbleMsgItem) => {
        popMenuItemComponent({
          item: item,
          chatVM: this.chatVM
        })
      }, (item: BubbleMsgItem, index: number) => `${JSON.stringify(item)}_${index}}`)
    }.constraintSize({ maxWidth: 248, minWidth: 190 })
    .padding({ bottom: 14 })

  }
}