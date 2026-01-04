import { GlobalState } from 'business_home/src/main/ets/utils/GlobalState';
import { ImageInfo, ImageInfos } from 'module_wallpaper_details';
import { RouterMap, RouterUtils } from 'lib_common';
import { DataHelper } from 'business_home/src/main/ets/data/mock/DataHelper';

@ObservedV2
export class NewMarkVM {
  @Trace selectEdit: boolean = false;
  @Trace selectAll: boolean = false;
  @Trace canDelete: boolean = false;
  @Trace select: ImageInfo[] = [];
  @Trace list: ImageInfo[] = [];
  @Trace isLoading: boolean = true;

  constructor() {
    this.list = [];
    this.isLoading = true;
  }

  aboutToAppear(): void {
    this.loadMarks();
    GlobalState.addFavoriteUpdateListener(this.updateListener);
  }

  aboutToDisappear(): void {
    GlobalState.removeFavoriteUpdateListener(this.updateListener);
  }

  addSelect(imageInfo: ImageInfo) {
    imageInfo.select = true;
    this.list = JSON.parse(JSON.stringify(this.list)) as ImageInfo[]
    this.select.push(imageInfo);
    this.selectAll = this.select.length === this.list.length ? true : false;
    this.canDelete = true;
  }

  public hasSelect(url: string): boolean {
    return this.select.some(item => item.url === url);
  }

  addSelectAll() {
    this.select.push(...this.list)

    for (let image of this.list) {
      image.select = true;
    }

    this.list = JSON.parse(JSON.stringify(this.list)) as ImageInfo[]
    this.selectAll = true;
    this.canDelete = true;
  }

  removeSelect(imageInfo: ImageInfo) {
    imageInfo.select = false;
    this.list = JSON.parse(JSON.stringify(this.list)) as ImageInfo[]
    this.select = this.select.filter(item => item.url !== imageInfo.url)
    this.selectAll = false;
    this.canDelete = this.select.length > 0 ? true : false;
  }

  removeSelectAll() {
    for (let image of this.list) {
      image.select = false;
    }
    this.list = JSON.parse(JSON.stringify(this.list)) as ImageInfo[]
    this.select = []
    this.selectAll = false;
    this.canDelete = false;
  }

  async loadMarks(): Promise<void> {
    this.isLoading = true;
    this.list = JSON.parse(JSON.stringify(DataHelper.getInstance().getFavorites())) as ImageInfo[]
    this.isLoading = false;
  }

  async cancelMark(index: number): Promise<void> {
    if (index >= 0 && index < this.list.length) {
      const mark = this.list[index];
      DataHelper.getInstance().removeFavoriteByUrl(mark.url)
      await this.loadMarks();
    }
  }

  delete() {
    DataHelper.getInstance().removeFavorite(this.select)
    this.list = JSON.parse(JSON.stringify(DataHelper.getInstance().getFavorites())) as ImageInfo[];
    this.select = []
    this.selectAll = false;
    this.selectEdit = this.list.length > 0 ? true : false;
    this.canDelete = this.select.length > 0 ? true : false;
  }

  async goDetail(index: number): Promise<void> {
    try {
      const imageInfos: ImageInfos = {
        url: this.list[index].url,
        list: this.list
      };

      // 跳转到详情页
      RouterUtils.pushPathByName(RouterMap.NEW_ROUTER_MAP_WALLPAPER_DETAIL, imageInfos);
    } catch (error) {
    }
  }

  private updateListener: () => void = () => this.loadMarks();
}