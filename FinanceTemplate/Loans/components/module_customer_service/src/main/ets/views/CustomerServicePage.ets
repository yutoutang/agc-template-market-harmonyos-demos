import { CustomerViewModel } from '../viewmodels/CustomerVM';
import { window } from '@kit.ArkUI';
import { ChatMessage } from '../model/ChatMessage';
import { hilog } from '@kit.PerformanceAnalysisKit';

@ComponentV2
export struct CustomerServicePage {
  @Local vm: CustomerViewModel = new CustomerViewModel();
  @Local keyboardHeight: number = 0; // Soft keyboard height
  scroller: Scroller = new Scroller();
  @Local heightValue: string = '100%';

  @Event customerServicecancelCallBack: () => void = () => {
  }

  @Event customerServiceConfirmCallBack: () => void = () => {
  }

  aboutToAppear(): void {
    try {
      window.getLastWindow(this.getUIContext().getHostContext()).then(currentWindow => {
        currentWindow.on('keyboardHeightChange', (data: number) => {
          this.keyboardHeight = this.getUIContext().px2vp(data);
          if (this.keyboardHeight > 0) {
            this.scroller.scrollEdge(Edge.End)
          }
        })
      })
    } catch (err) {
      hilog.error(0x0001, 'CustomerServicePage', `Face verification start error: ${err.message}`);
    }
  }

  build() {
    Column() {
      // 主内容区域
      Column() {
        if (this.vm.isTitleShow) {
          // 客服已接入，展示聊天界面
          this.ChatWindowBuilder()
        }
      }
      .layoutWeight(1)

      this.buttonBuilder()
    }
    .width('100%')
    .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM])
    .padding({ bottom: this.vm.safePaddingBottom })
    .bindSheet(this.vm.isContactDialogShow, this.ContactDialogBuilder(), {
      title: { title: '联系方式' },
      height: 280,
      dragBar: true,
      detents: [280, SheetSize.MEDIUM],
      onDisappear: () => {
        this.vm.isContactDialogShow = false;
        if (!this.vm.isTitleShow) {
          this.customerServicecancelCallBack()
        } else {
          this.customerServiceConfirmCallBack()
        }
      },
      preferType: SheetType.CENTER
    })
  }

  // 联系方式弹窗构建器
  @Builder
  ContactDialogBuilder() {
    Column({ space: 10 }) {
      // 提示文本
      Text('为了便于客服联系您，请先填写联系方式')
        .fontSize(16)
        .lineHeight(19)
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Start)
        .width('100%')
      // 联系电话输入框
      TextInput({
        placeholder: '请输入您的联系方式',
        text: this.vm.contactPhone
      })
        .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM])
        .width('100%')
        .borderRadius(16)
        .placeholderColor($r('sys.color.font_secondary'))
        .backgroundColor('#FFFFFF')
        .maxLength(11)
        .type(InputType.Number)
        .onChange((value: string) => {
          this.vm.contactPhone = value;
        })
        .enterKeyType(EnterKeyType.Done)
        .onSubmit(() => {
          this.vm.submit(this.vm.contactPhone);
        })

      Blank().layoutWeight(1)
      // 按钮区域
      Text('确认提交')
        .backgroundColor('#317AF7')
        .fontColor($r('sys.color.font_secondary'))
        .fontSize(16)
        .lineHeight(19)
        .width('100%')
        .height(40)
        .padding({ top: 10, bottom: 10 })
        .textAlign(TextAlign.Center)
        .borderRadius(20)
        .onClick(() => {
          this.vm.submit(this.vm.contactPhone);
        })

    }
    .width('100%')
    .borderRadius(10)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .padding({
      left: 15,
      right: 15,
      top: 16,
      bottom: 16
    })
    .zIndex(99999)
  }

  @Builder
  buttonBuilder() {
    Row() {
      TextInput({
        placeholder: '请输入咨询内容',
        text: this.vm.inputContent,
      })
        .layoutWeight(1)
        .height(40)
        .margin({ left: 15 })
        .placeholderColor($r('sys.color.font_secondary'))
        .enterKeyType(EnterKeyType.Send)
        .onFocus(() => {
          this.scroller.scrollEdge(Edge.End)
          this.heightValue = '52%'
        })
        //失去焦点
        .onBlur(() => {
          this.heightValue = '100%'
        })
        .onSubmit(() => {
          this.vm.sendMessage();
          this.scroller.scrollEdge(Edge.End)
        })
        .onChange((value: string) => {
          this.vm.inputContent = value;
        })


      Image(this.vm.inputContent !== '' ? $r('app.media.send_now') : $r('app.media.send_empty'))
        .width(40)
        .height(40)
        .margin({ left: 10, right: 15 })
        .onClick(() => {
          this.vm.sendMessage();
          this.scroller.scrollEdge(Edge.End)
        })
    }
    .width('100%')
    .borderRadius({
      topLeft: 32,
      topRight: 32,
      bottomLeft: 0,
      bottomRight: 0
    })
    .padding({ top: 10, bottom: 10 })
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.End)
    .visibility(this.vm.isTitleShow ? Visibility.Visible : Visibility.None)
    .offset({ y: this.keyboardHeight > 0 ? -(this.keyboardHeight - this.vm.safePaddingBottom) : 0 })
  }

  // 聊天窗口构建器
  @Builder
  ChatWindowBuilder() {
    Scroll(this.scroller) {
      Column({ space: 10 }) {
        ForEach(this.vm.chatMessages, (msg: ChatMessage) => {
          this.ChatMessageItemBuilder(msg);
        },
          (msg: ChatMessage) => {
            return JSON.stringify(msg)
          }
        )
      }
      .width('100%')
      .padding({
        left: 15,
        right: 15,
        top: 10,
        bottom: 10
      })
    }
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    // .width('100%')
    .height(this.heightValue)
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }

  // 单条聊天消息项构建器
  @Builder
  ChatMessageItemBuilder(msg: ChatMessage) {

    if (msg.sender === 'customer') {
      // 客服消息：居左，浅色背景
      Row({ space: 5 }) {
        Image($r('app.media.service_icon'))
          .width(30)
          .height(30)

        Row() {
          Text(msg.content)
            .fontSize(14)
            .lineHeight(20)
            .padding(10)
            .backgroundColor('#E6F7FF')
            .borderRadius(8)
            .textAlign(TextAlign.Start)
        }
        .layoutWeight(1)
        .margin({ right: 30 })
      }.width('100%')
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.Start)
    } else {
      // 用户消息：居右，蓝色背景
      Row({ space: 5 }) {
        Row() {
          Text(msg.content)
            .fontSize(14)
            .padding(10)
            .backgroundColor('#007DFF')
            .fontColor('#FFFFFF')
            .borderRadius(8)
            .textAlign(TextAlign.End)
        }
        .layoutWeight(1)
        .margin({ left: 30 })
        .justifyContent(FlexAlign.End)

        Image($r('app.media.ic_user_unlogin'))
          .width(30)
          .height(30)
      }.width('100%')
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.End)
    }
  }
}
