export interface newsInformationInterface {
  id: string
  image: Resource,
  title: string,
  time: string
  uri?: string
  content: Resource | string
}

export const newsInformation: newsInformationInterface[] = [
  {
    id: '1',
    image: $r('app.media.news_1'),
    title: '出行多样化，你知道南京交通到底有多便利',
    time: '2025-03-17',
    content: $r('app.string.newsContent1')
  },
  {
    id: '2',
    image: $r('app.media.news_2'),
    title: '南京10条地铁建设新进展！',
    time: '2025-03-16',
    content: $r('app.string.newsContent1')
  },
  {
    id: '3',
    image: $r('app.media.news_3'),
    title: '南京出租车收费新标准！',
    time: '2025-03-15',
    content: $r('app.string.newsContent1')
  },
  {
    id: '4',
    image: $r('app.media.news_4'),
    title: '南京地铁地图已更新！',
    time: '2025-02-26',
    content: $r('app.string.newsContent1')
  },
  {
    id: '5',
    image: $r('app.media.news_5'),
    title: '周边露营，地铁出行！',
    time: '2025-02-16',
    content: $r('app.string.newsContent1')
  },
  {
    id: '6',
    image: $r('app.media.news_6'),
    title: '现场直击，南京地铁早高峰！',
    time: '2025-02-16',
    content: $r('app.string.newsContent1')
  },
  {
    id: '7',
    image: $r('app.media.news_7'),
    title: '南京地铁，为爱发电！',
    time: '2025-02-26',
    content: $r('app.string.newsContent1')
  },
]