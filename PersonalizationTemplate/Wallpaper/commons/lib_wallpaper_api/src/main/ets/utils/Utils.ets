import { cryptoFramework } from '@kit.CryptoArchitectureKit';

/**
 * 通用方法类
 */
export class Utils {
  public static shuffleArray<T>(array: T[]): T[] {
    for (let i = array.length - 1; i > 0; i--) {
      // 生成 0 到 i 之间的随机索引
      let rand = cryptoFramework.createRandom();
      let randData = rand.generateRandomSync(1);
      const j = randData.data[0] % (i + 1);

      // 交换当前元素与随机位置的元素
      const temp = array[i];
      array[i] = array[j]
      array[j] = temp;
    }
    return array;
  }


  public static randomArticleId() {
    let rand = cryptoFramework.createRandom();
    // 生成1个字节的随机数，范围是0-255
    let randData = rand.generateRandomSync(1);
    // 将随机数映射到20-100的范围
    return (randData.data[0] % 81) + 20;
  }
}