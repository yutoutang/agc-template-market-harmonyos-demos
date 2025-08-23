import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import dayJs from 'dayjs'
import {
  agenda2x2Data,
  agenda2x4Data,
  agenda4x4Data,
  Card2x2Model,
  Card2x4Model,
  Card4x4Model,
  CardAgendaEventParams,
  initCardData,
  MyConfig,
  PreferencesUtil,
} from 'commons';
import { FormDataModel } from 'commons';


const TAG: string = 'EntryFormAbility';
const DOMAIN_NUMBER: number = 0xFF00;

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    if (!want || !want.parameters) {
      hilog.error(0x0000, TAG, `FormAbility onAddForm want or want.parameters is undefined`);
      return formBindingData.createFormBindingData('');
    }
    let formName: string = want.parameters[formInfo.FormParam.NAME_KEY] as string;
    let formId: string = want.parameters[formInfo.FormParam.IDENTITY_KEY] as string;
    let util = PreferencesUtil.getInstance();
    let preferences = util.getPreferences(this.context);
    let qrcode = preferences.getSync(`qrCode`, '') as string
    util.addFormId(preferences, formId);
    if (formName === 'widget') {
      let formData = new FormDataModel(formId);
      formData.day = this.calculateRemainingDays()
      formData._day = Math.ceil(dayJs('2025-06-22').diff(dayJs()) / (1000 * 3600 * 24))
      return formBindingData.createFormBindingData(formData);
    }
    if (formName === 'ticketWidget') {
      let key: string = `${formId}_ticket`;
      util.preferencesPut(preferences, key, 'ticket');
      let formData = new FormDataModel(formId);
      formData.qrcode = qrcode || '';
      return formBindingData.createFormBindingData(formData);
    }
    if (formName === 'smallAgendaWidget') {
      let key: string = `${formId}_agendaList_2x2`;
      util.preferencesPut(preferences, key, 'agendaList_2x2');
      let formData = new FormDataModel(formId);
      let data = preferences.getSync(`agendaList_2x2`, agenda2x2Data) as Card2x2Model
      // 是不是只有一个tab
      if (data.xiList.length > 0) {
        formData.agendaList_2x2 = data.xiList[0]
      }
      if (data.sanList.length > 0) {
        formData.agendaList_2x2 = data.sanList[0]
      }
      return formBindingData.createFormBindingData(formData);
    }
    if (formName === 'mediumAgendaWidget') {
      let key: string = `${formId}_agendaList_2x4`;
      util.preferencesPut(preferences, key, 'agendaList_2x4');
      let formData = new FormDataModel(formId);
      let data = preferences.getSync(`agendaList_2x4`, agenda2x4Data) as Card2x4Model
      // 是不是只有一个tab
      formData.agendaList_2x4 = data.sanList
      return formBindingData.createFormBindingData(formData);
    }
    if (formName === 'bigAgendaWidget') {
      let key: string = `${formId}_agendaList_4x4`;
      util.preferencesPut(preferences, key, 'agendaList_4x4');
      let formData = new FormDataModel(formId);
      let data = preferences.getSync(`agendaList_4x4`, agenda4x4Data) as Card4x4Model
      formData.agendaList_4x4 = data.sanList
      return formBindingData.createFormBindingData(formData);
    }
    return formBindingData.createFormBindingData('');
  }


  onUpdateForm(formId: string, wantParams?: Record<string, Object>) {

    new MyConfig(this.context);
    let util = PreferencesUtil.getInstance();
    let preferences = util.getPreferences(this.context);
    let smallAgendaWidget: string = `${formId}_agendaList_2x2`;
    let mediumAgendaWidget: string = `${formId}_agendaList_2x4`;
    let bigAgendaWidget: string = `${formId}_agendaList_4x4`;
    if (preferences.hasSync(smallAgendaWidget) ||
        preferences.hasSync(mediumAgendaWidget) ||
        preferences.hasSync(bigAgendaWidget)) {
      this.updateCardData(formId, () => {
        // 2x2
        if (preferences.hasSync(smallAgendaWidget)) {
          // 生成随机数
          let util = PreferencesUtil.getInstance();
          let preferences = util.getPreferences(this.context);
          let smallAgendaWidgetList: Card2x2Model = agenda2x2Data
          smallAgendaWidgetList = util.getPreferencesValue(preferences, `agendaList_2x2`) as Card2x2Model
          let formData = new FormDataModel(formId);
          if (smallAgendaWidgetList.xiList.length > 0) {
            formData.agendaList_2x2 = smallAgendaWidgetList.xiList[0]
          }
          if (smallAgendaWidgetList.sanList.length > 0) {
            formData.agendaList_2x2 = smallAgendaWidgetList.sanList[0]
          }
          let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
          formProvider.updateForm(formId, formMsg)

        }
        // 2x4
        if (preferences.hasSync(mediumAgendaWidget)) {
          // 生成随机数
          let util = PreferencesUtil.getInstance();
          let preferences = util.getPreferences(this.context);
          let mediumAgendaWidgetList: Card2x4Model = agenda2x4Data
          mediumAgendaWidgetList = util.getPreferencesValue(preferences, `agendaList_2x4`) as Card2x4Model
          let formData = new FormDataModel(formId);
          formData.agendaList_2x4 = mediumAgendaWidgetList.sanList
          let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
          formProvider.updateForm(formId, formMsg)

        }
        // 4x4
        if (preferences.hasSync(bigAgendaWidget)) {
          let util = PreferencesUtil.getInstance();
          let preferences = util.getPreferences(this.context);
          let bigAgendaWidgetList: Card4x4Model = agenda4x4Data
          bigAgendaWidgetList = util.getPreferencesValue(preferences, `agendaList_4x4`) as Card4x4Model
          let formData = new FormDataModel(formId);
          formData.agendaList_4x4 = bigAgendaWidgetList.sanList
          let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
          formProvider.updateForm(formId, formMsg)

        }
      })
      return
    }
    // Called to notify the form provider to update a specified form.
    let formData = new FormDataModel(formId);
    formData.day = this.calculateRemainingDays()
    formData._day = Math.ceil(dayJs('2025-06-22').diff(dayJs()) / (1000 * 3600 * 24))
    let formInfo: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
    formProvider.updateForm(formId, formInfo)
  }

  async updateCardData(formId: string, callback?: () => void) {
    initCardData(this.context, callback)
  }

  onFormEvent(formId: string, message: string): void {
    new MyConfig(this.context);
    let util = PreferencesUtil.getInstance();
    let preferences = util.getPreferences(this.context);
    // Called when a specified message event defined by the form provider is triggered.
    hilog.info(DOMAIN_NUMBER, TAG, `FormAbility onFormEvent, formId = ${formId}, message: ${JSON.stringify(message)}`);
    let parMessage: CardAgendaEventParams = JSON.parse(message)
    let formData = new FormDataModel(formId);
    if (parMessage.action === 'message') {
      if (parMessage.message === '2x2') {
        let data = preferences.getSync(`agendaList_2x2`, agenda2x2Data) as Card2x2Model
        // 下一个
        if (parMessage.eventName === 'next') {
          let index = parMessage.showIndex
          formData.agendaList_2x2 = data.xiList.length > 0 ? data.xiList[index] : data.sanList[index]
        }
      }
      if (parMessage.message === '2x4') {
        let data = preferences.getSync(`agendaList_2x4`, agenda2x4Data) as Card2x4Model
        if (parMessage.eventName === 'changeAddress') {
          if (parMessage.tabName === '大广场') {
            formData.agendaList_2x4 = data.sanList
          } else {
            formData.agendaList_2x4 = data.xiList
          }
        }
      }
      if (parMessage.message === '4x4') {
        let data = preferences.getSync(`agendaList_4x4`, agenda4x4Data) as Card4x4Model
        if (parMessage.eventName === 'changeAddress') {
          if (parMessage.tabName === '大广场') {
            formData.agendaList_4x4 = data.sanList
          } else {
            formData.agendaList_4x4 = data.xiList
          }
        }
      }
    }
    let formInfo: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
    formProvider.updateForm(formId, formInfo).then(() => {
      hilog.info(DOMAIN_NUMBER, TAG, 'FormAbility updateForm success.');
    }).catch((error: BusinessError) => {
      hilog.info(DOMAIN_NUMBER, TAG, `Operation updateForm failed. Cause: ${JSON.stringify(error)}`);
    })
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
    PreferencesUtil.getInstance().removeFormId(this.context, formId);
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }

  calculateRemainingDays() {
    const targetDate = dayJs('2025-06-20'); // 设置目标日期
    const now = dayJs();
    const diff = targetDate.diff(now);
    let dayDiff = Math.ceil(diff / (1000 * 3600 * 24));
    if (dayDiff < 0) {
      dayDiff = 0;
    }
    return dayDiff.toString()
  }

  getCurrentDate() {
    let currentDate = new Date();
    let month = currentDate.getMonth() + 1;
    let date = currentDate.getDate();
    return `${month}月${date}日`;
  }
}