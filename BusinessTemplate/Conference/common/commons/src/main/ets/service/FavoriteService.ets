
export class FavoriteService {
  private  static _instance: FavoriteService;
  public static get instance() {
    if (!FavoriteService._instance) {
      FavoriteService._instance = new FavoriteService()
    }
    return FavoriteService._instance;
  }

  private favoriteIdList: string[] = [];

  public addFavorite(favoriteId: string) {
    if (this.favoriteIdList.indexOf(favoriteId) === -1) {
      this.favoriteIdList.push(favoriteId);
    }
  }

  public cancelFavorite(favoriteId: string) {
    const index = this.favoriteIdList.indexOf(favoriteId);
    if (index !== -1) {
      this.favoriteIdList.splice(index, 1)
    }
  }

  public getFavoriteIdList() {
    return this.favoriteIdList;
  }
}