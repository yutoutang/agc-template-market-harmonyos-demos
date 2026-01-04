import { cryptoFramework } from '@kit.CryptoArchitectureKit';

export class RandomUtils {
  /**
   * 获取随机数(符合安全随机数)
   * @param leng 长度
   * @returns
   */
  static getRandomIndex(leng: number) {
    let rand = cryptoFramework.createRandom();
    // 设置生成随机数的字节长度为1
    let randData = rand.generateRandomSync(1);
    // 自定义范围(0-10之内)
    let num: number = randData.data[0] * leng / 255;
    num = Math.floor(num);
    return num;
  }

  static getRandom(leng: number) {
    let rand = cryptoFramework.createRandom();
    // 设置生成随机数的字节长度为1
    let randData = rand.generateRandomSync(1);
    // 自定义范围(0-10之内)
    let num: number = randData.data[0] * leng / 255;
    return num;
  }
}