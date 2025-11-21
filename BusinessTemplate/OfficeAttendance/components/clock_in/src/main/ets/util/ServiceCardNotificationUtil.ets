import { ClockInStatus } from '../types/ClockInEnums';
import { preferences } from '@kit.ArkData';
import { formBindingData, formProvider } from '@kit.FormKit';
import { DataManager } from '../controller/DataManagerController';

const TAG: string = '[ServiceCardNotificationUtil]';

export class ServiceCardNotificationUtil {
  public static notify(checkInStatus: ClockInStatus) {
    const preference = preferences.getPreferencesSync(getContext(), {
      'name': 'service_card'
    });

    let key: string = 'formIds';
    const formIds = preference.getSync(key, '') as string;
    if (formIds === '') {
      return;
    }

    const formIdArray = formIds.split(',');
    const value = DataManager.getTodayCheckInDetail();
    const startTime = value[0].time;
    const endTime = value[value.length - 1].time;
    formIdArray.forEach((formId: string) => {
      let formMsg: formBindingData.FormBindingData =
        formBindingData.createFormBindingData({
          startTime: startTime,
          endTime: endTime,
          checkInStatus: checkInStatus
        });
      formProvider.updateForm(formId, formMsg).then(() => {
        console.info(TAG, `updateForm success.`);
      }).catch((error: Error) => {
        console.error(TAG, `updateForm failed: ${JSON.stringify(error)}`);
      });
    })

  }
}