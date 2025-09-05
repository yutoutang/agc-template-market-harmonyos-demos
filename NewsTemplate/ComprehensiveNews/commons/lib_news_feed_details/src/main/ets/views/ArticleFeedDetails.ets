import { webview } from '@kit.ArkWeb';
import { PersistenceV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import dayjs from 'dayjs';
import { FeedComment, CommentOperation } from 'module_feedcomment';
import {
  FormatCount,
  RouterMap,
  RouterParams,
  RouterUtils,
  SettingModel,
  BundleInfo,
  NewsEnum,
  CommonConstants,
} from 'lib_common';
import { CommentResponse, NewsResponse } from 'lib_news_api';
import { NavHeaderBar } from 'lib_widget';
import { FeedCard } from 'module_newsfeed';
import { Share } from 'module_share';
import { ReadNewsComponent } from 'module_text_reader';
import { LongTakeAnimationProperties, LongTakeTransitionDelegate } from 'module_transition';
import { extractText, handlerCoverImage } from '../utils/Utils';
import { ArticleDetailsFooter } from '../components/ArticleDetailsFooter';
import { RecommendArea } from '../components/RecommendArea';
import NewsFeedVM from '../viewmodel/NewsFeedVM';
import { NewsContent } from '../components/NewsContent';
import { NewsFeedInfo } from '../model/Model';
import { LoginSheetUtils } from 'lib_account';
import { FeedBreakPointVM } from '../viewmodel/FeedBreakPointVM';

@Builder
export function ArticleFeedDetailsBuilder() {
  ArticleFeedDetails()
}

@ComponentV2
export struct ArticleFeedDetails {
  @Local articleId: string = ''
  @Local pixelMap: PixelMap | null = null
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  @Local formType: string = ''
  @Local newsFeedVM: NewsFeedVM = NewsFeedVM.instance
  @Local bundleInfo: BundleInfo | undefined = undefined
  @Local newsBreakPoint: FeedBreakPointVM = new FeedBreakPointVM()
  @Local longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  webViewController: webview.WebviewController = new webview.WebviewController();

  async aboutToAppear() {
    let params = RouterUtils.getParamByName<RouterParams<NewsResponse>>(RouterMap.ARTICLE_FEED_DETAILS)
    let newsData = params?.cardData as NewsFeedInfo
    let isQueryCardData = params?.isQueryCardData as boolean
    if (isQueryCardData) {
      this.articleId = newsData.id
      this.newsFeedVM.setCardData(newsData)
      this.formType = params?.formType ?? ''
    } else {
      this.articleId = params?.newsId ?? ''
      this.formType = params?.formType ?? ''
      this.newsFeedVM.initArticle(this.articleId)
    }
    this.newsFeedVM.initComment(this.articleId)
    this.bundleInfo = AppStorage.get('appInfo') as BundleInfo
    this.newsFeedVM.addHistory()
    this.newsFeedVM.setContinueData()
  }

  @Computed
  get readBody() {
    return this.newsFeedVM.articleDetails?.richContent ? extractText(this.newsFeedVM.articleDetails.richContent) :
    this.newsFeedVM.articleDetails.title
  }

  @Builder
  pointSplit() {
    Column() {
      Image(this.newsBreakPoint.isSplit ? $r('app.media.full_screen') : $r('app.media.split_screen'))
        .width(40)
        .height(40)
    }
    .onClick(() => {
      this.newsBreakPoint.switchSplit()
    })
    .visibility(this.newsBreakPoint.isSmDevice ? Visibility.Visible : Visibility.None)
  }

  @Builder
  readNewsBuilder() {
    Row({ space: 10 }) {
      this.pointSplit()
      ReadNewsComponent({
        author: this.newsFeedVM.articleDetails.author.authorNickName,
        date: dayjs(this.newsFeedVM.articleDetails.createTime).format('YYYY-MM-DD hh:mm:ss'),
        title: this.newsFeedVM.articleDetails.title,
        coverImage: handlerCoverImage(this.newsFeedVM.articleDetails),
        bundleName: this.bundleInfo?.appName,
        currentId: this.newsFeedVM.articleDetails.id,
        body: this.readBody,
      })
    }
  }

  @Builder
  shareBuilder() {
    Share({
      qrCodeInfo: {
        id: this.newsFeedVM.articleDetails.id,
        type: this.newsFeedVM.articleDetails.type,
        title: this.newsFeedVM.articleDetails.title,
        articleFrom: this.newsFeedVM.articleDetails.articleFrom,
        createTime: dayjs(this.newsFeedVM.articleDetails.createTime).format('YYYY-MM-DD hh:mm'),
        coverUrl: handlerCoverImage(this.newsFeedVM.articleDetails),
        isVideo: !!this.newsFeedVM.articleDetails.postImgList?.[0]?.surfaceUrl,
      },
      shareRenderBuilder: () => {
        this.shareCommentBuilder()
      },
    })
  }

  @Builder
  shareCommentBuilder() {
    Column({ space: 5 }) {
      Image($r('app.media.share_active'))
        .width(21)
        .height(21)
        .fillColor($r('sys.color.font_primary'))
      Text(FormatCount.formatToK(this.newsFeedVM.articleDetails.shareCount))
        .fontSize(10 * this.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
    }
    .accessibilityText('分享' + FormatCount.formatToK(this.newsFeedVM.articleDetails.shareCount))
  }

  @Builder
  ContentBuilder() {
    Column() {
      NavHeaderBar({
        title: '新闻详情',
        rightPartBuilder: () => {
          this.readNewsBuilder()
        },
      })
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Column() {
          List({ initialIndex: 0, scroller: this.newsFeedVM.scroller }) {
            if (this.newsFeedVM.articleDetails.type === NewsEnum.Article) {
              ListItem() {
                NewsContent({
                  fontSizeRatio: this.settingInfo.fontSizeRatio,
                  onAddLike: () => {
                    this.newsFeedVM.newsLike()
                  },
                  onAddWatch: () => {
                    this.newsFeedVM.watchOperation()
                  },
                  onComment: () => {
                    this.newsFeedVM.scrollToComment()
                  },
                })
              }
            } else {
              ListItem() {
                FeedCard({
                  componentId: 'feedDetails_news',
                  feedCardInfo: this.newsFeedVM.articleDetails,
                  fontSizeRatio: this.settingInfo.fontSizeRatio,
                  isNeedOperation: false,
                  onGoUserInfo: (authorId: string) => {
                    RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, authorId)
                  },
                  onLike: () => {
                    this.newsFeedVM.newsLike()
                  },
                  onWatch: () => {
                    this.newsFeedVM.watchOperation()
                  },
                  onComment: () => {
                    this.newsFeedVM.scrollToComment()
                  },
                })
              }
              .padding(16)
              .backgroundColor($r('sys.color.background_primary'))
            }
            ListItem() {
              ArticleDetailsFooter()
            }
            .padding({ left: 16, right: 16 })
            .backgroundColor($r('sys.color.background_primary'))

            ListItem() {
              RecommendArea({
                isFolderStatus: this.newsBreakPoint.isFolderStatus,
                settingInfo: this.settingInfo,
              })
            }
            .margin({ bottom: 8 })

            ListItem() {
              FeedComment({
                userInfo: this.newsFeedVM.getUserInfo(),
                commentList: this.newsFeedVM.commentInfoList,
                fontSizeRatio: this.settingInfo.fontSizeRatio,
                isDark: this.settingInfo.darkSwitch,
                navPathStack: RouterUtils.getStack(),
                addComment: (comment: CommentResponse, parentCommentId: string) => {
                  this.newsFeedVM.addSingleComment(comment, parentCommentId)
                },
                giveLike: (comment: CommentResponse, isLike: boolean) => {
                  this.newsFeedVM.addLike(comment, isLike)
                },
                onGoAuthorInfo: (authorId: string) => {
                  RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, authorId)
                },
                onDeleteComment: (commentId: string) => {
                  this.newsFeedVM.deleteComment(commentId)
                },
                onFirstComment: (commentContent: string) => {
                  this.newsFeedVM.addNewsComment(commentContent)
                },
              })
            }
            .id('news_feedComment')
            .padding({ left: 16, right: 16 })
            .backgroundColor($r('sys.color.background_primary'))
            .visibility(!this.newsBreakPoint.isFolderStatus ? Visibility.Visible : Visibility.None)
            .onAppear(() => {
              if (this.formType === 'comment') {
                this.newsFeedVM.scrollToComment()
              }
            })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .backgroundColor($r('sys.color.background_secondary'))
          .onAppear(() => {
            this.newsFeedVM.scrollToRestorePosition();
          })
          .onDidScroll(() => {
            this.newsFeedVM.setContinueOffset();
          })
        }
        .width(!this.newsBreakPoint.isFolderStatus ? CommonConstants.FULL_PERCENT : CommonConstants.HALF_PERCENT)

        Column() {
          FeedComment({
            feedCommentScroller:this.newsFeedVM.feedCommentScroller,
            userInfo: this.newsFeedVM.getUserInfo(),
            commentList: this.newsFeedVM.commentInfoList,
            fontSizeRatio: this.settingInfo.fontSizeRatio,
            isDark: this.settingInfo.darkSwitch,
            navPathStack: RouterUtils.getStack(),
            addComment: (comment: CommentResponse, parentCommentId: string) => {
              this.newsFeedVM.addSingleComment(comment, parentCommentId)
            },
            giveLike: (comment: CommentResponse, isLike: boolean) => {
              this.newsFeedVM.addLike(comment, isLike)
            },
            onGoAuthorInfo: (authorId: string) => {
              RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, authorId)
            },
            onDeleteComment: (commentId: string) => {
              this.newsFeedVM.deleteComment(commentId)
            },
            onFirstComment: (commentContent: string) => {
              this.newsFeedVM.addNewsComment(commentContent)
            },
          })

        }
        .width(!this.newsBreakPoint.isFolderStatus ? CommonConstants.FULL_PERCENT : CommonConstants.HALF_PERCENT)
        .id('news_feedComment')
        .padding({ left: 16, right: 16 })
        .backgroundColor($r('sys.color.background_primary'))
        .visibility(this.newsBreakPoint.isFolderStatus ? Visibility.Visible : Visibility.None)
        .onAppear(() => {
          if (this.formType === 'comment') {
            this.newsFeedVM.scrollToComment()
          }
        })
      }
      .layoutWeight(1)


      Column() {
        CommentOperation({
          commentCount: this.newsFeedVM.articleDetails.commentCount,
          fontSizeRatio: this.settingInfo.fontSizeRatio,
          isDark: this.settingInfo.darkSwitch,
          markCount: this.newsFeedVM.articleDetails.markCount!!,
          shareCount: this.newsFeedVM.articleDetails.shareCount,
          isMarked: this.newsFeedVM.articleDetails.isMarked!!,
          onMarked: (value: boolean) => {
            this.newsFeedVM.addMark(value)
          },
          shareBuilder: () => {
            this.shareBuilder()
          },
          onScrollToComment: () => {
            this.newsFeedVM.scrollToComment(this.newsBreakPoint.isSplit)
          },
          onComment: (commentContent: string) => {
            this.newsFeedVM.addNewsComment(commentContent)
          },
        })
      }
      .margin({ top: 16, bottom: 32 })
      .padding({ left: CommonConstants.PADDING_L, right: CommonConstants.PADDING_L })
    }
    .backgroundColor($r('sys.color.background_primary'))
  }

  build() {
    NavDestination() {
      if (this.longTakeSession) {
        LongTakeTransitionDelegate({
          longTakeSession: this.longTakeSession,
          contentBuilder: (): void => {
            this.ContentBuilder()
          },
        })
      } else {
        this.ContentBuilder()
      }
    }
    .backgroundColor(this.longTakeSession.navDestinationBgColor)
    .hideTitleBar(true)
    .id('ArticleFeedDetails')
    .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
      this.longTakeSession.setNewSize(newValue);
    })
    .onReady((navDestContext: NavDestinationContext) => {
      this.newsFeedVM.registerCustomTransition(navDestContext, this.longTakeSession)
    })
    .onShown(() => {
      this.newsFeedVM.enableContinue(this.getUIContext().getHostContext() as common.UIAbilityContext);
    })
  }
}