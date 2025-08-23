import { Constants } from '../commons/Constants';
import { CommentItem, KeywordItem } from '../commons/Types';
import { CommentApis } from '../https/Apis';
import { LazyDataSource, ObservedArray } from '../utils/LazyDataSource';

@ObservedV2
export class CommentListVM {
  @Trace keywordList: KeywordItem[] = [];
  @Trace commentList: LazyDataSource<CommentItem> = new LazyDataSource();
  @Trace curPage: number = 1
  @Trace totalNum: number = 0
  @Trace reachEnd: boolean = false;
  @Trace isLoading: boolean = false;
  scroller: Scroller = new Scroller();

  @Computed
  get edgeEffect() {
    if (typeof this.scroller.isAtEnd() === 'undefined') {
      return EdgeEffect.Spring;
    }
    return this.reachEnd || this.scroller.isAtEnd() ? EdgeEffect.Spring : EdgeEffect.None;
  }

  public async getRatingSummary() {
    this.keywordList = await CommentApis.getRatingSummary()
  }

  public async refreshCommentList() {
    this.reachEnd = false
    this.curPage = 1
    this.totalNum = 0
    this.commentList.clear()
    this.getCommentInfo()
  }

  public async getCommentInfo() {
    if (this.reachEnd) {
      return;
    }
    this.isLoading = true;
    const res = await CommentApis.getCommentInfo(this.curPage);
    if (res) {
      this.totalNum = res.totalNum
      const newComments = new ObservedArray(res.commentList);
      this.commentList.appendArrayData(newComments);
      if (this.curPage * Constants.COMMENT_PAGE_SIZE > this.totalNum) {
        this.reachEnd = true
      }
      this.curPage++
    }
    this.isLoading = false;
  }
}