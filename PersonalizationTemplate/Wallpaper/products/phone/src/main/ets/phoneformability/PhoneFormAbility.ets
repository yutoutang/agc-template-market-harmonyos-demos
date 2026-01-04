import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { Logger } from 'lib_common';

const TAG: string = '[PhoneFormAbility]';

export default class PhoneFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    class FormData {
      // 每一张卡片创建时都会被分配一个唯一的id
      formId: string = want.parameters!['ohos.extra.param.key.form_identity'].toString();
    }

    let formData = new FormData()
    // 返回数据给卡片
    return formBindingData.createFormBindingData(formData);
  }

  onRemoveForm(formId: string) {
    Logger.info(TAG, `onRemoveForm, formId = ${formId}`);
  }

  onAcquireFormState(want: Want) {
    return formInfo.FormState.READY;
  }

  onFormEvent(formId: string, message: string) {
    let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(message)
    formProvider.updateForm(formId, formMsg).then(() => {
    }).catch((error: Error) => {
    });
  }
}