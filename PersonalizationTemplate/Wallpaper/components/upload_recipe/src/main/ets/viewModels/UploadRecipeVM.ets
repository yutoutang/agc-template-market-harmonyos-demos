import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { WallpaperCategory, Keyword, ValidationResult } from '../types/Index';

@ObservedV2
export class UploadRecipeVM {
  @Trace mainImg: string = '';
  @Trace categories: WallpaperCategory[] = [
    { id: '1', name: '二次元', selected: false },
    { id: '2', name: '风景', selected: false },
    { id: '3', name: '动物萌宠', selected: false },
    { id: '4', name: '爱豆', selected: false },
    { id: '5', name: '影视', selected: false }
  ];
  @Trace keywords: Keyword[] = [
    { id: '1', name: '#森林', selected: false },
    { id: '2', name: '#湖泊', selected: false },
    { id: '3', name: '#雪景', selected: false },
    { id: '4', name: '#日出', selected: false },
    { id: '5', name: '#日落', selected: false },
    { id: '6', name: '#城市', selected: false },
    { id: '7', name: '#爱豆', selected: false },
    { id: '8', name: '#动漫人物', selected: false },
    { id: '9', name: '#星空', selected: false },
    { id: '10', name: '#油画', selected: false },
    { id: '11', name: '#动态效果', selected: false },
    { id: '12', name: '#萌宠', selected: false }
  ];

  // 获取关键词方法
  getAllKeywordNames(): string[] {
    return this.keywords.map(keyword => keyword.name); // 返回所有关键词的名称数组
  }

  getSelectedCategoryCount(): number {
    return this.categories.filter(category => category.selected).length;
  }

  getSelectedKeywordsCount(): number {
    return this.keywords.filter(keyword => keyword.selected).length;
  }

  isKeywordDisabled(keyword: Keyword): boolean {
    if (keyword.selected) {
      return false;
    }
    return this.getSelectedKeywordsCount() >= 2;
  }

  getSelectedCategory(): string {
    const selectedCategory = this.categories.find(category => category.selected);
    return selectedCategory ? selectedCategory.name : '';
  }

  getSelectedKeywords(): string[] {
    return this.keywords
      .filter(keyword => keyword.selected)
      .map(keyword => keyword.name);
  }

  toggleCategory(index: number): void {
    const newCategories = [...this.categories];
    newCategories.forEach((category, i) => {
      category.selected = i === index;
    });
    this.categories = newCategories;
  }

  toggleKeyword(index: number): void {
    const newKeywords = [...this.keywords];
    const currentKeyword = newKeywords[index];
    if (currentKeyword.selected) {
      currentKeyword.selected = false;
    } else {
      if (this.getSelectedKeywordsCount() < 2) {
        currentKeyword.selected = true;
      }
    }
    this.keywords = newKeywords;
  }

  validateForm(): ValidationResult {
    if (!this.mainImg) {
      return { isValid: false, message: '请先选择壁纸！' };
    }
    if (this.getSelectedCategoryCount() === 0) {
      return { isValid: false, message: '请选择壁纸分类！' };
    }
    const selectedKeywordsCount = this.getSelectedKeywordsCount();
    if (selectedKeywordsCount === 0) {
      return { isValid: false, message: '请至少选择一个关键词！' };
    }
    if (selectedKeywordsCount > 2) {
      return { isValid: false, message: '最多只能选择两个关键词！' };
    }
    return { isValid: true, message: '' };
  }

  public async selectImage(): Promise<string> {
    return new Promise((resolve, reject) => {
      try {
        let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
        photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
        photoSelectOptions.maxSelectNumber = 1;
        let photoPicker = new photoAccessHelper.PhotoViewPicker();
        photoPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
          if (photoSelectResult.photoUris.length === 0) {
            reject(new Error('未选择图片'));
            return;
          }
          let imgFile: fs.File | null = null;
          try {
            imgFile = fs.openSync(photoSelectResult.photoUris[0], fs.OpenMode.READ_ONLY);
            const uploadsDir = getContext().filesDir + '/uploads';
            try {
              fs.mkdirSync(uploadsDir);
            } catch (e) {
            }

            let newPath: string = uploadsDir + `/${util.generateRandomUUID(false)}.png`;
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