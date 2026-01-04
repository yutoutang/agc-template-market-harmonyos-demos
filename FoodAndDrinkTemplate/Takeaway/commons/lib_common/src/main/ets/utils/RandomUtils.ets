import cryptoFramework from '@ohos.security.cryptoFramework';
import { BusinessError } from '@ohos.base';

export class RandomUtils {
  // Generate a random number in promise mode
  public static doRandByPromise() {
    let rand = cryptoFramework.createRandom();
    let len = 4; // Generate a 4-byte random number
    let promiseGenerateRand = rand.generateRandom(len);
    promiseGenerateRand.then(randData => {
      console.info('[Promise]: rand result: ' + randData.data);
      try {
        rand.setSeed(randData);
      } catch (error) {
        let e: BusinessError = error as BusinessError;
        console.error(`setSeed failed, ${e.code}, ${e.message}`);
      }
    }).catch((error: BusinessError) => {
      console.error('[Promise]: error: ' + error.message);
    });
  }

  public static random(max: number) {
    let rand = cryptoFramework.createRandom();
    // 设置生成随机数的字节长度为1
    let randData = rand.generateRandomSync(1);
    // 自定义范围(0-10之内)
    let num: number = randData.data[0] * max / 255;
    return num;
  }

  doRandByCallback() {
    let rand = cryptoFramework.createRandom();
    let len = 4; // Generate a 4-byte random number
    rand.generateRandom(len, (err, randData) => {
      if (err) {
        console.error('[Callback]: err: ' + err.code);
      } else {
        console.info('[Callback]: generate random result: ' + randData.data);
        try {
          rand.setSeed(randData);
        } catch (error) {
          let e: BusinessError = error as BusinessError;
          console.error(`setSeed failed, ${e.code}, ${e.message}`);
        }
      }
    });
  }

  // Generate a random number synchronously
  public static doRandBySync() {
    let rand = cryptoFramework.createRandom();
    let len = 24; // Generate a 24-byte random number
    try {
      let randData = rand.generateRandomSync(len);
      if (randData != null) {
        console.info('[Sync]: rand result: ' + randData.data);
      } else {
        console.error('[Sync]: get rand result fail!');
      }
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      console.error(`do rand failed, ${e.code}, ${e.message}`);
    }
  }
}