import { PreferencesUtil } from './PreferencesUtil';
import {
  Card2x2Model,
  Card2x4Model,
  Card4x4Model,
  ItineraryAndCardAgendaModel
} from '../viewModel/ItineraryAndCardAgendaModel';
import { FormDataModel } from '../viewModel/FormDataModel';
import { formBindingData, formProvider } from '@kit.FormKit';

export function handleCardData(metadata: ItineraryAndCardAgendaModel[]) {
  let sanList = metadata.filter((item) => {
    return item.mMategoryI.join(',') === '大广场'
  })
  let xiList = metadata.filter((item) => {
    return item.mMategoryI.join(',') === '溪流村庄'
  })
  if (sanList.length > 0 && xiList.length > 0) {
    sanList.forEach((item) => {
      item.onlyOneTab = false
      item.isShowNext = sanList.length > 1
      item.allNum = sanList.length
    })
    xiList.forEach((item) => {
      item.onlyOneTab = false
      item.isShowNext = xiList.length > 1
      item.allNum = xiList.length
    })
  } else {
    sanList.forEach((item) => {
      item.onlyOneTab = true
      item.isShowNext = sanList.length > 1
      item.allNum = sanList.length
    })
    xiList.forEach((item) => {
      item.onlyOneTab = true
      item.isShowNext = xiList.length > 1
      item.allNum = xiList.length
    })
  }
  return [
    sanList,
    xiList
  ]
}

let smallAgendaWidgetList: Card2x2Model = {
  isLastData: true, //  是否是最后一个
  onlyOneTab: true, //  是否只有一条数据
  sanList: [],
  xiList: [],
}
let mediumAgendaWidgetList: Card2x4Model = {
  sanList: [],
  xiList: [],
}
let bigAgendaWidgetList: Card4x4Model = {
  sanList: [],
  xiList: [],
}

export async function initCardData(content: Content,
  callback?: () => void) {
  AppStorage.setOrCreate('agendaList_2x2', smallAgendaWidgetList);
  AppStorage.setOrCreate('agendaList_2x4', mediumAgendaWidgetList);
  AppStorage.setOrCreate('agendaList_4x4', bigAgendaWidgetList);
  callback && callback()
}

export async function sendCardData() {
  let util = PreferencesUtil.getInstance();
  let context1 = getContext() as Context
  let preferences = util.getPreferences(context1);

  let idArr = PreferencesUtil.getInstance().getFormIds(preferences);
  if (idArr.length > 0) {
    idArr.forEach((formId: string) => {
      if (preferences.getSync(`${formId}_agendaList_2x2`, '') as string === 'agendaList_2x2') {
        let formData = new FormDataModel(formId);
        let data = preferences.getSync(`agendaList_2x2`, smallAgendaWidgetList) as Card2x2Model
        if (data.xiList.length > 0) {
          formData.agendaList_2x2 = data.xiList[0]
        }
        if (data.sanList.length > 0) {
          formData.agendaList_2x2 = data.sanList[0]
        }
        let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
        formProvider.updateForm(formId, formMsg)
      }
      if (preferences.getSync(`${formId}_agendaList_2x4`, '') as string === 'agendaList_2x4') {
        let formData = new FormDataModel(formId);
        let data = preferences.getSync(`agendaList_2x4`, mediumAgendaWidgetList) as Card2x4Model
        formData.agendaList_2x4 = data.sanList
        let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
        formProvider.updateForm(formId, formMsg)
      }
      if (preferences.getSync(`${formId}_agendaList_4x4`, '') as string === 'agendaList_4x4') {
        let formData = new FormDataModel(formId);
        let data = preferences.getSync(`agendaList_4x4`, bigAgendaWidgetList) as Card4x4Model
        formData.agendaList_4x4 = data.sanList
        let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
        formProvider.updateForm(formId, formMsg)
      }
    })
  }
}

export async function setToken(token: string) {
  let util = PreferencesUtil.getInstance();
  let context1 = getContext() as Context
  let preferences = util.getPreferences(context1);
  util.preferencesPut(preferences, 'token', token)
}

export async function clearToken() {
  let util = PreferencesUtil.getInstance();
  let context1 = getContext() as Context
  let preferences = util.getPreferences(context1);
  util.preferencesPut(preferences, 'token', '')
}