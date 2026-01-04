// 验证结果类型
export interface ValidationResult {
  isValid: boolean;
  message: string;
}

// 壁纸分类类型
export interface WallpaperCategory {
  id: string;
  name: string;
  selected?: boolean;
}

// 关键词类型
export interface Keyword {
  id: string;
  name: string;
  selected: boolean;
}

// 需要上传的数据类型
export interface UploadRecipeData {
  mainImg: string;
  category: string;
  keywords: string[];
  uploadTime?: string;
  favoriteTime?: string; // 收藏时间字段
}

// 壁纸取消删除类型
export interface DialogResult {
  index: number;
}

// model/WallpaperItem
export class WallpaperItem {
  id: string = '';
  title: string = '';
  thumbnail: Resource = $r('app.media.ic_close');
  time: string = '';
  hotValue: number = 0;
}

export interface WallpaperDetailParams {
  wallpaperData: UploadRecipeData;
}

export interface NavPathStackEvent {
  pathStack: NavPathStack;
}

// 壁纸数据
export interface WallpaperData {
  mainImg: string;
  category: string;
  keywords: string[];
}

// 路由参数接口
export interface WallpaperDetailRouteParams {
  wallpaperData: WallpaperData;
}
