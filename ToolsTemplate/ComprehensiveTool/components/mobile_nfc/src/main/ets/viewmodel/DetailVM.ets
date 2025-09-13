import { hide, showDialogParams } from '@abner/dialog';
import { StrUtil, ToastUtil } from '@pura/harmony-utils';
import { OnNfcChanged } from '../common/nfc/Nfc';
import { getNavPathStack } from '../common/Route';
import { addMineDialog } from '../components/AddMineDialog';
import { renameDialog } from '../components/RenameDialog';
import { nfcCardInfo, NfcInfo } from '../db/NfcCardInfo';
import { DetailModel, RenameDialogParams } from '../model/Index';

@ObservedV2
export class DetailVM {
  private static _instance: DetailVM;
  @Trace data: DetailModel = new DetailModel(0, new NfcInfo());
  @Trace nfcInfo: NfcInfo = new NfcInfo();

  public static get instance() {
    if (!DetailVM._instance) {
      DetailVM._instance = new DetailVM();
    }
    return DetailVM._instance;
  }

  private loadData() {
    nfcCardInfo.findById(this.data.nfcInfo.id!)
      .then(result => {
        this.nfcInfo = result;
      }).catch((e: Error) => {
      ToastUtil.showToast('加载失败！');
      getNavPathStack().pop();
    });
  }

  rename() {
    let params = new RenameDialogParams();
    params.name = this.nfcInfo!.name;
    params.confirm = (name: string) => {
      if (StrUtil.isEmpty(name)) {
        ToastUtil.showToast('请先输入名称');
      } else if (name === this.nfcInfo!.name) {
        hide();
      } else {
        nfcCardInfo.findByName(name).then(result => {
          if (result) {
            ToastUtil.showToast('名称重复！');
          } else {
            this.nfcInfo!.name = name;
            nfcCardInfo.updateNfcInfo(this.nfcInfo!).then(result => {
              getContext()
                .eventHub
                .emit(OnNfcChanged.name,
                  new OnNfcChanged(this.nfcInfo.type, !this.nfcInfo.dealHistory, this.nfcInfo.isMine));
              ToastUtil.showToast('修改成功！');
              hide();
              this.loadData();
            }).catch((e: Error) => {
              ToastUtil.showToast('修改失败！');
            });
          }
        }).catch((e: Error) => {
          ToastUtil.showToast('修改失败！');
        });
      }
    };
    showDialogParams(wrapBuilder(renameDialog), params);
  }

  addMine(cardId: string, type: number) {
    nfcCardInfo.findAllWithMine(type).then(result => {
      if (result.length && result.find(item => item.cardId === cardId)) {
        ToastUtil.showToast('您已添加过此卡片，请勿重复添加！');
      } else {
        this.nfcInfo!.isMine = true;
        nfcCardInfo.updateNfcInfo(this.nfcInfo!).then(result => {
          getContext()
            .eventHub
            .emit(OnNfcChanged.name, new OnNfcChanged(this.nfcInfo.type, true, this.nfcInfo.isMine));
          showDialogParams(wrapBuilder(addMineDialog), undefined);
          this.loadData();
        }).catch((e: Error) => {
          ToastUtil.showToast('添加失败！');
        });
      }
    }).catch((e: Error) => {
      ToastUtil.showToast('添加失败！');
    });
  }
}