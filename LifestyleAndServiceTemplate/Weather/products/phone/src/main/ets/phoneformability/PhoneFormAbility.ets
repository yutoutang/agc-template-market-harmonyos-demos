import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { WidgetUtil } from 'business_home';

export default class PhoneFormAbility extends FormExtensionAbility {
  public onAddForm(want: Want) {
    let formData: Record<string, null> = { 'location': null };
    let formId = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string | undefined;
    if (formId) {
      WidgetUtil.addFormId(formId, this.context);
      WidgetUtil.publishFormId(formId, false);
    }
    WidgetUtil.updateWeatherInfo(this.context);
    return formBindingData.createFormBindingData(formData);
  }

  public onUpdateForm(formId: string): void {
    WidgetUtil.updateWeatherInfo(this.context, formId);
  }

  public onRemoveForm(formId: string) {
    WidgetUtil.delFormId(formId, this.context);
    WidgetUtil.publishFormId(formId, true);
  }
}