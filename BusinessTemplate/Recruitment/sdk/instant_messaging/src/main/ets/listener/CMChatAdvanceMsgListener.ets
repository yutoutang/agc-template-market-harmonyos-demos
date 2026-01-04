import { CMChatMessage } from '../viewmodels/CMChatMessage';

export interface CMChatAdvanceMsgListener {
  /**
   * 收到新消息
   *
   * @param message 消息
   */
  onRecvNewMessage?: (message: CMChatMessage) => void;
}