import { formBindingData, formProvider } from '@kit.FormKit';
import { FormDataModel } from '../viewModel/FormDataModel';
import { PreferencesUtil } from './PreferencesUtil';

export function sendUserInfo(qrCode: string) {
  let util = PreferencesUtil.getInstance();
  let context1 = getContext() as Context
  let preferences = util.getPreferences(context1);
  util.preferencesPut(preferences, 'qrCode', qrCode || '')
  let idArr = PreferencesUtil.getInstance().getFormIds(preferences);
  if (idArr.length > 0) {
    idArr.forEach((formId: string) => {
      if (preferences.getSync(`${formId}_ticket`, '') as string === 'ticket') {
        let formData = new FormDataModel(formId);
        formData.qrcode = qrCode || '';
        let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
        formProvider.updateForm(formId, formMsg)
      }
    })
  }
}
