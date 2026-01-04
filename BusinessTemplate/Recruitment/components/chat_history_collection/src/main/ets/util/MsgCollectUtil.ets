import { ChatContentSingleModel } from 'chat_base';
import { ChatMsgCollectModel } from '../viewmodel/ChatMsgCollectModel';
import { CollectDataManager } from './CollectDataManager';
import { arrayBufferToString } from './CommonUtil';

export class MsgCollectUtil {
  private static instance: MsgCollectUtil;
  private msgCollectList?: ChatMsgCollectModel[];

  private constructor() {
    let savedJson = CollectDataManager.getInstance()
      .getCollectData('') as string;
    if (savedJson.length > 0) {
      try {
        this.msgCollectList = JSON.parse(savedJson) as ChatMsgCollectModel[];
      } catch (e) {
        this.msgCollectList = [];
      }
    } else {
      this.msgCollectList = [];
    }
  }

  public static getInstance() {
    if (!MsgCollectUtil.instance) {
      MsgCollectUtil.instance = new MsgCollectUtil();
    }
    return MsgCollectUtil.instance;
  }

  public addCollectMsg(chatMsg: ChatContentSingleModel) {
    if (chatMsg) {
      this.addCollectMsgToPref(chatMsg).then(() => {
      });
    }
  }

  private async addCollectMsgToPref(collectMsg: ChatContentSingleModel): Promise<void> {
    let addResult = false;
    let chatMsgCollectModel: ChatMsgCollectModel = collectMsg as ChatMsgCollectModel;
    if (chatMsgCollectModel) {
      chatMsgCollectModel.customChatStr = collectMsg.customChat ? arrayBufferToString(collectMsg.customChat) : '';
      this.msgCollectList = this.msgCollectList?.filter((item) => item.chatId !== chatMsgCollectModel.chatId)
      this.msgCollectList = [chatMsgCollectModel].concat(this.msgCollectList ?? []);
      addResult = true;
    } else {
      addResult = false;
    }
    return new Promise<void>((resolve, reject) => {
      setTimeout(() => {
        if (addResult) {
          CollectDataManager.getInstance()
            .setCollectData(this.msgCollectList ? JSON.stringify(this.msgCollectList).replaceAll('__ob_', '') : '');
          resolve();
        } else {
          reject()
        }
      }, 1000)
    });
  }

  getCollectMsgList(): ChatMsgCollectModel[] {
    return this.msgCollectList ?? [];
  }
}