import { ChatMessage } from '../model/ChatMessage';


export class MockChatData {
  // 默认聊天消息（客服欢迎语）
  static defaultMessages: ChatMessage[] = [
    {
      sender: 'customer',
      content: '你好，请问有什么可以帮您的？',
      time: '12:00',
    },
  ];
}