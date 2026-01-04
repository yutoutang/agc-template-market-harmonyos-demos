import { cryptoFramework } from '@kit.CryptoArchitectureKit';

const TAG = '[RandomUtils]';

/**
 * 应用市场utils
 */
export class RandomUtils {
  /**
   * 是否有更新版本
   * @param context
   * @returns
   */
  public static getRandomIndex(leng: number): number {
    let rand = cryptoFramework.createRandom();
    // 设置生成随机数的字节长度为1
    let randData = rand.generateRandomSync(1);
    // 自定义范围(0-10之内)
    let num: number = randData.data[0] * leng / 256;
    num = Math.floor(num);
    return num;
  }
}