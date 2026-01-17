import { NewsEnum, VideoEnum } from '../../constants/Constants';
import { BaseNews } from '../../database/NewsType';

export class MockVideo {
  static mineList: BaseNews[] = [
    {
      id: 'video_mine_1',
      type: NewsEnum.Video,
      title: '《华为逆行者》科摩罗篇：驻守火山岛，他们是联接科摩罗群岛的信使',
      authorId: '001',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_9',
        newsType: 1,
      }, {
        newsId: 'article_11',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/73253951779340a39a7763e29f40ccb8.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/73253951779340a39a7763e29f40ccb8.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 405504,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'video_mine_2',
      type: NewsEnum.Video,
      title: '在马达加斯加，和盘古一起与风暴赛跑',
      authorId: '001',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_6',
        newsType: 1,
      }, {
        newsId: 'article_7',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/1fe450a626db4fc9ad86a960c60ea993.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/1fe450a626db4fc9ad86a960c60ea993.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 425386,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
  ];
  static liveVideoList: BaseNews[] = [
    {
      id: 'live_video1',
      type: NewsEnum.Video,
      title: '新通话，让每一次连接超越想象',
      authorId: 'author_1',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 1,
      shareCount: 0,
      isLiked: true,
      isMarked: false,
      recommends: [{
        newsId: 'article_10',
        newsType: 1,
      }, {
        newsId: 'article_11',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/a20e0965e56a4dc498fc33ee23750c0d.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/a20e0965e56a4dc498fc33ee23750c0d.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 134506,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'live_video2',
      type: NewsEnum.Video,
      title: '以行践言，让科技与自然共生',
      authorId: 'author_2',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 1,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: true,
      recommends: [{
        newsId: 'article_10',
        newsType: 1,
      }, {
        newsId: 'article_11',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/daa381bc66604878bd403ef77c1c458d.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/935d7a0c9e4a41db95de250a004ce6a7.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/daa381bc66604878bd403ef77c1c458d.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/935d7a0c9e4a41db95de250a004ce6a7.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 204800,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'live_video3',
      type: NewsEnum.Video,
      title: '用科技为黄河三角洲鸟类生态保护开创更多可能',
      authorId: 'author_3',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_10',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/95c55588cbdb4b999eeae0c069dbc5d9.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/eb8efe3c1000428e8619a47c1e110922.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/95c55588cbdb4b999eeae0c069dbc5d9.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/eb8efe3c1000428e8619a47c1e110922.jpg',
      videoType: VideoEnum.Landscape,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      videoDuration: 371605,
    },
  ]
  static list: BaseNews[] = [
    ...MockVideo.mineList,
    ...MockVideo.liveVideoList,
    {
      id: 'video1',
      type: NewsEnum.Video,
      title: '新通话，让每一次连接超越想象',
      authorId: 'author_1',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 1,
      shareCount: 0,
      isLiked: true,
      isMarked: false,
      recommends: [{
        newsId: 'article_10',
        newsType: 1,
      }, {
        newsId: 'article_11',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/a20e0965e56a4dc498fc33ee23750c0d.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/a20e0965e56a4dc498fc33ee23750c0d.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 134506,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'video2',
      type: NewsEnum.Video,
      title: '以行践言，让科技与自然共生',
      authorId: 'author_2',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 1,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: true,
      recommends: [{
        newsId: 'article_10',
        newsType: 1,
      }, {
        newsId: 'article_11',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/daa381bc66604878bd403ef77c1c458d.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/935d7a0c9e4a41db95de250a004ce6a7.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/daa381bc66604878bd403ef77c1c458d.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/935d7a0c9e4a41db95de250a004ce6a7.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 204800,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'video3',
      type: NewsEnum.Video,
      title: '用科技为黄河三角洲鸟类生态保护开创更多可能',
      authorId: 'author_3',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_10',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/95c55588cbdb4b999eeae0c069dbc5d9.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/eb8efe3c1000428e8619a47c1e110922.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/95c55588cbdb4b999eeae0c069dbc5d9.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/eb8efe3c1000428e8619a47c1e110922.jpg',
      videoType: VideoEnum.Landscape,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      videoDuration: 371605,
    },
    {
      id: 'video4',
      type: NewsEnum.Video,
      title: '《华为逆行者》科摩罗篇：驻守火山岛，他们是联接科摩罗群岛的信使',
      authorId: 'author_4',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_9',
        newsType: 1,
      }, {
        newsId: 'article_11',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/73253951779340a39a7763e29f40ccb8.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/73253951779340a39a7763e29f40ccb8.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 405504,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'video5',
      type: NewsEnum.Video,
      title: '在马达加斯加，和盘古一起与风暴赛跑',
      authorId: 'author_5',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_6',
        newsType: 1,
      }, {
        newsId: 'article_7',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/1fe450a626db4fc9ad86a960c60ea993.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/1fe450a626db4fc9ad86a960c60ea993.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 425386,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'video6',
      type: NewsEnum.Video,
      title: 'DeepSeek的所谓综合排名以“开创性+跨学科影响+方法论',
      authorId: 'author_6',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_6',
        newsType: 1,
      }, {
        newsId: 'article_7',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://e-file.huawei.com/mediares/MarketingMaterial_MCD/EBG/PUBLIC/zh/2025/05/e225ca18-0b76-4fca-918a-ff97e3a99de8.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
        },
      ],
      playCount: '1700',
      videoUrl: 'https://e-file.huawei.com/mediares/MarketingMaterial_MCD/EBG/PUBLIC/zh/2025/05/e225ca18-0b76-4fca-918a-ff97e3a99de8.mp4',
      coverUrl: 'https://e-file.huawei.com/mediares/Video_MCD/EBG/PUBLIC/zh/2025/05/43f01339-48e0-4e5d-a433-ccb8c423cdfe.png',
      videoType: VideoEnum.Landscape,
      videoDuration: 98005,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
    {
      id: 'video7',
      type: NewsEnum.Video,
      title: '综合排名以“开创性+跨学科影响+方法论',
      authorId: 'author_7',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_2',
        newsType: 1,
      }, {
        newsId: 'article_5',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://e-file.huawei.com/mediares/MarketingMaterial_MCD/EBG/PUBLIC/zh/2025/04/5feb8457-d5e9-4949-a181-795e4d873af9.mp4',
          surfaceUrl: 'https://e-file.huawei.com/mediares/Video_MCD/EBG/PUBLIC/zh/2025/04/3c04b872-197d-4551-a353-0eb99def6ca2.png',
        },
      ],
      playCount: '45000',
      videoUrl: 'https://e-file.huawei.com/mediares/MarketingMaterial_MCD/EBG/PUBLIC/zh/2025/04/5feb8457-d5e9-4949-a181-795e4d873af9.mp4',
      coverUrl: 'https://e-file.huawei.com/mediares/Video_MCD/EBG/PUBLIC/zh/2025/04/3c04b872-197d-4551-a353-0eb99def6ca2.png',
      videoType: VideoEnum.Landscape,
      videoDuration: 48234,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
    {
      id: 'video8',
      type: NewsEnum.Video,
      title: '第12波！伊朗猛砸高超弹，400秒击中以色列，撕裂世界第一防空网',
      authorId: 'author_4',
      markCount: 0,
      createTime: 1751089800000,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_10',
        newsType: 1,
      }],
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      postImgList: [
        {
          picVideoUrl: 'https://e-file.huawei.com/mediares/MarketingMaterial_MCD/EBG/PUBLIC/zh/2025/04/5feb8457-d5e9-4949-a181-795e4d873af9.mp4',
          surfaceUrl: 'https://e-file.huawei.com/mediares/Video_MCD/EBG/PUBLIC/zh/2025/04/3c04b872-197d-4551-a353-0eb99def6ca2.png',
        },
      ],
      videoUrl: 'https://e-file.huawei.com/mediares/MarketingMaterial_MCD/EBG/PUBLIC/zh/2025/04/5feb8457-d5e9-4949-a181-795e4d873af9.mp4',
      coverUrl: 'https://e-file.huawei.com/mediares/Video_MCD/EBG/PUBLIC/zh/2025/04/3c04b872-197d-4551-a353-0eb99def6ca2.png',
      articleFrom: '4号选手',
      videoDuration: 48234,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
  ];
}