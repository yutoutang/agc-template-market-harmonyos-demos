import { AccountUtil, BaseHeader, RouterMap, RouterModule } from 'commonlib';
import { MinePageVM } from '../viewModels/MinePageVM';
import { PersonalHomepage } from 'personal_homepage';
import { emitter } from '@kit.BasicServicesKit';

@Builder
export function MinePageBuilder() {
  MinePage();
}

@Preview
@ComponentV2
struct MinePage {
  vm: MinePageVM = MinePageVM.instance;

  aboutToAppear(): void {
    this.vm.init()
    emitter.on('refreshMinePage', () => {
      this.vm.refreshMinePage()
    });
  }

  aboutToDisappear(): void {
    emitter.off('refreshMinePage', () => {
      this.vm.refreshMinePage()
    });
  }

  @Monitor('vm.userInfo.isLogin')
  changeLogin(monitor: IMonitor) {
    this.vm.changeLogin()
  }

  build() {
    NavDestination() {
      Column() {
        BaseHeader({
          showTitle: false,
          showLeftMenu: true,
          showMsg: true,
          noticeNum: this.vm.noticeList.length,
          changeSideBar: (flag: boolean) => {
            this.vm.changeSideBar(flag)
          },
        })
        PersonalHomepage({
          bloggerInfo: this.vm.bloggerInfo,
          recipeList: this.vm.recipeList,
          isSelf: true,
          isLogin: this.vm.userInfo.isLogin,
          currentIndex: this.vm.currentIndex,
          isToDelete: this.vm.isToDelete,
          userTagBuilderParam: (): void => {
            this.userTagBuilder()
          },
          membershipBuilderParam: (): void => {
            this.membershipBuilder()
          },
          uploadBuilderParam: (): void => {
            this.uploadRecipeBuilder()
          },
          onClickCb: (id: number) => {
            RouterModule.push(RouterMap.DISHES, { 'id': id } as Record<string, number>)
          },
          jumpBloggerInfo: (id: number) => {
            RouterModule.push(RouterMap.BLOGGER_PROFILE_PAGE, { 'id': id } as Record<string, number>)
          },
          changeTabIndex: (index: number) => {
            this.vm.changeTabs(index)
          },
          login: () => {
            this.vm.login()
          },
          jumpFollowers: () => {
            RouterModule.push(RouterMap.FOLLOWERS_PAGE, { 'id': this.vm.bloggerInfo.id } as Record<string, number>)
          },
          deleteRecipes: (ids: number[]) => {
            this.vm.deleteMyRecipe(ids)
          },
          changeDeleteState: (isToDelete: boolean) => {
            this.vm.isToDelete = isToDelete
          },
        }).layoutWeight(1).onClick(() => {
          if (this.vm.isToDelete) {
            this.vm.isToDelete = false
          }
        })
      }
    }.hideTitleBar(true);
  }

  @Builder
  userTagBuilder() {
    Row() {
      Image(this.vm.userInfo.isMembership ? $r('app.media.ic_vip') : $r('app.media.ic_vip_off')).width(20).height(18)
      Text(this.vm.userInfo.isMembership ? 'VIP会员' : '未开通')
        .fontSize(12)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: 8 })
    }
    .width(96)
    .padding({
      top: 6,
      bottom: 6,
      left: 8,
      right: 8,
    })
    .borderRadius(8)
    .backgroundColor(this.vm.userInfo.isMembership ? '#FCF2CC' : $r('sys.color.background_secondary'))
    .margin({ top: 4 })
    .visibility(this.vm.userInfo.isLogin ? Visibility.Visible : Visibility.None)
  }

  @Builder
  membershipBuilder() {
    Stack() {
      Image(this.vm.gridCount === 2 ? $r('app.media.bg_membership') : $r('app.media.bg_large_membership'))
        .width('100%')
      Row() {
        Button(this.vm.userInfo.isMembership ? '会员中心' : '开通会员', { controlSize: ControlSize.SMALL })
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('#E3922F')
          .onClick(() => {
            RouterModule.push(RouterMap.MEMBER_CENTER_PAGE);
          })
      }.padding(12)

    }
    .width('100%')
    .alignContent(Alignment.BottomEnd)
    .visibility(this.vm.userInfo.isLogin ? Visibility.Visible : Visibility.None)
  }

  @Builder
  uploadRecipeBuilder() {
    FlowItem() {
      Column({ space: 12 }) {
        Image($r('app.media.ic_public_add')).width(40).height(40).fillColor('#66000000');
        Text('上传我的菜谱').fontSize(14).fontColor('#66000000');
      }
      .height(160)
      .width('100%')
      .backgroundColor('#F1F3F5')
      .borderRadius(8)
      .margin({bottom: 46})
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        // 添加菜谱
        if (AccountUtil.getUserInfo().isLogin) {
          RouterModule.push(RouterMap.UPLOAD_RECIPE_PAGE, undefined, () => {
            this.vm.queryMyRecipeList()
          });
        } else {
          RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
        }
      });
    }.height(208)
  }
}

