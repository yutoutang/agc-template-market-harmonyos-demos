import { util } from '@kit.ArkTS';
import { AlertDialog, LengthMetrics, promptAction } from '@kit.ArkUI';
import { TitleBuilder } from '../common/TitleBuilder';
import { PersonCard } from '../common/PersonCard';
import { RouteMap } from '../common/CommonConst';
import { CommonPersonPageVM } from '../viewModels/CommonPersonPageVM';
import { Context, Contact, SelectMode } from '../common/Types';


@Builder
export function CommonPersonPageBuilder(_: string, context: Context) {
  CommonPersonPage({ ctx: context });
}


@ComponentV2
struct CommonPersonPage {
  @Param ctx: Context = new Context();
  vm: CommonPersonPageVM = CommonPersonPageVM.instance;
  private listScroller: ListScroller = new ListScroller();
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: '确定要删除该参观人吗？',
      primaryButton: {
        value: '取消',
        action: () => {
          this.listScroller.closeAllSwipeActions();
        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.delContact();
          this.listScroller.closeAllSwipeActions();
        },
      },
    }),
  });

  aboutToAppear(): void {
    this.vm.getPersonList();
    this.vm.selectList.length = 0;
  }

  @Builder
  itemEnd(personID: string) {
    Row() {
      Text('删除')
        .padding(5)
        .fontSize(16)
        .backgroundColor($r('sys.color.ohos_id_color_palette8'))
        .fontColor(Color.White)
        .borderRadius($r('sys.float.ohos_id_text_size_body2'))
        .textAlign(TextAlign.Center)
        .width(74)
        .height(74)
        .onClick(() => {
          this.vm.delId = personID;
          this.dialogControllerConfirm.open();
        });
    }.padding(4).justifyContent(FlexAlign.SpaceEvenly);
  }

  build() {
    NavDestination() {
      Column() {
        Column({ space: 12 }) {
          Row() {
            Image($r('app.media.module_person_add')).width(24).height(24);
            Text('新增常用人')
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor('#D1B380');
          }
          .backgroundColor('#FFFFFF')
          .width('100%')
          .border({ width: 1, color: '#D1B380' })
          .borderRadius(16)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.ctx.contact = new Contact(util.generateRandomUUID(false), '身份证', '', '', '');
            this.ctx.navPathStack.pushPathByName(RouteMap.PERSON_EDIT_PAGE, this.ctx);
          });

          // 多选模式
          if (this.ctx.selectMode === SelectMode.MORE_SELECT) {
            List({ space: 12 }) {
              ForEach(this.vm.personList, (item: Contact) => {
                ListItem() {
                  PersonCard({
                    cardId: item.cardID,
                    name: item.name,
                    isDisable: this.ctx.disableId.includes(item.personID),
                    onCheckChange: (value: boolean) => {
                      if (value) {
                        this.vm.selectContact(item);
                      } else {
                        this.vm.cancelContact(item);
                      }
                    },
                  });

                };
              }, (item: Contact) => JSON.stringify(item));
            }.scrollBar(BarState.Off).layoutWeight(1);
          }

          // 单选模式
          if (this.ctx.selectMode === SelectMode.SINGLE_SELECT) {
            List({ space: 12 }) {
              ForEach(this.vm.personList, (item: Contact) => {
                ListItem() {
                  PersonCard({
                    cardId: item.cardID,
                    name: item.name,
                    isChecked: false,
                  });
                }.onClick(() => {
                  this.ctx.onSelect(this.vm.cloneContact(item));
                  this.ctx.navPathStack.pop();
                });

              }, (item: Contact) => JSON.stringify(item));
            }.scrollBar(BarState.Off).layoutWeight(1);
          }

          // 列表展示模式
          if (this.ctx.selectMode === SelectMode.NO_SELECT) {
            List({ space: 12, scroller: this.listScroller }) {
              ForEach(this.vm.personList, (item: Contact) => {
                ListItem() {
                  PersonCard({
                    cardId: item.cardID,
                    name: item.name,
                    isChecked: false,
                  });
                }.onClick(() => {
                  this.ctx.contact = item;
                  this.ctx.navPathStack.pushPathByName(RouteMap.PERSON_EDIT_PAGE, this.ctx);
                })
                .swipeAction({
                  end: {
                    builder: () => {
                      this.itemEnd(item.personID);
                    },
                  }, edgeEffect: SwipeEdgeEffect.Spring,
                });

              }, (item: Contact) => JSON.stringify(item));
            }.scrollBar(BarState.Off).layoutWeight(1);
          }


        }.layoutWeight(1);


        if (this.ctx.selectMode === SelectMode.MORE_SELECT) {
          Column() {
            Button('确定')
              .height(40)
              .width('100%')
              .backgroundColor('#D1B380')
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_on_primary'))
              .onClick(() => {
                if (this.vm.selectList.length) {
                  this.ctx.onSelect(this.vm.cloneContactList(this.vm.selectList));
                  this.ctx.navPathStack.pop();
                } else {
                  promptAction.showToast({ message: '请选择至少一个常用人！' });
                }
              });
          }.padding(12).backgroundColor('#F3F4F5');
        }


      }.padding({ top: 4, left: 16, right: 16 }).height('100%');
    }.title(TitleBuilder('常用人'), { paddingStart: LengthMetrics.vp(16) })
    .backgroundColor('#F3F4F5').onShown(() => {
      this.vm.getPersonList();
    });
  }
}