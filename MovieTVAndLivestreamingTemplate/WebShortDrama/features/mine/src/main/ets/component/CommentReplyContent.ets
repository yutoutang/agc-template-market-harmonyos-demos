import { jumpDetailPage, MyMessageStorage } from '@agctemplate/detail'
import { WindowManager } from '@agctemplate/utils'
import { it } from '@ohos/hypium'
import { CommentData, Reply } from '../models/messageData'
import { MessageCard } from './MessageCard'

@ComponentV2
export struct CommentReplyContent {

  @Param commentDataList: Array<CommentData> = []
  @Param myMessageList: Array<CommentData> = []
  @Local myMessageStorage: MyMessageStorage = MyMessageStorage.instance()

  build() {
    List() {
      ForEach(
        this.myMessageList,
        (item: CommentData) => {
          ForEach(
            item.replyList,
            (each: Reply, index: number) => {
              if(each.replyPeople === item.name) {
                ListItem() {
                  MessageCard({
                    myMessage: item,
                    reply: each
                  })
                }
                .onClick(() => {
                  jumpDetailPage(item.drama, item.drama.curIndex, 0, () => {
                    WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
                  })
                  this.myMessageStorage.isShowCommentSheet = true
                  this.myMessageStorage.isSpread = true
                  let commentIndex: number = this.commentDataList.indexOf(item)
                  this.myMessageStorage.moreList[commentIndex] = index - index % 5 + 5
                  if(commentIndex === 0) {
                    this.myMessageStorage.scrollIndex = index
                  }else {
                    this.commentDataList.slice(0, commentIndex).forEach((comment) => {
                      if(comment.replyList.length > 0) {
                        this.myMessageStorage.scrollIndex++
                      }
                    })
                    this.myMessageStorage.scrollIndex += (commentIndex + index)
                  }
                })
              }
            }
          )
        }
      )
      ListItem()
        .width('100%')
        .height(30)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}