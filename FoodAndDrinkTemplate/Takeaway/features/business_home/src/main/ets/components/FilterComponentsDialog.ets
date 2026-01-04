import { FilterComponents } from 'lib_product_waterflow';
import { HomeViewModel } from '../viewmodels/HomeViewModel';
import { HashMap } from '@kit.ArkTS';
import { RandomUtils } from 'lib_common';

@CustomDialog
struct FilterComponentsDialog {
  controller?: CustomDialogController;
  vm: HomeViewModel = new HomeViewModel();
  changeByThreshold: number = 0
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }
  changeByThresholdZ: (value: number) => void = (value: number) => {
  }

  build() {
    Column() {
      Text('筛选店铺')
        .fontWeight(FontWeight.Bold)
        .fontSize(24)
        .alignSelf(ItemAlign.Start)
        .padding({ left: 16, top: 16 })
      FilterComponents({
        scoreThreshold: this.vm.scoreThreshold,
        salesThreshold: this.vm.salesThreshold,
        deliveryTimeThreshold: this.vm.deliveryTimeThreshold,
        cancel: this.cancel,
        confirm: this.confirm,
        handleClickItem: (item: HashMap<string, number>) => {
          // 遍历item值，获取对应的数据
          if (!item.isEmpty()) {
            this.vm.scoreThreshold = item.get(FilterComponents.EVALUATION_KEY)
            this.vm.salesThreshold = item.get(FilterComponents.SALESVOLUME_KEY)
            this.vm.deliveryTimeThreshold = item.get(FilterComponents.TIME_KEY)
          } else {
            // 清空筛选条件
            this.vm.scoreThreshold = undefined
            this.vm.salesThreshold = undefined
            this.vm.deliveryTimeThreshold = undefined
          }
          //随机数
          this.changeByThreshold = RandomUtils.random(100)
          this.changeByThresholdZ(this.changeByThreshold)
        }
      });
    }
    .height('100%')
    .width('100%')
  }
}

export { FilterComponentsDialog };
