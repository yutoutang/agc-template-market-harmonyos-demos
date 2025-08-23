import { cryptoFramework } from '@kit.CryptoArchitectureKit';

export class CommonUtil {
  public static generateRandomInRange(n: number, m: number): number {
    const random = CommonUtil._generateRandom0To255() / 256 * (m - n + 1) + n;
    return Math.floor(random);
  }

  public static generateRandomBoolean(): boolean {
    return CommonUtil._generateRandom0To255() < 128;
  }

  private static _generateRandom0To255(): number {
    let rand = cryptoFramework.createRandom();
    let randData = rand.generateRandomSync(1);
    return randData.data[0];
  }
}