//一级Tab
export interface WallpaperSuperTab {
  id: string
  text: string
  child: WallpaperChildTab[]
}

//二级Tab
export interface WallpaperChildTab {
  id: string
  text: string
}