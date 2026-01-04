// 聊天消息类型定义
export interface ChatMessage {
  sender: 'user' | 'customer'; // 发送者：用户或客服
  content: string; // 消息内容
  time: string; // 消息时间
}