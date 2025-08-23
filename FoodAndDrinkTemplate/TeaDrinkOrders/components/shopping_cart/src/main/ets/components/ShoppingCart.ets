import { CarGoodsInfo, MyCar } from '../models/Index';
import { MyCarComp } from './MyCarComp';
import { MyCarListComp } from './MyCarListComp';

@ComponentV2
export struct ShoppingCart {
  @Param @Require myCar: MyCar
  @Param @Require carCheck: Array<string>
  @Param isRest: boolean = false;
  @Local showCarList: boolean = false;
  @Event goConfirmOrderCb: (carGoodsSelect: Array<CarGoodsInfo>) => void = () => {
  };
  @Event clearCarCb: () => void = () => {
  };
  @Event updateCarCb: (id: string, num: number) => void = () => {
  };
  @Event changeCarCheck: (id: string, isDelete?: boolean) => void = () => {
  };

  build() {
    Column() {
      MyCarListComp({
        carGoods: this.myCar.carGoods,
        carCheck: this.carCheck,
        changeCarPanel: () => this.changeCarPanel(),
        clearCarCb: () => this.clearCarCb(),
        updateCarCb: (id: string, num: number) => this.updateCarCb(id, num),
        changeCarCheck: (id: string, isDelete?: boolean) => this.changeCarCheck(id, isDelete),
      }).layoutWeight(1).visibility(this.showCarList ? Visibility.Visible : Visibility.None)
      // 购物车
      MyCarComp({
        myCar: this.myCar,
        carCheck: this.carCheck,
        isRest: this.isRest,
        showCarList: this.showCarList,
        changeCarPanel: (value: boolean) => this.changeCarPanel(value),
        goConfirmOrderCb: (carGoodsSelect: Array<CarGoodsInfo>) => this.goConfirmOrderCb(carGoodsSelect),
      }).visibility(this.myCar.carGoods.length ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
  }

  changeCarPanel(value = false): void {
    this.showCarList = value
  }
}
