import { showDialogParams } from '@abner/dialog';
import { ToastUtil } from '@pura/harmony-utils';
import { common } from '@kit.AbilityKit';
import { nfcController } from '@kit.ConnectivityKit';
import {
  NFC_STATE_COMPLETE,
  NFC_STATE_NORMAL,
  NFC_STATE_READ,
  NFC_STATE_WAIT,
  NFC_STATE_WRITE,
  OnNfcChanged,
  startCloneNFC,
  startFormatNFC,
  startReadNFC,
  stopNFC } from '../common/nfc/Nfc';
import { ActionModel, DetailModel, ResultModel } from '../model/Index';
import { nfcOpenDialog, NfcOpenDialogParams } from '../components/NfcOpenDialog';
import { getNavPathStack } from '../common/Route';
import { ACTION_TYPE, NFC_TYPE, PAGE_TYPES, RTYPE } from '../common/Enum';
import { nfcCardInfo } from '../db/NfcCardInfo';

@ObservedV2
export class ActionVM {
  private static _instance: ActionVM;
  @Trace data: ActionModel = new ActionModel(ACTION_TYPE.ACTION_READ);
  @Trace state: number = NFC_STATE_NORMAL;

  public static get instance() {
    if (!ActionVM._instance) {
      ActionVM._instance = new ActionVM();
    }
    return ActionVM._instance;
  }

  getImgRes(state: number): Resource {
    switch (this.data.action) {
      case ACTION_TYPE.ACTION_READ:
        return state === NFC_STATE_NORMAL ? $r('app.media.read_card')
          : $r('app.media.attach_card');
      case ACTION_TYPE.ACTION_CLONE:
        return $r('app.media.clone_card');
      case ACTION_TYPE.ACTION_CHECK_SUPPORT_CLONE:
        break;
    }
    return $r('app.media.read_card');
  }

  getBtnStr(state: number): ResourceStr {
    switch (this.data?.action ?? ACTION_TYPE.ACTION_READ) {
      case ACTION_TYPE.ACTION_READ:
        return state === NFC_STATE_NORMAL ? '开始读取' : this.state === NFC_STATE_WAIT ? '请贴附卡片' : '正在读卡...';
      case ACTION_TYPE.ACTION_CLONE:
        switch (state) {
          case NFC_STATE_NORMAL:
            return '开始克隆';
          case NFC_STATE_WAIT:
            return '请贴附卡片';
          case NFC_STATE_READ:
            return '正在读卡备份...';
          case NFC_STATE_WRITE:
          default:
            return '正在克隆...';
        }
      case ACTION_TYPE.ACTION_CHECK_SUPPORT_CLONE:
        break;
    }
    return '';
  }

  preCheck(): boolean {
    if (canIUse('SystemCapability.Communication.NFC.Core')) {
      if (nfcController.isNfcOpen()) {
        return true;
      } else {
        let params = new NfcOpenDialogParams();
        params.confirm = () => {
          let context = getContext(this) as common.UIAbilityContext;
          context.startAbility({
            bundleName: 'com.huawei.hmos.settings',
            abilityName: 'com.huawei.hmos.settings.MainAbility',
            uri: 'nfc_settings',
          });
        };
        showDialogParams(wrapBuilder(nfcOpenDialog), params);
      }
    } else {
      ToastUtil.showToast('当前设备不支持NFC！');
    }
    return false;
  }

  confirm() {
    if (this.state === NFC_STATE_NORMAL) {
      if (!this.preCheck()) {
        return;
      }
      switch (this.data.action) {
        case ACTION_TYPE.ACTION_READ:
          startReadNFC(this.data.nfcType!, (err, result) => {
            if (err) {
              stopNFC();
              switch (err.code.toString()) {
                case '3100101':
                case '3100201':
                case '3100202':
                  this.state = NFC_STATE_NORMAL;
                  ToastUtil.showToast('克隆失败：请保持卡片贴于手机背面NFC感应区域，请勿移动卡片');
                  break;
                default:
                  this.state = NFC_STATE_NORMAL;
                  ToastUtil.showToast('读卡失败：卡片可能被加密或不支持此种卡片');
                  getNavPathStack()
                    .pushPathByName('ResultPage', new ResultModel(ACTION_TYPE.ACTION_READ, RTYPE.RTYPE_READ_FAIL, this.data));
                  break;
              }
            } else {
              this.state = result.state;
              switch (result.state) {
                case NFC_STATE_WAIT:
                  break;
                case NFC_STATE_READ:
                  break;
                case NFC_STATE_COMPLETE:
                  if (result.nfcInfo) {
                    switch (this.data.nfcType) {
                      case NFC_TYPE.NFC_TYPE_DOOR:
                      case NFC_TYPE.NFC_TYPE_ELEVATOR:
                      case NFC_TYPE.NFC_TYPE_BIKE:
                      default:
                        if (result.nfcInfo.balance >= 0) {
                          this.state = NFC_STATE_NORMAL;
                          ToastUtil.showToast('读卡失败：卡片可能被加密或不支持此种卡片');
                          getNavPathStack()
                            .pushPathByName('ResultPage', new ResultModel(ACTION_TYPE.ACTION_READ, RTYPE.RTYPE_READ_FAIL, this.data));
                          return;
                        }
                        break;
                      case NFC_TYPE.NFC_TYPE_BUS:
                      case NFC_TYPE.NFC_TYPE_BANK:
                        if (result.nfcInfo.balance === -1) {
                          this.state = NFC_STATE_NORMAL;
                          ToastUtil.showToast('读卡失败：卡片可能被加密或不支持此种卡片');
                          getNavPathStack()
                            .pushPathByName('ResultPage', new ResultModel(ACTION_TYPE.ACTION_READ, RTYPE.RTYPE_READ_FAIL, this.data));
                          return;
                        }
                        break;
                    }

                    nfcCardInfo.insertNfcInfo(result.nfcInfo)
                      .then(id => {
                        result.nfcInfo!.id = id;
                        getContext()
                          .eventHub
                          .emit(OnNfcChanged.name,
                            new OnNfcChanged(result.nfcInfo!.type, !result.nfcInfo!.dealHistory,
                              result.nfcInfo!.isMine));
                        getNavPathStack()
                          .replacePathByName('DetailPage', new DetailModel(PAGE_TYPES.PAGE_TYPE_READ, result.nfcInfo));
                      })
                      .catch((e: Error) => {
                        this.state = NFC_STATE_NORMAL;
                        ToastUtil.showToast('读卡失败：卡片可能被加密或不支持此种卡片');
                        getNavPathStack()
                          .pushPathByName('ResultPage', new ResultModel(ACTION_TYPE.ACTION_READ, RTYPE.RTYPE_READ_FAIL, this.data));
                      });
                  } else {
                    this.state = NFC_STATE_NORMAL;
                    ToastUtil.showToast('读卡失败：卡片可能被加密或不支持此种卡片');
                    getNavPathStack()
                      .pushPathByName('ResultPage', new ResultModel(ACTION_TYPE.ACTION_READ, RTYPE.RTYPE_READ_FAIL, this.data));
                  }
                  break;
              }
            }
          });
          break;
        case ACTION_TYPE.ACTION_CLONE:
          startCloneNFC(this.data.nfcType!, this.data.nfcInfo!, (err, result) => {
            if (err) {
              stopNFC();
              switch (err.code.toString()) {
                case '3100101':
                case '3100201':
                case '3100202':
                  this.state = NFC_STATE_NORMAL;
                  getNavPathStack()
                    .pushPathByName('ResultPage', new ResultModel(ACTION_TYPE.ACTION_CLONE, RTYPE.RTYPE_CLONE_FAIL, this.data,
                      '克隆失败：请保持卡片贴于手机背面NFC感应区域，请勿移动卡片'));
                  break;
                default:
                  this.state = NFC_STATE_NORMAL;
                  getNavPathStack()
                    .pushPathByName('ResultPage', new ResultModel(ACTION_TYPE.ACTION_CLONE, RTYPE.RTYPE_CLONE_FAIL, this.data));
                  break;
              }
            } else {
              this.state = result.state;
              switch (result.state) {
                case NFC_STATE_WAIT:
                  break;
                case NFC_STATE_WRITE:
                  break;
                case NFC_STATE_COMPLETE:
                  getNavPathStack()
                    .pushPathByName('ResultPage', new ResultModel(ACTION_TYPE.ACTION_CLONE, RTYPE.RTYPE_CLONE_SUCCESS, this.data));
                  break;
              }
            }
          });
          break;
        case ACTION_TYPE.ACTION_FORMAT:
          startFormatNFC(this.data.nfcType!, this.data, (err, result) => {
            if (err) {
              stopNFC();
              this.state = NFC_STATE_NORMAL;
              switch (err.code.toString()) {
                case '3100101':
                case '3100201':
                case '3100202':
                  ToastUtil.showToast('克隆失败：请保持卡片贴于手机背面NFC感应区域，请勿移动卡片');
                  break;
                default:
                  ToastUtil.showToast('格式化失败：卡片可能被加密或不支持此种卡片');
                  break;
              }
            } else {
              this.state = result.state;
              switch (result.state) {
                case NFC_STATE_WAIT:
                  break;
                case NFC_STATE_READ:
                  break;
                case NFC_STATE_COMPLETE:
                  break;
              }
            }
          });
          break;
        case ACTION_TYPE.ACTION_CHECK_SUPPORT_CLONE:
          break;
      }
    }
  }
}