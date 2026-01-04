@ObservedV2
export class ImageInfo {
  id: string = '';
  type: string = '';
  keywords: string = '';
  userAvatar: string = '';
  userName: string = '';
  url: string = '';
  like: boolean = false;
  hotValue: number = 0;
  time: number = 0;
  isVideo?: boolean = false;
  src?: string = '';
  @Trace select?: boolean = false;
}

export interface ImageInfos {
  url: string;
  list: ImageInfo[];
}