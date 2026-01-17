import { queryMyRecipeList, RecipeBriefInfo, deleteMyRecipe } from 'network';
import { promptAction } from '@kit.ArkUI';
import { DialogParams, DialogUtil, GlobalContextUtils } from 'commonlib';
import { ConfirmDialogComponent } from '../components/ConfirmDialogComponent';

@ObservedV2
export class MyRecipeVM {
  @Trace recipeList: RecipeBriefInfo[] = [];
  @Trace isToDelete: boolean = false;
  @Trace toDeleteIds: number[] = [];
  @Trace wBuilder: WrappedBuilder<[DialogParams]> = wrapBuilder(ConfirmDialogComponent);

  private static _instance: MyRecipeVM;

  public static get instance() {
    if (!MyRecipeVM._instance) {
      MyRecipeVM._instance = new MyRecipeVM();
    }
    return MyRecipeVM._instance;
  }

  public async getMyRecipeList() {
    const res = await queryMyRecipeList();
    if (res.status === 200) {
      this.recipeList = res.data;
    }
  }

  public async deleteMyRecipe() {
    const res = await deleteMyRecipe(this.toDeleteIds);
    if (res.status === 200) {
      this.isToDelete = false;
      this.toDeleteIds = [];
      this.getMyRecipeList();
      GlobalContextUtils.showToast({ message: '删除成功！' });
    }
  }

  deleteConfirm(){
    if (this.toDeleteIds.length) {
      DialogUtil.openDialog(this.wBuilder, {
        title: '确认删除所选菜谱？', confirmFunc: () => {
          this.deleteMyRecipe();
          DialogUtil.close()
        },
        cancelFunc: () => {
          DialogUtil.close()
        },
      });
    } else {
      GlobalContextUtils.showToast({ message: '请选择您要删除的菜谱！' });
    }
  }
}