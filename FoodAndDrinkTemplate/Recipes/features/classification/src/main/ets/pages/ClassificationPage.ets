import { ClassificationVM } from '../viewModels/ClassificationVM';
import { CommonConstants, HeaderMenuBuilder, RouterMap, RouterModule } from 'commonlib';
import { LinkCategory } from 'link_category';

@Builder
export function ClassificationPageBuilder() {
  ClassificationPage();
}

@ComponentV2
struct ClassificationPage {
  vm: ClassificationVM = ClassificationVM.instance;

  aboutToAppear(): void {
    this.vm.init()
  }

  build() {
    NavDestination() {
      Row() {
        Text('菜谱分类')
          .fontSize(24)
          .fontWeight(500)
          .padding({ left: 8 })
          .height(56)

        Row() {
          Image($r('app.media.ic_title_search')).width(40).height(40).onClick(() => {
            RouterModule.push(RouterMap.SEARCH,
              {
                'keyword': this.vm.recipeCategoryList[this.vm.currentIndex].name,
                'form': CommonConstants.CLASSIFICATION_PAGE,
              } as Record<string, string>)
          })
          Image($r('app.media.ic_title_menu'))
            .width(40)
            .height(40)
            .margin({ left: 8 })
            .bindMenu(HeaderMenuBuilder())
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ left: 16, right: 16 })
      .constraintSize({ maxWidth: '100%' })
      LinkCategory({
        recipeCategoryList: this.vm.recipeCategoryList,
        currentIndex: this.vm.currentIndex,
        gridCount: this.vm.gridCount,
        onRecipeClick: (listItem) => {
          RouterModule.push(RouterMap.DISHES, { 'id': listItem.id } as Record<string, number>)
        },
        changeCurrentIndex: (index: number) => {
          this.vm.changeCurrentIndex(index)
        },
      })
    }.hideTitleBar(true)
  }
}