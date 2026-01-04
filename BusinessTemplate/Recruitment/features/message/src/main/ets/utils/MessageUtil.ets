import { CMChatGroupMemberInfo } from 'instant_messaging';
import { buffer, util } from '@kit.ArkTS';

/**
 * 消息工具类
 */
export class MessageUtil {
  /**
   * 解析群成员列表
   * @param memberList 群成员列表
   */
  static parseGroupAvatar(memberList: CMChatGroupMemberInfo[]) {
    let count = 0;
    let groupAvatar: string[][] = [];
    for (let index = 0; index < memberList.length; index++) {
      const element = memberList[index];
      let rowAvatar: string[] = groupAvatar[count] ?? [];
      rowAvatar.push(element.avatarUrl);
      groupAvatar[count] = rowAvatar;

      if (memberList.length < 5) {
        if (memberList.length === 3) {
          if (index === 0) {
            count++;
          }
        }
        if (rowAvatar.length >= 2) {
          count++;
        }
      } else {
        if (memberList.length === 5) {
          if (index === 1) {
            count++;
          }
        } else if (memberList.length === 7) {
          if (index === 0) {
            count++;
          }
        } else if (memberList.length === 8) {
          if (index === 1) {
            count++;
          }
        }
        if (rowAvatar.length >= 3) {
          count++;
        }
      }
      if (index >= 8) {
        break;
      }
    }
    return groupAvatar;
  }

  /**
   * 字符串转ArrayBuffer
   */
  static strToArrayBuffer(content: string) {
    try {
      return buffer.from(content, 'utf-8').buffer;
    } catch (error) {
      return new ArrayBuffer(0)
    }
  }

  /**
   * ArrayBuffer转字符串
   */
  static arrayBufferToStr(data: ArrayBuffer) {
    let textDecoder = util.TextDecoder.create('utf-8');
    return textDecoder.decodeToString(new Uint8Array(data));
  }
}