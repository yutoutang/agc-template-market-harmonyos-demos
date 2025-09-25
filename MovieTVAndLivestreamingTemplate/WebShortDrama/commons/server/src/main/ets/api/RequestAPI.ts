import { BaseResponse } from '@agctemplate/utils'
import { DramaPageReq } from '../bean/request/DramaPageReq'
import { PageReq } from '../bean/request/PageReq'
import { CommentListRes } from '../bean/response/CommentListRes'
import { FeedDramaListRes } from '../bean/response/DramaListRes'
import { SearchPageReq } from '../bean/request/SearchPageReq'
import { CategoryRes } from '../bean/response/CategoryRes'
import { MyFollowDramaRes } from '../bean/response/MyFollowDramaRes'
import { Body, POST, GET } from './Decorators'
import { SearchTipRes } from '../bean/response/SearchTipRes'
import { TheaterDramaRes } from '../bean/response/TheaterDramaRes'
import { Domain } from './Domain'
import './mock/ApiMock'
import './mock/TheaterApiMock'
import { BannerRes } from '../bean/response/BannerRes'
import { MyWatchRecordData, MyWatchRecordRes } from '../bean/response/MyWatchRecordRes'
import { TokenReq } from '../bean/request/TokenReq'
import { TokenRes } from '../bean/response/TokenRes'
import { UserInfoRes } from '../bean/response/UserInfoRes'
import { EpisodeListRes } from '../bean/response/EpisodeListRes'
import { UserLoginRes } from '../bean/response/UserLoginRes'
import { GetUserInfoRes } from '../bean/response/GetUserInfoRes'
import { AssociateAccountRes, AssociateAccountRequest } from '../bean/response/AssociateAccountRes'
import { DisassociateAccountRes } from '../bean/response/DiassociateAccountRes'
import { MyLikeDramaRes } from '../bean/response/MyLikeDramaRes'
import { CommentItem, Drama, Replying, ReplyLike } from './mock/mockData/bean'

export class RequestAPI implements Domain {
  getDomain(): string {
    // todo 替换成你业务接口访问的域名
    return 'https://agc.template.com';
  }

  @POST({ path: '/myfollowdrama/list', needLogin: true })
  getMyFollowDrama(@Body pageReq: PageReq): Promise<BaseResponse<MyFollowDramaRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/mylikedrama/list', needLogin: true })
  getMyLikeDrama(@Body pageReq: PageReq): Promise<BaseResponse<MyLikeDramaRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/mywatchrecord/list' })
  getMyWatchRecord(@Body pageReq: PageReq): Promise<BaseResponse<MyWatchRecordRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/feeddrama/list' })
  getFeedDramaList(@Body pageReq: PageReq): Promise<BaseResponse<FeedDramaListRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/episode/list' })
  getEpisodeList(@Body dramaId: string): Promise<BaseResponse<EpisodeListRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/comment/list' })
  getCommentList(@Body pageReq: PageReq): Promise<BaseResponse<CommentListRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @GET({ path: '/theater/category' })
  getBillboardCategoryList(): Promise<BaseResponse<CategoryRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @GET({ path: '/theater/billboard' })
  getBillboardDramaList(@Body pageReq: DramaPageReq): Promise<BaseResponse<TheaterDramaRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @GET({ path: '/theater/billboard/preview' })
  getBillboardDramaPreviewList(@Body category: string): Promise<BaseResponse<TheaterDramaRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @GET({ path: '/theater/recommend' })
  getRecommendDramaList(@Body pageReq: PageReq): Promise<BaseResponse<TheaterDramaRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @GET({ path: '/theater/viprecommend' })
  getVipRecommendDramaList(@Body pageReq: PageReq): Promise<BaseResponse<TheaterDramaRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @GET({ path: '/theater/search' })
  getSearchDramaList(@Body pageReq: SearchPageReq): Promise<BaseResponse<TheaterDramaRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @GET({ path: '/theater/search/tip' })
  getSearchTipList(@Body searchText: string): Promise<BaseResponse<SearchTipRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @GET({ path: '/theater/banner' })
  getBannerList(): Promise<BaseResponse<TheaterDramaRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @GET({ path: '/theater/vipbanner' })
  getVipBannerList(): Promise<BaseResponse<TheaterDramaRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/api/user/login' })
  userLogin(@Body id: string): Promise<BaseResponse<UserLoginRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @GET({ path: '/api/user/info' })
  getUserInfo(@Body id: string): Promise<BaseResponse<GetUserInfoRes>> {
    return Promise.resolve(new BaseResponse());
  }

  @POST({ path: '/api/user/associate' })
  associateAccount(@Body data: AssociateAccountRequest): Promise<BaseResponse<AssociateAccountRes>> {
    return Promise.resolve(new BaseResponse());
  }

  @POST({ path: '/api/user/disassociate' })
  disassociateAccount(): Promise<BaseResponse<DisassociateAccountRes>> {
    return Promise.resolve(new BaseResponse());
  }

  @POST({ path: '/getaccesstoken' })
  getAccessToken(@Body tokenReq: TokenReq): Promise<BaseResponse<TokenRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/getuserinfo', needLogin: true })
  userInfo(): Promise<BaseResponse<UserInfoRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/setfavorite', needLogin: true })
  setFavorite(@Body dramaId: string): Promise<BaseResponse<MyFollowDramaRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/unsetfavorite', needLogin: true })
  unsetFavorite(@Body dramaId: string): Promise<BaseResponse<MyFollowDramaRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/setmyWatchrecord', needLogin: true })
  setMyWatchRecord(@Body drama: Drama): Promise<BaseResponse<MyWatchRecordRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/unsetsetmyWatchrecord', needLogin: true })
  unsetMyWatchRecord(@Body dramaId: string): Promise<BaseResponse<MyWatchRecordRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/setlike', needLogin: true })
  setLike(@Body dramaId: string): Promise<BaseResponse<MyLikeDramaRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/unsetlike', needLogin: true })
  unsetLike(@Body dramaId: string): Promise<BaseResponse<MyLikeDramaRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/addcomment', needLogin: true })
  addComment(@Body commentItem: CommentItem): Promise<BaseResponse<CommentItem>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/addreply', needLogin: true })
  addReply(@Body replying: Replying): Promise<BaseResponse<Replying>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/oncommentlike', needLogin: true })
  onCommentLike(@Body id: number): Promise<BaseResponse<number>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/onreplylike', needLogin: true })
  onReplyLike(@Body replyLike: ReplyLike): Promise<BaseResponse<ReplyLike>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/commentreplylist', needLogin: true })
  getRelyList(@Body pageReq: PageReq): Promise<BaseResponse<CommentListRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/commentlikelist', needLogin: true })
  getLikeList(@Body pageReq: PageReq): Promise<BaseResponse<CommentListRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/deletecommentreplylist', needLogin: true })
  deleteRelyList(@Body ids: number[]): Promise<BaseResponse<string>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/deletecommentlikelist', needLogin: true })
  deleteLikeList(@Body ids: number[]): Promise<BaseResponse<string>> {
    return Promise.resolve(new BaseResponse())
  }
}
