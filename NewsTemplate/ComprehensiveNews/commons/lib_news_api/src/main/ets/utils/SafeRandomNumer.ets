import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[SafeRandomGenerate]';

/*
 * 生成安全随机数
 * */
export class SafeRandomGenerate {
  /**
   * Generate a byteCount-byte random number.
   * @param byteCount
   * @returns
   */
  public static generate(byteCount: number = 4): string {
    try {
      const rand = cryptoFramework.createRandom();
      const randData = rand.generateRandomSync(byteCount);
      if (randData.data.length !== 0) {
        const data = randData.data.join('');
        UtilLog.info(TAG, `Succcess to generateRandomSync. data: ${data}`);
        return data;
      } else {
        UtilLog.warn(TAG, `randData.data.length is empty`);
        return '';
      }
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      UtilLog.error(TAG, `Failed to generateRandomSync. Code is ${e.code}, message is ${e.message}`);
      return '';
    }
  }
}