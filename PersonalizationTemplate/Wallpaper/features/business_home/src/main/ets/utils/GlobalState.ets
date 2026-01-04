import { UploadRecipeData } from 'upload_recipe';

export class GlobalState {
  private static currentWallpaper: UploadRecipeData | null = null;
  private static favoriteUpdateListeners: Array<() => void> = [];
  private static favoriteStatusListeners: Array<(isLiked: boolean) => void> = [];

  static setCurrentWallpaper(data: UploadRecipeData): void {
    GlobalState.currentWallpaper = data;
  }

  static getCurrentWallpaper(): UploadRecipeData | null {
    return GlobalState.currentWallpaper;
  }

  static clearCurrentWallpaper(): void {
    GlobalState.currentWallpaper = null;
  }

  static addFavoriteUpdateListener(listener: () => void): void {
    GlobalState.favoriteUpdateListeners.push(listener);
  }

  static removeFavoriteUpdateListener(listener: () => void): void {
    const index = GlobalState.favoriteUpdateListeners.indexOf(listener);
    if (index !== -1) {
      GlobalState.favoriteUpdateListeners.splice(index, 1);
    }
  }

  static notifyFavoriteUpdated(): void {
    GlobalState.favoriteUpdateListeners.forEach(listener => listener());
  }

  static addFavoriteStatusListener(listener: (isLiked: boolean) => void): void {
    GlobalState.favoriteStatusListeners.push(listener);
  }

  static removeFavoriteStatusListener(listener: (isLiked: boolean) => void): void {
    const index = GlobalState.favoriteStatusListeners.indexOf(listener);
    if (index !== -1) {
      GlobalState.favoriteStatusListeners.splice(index, 1);
    }
  }

  static notifyFavoriteStatusUpdated(isLiked: boolean): void {
    GlobalState.favoriteStatusListeners.forEach(listener => listener(isLiked));
  }
}
