import { BaseTabs, TabIndexEnum } from 'base_ui';
import { FeaturedRecipes, LazyDataSource, RecipeBriefInfo } from 'featured_recipes';
import { BloggerInfo } from '../types/Index';
import { BloggerInfomation } from './BloggerInfomation';

@ComponentV2
export struct PersonalHomepage {
  @Param bloggerInfo: BloggerInfo = new BloggerInfo();
  @Param recipeList: LazyDataSource<RecipeBriefInfo> = new LazyDataSource();
  @Param isSelf: boolean = false;
  @Param isLogin: boolean = false;
  @Param isFollower: boolean = false;
  @Param currentIndex: number = TabIndexEnum.FIRST;
  @Param isToDelete: boolean = false;
  @Local selectIds: number[] = []
  @BuilderParam userTagBuilderParam: () => void = this.userTagBuilder;
  @BuilderParam membershipBuilderParam: () => void = this.membershipBuilder;
  @BuilderParam uploadBuilderParam: () => void = this.uploadBuilder;
  scroller: Scroller = new Scroller();
  @Event onClickCb: (id: number) => void = () => {
  }
  @Event jumpBloggerInfo: (id: number) => void = () => {
  }
  @Event login: () => void = () => {
  }
  @Event followCb: (isFollower: boolean) => void = () => {
  }
  @Event changeTabIndex: (index: number) => void = () => {
  }
  @Event jumpFollowers: () => void = () => {
  }
  @Event deleteRecipes: (ids: number[]) => void = () => {
  }
  @Event changeDeleteState: (isToDelete: boolean) => void = () => {
  }

  @Builder
  userTagBuilder() {
  }

  @Builder
  membershipBuilder() {
  }

  @Builder
  uploadBuilder() {
  }

  @Computed
  get showDeleteBtn() {
    return this.isSelf && this.isLogin && this.isToDelete && this.currentIndex === TabIndexEnum.FIRST
  }

  @Monitor('isToDelete')
  changeDelete(monitor: IMonitor) {
    if (!monitor.value()?.now) {
      this.selectIds = []
    }
  }

  build() {
    Stack() {
      Scroll(this.scroller) {
        Column() {
          BloggerInfomation({
            bloggerInfo: this.bloggerInfo,
            isSelf: this.isSelf,
            isLogin: this.isLogin,
            isFollower: this.isFollower,
            userTagBuilderParam: (): void => {
              this.userTagBuilderParam()
            },
            membershipBuilderParam: (): void => {
              this.membershipBuilderParam()
            },
            login: () => {
              this.login()
            },
            jumpFollowers: () => {
              this.jumpFollowers()
            },
            followCb: (isFollower: boolean) => {
              this.followCb(isFollower)
            },
          })
          BaseTabs({
            tabsTitle: ['菜谱', '收藏'],
            currentIndex: this.currentIndex,
            changeTabs: (index: number) => {
              this.changeTabIndex(index)
            },
          }).margin({ top: 12, bottom: 10 })
          FeaturedRecipes({
            dishesList: this.recipeList,
            canDelete: this.showDeleteBtn,
            isToDelete: this.isToDelete,
            onClickCb: (id: number) => {
              this.onClickCb(id)
            },
            jumpBloggerInfo: (id: number) => {
              this.jumpBloggerInfo(id)
            },
            deleteRecipes: (ids: number[]) => {
              this.deleteRecipes(ids)
            },
            changeSelect: (id: number, flag: boolean) => {
              if (flag) {
                this.selectIds.push(id)
              } else {
                this.selectIds = this.selectIds.filter(item => item !== id);
              }
            },
            changeDeleteState: (isToDelete: boolean) => {
              this.changeDeleteState(isToDelete)
            },
          }) {
            if (this.currentIndex === TabIndexEnum.FIRST) {
              this.uploadBuilderParam()
            }
          }
        }
        .width('100%')
        .padding({ top: 12, left: 16, right: 16 })
        .alignItems(HorizontalAlign.Start);

      }.width('100%').height('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)

      if (this.showDeleteBtn) {
        Row({ space: 8 }) {
          Image($r('app.media.ic_public_trash')).fillColor(Color.White).width(19).height(17);
          Text('删除').fontColor(Color.White).fontSize(16).fontWeight(FontWeight.Medium);
        }
        .width(128)
        .height(40)
        .borderRadius(20)
        .backgroundColor('#E84026')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 10 })
        .onClick(() => {
          this.deleteRecipes(this.selectIds)
        });
      }
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Bottom)
  }
}
