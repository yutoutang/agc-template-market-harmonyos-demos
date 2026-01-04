import { promptAction } from '@kit.ArkUI';
import { Context } from '@kit.AbilityKit';
import { BaseViewModel, RouterUtils } from 'lib_common';
import { ImageInfo } from 'module_wallpaper_details';
import { UploadRecipe, UploadRecipeData, WallpaperCategory } from 'upload_recipe';
import { WallPaperLocalApi } from 'lib_wallpaper_api';
import { DataHelper } from '../data/mock/DataHelper';
import { SearchMockData } from 'lib_product_search';

interface NavPathStackEvent {
  pathStack: NavPathStack;
}

// 临时存储上传的图片
export class ImageUtils {
  static image: string[] = []; // 存储上传的图片路径
}

@ObservedV2
class UpLoadPageVM extends BaseViewModel {
  @Trace refreshKey: number = 0; // 刷新组件重置
  @Trace shouldReset: boolean = false;
}

@Builder
export function NewUpLoadPageBuilder() {
  NewUpLoadPage()
}

@ComponentV2
export struct NewUpLoadPage {
  stack: NavPathStack = new NavPathStack();
  private context: Context = getContext();
  private vm: UpLoadPageVM = new UpLoadPageVM();
  private tab: WallpaperCategory[] = [];

  // 壁纸上传回调
  async handleUploadRecipe(data: UploadRecipeData): Promise<void> {

    // 临时存储壁纸
    ImageUtils.image.push(data.mainImg);

    try {

      const imageInfo: ImageInfo = {
        id: '0',
        userAvatar: this.vm.userInfoModel.authorIcon,
        userName: this.vm.userInfoModel.authorNickName,
        hotValue: 0,
        like: false,
        type: data.category,
        url: data.mainImg,
        keywords: data.keywords.join(','),
        time: new Date().getTime()
      };
      WallPaperLocalApi.addWallpaperList(imageInfo)
      SearchMockData.allWallpapers.push(imageInfo)
      this.context.eventHub.emit('updateWallpaper')
      // 保存上传记录到本地
      await DataHelper.getInstance().addUpload(imageInfo);
      promptAction.showToast({
        message: '壁纸上传成功！',
        duration: 2000
      });

      // 重置数据
      this.resetPageState();
      RouterUtils.pop();
    } catch (error) {
      promptAction.showToast({
        message: '保存记录失败',
        duration: 2000
      });
    }
  }

  // 重置上传页面
  resetPageState(): void {
    this.vm.refreshKey += 1; // 组件重新渲染
    // 清空图片存储
    if (ImageUtils.image.length > 0) {
      ImageUtils.image = [];
    }
  }

  aboutToAppear(): void {
    this.tab = WallPaperLocalApi.getWallPaperTabList2().filter(tab => tab.name !== '推荐');
    this.resetPageState();
  }

  onPageHide(): void {
    this.resetPageState();
  }

  build() {
    NavDestination() {
      Column() {
        this.buildTopBar()
        this.buildUploadComponent()
      }
      .margin({ top: 40 })
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'));
    }
    .hideTitleBar(true)
    .onReady((event: NavPathStackEvent) => {
      this.stack = event.pathStack;
    });
  }

  @Builder
  buildTopBar() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(40)
        .height(40)
        .margin({ left: 16 })
        .onClick(() => {
          this.resetPageState();
          RouterUtils.pop();
        });

      Text('上传壁纸')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .margin({ left: 8 })
        .layoutWeight(1);
    }
    .width('100%')
    .height(56)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  buildUploadComponent() {
    // 重置上传组件数据
    if (this.vm.refreshKey % 2 === 0) {
      UploadRecipe({
        categories: this.tab,
        uploadRecipe: (data: UploadRecipeData) => {
          this.handleUploadRecipe(data);
        }
      })
        .layoutWeight(1)
        .id('uploadRecipeEven');
    } else {
      UploadRecipe({
        categories: this.tab,
        uploadRecipe: (data: UploadRecipeData) => {
          this.handleUploadRecipe(data);
        }
      })
        .layoutWeight(1)
        .id('uploadRecipeOdd');
    }
  }
}