import { promptAction, window } from '@kit.ArkUI';
import { BaseViewModel, CommonConfirmDialog, RouterUtils } from 'lib_common';
import { PostRequest, PostServiceApi, PostImgList } from 'lib_news_api';
import { PostImgVideoItem } from 'module_post';
import { emitter } from '@kit.BasicServicesKit';

@ObservedV2
export class PublishPostViewModel extends BaseViewModel {
  @Trace body: string = '';
  @Trace mediaList: PostImgVideoItem[] = [];
  @Trace paddingBottom: number = this.windowModel.windowBottomPadding;

  enablePublish() {
    if (this.body) {
      return true;
    }
    if (this.mediaList.length) {
      return true;
    }
    return false;
  }

  publishPost() {
    if (!this.enablePublish()) {
      return;
    }
    const params: PostRequest = {
      postBody: this.body,
      postImgList: this.mediaList as PostImgList[],
    };
    PostServiceApi.publishPost(params);
    promptAction.showToast({ message: '发表成功' });
    /*
     * 事件分发，通知首页刷新
     * */
    emitter.emit('recommendRefresh')
    RouterUtils.pop();
  }

  onBackPressed(): boolean {
    if (this.enablePublish()) {
      CommonConfirmDialog.show({
        primaryTitle: '温馨提示',
        content: '当前内容未发表，返回将丢失。是否确认返回？',
        confirm: () => {
          RouterUtils.pop();
        },
      });
      return true;
    }
    return false;
  }

  onKeyBoard() {
    window.getLastWindow(getContext(this)).then(currentWindow => {
      currentWindow.on('keyboardHeightChange', this.onKeyBoardCB);
    })
  }

  offKeyBoard() {
    window.getLastWindow(getContext(this)).then(currentWindow => {
      currentWindow.off('keyboardHeightChange', this.onKeyBoardCB);
    })
  }

  onKeyBoardCB: (height: number) => void = (height: number) => {
    animateTo({
      duration: 200,
      curve: Curve.EaseInOut,
    }, () => {
      if (height > 0) {
        this.paddingBottom = 0;
      } else {
        this.paddingBottom = this.windowModel.windowBottomPadding;
      }
    });
  };
}