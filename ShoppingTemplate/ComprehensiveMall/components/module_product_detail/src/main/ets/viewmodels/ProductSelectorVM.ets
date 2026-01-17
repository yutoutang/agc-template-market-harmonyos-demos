import {ToastDialog as promptAction} from '@hw-agconnect/ui-toast'
import { SpecViewModel } from '../commons/Models';
import { ProductSelectionInfo, SkuItem, SpecOption } from '../commons/Types';
import { ProductDetailApis } from '../https/Apis';

@ObservedV2
export class ProductSelectorVM {
  @Trace
  stockInfo: ProductSelectionInfo | undefined = undefined;
  @Trace
  skuMap: Map<string[], SkuItem> = new Map();
  @Trace
  selectedCount: number = 1;
  @Trace
  specViewListMap: Map<string, SpecViewModel[]> = new Map();
  @Trace
  selectedKey: Record<string, SpecViewModel | undefined> = {};
  @Trace
  curSku: SkuItem | undefined = undefined;
  @Trace
  selectorBanner: ResourceStr | undefined = undefined;

  // 当前选中规格的价格
  @Computed
  get curPrice() {
    if (this.curSku) {
      return this.curSku.price * this.selectedCount;
    }
    if (this.stockInfo) {
      return this.stockInfo.priceRange;
    }
    return 0;
  }

  // 当前选中规格的原始价格
  @Computed
  get curDashPrice() {
    if (this.curSku) {
      return this.curSku.dashPrice * this.selectedCount;
    }
    if (this.stockInfo) {
      return this.stockInfo.priceRange;
    }
    return 0;
  }

  // 是否可以提交规格
  @Computed
  get enableConfirm() {
    return !this.curSku || (this.curSku && this.curSku.stock > 0);
  }

  async initData(id: string) {
    this.stockInfo = await ProductDetailApis.getProductStockInfo(id);
    if (this.stockInfo) {
      this.getStockMap(this.stockInfo.skuItems);
      this.getSpecViewListMap();
      this.getSelectorBanner();
    }
  }

  // 获取规格库存数据
  getStockMap(skuItems: SkuItem[]) {
    skuItems.forEach((skuItem) => {
      const specs: [string, string][] = Object.entries(skuItem.specs);
      const key = specs.map((spec) => spec[1]);
      this.skuMap.set(key, skuItem);
    });
  }

  // 获取规格列表展示数据
  getSpecViewListMap() {
    const helper = (option: SpecOption) => {
      const arr: SpecViewModel[] = [];
      option.values.forEach((item) => {
        const view = new SpecViewModel(
          option.key,
          option.label,
          item.id,
          item.text,
          this.isSpecOutOfStock(item.id, this.skuMap),
          false,
        );
        view.image = item.image;
        arr.push(view);
      });
      this.specViewListMap.set(option.key, arr);
    };
    if (this.stockInfo?.specOptionWithImage) {
      helper(this.stockInfo.specOptionWithImage);
    }
    if (this.stockInfo?.specOptions) {
      this.stockInfo.specOptions.forEach((option) => {
        helper(option);
      });
    }
  }

  // 该规格的商品是否没货
  isSpecOutOfStock(key: string, map: Map<string[], SkuItem>) {
    for (let sku of Array.from(map)) {
      const keys = sku[0];
      const skuItem = sku[1];
      if (keys.includes(key) && skuItem.stock) {
        return false;
      }
    }
    return true;
  }

  // 点击规格按钮
  handleSpecClick(item: SpecViewModel) {
    const old = this.selectedKey[item.specKey];
    if (old) {
      old.isSelected = false;
    }
    if (old?.id === item.id) {
      this.selectedKey[item.specKey] = undefined;
    } else {
      this.selectedKey[item.specKey] = item;
      item.isSelected = true;
    }
    this.refreshSpecView();
    this.getCurSku();
    this.getSelectorBanner();
    this.selectedCount = 1;
  }

  // 刷新当前选中规格的库存状态
  refreshSpecView() {
    const selectedKeys = Object.keys(this.selectedKey);
    selectedKeys.forEach((key) => {
      const selectedSpec = this.selectedKey[key];
      const map: Map<string[], SkuItem> = new Map();
      Array.from(this.skuMap).forEach((sku) => {
        const keys = sku[0];
        if (!selectedSpec || keys.includes(selectedSpec.id)) {
          map.set(keys, sku[1]);
        }
      });
      Array.from(this.specViewListMap).forEach((spec) => {
        if (spec[0] !== key) {
          spec[1].forEach((model) => {
            model.isTempOutOfStock = this.isSpecOutOfStock(model.id, map);
          });
        }
      });
    });
  }

  // 获取当前选中的商品
  getCurSku() {
    const skuArr = Array.from(this.skuMap);
    const temp = Object.entries(this.selectedKey);
    const selectedKeys = temp
      .map((item) => item[1]?.id)
      .filter((item) => item !== undefined);
    for (let sku of skuArr) {
      if (sku[0].every((ele) => selectedKeys.includes(ele))) {
        this.curSku = sku[1];
        return;
      }
    }
    this.curSku = undefined;
  }

  // 修改商品数量
  handleCountChange(isAdd: boolean = true) {
    if (!this.curSku) {
      promptAction.showToast({ message: '还有规格没有选择' });
      return;
    }
    if (this.curSku.stock <= 0) {
      promptAction.showToast({ message: '库存不足' });
      return;
    }
    if (isAdd) {
      if (this.selectedCount >= this.curSku.stock) {
        promptAction.showToast({ message: '数量不能再增加了，超出库存限制！' });
      } else {
        this.selectedCount++;
      }
    } else {
      if (this.selectedCount <= 1) {
        promptAction.showToast({ message: '宝贝数量不能再减少了~' });
      } else {
        this.selectedCount--;
      }
    }
  }

  // 获取商品展示图
  getSelectorBanner() {
    if (this.stockInfo?.specOptionWithImage) {
      const value = this.selectedKey[this.stockInfo.specOptionWithImage.key];
      if (value) {
        const imageItem = this.stockInfo.specOptionWithImage.values.filter(
          (item) => item.id === value.id,
        );
        if (imageItem?.length === 1) {
          this.selectorBanner = imageItem[0].image;
          return;
        }
      }
    }
    this.selectorBanner = this.stockInfo?.defaultBanner ?? '';
  }
}
