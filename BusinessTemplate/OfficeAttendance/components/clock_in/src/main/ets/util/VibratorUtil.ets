import { BusinessError } from '@kit.BasicServicesKit';
import { vibrator } from '@kit.SensorServiceKit';

const TAG: string = 'VibratorUtil';

export class VibratorUtil {
  public static notification(duration: number, id: number): void {
    try {
      // 触发马达振动
      vibrator.startVibration({
        type: 'time',
        duration: duration,
      }, {
        id: id,
        usage: 'notification'
      }, (error: BusinessError) => {
        if (error) {
          console.error(TAG, `Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
          return;
        }
        console.info(TAG, 'Succeed in starting vibration');
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.info(TAG, `An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
    }
  }
}