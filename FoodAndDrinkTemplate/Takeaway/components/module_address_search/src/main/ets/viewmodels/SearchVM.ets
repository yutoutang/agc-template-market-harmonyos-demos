import { site } from '@kit.MapKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { HistoryListModel, HistoryUtil } from '../utils/HistoryUtil';
import { IAddressInfo } from '../types/Address';
import { Logger } from '../utils/Logger';

const TAG = '[SearchVM]';

@ObservedV2
export class SearchVM {
  // 当前文本
  @Trace text: string = '';
  // 搜索历史结果
  @Trace historyList: HistoryListModel = HistoryUtil.getHistoryList();
  // 搜索补全结果
  @Trace searchList: IAddressInfo[] = [];
  // 正在搜索
  @Trace searching: boolean = false;
  private static _instance: SearchVM;

  public static get instance() {
    if (!SearchVM._instance) {
      SearchVM._instance = new SearchVM();
    }
    return SearchVM._instance;
  }

  /** 自动补全地址 **/
  public async autoCompleteAddress() {
    if (!this.text) {
      return;
    }
    this.searching = true;
    let params: site.QueryAutoCompleteParams = { query: this.text, language: 'zh' };

    site.queryAutoComplete(params)
      .then(res => {
        if (res.sites) {
          this.searchList = res.sites.map(item => {
            return {
              siteId: item.siteId,
              name: item.name,
              addr: item.formatAddress,
              location: item.location,
            } as IAddressInfo;
          });
        }
        Logger.info(TAG, 'Succeeded in querying.');
        this.searching = false;
      })
      .catch((err: BusinessError) => {
        // 搜索结果为空时 报错异常码
        if (err.code === 1002603001) {
          this.searchList.length = 0;
        }
        Logger.error(TAG, 'Failed in querying:' + JSON.stringify(err));
        this.searching = false;
      });
  }

  /** 重置参数 **/
  public resetSearchData(text: string) {
    this.text = text;
    this.searchList.length = 0;
    this.searching = false;
  }
}
