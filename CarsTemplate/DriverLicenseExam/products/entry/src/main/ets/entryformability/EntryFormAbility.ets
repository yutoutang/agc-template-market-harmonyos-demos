import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { CommonModel, CommonConstants, PreferencesUtil } from '@ohos_agcit/driver_license_exam_commonlib';

interface GeneratedObjectLiteralInterface_1 {
  index: string | number | bigint | true | object;
  didCount: string | number | bigint | true | object;
  totalCount: string | number | bigint | true | object;
}

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    const formId = want.parameters![formInfo.FormParam.IDENTITY_KEY] as string;
    const preferencesUtil = PreferencesUtil.getInstance();
    const preference = preferencesUtil.getPreferences(this.context)
    preferencesUtil.addFormId(preference, formId);
    const index = preferencesUtil.getPreferencesValue(preference, 'tabIndex') || 0;
    const didCount = preferencesUtil.getPreferencesValue(preference, 'didCount') || 0;
    const totalCount = preferencesUtil.getPreferencesValue(preference, 'totalCount') || 0;
    const data: GeneratedObjectLiteralInterface_1 = {
      index:index,
      didCount: didCount,
      totalCount: totalCount
    }
    return formBindingData.createFormBindingData(data);
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
}