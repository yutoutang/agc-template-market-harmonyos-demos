import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import {
  BreakpointModel,
  CommonConfirmDialog,
  CommonConstants,
  CommonLoadingDialog,
  GlobalContextUtils,
  RouterMap,
  RouterUtils,
  SettingModel,
} from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { PostImgList, PostRequest, PostServiceApi } from 'lib_news_api';
import { ArticlePost } from 'module_articlepost';
import { PostImgVideoItem, PublishPostComp, FileUtils } from 'module_post';
import { KindsList, newsKindsList, NewsSelectType } from '../constants/NewsConstants';
import { VideoPost } from '../components/VideoPost';

@Builder
export function NewsPostBuilder() {
  NewsPost()
}

@ComponentV2
export struct NewsPost {
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
  @Local newsKindsList: KindsList[] = newsKindsList
  @Local content: string = ''
  @Local title: string = ''
  @Local videoCanBack: boolean = false
  @Local targetIndex: number = 0
  @Local selectedId: string = NewsSelectType.ARTICLE
  @Local postBody: string = ''
  @Local mediaList: PostImgVideoItem[] = []
  @Local isTabHide: boolean = false
  @Local controller: TextAreaController = new TextAreaController();
  @Local enableClick: boolean = true;

  @Computed
  get canNext() {
    if (this.selectedId === NewsSelectType.ARTICLE) {
      return (this.title.trim().length > 1 && this.content.trim().length > 0)
    }
    return this.enablePublish
  }

  @Computed
  get enablePublish() {
    if (this.postBody) {
      return true;
    }
    if (this.mediaList.length) {
      return true;
    }
    return false;
  }

  @Computed
  get isOnEdit() {
    return this.title.trim().length > 0 || this.content.trim().length > 0
  }

  @Computed
  get isPost() {
    return this.selectedId === NewsSelectType.POST
  }

  publishPost() {
    if (!this.enableClick) {
      return;
    }
    // 防止暴力点击
    this.enableClick = false;
    this.controller.stopEditing();

    CommonLoadingDialog.show({
      loadColor: $r('sys.color.icon_on_primary'),
      textColor: $r('sys.color.font_on_primary'),
      maskColor: $r('sys.color.mask_secondary'),
      autoCancel: false,
      text: '发布中',
    })

    setTimeout(async () => {
      const list: PostImgList[] = [];
      for (let item of this.mediaList) {
        const picVideoUrl = await FileUtils.handleUri(GlobalContextUtils.globalUIContext, item.picVideoUrl);
        list.push({
          picVideoUrl: picVideoUrl,
          surfaceUrl: item.surfaceUrl,
        });
      }
      const params: PostRequest = {
        postBody: this.postBody,
        postImgList: list,
      };
      PostServiceApi.publishPost(params)
        .then(() => {
          GlobalContextUtils.showToast({ message: '发布成功' });
          /*
           * 事件分发，通知首页刷新
           * */
          emitter.emit('recommendRefresh')
          RouterUtils.pop();
        })
        .catch(() => {
          GlobalContextUtils.showToast({ message: '发布失败' });
        })
        .finally(() => {
          CommonLoadingDialog.close();
          this.enableClick = true;
        });
    }, 50);
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '',
        rightPartBuilder: () => {
          this.barRight()
        },
      })
      Column() {
        Tabs({ index: this.targetIndex }) {
          TabContent() {
            ArticlePost({
              fontSizeRatio: this.settingInfo.fontSizeRatio,
              darkMode: this.settingInfo.darkSwitch,
              onTitleChange: (value: string) => {
                this.title = value
              },
              onContentChange: (value: string) => {
                this.content = value
              },
            })
          }

          TabContent() {
            VideoPost({
              fontSizeRatio: this.settingInfo.fontSizeRatio,
              onValidate: (isCanBack: boolean) => {
                this.videoCanBack = isCanBack
              },
            })
          }

          TabContent() {
            PublishPostComp({
              fontRatio: this.settingInfo.fontSizeRatio,
              controller: this.controller,
              onChange: (body: string, mediaList: PostImgVideoItem[]) => {
                this.postBody = body
                this.mediaList = mediaList
              },
              isFocus: (isTabHide: boolean) => {
                this.isTabHide = isTabHide
              },
            })
          }
        }
        .barHeight(0)
        .layoutWeight(1)
        .onAnimationStart((_index: number, targetIndex: number) => {
          this.selectedId = this.newsKindsList[targetIndex].id
        })
        .onChange((index: number) => {
          this.targetIndex = index
        })
      }
      .padding({ left: this.breakPointModel.pagePadding, right: this.breakPointModel.pagePadding })
      .layoutWeight(1)

      Column() {
        this.newsPublishKindsList()
      }
      .visibility(this.isTabHide ? Visibility.None : Visibility.Visible)
    }
    .onBackPressed(() => {
      if (this.isOnEdit || this.videoCanBack) {
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
    })
    .hideTitleBar(true)
  }

  @Builder
  newsPublishKindsList() {
    Flex({ justifyContent: FlexAlign.SpaceAround }) {
      ForEach(this.newsKindsList, (item: KindsList, index: number) => {
        Row() {
          Text(item.name)
            .fontSize(16 * this.settingInfo.fontSizeRatio)
            .fontColor(this.selectedId === item.id ? $r('sys.color.icon_primary') : $r('sys.color.icon_secondary'))
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .flexGrow(1)
        .onClick(() => {
          this.selectedId = item.id
          this.targetIndex = index
        })
      }, (item: KindsList) => item.id)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: CommonConstants.PADDING_L, bottom: 36 })
  }

  @Builder
  barRight() {
    Row() {
      Button(this.isPost ? '发表' : '下一步')
        .width(82)
        .opacity(this.canNext ? 1 : 0.4)
        .height(40)
        .fontSize(16 * this.settingInfo.fontSizeRatio)
        .fontColor(true ? $r('sys.color.font_on_primary') : $r('sys.color.font_tertiary'))
        .backgroundColor(true ? $r('app.color.app_theme') :
          $r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          if (this.canNext) {
            if (this.isPost) {
              this.publishPost()
              return
            }
            let params: Record<string, string> = {
              'title': this.title,
              'content': this.content,
            }
            RouterUtils.pushPathByName(RouterMap.NEWS_PUBLISH_SELECT, params)
          }
        })
    }
    .visibility(this.selectedId !== NewsSelectType.VIDEO ? Visibility.Visible : Visibility.None)
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
  }
}
