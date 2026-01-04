import { promptAction } from '@kit.ArkUI';
import { MockChatData } from '../mockdata/MockChatData'; // 假设模拟聊天数据的文件
import { ChatMessage } from '../model/ChatMessage';

@ObservedV2
export class CustomerViewModel {
  // 控制联系方式弹窗显示/隐藏
  @Trace isContactDialogShow: boolean = true;
  // 存储用户输入的联系电话
  @Trace contactPhone: string = '';
  // 标记客服是否已接入
  @Trace isTitleShow: boolean = false;
  // 聊天消息列表
  @Trace chatMessages: ChatMessage[] = [];
  // 用户输入的咨询内容
  @Trace inputContent: string = '';
  // 底部安全区域高度
  @Trace safePaddingBottom: number = 20;

  constructor() {
    // 初始化时若客服已接入，加载模拟聊天数据（含默认欢迎语）
    if (this.isTitleShow) {
      this.loadMockChatData();
    }
  }

  // 加载模拟聊天数据（客服欢迎语 + 历史对话示例）
  loadMockChatData() {
    this.chatMessages = MockChatData.defaultMessages;
  }


  submit(phone: string) {
    if (phone === '') {
     promptAction.showToast({ message: '请留下您的联系方式' });
    } else if (!this.isPhoneNumberValid(phone)) {
      promptAction.showToast({ message: '手机号格式不正确' });
    } else {
      this.isTitleShow = true;
      this.isContactDialogShow = false;
      this.loadMockChatData(); // 接入后加载聊天数据
    }
  }

  isPhoneNumberValid(phoneNumber: string): boolean {
    if (!phoneNumber) {
      return false;
    }
    // 正则表达式：以1开头，第二位是3-9，后面跟9位数字
    const phoneRegex = /^1[3-9]\d{9}$/;
    return phoneRegex.test(phoneNumber);
  }

  // 发送用户输入的消息
  sendMessage() {
    if (this.inputContent.trim() === '') {
      return;
    }

    // 添加用户消息到列表
    this.chatMessages.push({
      sender: 'user',
      content: this.inputContent,
      time: new Date().toLocaleTimeString(),
    });

    // 模拟 AI 回复（1秒后返回固定回复，实际可对接接口）
    setTimeout(() => {
      this.chatMessages.push({
        sender: 'customer',
        content: '您好，关于修改还款日期的问题，您可以在APP内【我的贷款】-【还款计划】中操作调整~',
        time: new Date().toLocaleTimeString(),
      });
    }, 1000);

    this.inputContent = ''; // 清空输入框
  }
}

