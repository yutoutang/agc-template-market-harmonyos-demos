import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@ohos.base';
import { fileIo as fs } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { promptAction } from '@kit.ArkUI';
import sdk from 'libveditor.so';
import { EditVideo, VideoAsset } from '../model/Index';

@ObservedV2
export class VideoManageVM {
  private static _instance: VideoManageVM;
  @Trace videoUri: string | undefined = undefined;
  @Trace draftTabIndex: number = 0;
  @Trace drafts: EditVideo[] = [];
  @Trace recycles: EditVideo[] = [];
  @Trace screenWidth: Length | undefined = 0;
  @Trace oldScreenWidth: Length | undefined = 0;
  @Trace screenHeight: Length | undefined = 0;
  @Trace oldScreenHeight: Length | undefined = 0;
  @Trace pathStack: NavPathStack = new NavPathStack();
  @Trace selectedDrafts: EditVideo[] = [];
  @Trace selectedRecycles: EditVideo[] = [];
  @Trace isEdit: boolean = false;
  @Trace isAccept: boolean = false;
  fd: number = 0;
  file: fs.File | undefined = undefined;
  draftCategory: string[] = ['剪辑', '回收站'];

  public static get instance() {
    if (!VideoManageVM._instance) {
      VideoManageVM._instance = new VideoManageVM();
    }
    return VideoManageVM._instance;
  }

  handleDraftClickEvent(video: EditVideo) {
    if (this.draftTabIndex === 1) {
      promptAction.showToast({
        message: '回收站内的草稿不支持编辑',
        duration: 1000,
      });
      return;
    }

    this.videoUri = video.mediaUri;
    this.file = fs.openSync(video.mediaUri);
    this.fd = this.file.fd;

    let res: number = sdk.SetVideo(this.videoUri, this.fd);

    hilog.info(0xFF00, 'VideoClip', `selected draft URI: ${this.videoUri}, fd: ${this.fd}`);

    if (res === 0) {
      let videoAsset: VideoAsset = {
        videoUri: video.mediaUri,
        fd: this.fd,
        screenWidth: this.screenWidth,
        screenHeight: this.screenHeight,
      };
      this.pathStack.pushPathByName('VideoEdit', videoAsset, (popInfo: PopInfo) => {
        this.drafts.unshift(popInfo.result as EditVideo);
      });
    }
  }

  async selectVideo() {
    try {
      let options: photoAccessHelper.PhotoSelectOptions = {
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE,
        isEditSupported: false,
        maxSelectNumber: 1,
        isPhotoTakingSupported: false,
        isSearchSupported: true,
        isOriginalSupported: true,
      };
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select(options).then((selectResult: photoAccessHelper.PhotoSelectResult) => {
        if (selectResult.photoUris.length === 0) {
          hilog.info(0xFF00, 'VideoClip', `no photo are selected.`);
        } else {
          selectResult.photoUris.forEach((uri) => {
            hilog.info(0xFF00, 'VideoClip', `selected photo URI: ${uri}`);
            this.videoUri = uri;
            this.file = fs.openSync(this.videoUri);
            this.fd = this.file.fd;

            let res: number = sdk.SetVideo(this.videoUri, this.fd);

            if (res === 0) {
              let videoAsset: VideoAsset = {
                videoUri: this.videoUri,
                fd: this.fd,
                screenWidth: this.screenWidth,
                screenHeight: this.screenHeight,
              };
              this.pathStack.pushPathByName('VideoEdit', videoAsset, (popInfo: PopInfo) => {
                this.drafts.unshift(popInfo.result as EditVideo);
              });
            } else {
              promptAction.showToast({
                message: '请选择要创作的视频',
              });
            }
          });
        }
      }).catch((err: BusinessError) => {
        hilog.error(0xFF00, 'VideoClip', `PhotoPicker,select failed with err: ${err.code},${err.message}`);
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      hilog.error(0xFF00, 'VideoClip', `PhotoPicker,select failed with err: ${err.code},${err.message}`);
    }
  }

  clearCheckStatus() {
    if (this.draftTabIndex === 0) {
      this.drafts.map(item => item.isSelect = false);
    } else {
      this.recycles.map(item => item.isSelect = false);
    }
  }

  selectDraft(video: EditVideo, value: boolean) {
    // 如为勾选
    if (value) {
      this.selectedDrafts.push(video);
    } else {
      this.selectedDrafts = this.selectedDrafts.filter(item => item.videoId !== video.videoId);
    }
  }

  selectRecycle(video: EditVideo, value: boolean) {
    // 如为勾选
    if (value) {
      this.selectedRecycles.push(video);
    } else {
      this.selectedRecycles = this.selectedRecycles.filter(item => item.videoId !== video.videoId);
    }
  }

  moveToRecycle() {
    this.recycles.push(...this.selectedDrafts);
    // 从草稿箱删除
    this.selectedDrafts.forEach(item => {
      this.drafts = this.drafts.filter(draft => draft.videoId !== item.videoId);
    });
    // 清空选择列表
    this.selectedDrafts = [];
    this.isEdit = false;
  }

  restoreToDraft() {
    this.drafts.push(...this.selectedRecycles);
    this.selectedRecycles.forEach(item => {
      this.recycles = this.recycles.filter(recycle => recycle.videoId !== item.videoId);
    });
    this.selectedRecycles = [];
    this.isEdit = false;
  }

  deletePermanently() {
    this.selectedRecycles.forEach(item => {
      this.recycles = this.recycles.filter(recycle => recycle.videoId !== item.videoId);
    });
    this.selectedRecycles = [];
    this.isEdit = false;
  }
}