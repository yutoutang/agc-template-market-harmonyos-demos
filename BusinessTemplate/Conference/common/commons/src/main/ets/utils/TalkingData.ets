
export class MyTalkingData {
  /**
   * 生成36位UUID，带-
   */
  static generateUUID36(): string {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
    const uuid = new Array<string>(36);
    let rand = 0;
    for (let i = 0; i < 36; i++) {
      if (i === 8 || i === 13 || i === 18 || i === 23) {
        uuid[i] = '-';
      } else if (i === 14) {
        uuid[i] = '4';
      } else {
        if (rand <= 0x02) {
          rand = 0x2000000 + (MyTalkingData.getRandomFloat() * 0x1000000) | 0;
        }
        const r = rand & 0xf;
        rand = rand >> 4;
        uuid[i] = chars[(i === 19) ? (r & 0x3) | 0x8 : r];
      }
    }
    return uuid.join('');
  }

  /**
   * 生成0-1随机数
   * @returns
   */
  public static getRandomFloat() {
    return Math.abs(Math.sin(Date.now()));
  }
}