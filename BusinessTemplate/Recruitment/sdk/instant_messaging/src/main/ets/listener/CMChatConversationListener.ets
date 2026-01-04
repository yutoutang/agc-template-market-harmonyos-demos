
export interface CMChatConversationListener {
  /**
   * 有新的会话（比如收到一个新同事发来的单聊消息、或者被拉入了一个新的群组中），可以根据会话的
   * orderKey 重新对会话列表做排序
   *
   * @param conversationList 会话列表
   */
  onNewConversation?: () => void;
  /**
   * 某些会话的关键信息发生变化（未读计数发生变化、最后一条消息被更新等等），可以根据会话的
   * orderKey 重新对会话列表做排序
   *
   * @param conversationList 会话列表
   */
  onConversationChanged?: () => void;
}