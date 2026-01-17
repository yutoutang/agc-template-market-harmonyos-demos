import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import { RecipeIngredient, Step } from '../types/Index';
import { common } from '@kit.AbilityKit';


const TAG = '[UploadRecipeVM]';

@ObservedV2
export class UploadRecipeVM {
  // 主图
  @Trace mainImg: string = '';
  // 标题
  @Trace title: string = ''
  // 最大长度
  @Trace maxLength: number = 200
  // 当前长度
  @Trace curLength: number = 0
  // 描述
  @Trace description: string = ''
  // 用料
  @Trace ingredients: RecipeIngredient[] = [{ name: '', quantity: '', unit: '' }]
  // 步骤
  @Trace steps: Step[] = [new Step('', '')]
  // 记录当前步骤
  @Trace curStep: number = 1

  public clearData() {
    this.title = ''
    this.curLength = 0
    this.description = ''
    this.mainImg = ''
    this.curStep = 1
    this.ingredients = [{ name: '', quantity: '', unit: '' }]
    this.steps = [new Step('', '')]
  }

  isStepsEmpty(): boolean {
    let isEmpty: boolean = false
    this.steps.forEach((val) => {
      if (!val.description || !val.stepImg) {
        isEmpty = true
      }
    })
    return isEmpty
  }

  isIngredientsEmpty(): boolean {
    let isEmpty: boolean = false
    this.ingredients.forEach((val) => {
      if (!val.name || !val.quantity) {
        isEmpty = true
      }
    })
    return isEmpty
  }

  isUploadValid(): boolean {
    if (!this.title) {
      promptAction.showToast({ message: '请填写标题！' });
      return false
    }
    if (!this.mainImg) {
      promptAction.showToast({ message: '请上传主图！' });
      return false
    }
    if (!this.description) {
      promptAction.showToast({ message: '请补充描述！' });
      return false
    }
    if (this.isIngredientsEmpty()) {
      promptAction.showToast({ message: '请补充用料名称、数量！' });
      return false
    }
    if (this.isStepsEmpty()) {
      promptAction.showToast({ message: '请完善步骤！' });
      return false
    }

    return true
  }


  // 获取图片
  public async selectImage(context: common.UIAbilityContext): Promise<string> {
    return new Promise((resolve, reject) => {
      try {
        let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
        photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
        photoSelectOptions.maxSelectNumber = 1;
        let photoPicker = new photoAccessHelper.PhotoViewPicker();
        photoPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
          let imgFile: fs.File | null = null;
          try {
            imgFile = fs.openSync(photoSelectResult.photoUris[0]!, fs.OpenMode.READ_ONLY);
            let newPath: string = context.cacheDir + `/${util.generateRandomUUID(false)}.png`;
            fs.copyFileSync(imgFile.fd, newPath);
            resolve('file://' + newPath);
          } catch (err) {
            reject(err);
          } finally {
            if (imgFile) {
              fs.closeSync(imgFile);
            }
          }
        }).catch((err: BusinessError) => {
          reject(err);
        });
      } catch (error) {
        let err: BusinessError = error as BusinessError;
        reject(err);
      }
    });
  }
}