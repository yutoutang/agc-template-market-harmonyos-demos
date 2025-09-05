import { BreakpointModel, BreakpointNameEnum, CoverUri, RouterMap, RouterUtils, UserInfoModel } from 'lib_common'
import { NewsStyleEnum, newsStyleList, videoSetting } from '../constants/NewsConstants'
import { AppStorageV2, promptAction } from '@kit.ArkUI'
import { ArticleServiceApi, PostImgList } from 'lib_news_api'
import { emitter } from '@kit.BasicServicesKit'

@ObservedV2
export class NewsPostViewModel extends UserInfoModel {
  @Trace title: string = ''
  @Trace content: string = ''
  @Trace coverThreeList: CoverUri[] = [new CoverUri(), new CoverUri(), new CoverUri()]
  @Trace coverSingleList: CoverUri[] = [new CoverUri()]
  @Trace selectedId: string = NewsStyleEnum.IMAGE_NONE
  @Trace breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get isSmDevice() {
    return this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM
  }

  public async publishNews() {
    let message = await this.validate()
    if (message) {
      promptAction.showToast({ message: message })
      return
    }
    /*
     * 确定文章发布需要用到的模板
     * 一张图需要左文右图
     * 三张图需要上文下图
     * */
    let postImgList: PostImgList[] = []
    if (this.selectedId === NewsStyleEnum.IMAGE_SINGLE) {
      postImgList.push({
        picVideoUrl: this.coverSingleList[0].uri,
        surfaceUrl: '',
      })
    }
    if (this.selectedId === NewsStyleEnum.IMAGE_THREE) {
      this.coverThreeList.forEach(item => postImgList.push({
        picVideoUrl: item.uri,
        surfaceUrl: '',
      }))
    }
    let setting = newsStyleList.find(item => item.id === this.selectedId)?.setting as string
    let articleInfo = ArticleServiceApi.addArticle(this.title, this.handleImageSize(this.content), setting, postImgList)
    // 添加到动态布局文件中
    ArticleServiceApi.addFlexLayout(articleInfo.id, setting)
    RouterUtils.popToName(RouterMap.INDEX_PAGE)
    // 通知首页刷新
    emitter.emit('home_recommend_fresh')
  }

  public async publishVideo(surface: string, videoUri: string, title: string) {
    if (!surface) {
      promptAction.showToast({ message: '未上传视频' })
      return
    }
    /*
     * 使用视频模板
     * */
    let postImgList: PostImgList[] = [{
      picVideoUrl: videoUri,
      surfaceUrl: surface,
    }]
    let articleInfo = ArticleServiceApi.addArticle(title, '', videoSetting, postImgList)
    // 添加到动态布局文件中
    ArticleServiceApi.addFlexLayout(articleInfo.id, videoSetting)
    RouterUtils.replacePathByName(RouterMap.INDEX_PAGE)
    // 通知首页刷新
    emitter.emit('home_recommend_fresh')
  }

  public handleImageSize(content: string) {
    // 需要统一处理富文本image的宽高
    return content = content.replaceAll('<img', '<img class="image-preview post-image"')
  }

  public async validate() {
    let message = ''
    if (this.selectedId === NewsStyleEnum.IMAGE_SINGLE) {
      message = this.coverSingleList[0].uri ? '' : '封面图未上传'
    }
    if (this.selectedId === NewsStyleEnum.IMAGE_THREE) {
      let len = this.coverThreeList.filter(item => !item.uri).length
      message = len ? `还有${len}张封面未上传` : ''
    }
    return message
  }
}