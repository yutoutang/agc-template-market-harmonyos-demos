import { UploadRecipeData, WallpaperCategory, Keyword } from '../types/Index';
import { UploadRecipeVM } from '../viewModels/UploadRecipeVM';
import { promptAction } from '@kit.ArkUI';
import fs from '@ohos.file.fs';

@ComponentV2
export struct UploadRecipe {
  @Param @Require categories: WallpaperCategory[] = [];
  @Local vm: UploadRecipeVM = new UploadRecipeVM();
  @Event uploadRecipe: (data: UploadRecipeData) => void = () => {
  }

  aboutToAppear(): void {
    this.vm.categories = this.categories;
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Column() {
            Text('壁纸')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 2 })

            Text('支持格式: .jpg/.png，单个文件不能超过10MB')
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))

            if (this.vm.mainImg) {
              Image(this.vm.mainImg)
                .width(120)
                .height(120)
                .margin({ top: 12 })
                .borderRadius(12)
                .onClick(() => {
                  this.selectAndValidateImage();
                });
            } else {
              Column() {
                Image($r('app.media.icon_add')).width(24).height(24).fillColor('#66000000');
                Text('上传壁纸').fontSize(14).fontColor('#66000000').margin({ top: 8 });
              }
              .width(120)
              .height(120)
              .margin({ top: 9 })
              .backgroundColor('#0F000000')
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.selectAndValidateImage();
              });
            }
          }.columnWrapExtend();

          Column() {
            Text('壁纸分类')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 12 })

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.vm.categories, (category: WallpaperCategory, index: number) => {
                Text(category.name)
                  .fontSize(14)
                  .fontColor(category.selected ? '#FFFFFF' : '#e6000000')
                  .backgroundColor(category.selected ? '#ff0a59f7' : '#0F000000')
                  .padding({
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 8
                  })
                  .borderRadius(20)
                  .margin({ right: 12, bottom: 8 })
                  .onClick(() => {
                    this.vm.toggleCategory(index);
                  })
              }, (category: WallpaperCategory) => JSON.stringify(category))
            }
          }.columnWrapExtend().margin({ top: 12 });

          Column() {
            Text('关键词')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 12 })

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.vm.keywords, (keyword: Keyword, index: number) => {
                Text(keyword.name)
                  .fontSize(14)
                  .fontColor(keyword.selected ? '#FFFFFF' : '#e6000000')
                  .backgroundColor(
                    keyword.selected ? '#ff0a59f7' : '#0F000000')
                  .padding({
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 8
                  })
                  .borderRadius(20)
                  .margin({ right: 12, bottom: 8 })
                  .opacity(this.vm.isKeywordDisabled(keyword) ? 0.4 : 1)
                  .onClick(() => {
                    if (!this.vm.isKeywordDisabled(keyword)) {
                      this.vm.toggleKeyword(index);
                    } else {
                    }
                  })
              }, (keyword: Keyword) => JSON.stringify(keyword))
            }

            Text(`已选择 ${this.vm.getSelectedKeywordsCount()}/2 个关键词`)
              .fontSize(12)
              .fontColor($r('sys.color.font_tertiary'))
              .margin({ top: 8 })
          }.columnWrapExtend().margin({ top: 12 });

        }.padding({ top: 12, bottom: 20 });
      }.height('calc(80% - 76vp)').scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring);

      // 上传按钮
      Row() {
        Button('上传')
          .height(40)
          .width('100%')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .onClick(() => {
            const validation = this.vm.validateForm();
            if (!validation.isValid) {
              promptAction.showToast({ message: validation.message });
              return;
            }

            const data: UploadRecipeData = {
              mainImg: this.vm.mainImg,
              category: this.vm.getSelectedCategory(),
              keywords: this.vm.getSelectedKeywords()
            }
            this.uploadRecipe(data);
          });
      }.height(76).width('100%').padding({ left: 40, right: 40, top: 24 });
    }.height('100%').backgroundColor($r('sys.color.background_secondary'));
  }

  async selectAndValidateImage() {
    try {
      const imagePath = await this.vm.selectImage();
      if (!this.isValidImageFormat(imagePath)) {
        promptAction.showToast({ message: '只支持.jpg和.png格式的壁纸！' });
        return;
      }
      if (!await this.isValidImageSize(imagePath)) {
        promptAction.showToast({ message: '壁纸大小不能超过10MB！' });
        return;
      }
      this.vm.mainImg = imagePath;
    } catch (error) {
    }
  }

  isValidImageFormat(imagePath: string): boolean {
    const lowerCasePath = imagePath.toLowerCase();
    return lowerCasePath.endsWith('.jpg') ||
    lowerCasePath.endsWith('.jpeg') ||
    lowerCasePath.endsWith('.png');
  }

  async isValidImageSize(imagePath: string): Promise<boolean> {
    try {
      const filePath = imagePath.replace('file://', '');
      const stats = fs.statSync(filePath);
      const fileSizeMB = stats.size / (1024 * 1024);
      return fileSizeMB <= 10;
    } catch (error) {
      return false;
    }
  }
}

@Extend(Column)
function columnWrapExtend() {
  .width('100%')
  .padding({
    left: 16,
    right: 16,
    top: 12,
    bottom: 12,
  })
  .alignItems(HorizontalAlign.Start);
}