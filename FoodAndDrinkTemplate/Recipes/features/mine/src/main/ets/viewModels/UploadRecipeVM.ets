import { GlobalContextUtils, Logger, RouterModule } from 'commonlib';
import { RecipeStep, uploadMyRecipe, UploadRecipeBody } from 'network';
import { promptAction } from '@kit.ArkUI';
import { Step, UploadRecipeData } from 'upload_recipe';


const TAG = '[UploadRecipeVM]';

@ObservedV2
export class UploadRecipeVM {
  public async uploadRecipe(data: UploadRecipeData) {
    const requestBody: UploadRecipeBody = {
      description: data.description,
      title: data.title,
      ingredients: data.ingredients,
      steps: data.steps.map((item: Step, index: number) => {
        const val: RecipeStep = {
          description: item.description,
          stepNumber: index + 1,
        };
        return val;
      }),
    };
    try {
      const res = await uploadMyRecipe(requestBody)
      if (res.status === 200) {
        GlobalContextUtils.showToast({ message: '上传成功！' });
        RouterModule.pop('success')
      }

    } catch (err) {
      GlobalContextUtils.showToast({ message: '上传失败！' });
      Logger.error(TAG, err)
    }
  }
}