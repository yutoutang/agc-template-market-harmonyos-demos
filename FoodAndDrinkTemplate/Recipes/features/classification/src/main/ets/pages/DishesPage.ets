import { AccountUtil, buildTitleBar, CommonConstants, RouterMap, RouterModule } from 'commonlib';
import { DishesVM } from '../viewModels/DishesVM';
import { LengthMetrics, promptAction } from '@kit.ArkUI';
import { RecipeIngredient } from '../types/Index';
import { RecipeStep } from 'network';
import { BasketItem } from 'shopping_basket';

@Builder
export function DishesPageBuilder() {
  DishesPage();
}

@ComponentV2
struct DishesPage {
  @Local vm: DishesVM = new DishesVM();

  aboutToAppear(): void {
    this.vm.init();
  }

  @Computed
  get isInBasket() {
    return this.vm.basketList.list.some((item: BasketItem) => item.id === this.vm.recipeDetail?.id);
  }

  build() {
    NavDestination() {
      Stack() {
        Scroll() {
          Column() {
            Image($r(`app.media.${this.vm.recipeDetail?.thumbnail}`)).width(CommonConstants.FULL_WIDTH);

            Column() {
              Column() {
                Row() {
                  Text(this.vm.recipeDetail?.title)
                    .fontSize(20)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .layoutWeight(1)
                  Row() {
                    Image(this.vm.collection ? $r('app.media.ic_star') : $r('app.media.ic_star_fill'))
                      .width(24)
                      .height(24);
                    Text(this.vm.collection ? '已收藏' : '收藏')
                      .fontSize(10)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .margin({ left: 8 });
                  }.onClick(() => {
                    this.vm.collectCb()
                  });
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .padding({ top: 24, bottom: 24 });

                Divider().strokeWidth(1)
              }

              Column() {
                Row() {
                  Row() {
                    Image($r(`app.media.${this.vm.recipeDetail?.authorAvatar}`)).width(40).height(40).borderRadius(20);
                    Text(this.vm.recipeDetail?.author)
                      .fontSize(14)
                      .fontColor($r('sys.color.font_primary'))
                      .margin({ left: 4 });
                  }.onClick(() => {
                    RouterModule.push(RouterMap.BLOGGER_PROFILE_PAGE,
                      { 'id': this.vm.recipeDetail?.authorId } as Record<string, number>)
                  })

                  Button(this.vm.isFollower ? '已关注' : '关注', { controlSize: ControlSize.SMALL })
                    .fontSize($r('sys.float.Body_M'))
                    .fontColor(this.vm.isFollower ? '#E84026' : $r('sys.color.font_on_primary'))
                    .fontWeight(FontWeight.Medium)
                    .backgroundColor(this.vm.isFollower ? '#33FD4238' : '#FD4238')
                    .onClick(() => {
                      this.vm.changeFollower(!this.vm.isFollower)
                    })
                }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                Text(this.vm.recipeDetail?.description)
                  .fontSize(12)
                  .fontColor($r('sys.color.font_secondary'))
                  .margin({ top: 12 });

              }
              .width('100%')
              .padding({ top: 24 })
              .alignItems(HorizontalAlign.Start);

              Column() {
                Row() {
                  Text('用料').fontSize(18).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'));
                  Button(this.isInBasket ? '已加入菜篮子' : '加入菜篮子',
                    { controlSize: ControlSize.SMALL })
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .padding({
                      top: 4,
                      bottom: 4,
                      left: 8,
                      right: 8,
                    })
                    .backgroundColor('#0D000000')
                    .onClick(() => {
                      this.vm.addBasket()
                    });
                }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                Divider().strokeWidth(1).margin({ top: 12 })
                ForEach(this.vm.recipeDetail?.ingredients, (item: RecipeIngredient) => {
                  Row({ space: 8 }) {
                    Text(item.name).fontSize(12).fontColor($r('sys.color.font_primary')).layoutWeight(1);
                    Text() {
                      Span(item.quantity);
                      Span(item.unit);
                    }.fontSize(12).fontColor($r('sys.color.font_primary')).layoutWeight(1);
                  }.padding({ top: 12, bottom: 12 }).width('100%');

                  Divider().strokeWidth(1)
                }, (item: RecipeIngredient, index) => item.name + item.quantity + item.unit);
              }.margin({ top: 24 })

              Column() {
                ForEach(this.vm.recipeDetail?.steps, (item: RecipeStep) => {
                  Column() {
                    Text(`步骤 ${item.stepNumber}`)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .margin({ top: 4 });
                    Image($r('app.media.img_step')).width('100%').borderRadius(16).margin({ top: 16 });
                    Text(item.description).fontSize(14).fontColor($r('sys.color.font_primary')).margin({ top: 12 });
                  }.padding({ top: 12, bottom: 12 }).width('100%').alignItems(HorizontalAlign.Start);

                  Divider().strokeWidth(1)
                }, (item: RecipeStep, index) => item.stepNumber + item.description);
              }
            }.padding({ left: 16, right: 16 });

          }
        }
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);

        Image($r('app.media.ic_basket')).width(40).height(40).onClick(() => {
          if (AccountUtil.getUserInfo().isLogin) {
            RouterModule.push(RouterMap.SHOPPING_BASKET_PAGE);
          } else {
            promptAction.showToast({ message: '未登录，请登录后重试！' });
            RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
          }

        }).margin({ bottom: 50, right: 16 });
      }.alignContent(Alignment.BottomEnd);

    }.title(buildTitleBar(this.vm.recipeDetail?.title), { paddingStart: LengthMetrics.vp(16) });
  }
}

