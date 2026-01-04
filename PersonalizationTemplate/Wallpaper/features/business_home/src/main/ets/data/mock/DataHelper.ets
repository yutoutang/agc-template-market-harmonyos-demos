import { ImageInfo } from 'module_wallpaper_details';

@ObservedV2
export class DataHelper {
  private static instance: DataHelper;
  @Trace private favorites: ImageInfo[] = []; // 收藏列表
  @Trace private uploads: ImageInfo[] = []; // 上传记录列表

  public static getInstance(): DataHelper {
    if (!DataHelper.instance) {
      DataHelper.instance = new DataHelper();
    }
    return DataHelper.instance;
  }

  public getFavorites(): ImageInfo[] {
    this.favorites = [...this.favorites].sort((a, b) => b.time! - a.time!);
    return this.favorites;
  }

  public getUploads(): ImageInfo[] {
    this.uploads = [...this.uploads].sort((a, b) => b.time! - a.time!);
    return this.uploads;
  }

  // 添加收藏
  public addFavorite(imageInfo: ImageInfo): void {
    if (!this.favorites.some(item => item.url === imageInfo.url)) {
      imageInfo.time = new Date().getTime()
      this.favorites.push(imageInfo);
    }
  }

  // 添加上传记录
  public addUpload(imageInfo: ImageInfo): void {
    if (!this.uploads.some(item => item.url === imageInfo.url)) {
      imageInfo.time = new Date().getTime()
      this.uploads.push(imageInfo);
    }
  }

  // 从收藏中查询
  public getFavoriteByUrl(url: string): ImageInfo | undefined {
    return this.favorites.find(info => info.url === url);
  }

  // 从上传记录中查询
  public getUploadByUrl(url: string): ImageInfo | undefined {
    return this.uploads.find(info => info.url === url);
  }

  // 判断收藏中是否存在指定 URL 的 ImageInfo
  public hasFavoriteByUrl(url: string): boolean {
    return this.favorites.some(item => item.url === url);
  }

  // 判断上传记录中是否存在指定 URL 的 ImageInfo
  public hasUploadByUrl(url: string): boolean {
    return this.uploads.some(item => item.url === url);
  }

  // 从收藏中删除指定 URL 的 ImageInfo
  public removeFavoriteByUrl(url: string): void {
    this.favorites = this.favorites.filter(item => item.url !== url);
  }

  public removeFavorite(imageInfos: ImageInfo[]): void {
    for (let image of imageInfos) {
      this.removeFavoriteByUrl(image.url);
    }
  }

  // 从上传记录中删除指定 URL 的 ImageInfo
  public removeUploadByUrl(url: string): void {
    this.uploads = this.uploads.filter(item => item.url !== url);
  }

  public removeUpload(imageInfos: ImageInfo[]): void {
    for (let image of imageInfos) {
      this.removeUploadByUrl(image.url);
    }
  }

  // 清空所有收藏
  public clearFavorites(): void {
    this.favorites = [];
  }

  // 清空所有上传记录
  public clearUploads(): void {
    this.uploads = [];
  }
}