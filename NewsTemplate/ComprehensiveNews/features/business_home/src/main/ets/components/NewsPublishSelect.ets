import { PersistenceV2 } from '@kit.ArkUI'
import { CommonConstants, CoverUri, UserInfoModel } from 'lib_common'
import { ButtonGroup, NavHeaderBar } from 'lib_widget'
import { NewsStyleEnum, newsStyleList } from '../constants/NewsConstants'
import { NewsPostViewModel } from '../viewmodels/NewsPostViewModel'
import { UploadCover } from './UploadCover'


@Builder
export function NewsPublishSelectBuilder() {
  NewsPublishSelect()
}

@ComponentV2
export struct NewsPublishSelect {
  @Local newsPostViewModel: NewsPostViewModel = new NewsPostViewModel()
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;

  @Builder
  noneImageNews() {
    Column({ space: 16 }) {
      Text(this.newsPostViewModel.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Text(this.userInfoModel.authorNickName)
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_tertiary'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  singleImageNews() {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      Column({ space: 16 }) {
        Text(this.newsPostViewModel.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
        Text(this.userInfoModel.authorNickName)
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .flexGrow(1)
      .alignItems(HorizontalAlign.Start)

      ForEach(this.newsPostViewModel.coverSingleList, (item: CoverUri) => {
        Column() {
          UploadCover({
            coverUri: item.uri,
            onSelected: (uri: string) => {
              item.uri = uri
            },
            onDeleteUri: (uri: string) => {
              item.uri = ''
            },
          })
        }
      })
    }
  }

  @Builder
  threeImageNews() {
    Column({ space: 16 }) {
      Text(this.newsPostViewModel.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.newsPostViewModel.coverThreeList, (item: CoverUri) => {
          Column() {
            UploadCover({
              coverUri: item.uri,
              onSelected: (uri: string) => {
                item.uri = uri
              },
            })
          }
        })
      }

      Text(this.userInfoModel.authorNickName)
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_tertiary'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '',
      })
      Column({ space: 16 }) {
        ButtonGroup({
          buttonList: newsStyleList,
          selectedId: this.newsPostViewModel.selectedId!!,
        })
        if (this.newsPostViewModel.selectedId === NewsStyleEnum.IMAGE_NONE) {
          this.noneImageNews()
        } else if (this.newsPostViewModel.selectedId === NewsStyleEnum.IMAGE_SINGLE) {
          this.singleImageNews()
        } else {
          this.threeImageNews()
        }
      }
      .padding({ left: CommonConstants.SPACE_L, right: CommonConstants.SPACE_L })

      Column() {
        Button('发布')
          .width(CommonConstants.FULL_PERCENT)
          .onClick(() => {
            this.newsPostViewModel.publishNews()
          })
      }
      .position({ bottom: 32, left: 0 })
      .width(CommonConstants.FULL_PERCENT)
      .padding({ left: 16, right: 16 })
    }
    .hideTitleBar(true)
    .onReady((context) => {
      const param = context.pathInfo.param as Record<string, string>
      this.newsPostViewModel.title = param.title
      this.newsPostViewModel.content = param.content
    })
  }
}