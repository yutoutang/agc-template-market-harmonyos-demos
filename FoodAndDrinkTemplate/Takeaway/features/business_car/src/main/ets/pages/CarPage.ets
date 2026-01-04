import { CommonConfirmDialog, CommonConstants, Logger, RouterMap, RouterUtils, singleClick } from 'lib_common'
import { AddrMgtApi, CarGoodsInfo, MyCar, MyCartServiceApi, StoreServiceApi, SubmitOrderItem } from 'lib_takeaway_api'
import { IAddrInfo } from 'lib_takeaway_api/src/main/ets/database/IAddrType'
import { NavHeaderBar } from 'lib_widget'
import { buildNoCarCard } from '../components/NoCarCard'
import { CarPageViewModel } from '../viewmodels/CarPageViewModel'
import { promptAction } from '@kit.ArkUI'
import { CarGoodsCard } from '../components/CarGoodsCard'

const TAG = '[CarPage]';

@Builder
export function CarPageBuilder() {
  CarPage()
}

@ComponentV2
struct CarPage {
  @Local carVM: CarPageViewModel = new CarPageViewModel()
  @Local selectAll: boolean = false
  @Local selectButton: boolean = false
  @Consumer() selectedIndex: number = 0;
  @Local addressInfo: IAddrInfo | undefined = undefined
  @Provider() checkCarIds: string[] = []
  @Provider() allCarIds: string[] = []
  @Local storeCars: MyCar[] = []

  @Monitor('selectedIndex')
  public selectedIndexChange(monitor: IMonitor) {
    if (this.selectedIndex === 2) {
      Logger.info(TAG,' CarPage selectedIndexChange')
      this.refreshCar()
    } else {
      this.carVM.isShow = false
    }
  }

  @Monitor('carVM.myCar.myCar')
  public myCarChange(monitor: IMonitor) {
    Logger.info(TAG,' CarPage myCarChange')
    this.refreshCar()
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '购物车',
          isSubTitle: false,
          rightPartBuilder: () => {
            this.editCarBuilder()
          },
        })

        if (!this.carVM.userInfoModel.isLogin) {
          // 未登录
          Row() {
            buildNoCarCard(this.carVM.userInfoModel.isLogin)
          }
          .padding(10)
        } else if (this.carVM.isShow) {
          // 已登录
          // 地址
          Row({ space: 8 }) {
            Image($r('app.media.local_fill'))
              .width(18)
              .objectFit(ImageFit.Cover)
            Text(this.carVM.settingInfo.address)
              .fontSize(16)
              .fontWeight(400)
              .fontColor('#333333')
              .textAlign(TextAlign.Start)
              .layoutWeight(1)
          }
          .onClick(() => {
            let onPop: Callback<PopInfo> = (pop: PopInfo) => {
              this.refreshCar()
            }
            RouterUtils.pushPathByName(RouterMap.MY_ADDRESS_SEARCH_PAGE, null, onPop)
          })
          .height(64)
          .margin({
            bottom: 10,
            left: 10,
            right: 10
          })
          .padding(10)
          .borderRadius(12)
          .backgroundColor($r('sys.color.comp_background_list_card'))

          // 购物车列表和结算
          Stack({ alignContent: Alignment.BottomStart }) {
            // 购物车列表
            Scroll() {
              Column() {
                Column() {
                  if (this.storeCars.length > 0) {
                    // 展示购物车
                    List({ space: 10 }) {
                      ForEach(this.storeCars, (storeCard: MyCar) => {
                        ListItem() {
                          Column() {
                            // 店铺名称
                            Row() {
                              CheckboxGroup({ group: storeCard.storeId })
                                .checkboxShape(CheckBoxShape.CIRCLE)
                                .selectedColor($r('app.color.orange_yellow'))
                                .margin({
                                  left: 10,
                                  right: 10
                                })
                                .onChange((result: CheckboxGroupResult) => {
                                  storeCard.checkCarIds = result.name
                                  if (result.status === SelectStatus.None) {
                                    this.carVM.checkStoreList =
                                      this.carVM.checkStoreList.filter((item: string) => item !== storeCard.storeId)
                                  } else {
                                    if (!this.carVM.checkStoreList.includes(storeCard.storeId)) {
                                      this.carVM.checkStoreList.push(storeCard.storeId)
                                    }
                                  }
                                })
                              Row() {
                                Text(storeCard.storeInfo?.name)
                                  .fontColor('#333333')
                                  .fontWeight(600)
                                  .fontSize(16)
                                Image($r('app.media.ic_right'))
                                  .width($r('app.float.arrow_right_w'))
                                  .draggable(false)
                                  .margin({
                                    left: 4
                                  })
                              }
                              .onClick(() => {
                                let onPop: Callback<PopInfo> = (pop: PopInfo) => {
                                  this.selectedIndex = 2
                                  this.refreshCar()
                                }
                                this.selectedIndex = 0
                                RouterUtils.pushPathByName(RouterMap.STORE_PAGE, storeCard.storeId, onPop)
                              })
                            }
                            .width(CommonConstants.FULL_PERCENT)
                            .justifyContent(FlexAlign.Start)

                            Divider().width(CommonConstants.FULL_PERCENT).margin({
                              top: 8,
                              bottom: 8
                            })

                            // 店铺购物车卡片
                            ForEach(storeCard.goodsList, (carGoods: CarGoodsInfo) => {
                              CarGoodsCard({
                                carVM: this.carVM,
                                carGoods: carGoods,
                                storeId: storeCard.storeId,
                                refresh: () => {
                                  this.refreshCar()
                                }
                              })
                            }, (carGoods: CarGoodsInfo) => carGoods.id)

                          }
                          .padding({
                            top: 8,
                            bottom: 8
                          })
                          .width(CommonConstants.FULL_PERCENT)
                          .borderRadius(12)
                          .backgroundColor(Color.White)
                        }

                      }, (storeCard: MyCar) => storeCard.storeId)
                    }
                  } else {
                    buildNoCarCard(this.carVM.userInfoModel.isLogin)
                  }
                }
                .width(CommonConstants.FULL_PERCENT)
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Start)
                .borderRadius(12)
              }
              .width(CommonConstants.FULL_PERCENT)
              .constraintSize({ minHeight: '100%' })
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Start)
            }
            .padding(10)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
            .layoutWeight(1)
            .width(CommonConstants.FULL_PERCENT)
            .margin({
              bottom: 52
            })

            // 结算栏
            Row() {
              // 全选按钮
              Row() {
                Checkbox({ name: '全选' })
                  .selectedColor($r('app.color.orange_yellow'))
                  .select(this.selectButton)
                  .shape(CheckBoxShape.CIRCLE)
                  .onChange((value: boolean) => {
                    this.onChangeAllCheck(value)
                  })
                Text('全选')
                  .fontColor('#909399')
                  .fontWeight(400)
                  .fontSize(14)
                  .margin({ left: 8, right: 8 })
              }
              .margin({
                left: 14
              })
              .height(CommonConstants.FULL_PERCENT)

              Row() {
                Row() {
                  Text('合计: ')
                    .fontColor('#909399')
                    .fontWeight(400)
                    .fontSize(14)
                  Text($r('app.string.currency_symbol'))
                    .fontColor('#121212')
                    .fontWeight(500)
                    .fontSize(12)
                  Text(this.carVM.totalPrice.toFixed(2).toString())
                    .fontColor('#121212')
                    .fontWeight(500)
                    .fontSize(16)
                }
                .visibility(this.carVM.isEdit ? Visibility.None : Visibility.Visible)

                Button() {
                  Text(this.carVM.isEdit ? '删除' : '去结算')
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Color.White)
                }
                .margin({
                  left: 12,
                  right: 15,
                })
                .width(92)
                .height(32)
                .backgroundColor(this.carVM.isEdit ? '#FF2D19' : $r('app.color.app_theme'))
                .onClick(singleClick(() => {
                  this.submitClick()
                }))
              }
              .justifyContent(FlexAlign.End)
              .alignItems(VerticalAlign.Center)

            }
            .width(CommonConstants.FULL_PERCENT)
            .height(52)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .justifyContent(FlexAlign.SpaceBetween)
            .visibility(this.storeCars.length > 0 ? Visibility.Visible : Visibility.None)
          }
          .width(CommonConstants.FULL_PERCENT)
          .layoutWeight(1)

        }

      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .onReady((context: NavDestinationContext) => {
      this.refreshCar()
      this.addressInfo = AddrMgtApi.defaultAddress()
    })
    .hideTitleBar(true)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('sys.color.background_secondary'))

  }

  onChangeAllCheck(value: boolean) {
    if ((value && !this.selectAll) || (value && this.selectAll)) {
      // 全选按钮选中,但数据处于非全选状态,将所有数据置为全选
      for (let storeCar of this.carVM.myCar.myCar) {
        for (let goods of storeCar.goodsList) {
          goods.isCheck = true
        }
      }
      let tem = this.allCarIds
      this.checkCarIds = tem
      this.selectButton = true
    } else if (!value && this.selectAll) {
      // 全选按钮未选中,数据处于全选状态
      for (let storeCar of this.carVM.myCar.myCar) {
        for (let goods of storeCar.goodsList) {
          goods.isCheck = false
        }
      }
      this.checkCarIds = []
      this.selectButton = false
    }
  }

  refreshCar() {
    let tempStoreCars: MyCar[] = MyCartServiceApi.getMyCar(this.carVM.settingInfo.address)
    this.storeCars = tempStoreCars
    let tempCarTotalMoney: number = 0
    let tempCheckCarIds: string[] = []
    let tempAllCarIds: string[] = []
    let tempGoodsTotalNum: number = 0
    let tempCheckGoodsList: CarGoodsInfo[] = []
    let tempCheckStoreList: string[] = []
    for (let storeCar of this.storeCars) {
      let checkIds: string[] = []
      for (let carGoods of storeCar.goodsList) {
        tempAllCarIds.push(carGoods.id)
        tempGoodsTotalNum += carGoods.num
        if (carGoods.isCheck) {
          tempCheckGoodsList.push(carGoods)
          checkIds.push(carGoods.id)
          tempCheckCarIds.push(carGoods.id)
          tempCarTotalMoney += carGoods.money * carGoods.num
        }
      }
      storeCar.checkCarIds = checkIds
      if (!tempCheckStoreList.includes(storeCar.storeId)) {
        tempCheckStoreList.push(storeCar.storeId)
      }
    }
    this.checkCarIds = tempCheckCarIds
    this.allCarIds = tempAllCarIds
    this.selectAll = this.checkCarIds.length === this.allCarIds.length && this.allCarIds.length > 0
    this.selectButton = this.selectAll
    this.carVM.isShow = true
    this.carVM.totalPrice = tempCarTotalMoney
    this.carVM.totalGoodsNum = tempGoodsTotalNum
    this.carVM.checkGoodsList = tempCheckGoodsList
    this.carVM.checkStoreList = tempCheckStoreList
  }

  submitClick() {
    if (this.carVM.isEdit) {
      // 删除
      CommonConfirmDialog.show({
        primaryTitle: '是否删除所选餐品',
        content: '',
        confirm: () => {
          let flag = MyCartServiceApi.batchDeleteCar(this.checkCarIds)
          if (flag === 1) {
            this.refreshCar()
            promptAction.showToast({ message: '删除成功' })
          }
        },
      })
    } else {
      let errorMsg: string = this.carVM.checkSubmit(this.carVM.checkStoreList, this.carVM.checkGoodsList)
      if (errorMsg) {
        promptAction.showToast({ message: errorMsg })
        return
      }
      let checkStoreInfo = StoreServiceApi.queryStoreByStoreId(this.carVM.checkStoreList[0])
      if (checkStoreInfo) {
        let submitOrderItem: SubmitOrderItem = {
          carGoodsList: this.carVM.checkGoodsList,
          storeInfo: checkStoreInfo,
        }
        let onPop: Callback<PopInfo> = (pop: PopInfo) => {
          this.refreshCar()
        }
        RouterUtils.pushPathByName(RouterMap.ORDER_SUBMIT, submitOrderItem, onPop)
      }

    }
  }

  @Builder
  editCarBuilder() {
    Row() {
      Text(this.carVM.isEdit ? '退出编辑' : '编辑')
        .fontSize(14)
        .fontWeight(400)
        .fontColor('#8B8B8B')
        .onClick(() => {
          this.carVM.isEdit = !this.carVM.isEdit
          this.refreshCar()
        })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
    .visibility(this.carVM.userInfoModel.isLogin ? Visibility.Visible : Visibility.None)
  }
}