import { Context } from '../common/Context';
import { buildLoadingMask } from '../common/CommonBuilders';
import { IColor, IStyle, Operation, RouteMap, ViewModelState } from '../common/CommonConst';
import { AddressDTO } from '../model/AddressDTO';
import { AddressVM } from '../viewmodel/AddressVM';
import { ComponentContent } from '@kit.ArkUI';

@ComponentV2
struct AddressManagePage {
  @Param
  public ctx: Context = new Context();

  public aboutToAppear(): void {
    this.ctx.addressMgr.initialize();
  }

  public build(): void {
    NavDestination() {
      Column() {
        Stack() {
          if (this.ctx.addressMgr.state === ViewModelState.READY) {
            this.buildMainContent();
          }
          if (this.ctx.addressMgr.isLoading) {
            buildLoadingMask();
          }
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .backgroundColor(IColor.BACKGROUND)
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    }
    .title('收货地址')
  }

  @Builder
  private buildMainContent(): void {
    Column() {
      Column() {
        if (this.ctx.addressMgr.list.length > 0) {
          List({ space: IStyle.CARD_GAP }) {
            ForEach(this.ctx.addressMgr.list, (address: AddressVM) => {
              ListItem() {
                this.buildAddressCard(address);
              }
            }, (item: AddressVM, index: number) => index + '__' + JSON.stringify(item))
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .contentStartOffset(IStyle.CARD_GAP)
          .contentEndOffset(IStyle.CARD_GAP)
          .padding({ left: IStyle.CARD_GAP, right: IStyle.CARD_GAP })
        } else {
          Text('您还没有添加收货地址')
            .fontSize(14)
            .fontColor(IColor.BLACK_TRANSPARENT_60)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

      this.buildCreateAddressButton();
    }
    .height('100%')
  }

  @Builder
  private buildAddressCard(address: AddressVM): void {
    Column() {
      Column() {
        Text(address.title)
          .width('100%')
          .fontColor(IColor.BLACK_TRANSPARENT_90)
          .fontSize(14)
          .fontWeight(600)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(address.fullAddress)
          .width('100%')
          .fontColor(IColor.BLACK_TRANSPARENT_60)
          .fontSize(12)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 5 })
      }

      Row() {
        Row() {
          Checkbox()
            .width(14)
            .height(14)
            .margin(0)
            .hitTestBehavior(HitTestMode.None)
            .selectedColor(IColor.THEME_PRIMARY)
            .shape(CheckBoxShape.CIRCLE)
            .select(address.isDefault)
          Text(address.isDefault ? '已默认' : '设为默认')
            .fontColor(IColor.BLACK_TRANSPARENT_60)
            .fontSize(12)
            .margin({ left: 8 })
        }
        .responseRegion([
          {
            x: 0,
            y: '-50%',
            width: '100%',
            height: '200%',
          },
          {
            x: -16,
            y: '-50%',
            width: 16,
            height: '200%',
          },
        ])
        .onClick(() => {
          const dto: AddressDTO = address.toDTO();
          dto.isDefault = !dto.isDefault;
          this.ctx.addressMgr.update(dto);
        })

        Row() {
          Button(){
            Text('删除')
              .fontColor(IColor.BLACK_TRANSPARENT_60)
              .fontSize(10)
          }
            .width(36)
            .backgroundColor(IColor.WHITE)
            .borderWidth(1)
            .borderColor('#99000000')
            .onClick(() => {
              const uiContext = this.getUIContext();
              const promptAction = uiContext.getPromptAction();
              const params: ParamsForDeleteDialog = new ParamsForDeleteDialog();
              const contentNode = new ComponentContent(uiContext, wrapBuilder(buildDeleteDialog), params);
              params.onClose = () => promptAction.closeCustomDialog(contentNode);
              params.onDelete = () => this.ctx.addressMgr.delete(address.id);
              promptAction.openCustomDialog(contentNode);
            })
          Button(){
            Text('修改')
              .fontColor(IColor.BLACK_TRANSPARENT_60)
              .fontSize(10)
          }
            .width(36)
            .backgroundColor(IColor.WHITE)
            .borderWidth(1)
            .borderColor(IColor.BLACK_TRANSPARENT_60)
            .margin({ left: 8 })
            .onClick(() => {
              this.ctx.editingAddressDTO = address.toDTO();
              this.ctx.operation = Operation.EDIT;
              this.ctx.navPathStack.pushPathByName(RouteMap.ADDRESS_EDIT_PAGE, this.ctx);
            })
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(110)
    .borderRadius(8)
    .backgroundColor(IColor.WHITE)
    .padding(16)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      if (this.ctx.isSelectMode) {
        this.ctx.onSelect(address.toDTO());
        this.ctx.navPathStack.pop();
      }
    })
  }

  @Builder
  private buildCreateAddressButton(): void {
    Column() {
      Row() {
        Button('添加新地址')
          .width('80%')
          .height(40)
          .fontWeight(500)
          .backgroundColor(IColor.THEME_PRIMARY)
          .onClick(() => {
            this.ctx.editingAddressDTO = null;
            this.ctx.operation = Operation.CREATE;
            this.ctx.navPathStack.pushPathByName(RouteMap.ADDRESS_EDIT_PAGE, this.ctx);
          })
      }
      .width('100%')
      .height(52)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .backgroundColor(IColor.WHITE)
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
  }
}

@Builder
export function buildAddressManagePage(_: string, context: Context) {
  AddressManagePage({ ctx: context })
}

class ParamsForDeleteDialog {
  public onClose = () => {
  };
  public onDelete = () => {
  };
}

@Builder
function buildDeleteDialog(params: ParamsForDeleteDialog): void {
  Column() {
    Text('确定要删除地址吗？')
      .fontSize(16)
      .fontColor(IColor.BLACK_TRANSPARENT_90)
      .fontWeight(600)
      .margin({ bottom: 8 })
    Row() {
      Button() {
        Text('取消')
          .fontColor(IColor.BLACK_TRANSPARENT_60)
      }
      .width('50%')
      .height(40)
      .fontWeight(500)
      .type(ButtonType.Normal)
      .backgroundColor(Color.Transparent)
      .onClick(() => params.onClose())

      Button() {
        Text('删除')
          .fontColor(IColor.THEME_PRIMARY)
      }
      .width('50%')
      .height(40)
      .fontWeight(500)
      .type(ButtonType.Normal)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        params.onClose();
        params.onDelete();
      })
    }
    .width('100%')
  }
  .width('90%')
  .padding(16)
  .justifyContent(FlexAlign.Start)
  .backgroundColor(IColor.GRAY_LIGHT_TRANSPARENT_85)
  .borderRadius(24)
}