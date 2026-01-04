import { newsInformation, newsInformationInterface, RouterMap, RouterUtils } from 'lib_common';

@ComponentV2
export struct NewsSwiper {
  @Local announcementTitles: string[] = []
  @Local currentIndex: number = 0;
  @Local currentNewsList: newsInformationInterface[] = []

  aboutToAppear(): void {
    this.initAnnouncementTitles()
  }

  build() {
    Row() {
      Image($r('app.media.gonggao'))
        .width(20)
        .height(20)
        .margin({ left: 16, right: 8 })

      // 中间滚动文字区域
      Stack() {
        if (this.announcementTitles.length > 0) {
          Swiper() {
            ForEach(this.announcementTitles, (title: string, index: number) => {
              Text(title)
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ right: 30 })
                .width('100%')
                .onClick(() => {
                  // 点击跳转到对应的公告详情页
                  if (this.currentNewsList.length > index) {
                    const currentNews = this.currentNewsList[index]
                    RouterUtils.pushPathByName(RouterMap.NEWSDETAIL_PAGE, currentNews)
                  }
                })
            }, (v: string) => v)
          }
          .autoPlay(true) // 开启自动滚动
          .interval(100) // 滚动间隔（毫秒），值越小滚动越平滑
          .duration(8000) // 滚动动画时长（毫秒），固定时长实现匀速效果
          .curve(Curve.Linear)
          .loop(true) // 开启循环滚动
          .vertical(false) // 水平方向滚动
          .indicator(false) // 隐藏滚动指示器
          .onChange((index: number) => {
            // 更新当前索引
            this.currentIndex = index
          })
        } else {
          // 如果没有公告数据，显示默认文本
          Text('暂无官方公告')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .padding({ left: 4, right: 4 })
            .width('100%')
        }
      }
      .layoutWeight(1)
      .height(48)
      .clip(true) // 裁剪超出部分

      Image($r('app.media.ic_right'))
        .width(12)
        .height(12)
        .margin({ right: 16, left: 8 })
    }
    .width('100%')
    .height(48)
    .borderRadius(20)
    .margin({ top: 10, bottom: 8 })
    .backgroundColor(Color.White)
    .onClick(() => {
      // 整个区域点击事件
      if (this.currentNewsList.length > 0 && this.currentIndex < this.currentNewsList.length) {
        const currentNews = this.currentNewsList[this.currentIndex]
        RouterUtils.pushPathByName(RouterMap.NEWSDETAIL_PAGE, currentNews)
      }
    })
  }

  // 初始化公告标题列表
  private initAnnouncementTitles() {
    if (newsInformation.length > 0) {
      // 按时间排序，获取最新的公告标题
      const sortedNews = [...newsInformation].sort((a, b) => {
        // 将时间字符串转换为Date对象进行比较
        const dateA = new Date(a.time.replace(/\./g, '-'))
        const dateB = new Date(b.time.replace(/\./g, '-'))
        return dateB.getTime() - dateA.getTime()
      })

      // 保存完整的新闻对象列表，最多显示最新的2条
      this.currentNewsList = sortedNews.slice(0, 2)
      // 提取标题
      this.announcementTitles = this.currentNewsList.map(news => news.title)
    }
  }
}
