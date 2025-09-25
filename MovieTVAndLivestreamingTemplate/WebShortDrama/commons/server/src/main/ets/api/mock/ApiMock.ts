import { MockAdapter } from '@agctemplate/utils';
import { getEpisodeList } from './mockData/mockEpisodeList';
import {
  getDramaInfo,
  getFavorite,
  getFeedDramaList,
  getLike,
  getMyWatchRecord,
  setFavorite,
  setLike,
  setMyWatchRecord,
  unsetFavorite,
  unsetLike,
  unsetMyWatchRecord
} from './mockData/mockDramaFactory';
import { addComment, addReply, getCommentList, onCommentLike, onReplyLike } from './mockData/mockCommentList';

// 设置模拟规则
MockAdapter
  .withDelay(100)
  .onPost({
    url: 'https://agc.template.com/mywatchrecord/list'
  }, {
    ret: {
      code: '0'
    },
    total: 3,
    myWatchRecord: getMyWatchRecord()
  })
  .onPost({
    url: 'https://agc.template.com/myfollowdrama/list'
  }, () => {
    return {
      ret: {
        code: '0'
      },
      total: 3,
      myFollowDramas: getFavorite()
    }
  })
  .onPost({
    url: 'https://agc.template.com/mylikedrama/list'
  }, () => {
    return {
      ret: {
        code: '0'
      },
      total: 3,
      myLikeDramas: getLike()
    }
  })
  .onPost({
    url: 'https://agc.template.com/comment/list'
  }, {
    ret: {
      code: '0'
    },
    totalCount: 4,
    commentList: getCommentList()
  })
  .onPost({
    url: 'https://agc.template.com/feeddrama/list'
  }, {
    ret: {
      code: '0'
    },
    total: 3,
    feedDramaList: getFeedDramaList()
  })
  .onPost({
    url: 'https://agc.template.com/episode/list'
  }, (config) => {
    let dramaId = JSON.parse(config.data)
    return {
      ret: {
        code: '0'
      },
      total: 3,
      dramaInfo: getDramaInfo(dramaId),
      episodeList: getEpisodeList()
    }
  })
  .onPost({
    url: 'https://agc.template.com/getaccesstoken'
  }, {
    ret: {
      code: '0'
    },
    accessToken: 'accessToken',
    refreshToken: 'refreshToken',
    expireTime: `${Date.now() + 60 * 60 * 1000}`
  })
  .onPost({
    url: 'https://agc.template.com/getuserinfo'
  }, {
    ret: {
      code: '0'
    },
    id: '123',
    name: '瓜瓜',
    image: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar%2Fman1.png?token=454d3803-0b69-4fb5-b0d1-33c0f9007d15',
    phone: '133****7890'
  })
  .onPost({
    url: 'https://agc.template.com/setfavorite'
  }, (data) => {
    let dramaId = JSON.parse(data.data)
    setFavorite(dramaId)
    return {
      ret: {
        code: '0'
      }
    }
  })
  .onPost({
    url: 'https://agc.template.com/unsetfavorite'
  }, (data) => {
    let dramaId = JSON.parse(data.data)
    unsetFavorite(dramaId)
    return {
      ret: {
        code: '0'
      }
    }
  })
  .onPost({
    url: 'https://agc.template.com/setlike'
  }, (data) => {
    let dramaId = JSON.parse(data.data)
    setLike(dramaId)
    return {
      ret: {
        code: '0'
      }
    }
  })
  .onPost({
    url: 'https://agc.template.com/unsetlike'
  }, (data) => {
    let dramaId = JSON.parse(data.data)
    unsetLike(dramaId)
    return {
      ret: {
        code: '0'
      }
    }
  })
  .onPost({
    url: 'https://agc.template.com/setmyWatchrecord'
  }, (data) => {
    let dramaId = JSON.parse(data.data)
    setMyWatchRecord(dramaId)
    return {
      ret: {
        code: '0'
      }
    }
  })
  .onPost({
    url: 'https://agc.template.com/unsetsetmyWatchrecord'
  }, (data) => {
    let dramaId = JSON.parse(data.data)
    unsetMyWatchRecord(dramaId)
    return {
      ret: {
        code: '0'
      }
    }
  })
  .onPost({
    url: 'https://agc.template.com/api/user/associate'
  }, {
    ret: {
      code: '0'
    },
    cellphone: '133****7890'
  })
  .onPost({
    url: 'https://agc.template.com/api/user/disassociate'
  }, {
    ret: {
      code: '0'
    },
    cellphone: '133****7890'
  })
  .onGet({
    url: 'https://agc.template.com/api/user/info'
  }, {
    ret: {
      code: '0'
    },
    userInfo: {
      id: '123',
      nickname: '瓜瓜',
      avatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar%2Fman1.png?token=454d3803-0b69-4fb5-b0d1-33c0f9007d15',
      cellphone: '133****7890',
      isPhoneAssociated: false,
      isMock: false
    }
  })
  .onPost({
    url: 'https://agc.template.com/addcomment'
  }, (data) => {
    addComment(JSON.parse(data.data))
    return {
      ret: {
        code: '0'
      }
    }
  })
  .onPost({
    url: 'https://agc.template.com/addreply'
  }, (data) => {
    addReply(JSON.parse(data.data))
    return {
      ret: {
        code: '0'
      }
    }
  })
  .onPost({
    url: 'https://agc.template.com/oncommentlike'
  }, (data) => {
    onCommentLike(JSON.parse(data.data))
    return {
      ret: {
        code: '0'
      }
    }
  })
  .onPost({
    url: 'https://agc.template.com/onreplylike'
  }, (data) => {
    onReplyLike(JSON.parse(data.data))
    return {
      ret: {
        code: '0'
      }
    }
  })
  .onPost({
    url: 'https://agc.template.com/commentreplylist'
  }, {
    ret: {
      code: '0'
    },
    total: 3,
    commentList: getCommentList()
  })
  .onPost({
    url: 'https://agc.template.com/commentlikelist'
  }, {
    ret: {
      code: '0'
    },
    total: 3,
    commentList: getCommentList()
  })
  .onPost({
    url: 'https://agc.template.com/deletecommentreplylist'
  }, {
    ret: {
      code: '0'
    },
    message: 'success'
  })
  .onPost({
    url: 'https://agc.template.com/deletecommentlikelist'
  }, {
    ret: {
      code: '0'
    },
    message: 'fail'
  })

