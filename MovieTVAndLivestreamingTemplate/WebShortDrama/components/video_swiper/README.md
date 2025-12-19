# 竖屏滑动视频组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了展示短剧竖屏滑动视频、上下滑动切换短剧视频、切换到指定索引短剧视频等相关的能力，可以帮助开发者快速集成滑动短剧视频相关的能力。

<img src="./screenshots/video_swiper.jpeg" height="300">

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.0 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.0 Release SDK及以上
- 设备类型：华为手机（直板机、双折叠）
- HarmonyOS版本：HarmonyOS 5.0.0 Release及以上

### 权限

- 网络权限：ohos.permission.INTERNET

## 使用

1. 安装组件。 

    如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

    如果是从生态市场下载组件，请参考以下步骤安装组件。

    a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

    b. 在项目根目录build-profile.json5添加video_swiper模块

    ```typescript
    // 在项目根目录build-profile.json5填写video_swiper路径。其中XXX为组件存放的目录名
    "modules": [
      {
        "name": "video_swiper",
        "srcPath": "./XXX/video_swiper"
      },
      {
        "name": "module_cast",
        "srcPath": "./XXX/module_cast"
      }
    ]
    ```
   
    c. 在项目根目录oh-package.json5中添加依赖。

    ```typescript
    // XXX为组件存放的目录名称
    "dependencies": {
      "video_swiper": "file:./XXX/video_swiper"
    }
    ```

2. 引入组件。

   ```typescript
   import { VideoSwiper, PlayController } from 'video_swiper';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   ```typescript
   import {
      PlayController,
      PlaySession,
      VideoPlayData,
      VideoPlayDataSource,
      VideoSwiper
   } from 'video_swiper';
   import { media } from '@kit.MediaKit';
   import common from '@ohos.app.ability.common';
   
   class EpisodeData implements VideoPlayData {
      url: media.AVFileDescriptor | string
   
      constructor(url: media.AVFileDescriptor | string) {
         this.url = url;
      }
   
      getName(): string {
         return 'name'
      }
   
      getId(): string {
         return 'id'
      }
   
      getDuration(): number {
         return 0
      }
   
      getUrl(): media.AVFileDescriptor | string {
         return this.url
      }
   
      getPlayTime(): number {
         return 0;
      }
   
      getPic(): string {
         return '';
      }
      isLocked():boolean{
         return false;
      }
   }
   
   @ComponentV2
   struct VideoDetail {
      build() {
         Stack({ alignContent: Alignment.Bottom }) {
            Text('Hello Video Swiper')
               .fontSize(40)
               .fontColor($r('sys.color.white'))
         }.height('100%')
   
      }
   }
   
   @Entry
   @ComponentV2
   struct Index {
      data: VideoPlayDataSource = new VideoPlayDataSource()
      httpUrls: Array<string> = []
      rawUrls: Array<string> = []
      private context: common.UIAbilityContext | undefined = undefined;
   
      aboutToAppear() {
      //初始化数据
      this.httpUrls = ['https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/2.m3u8','https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/3.m3u8']
      this.httpUrls.forEach((item:string)=>{
        let videoData: EpisodeData =
          new EpisodeData(item)
        this.data.pushData(videoData);
      })

      this.rawUrls = ['XX.mp4','XX.mp4']//1、将本地视频放在模块的resources/rawfile文件夹下 2、数组中填写本地视频文件名称(本地视频必须为mp4格式)
      this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      this.rawUrls.forEach(async (item:string)=> {
        let fileName = item; 
        let fileDescriptor = await this.context!.resourceManager.getRawFd(fileName);
        let avFileDescriptor: media.AVFileDescriptor =
          { fd: fileDescriptor.fd, offset: fileDescriptor.offset, length: fileDescriptor.length };
        let videoData: EpisodeData =
          new EpisodeData(avFileDescriptor)
        this.data.pushData(videoData);
        })
      }
   
      build() {
         Column() {
            // 视频切换组件
            VideoSwiper({
               videoPlayDataSource: this.data, // 视频数据
               contentBuilder: wrapBuilder(videoDetailComponent), // 自定义播放视频上的浮层界面
            })
         }
      }
   }
   
   @Builder
   function videoDetailComponent(videoData: VideoPlayData, playControl: PlayController,
      playerSession: PlaySession) {
   
      VideoDetail()
   }
   ```

4. 如需播放网络视频，需申请网络访问权限：ohos.permission.INTERNET

## API参考

### 接口

VideoSwiper(options: VideoSwiperOptions)

竖屏滑动视频组件。

**参数：**

| 参数名     | 类型                                            | 必填 | 说明         |
|---------|-----------------------------------------------|----|------------|
| options | [VideoSwiperOptions](#VideoSwiperOptions对象说明) | 是  | 配置竖屏滑动视频的参数。 |

### VideoSwiperOptions对象说明

| 名称                  | 类型                                                                              | 必填 | 说明             |
|---------------------|---------------------------------------------------------------------------------|----|----------------|
| videoPlayDataSource | [VideoPlayDataSource](#VideoPlayDataSource)                                     | 是  | 视频数据源          |
| playController      | [PlayController](#PlayController)                                               | 否  | 滑动播放控制器        |
| contentBuilder      | [WrappedBuilder<[VideoPlayData, PlayController, PlaySession]>](#WrappedBuilder) | 是  | 播放视频的上层自定义视图组件 |
| currentVideoIndex   | number                                                                          | 否  | 要播放的索引，默认0     |

### VideoPlayDataSource

竖屏滑动视频组件的视频数据源。**支持网络链接和本地资源，本地资源文件放在模块的resources/rawfile文件夹下。**

#### totalCount

totalCount(): number

获取总长度

#### getgData

getData(index: number): VideoPlayData

获取索引数据

#### addData

addData(index: number, data: VideoPlayData): void

增加视频到指定索引

#### pushData

pushData(data: VideoPlayData): void

添加数据

### PlayController

VideoSwiper组件的控制器，用于播放控制，剧集选集等交互。

#### constructor

constructor()

PlayController的构造函数。

#### play

play()

播放视频

#### pause

pause()

停止播放视频

#### seek

seek(timeMs: number)

设置播放进度，单位ms（跳转到指定时间的前一个关键帧视频）

#### setSpeed

setSpeed(speed: media.PlaybackSpeed)

设置播放速度（单视频生效）

#### changeIndex

changeIndex(index: number)

播放指定索引视频

### WrappedBuilder

WrappedBuilder<[VideoPlayData, PlayController, PlaySession]>

竖屏滑动视频组件自定义播放上层视图接口， 用于开发者自定义显示内容，并和播放视频交互，例如播放控制、事件监听、剧集选集等。

### VideoPlayData

视频数据抽象接口，开发者在满足此接口定义情况下可以继承实现扩展

#### getUrl

getUrl(): string | media.AVFileDescriptor

获取播放资源，需开发者实现

#### getPlayTime

getPlayTime():number

获取当前播放进度，需开发者实现

#### getPic

getPic(): ResourceStr

获取封面图片用于视频加载时显示，需开发者实现

### PlaySession

单个播放视频的会话管理，封装avplayer实现单视频播控和事件监听

#### onStateChange

onStateChange(key: string, callback: (state: string) => void): void

状态变化事件监听，支持"stateChange"监听

#### onTimeUpdate

onTimeUpdate(key: string, callback: (time: number) => void): void

播放时间进度更新事件监听

## 示例代码

### 示例1（剧集播放页播放视频）

本示例通过video_swiper实现播放视频。

   ```typescript
   import {
      PlayController,
      PlaySession,
      VideoPlayData,
      VideoPlayDataSource,
      VideoSwiper
   } from 'video_swiper';
   import { media } from '@kit.MediaKit';
   import common from '@ohos.app.ability.common';
   
   class EpisodeData implements VideoPlayData {
      id: string
      url: media.AVFileDescriptor | string
   
      constructor(url: media.AVFileDescriptor | string, id: string) {
         this.url = url;
         this.id = id;
      }
   
      getName(): string {
         return 'name'
      }
   
      getId(): string {
         return this.id
      }
   
      getDuration(): number {
         return 0
      }
   
      getUrl(): media.AVFileDescriptor | string {
         return this.url
      }
   
      getPlayTime(): number {
         return 0;
      }
   
      getPic(): string {
         return '';
      }
      isLocked():boolean{
         return false;
      }
   }
   
   @ComponentV2
   struct VideoDetail {
      build() {
         Stack({ alignContent: Alignment.Bottom }) {
            Text('Hello Video Swiper')
               .fontSize(40)
               .fontColor($r('sys.color.white'))
         }.height('100%')
   
      }
   }
   
   @Entry
   @ComponentV2
   struct Index {
      data: VideoPlayDataSource = new VideoPlayDataSource()
      httpUrls: Array<string> = []
      rawUrls: Array<string> = []
      private context: common.UIAbilityContext | undefined = undefined;
      private videoIndex:number = 0;
   
      aboutToAppear() {
      //初始化数据
      this.httpUrls = ['https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/2.m3u8','https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/3.m3u8']
      this.httpUrls.forEach((item:string)=>{
         let videoData: EpisodeData =
            new EpisodeData(item,String(this.videoIndex++))
         this.data.pushData(videoData);
      })

      this.rawUrls = ['XX.mp4','XX.mp4']//1、将本地视频放在模块的resources/rawfile文件夹下 2、数组中填写本地视频文件名称(本地视频必须为mp4格式)
      this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      this.rawUrls.forEach(async (item:string)=> {
         let fileName = item;
         let fileDescriptor = await this.context!.resourceManager.getRawFd(fileName);
         let avFileDescriptor: media.AVFileDescriptor =
            { fd: fileDescriptor.fd, offset: fileDescriptor.offset, length: fileDescriptor.length };
         let videoData: EpisodeData =
            new EpisodeData(avFileDescriptor,String(this.videoIndex++))
         this.data.pushData(videoData);
        })
      }
   
      build() {
         Column() {
            // 视频切换组件
            VideoSwiper({
               videoPlayDataSource: this.data, // 视频数据
               contentBuilder: wrapBuilder(videoDetailComponent), // 自定义播放视频上的浮层界面
            })
         }
      }
   }
   
   @Builder
   function videoDetailComponent(videoData: VideoPlayData, playControl: PlayController,
      playerSession: PlaySession) {
   
      VideoDetail()
   }
   ```

<img src="./screenshots/video_swiper_1.jpeg" width="300">

### 示例2（自定义组件使用，播放/暂停/更改播放剧集等）

   ```typescript
   import {
      PlayController,
      PlaySession,
      VideoPlayData,
      VideoPlayDataSource,
      VideoSwiper
   } from 'video_swiper';
   import { media } from '@kit.MediaKit';
   import { hilog } from '@kit.PerformanceAnalysisKit';
   import common from '@ohos.app.ability.common';
   
   class EpisodeData implements VideoPlayData {
      id: string;
      desc: string;
      url:media.AVFileDescriptor | string;
   
      constructor(url:media.AVFileDescriptor | string, desc: string, id: string) {
         this.desc = desc
         this.url = url
         this.id = id
      }
   
      getName(): string {
         return 'name'
      }
   
      getId(): string {
         return this.id
      }
   
      getDuration(): number {
         return 0
      }
   
      getUrl(): media.AVFileDescriptor | string {
         return this.url
      }
   
      getPlayTime(): number {
         return 0;
      }
   
      getPic(): string {
         return '';
      }
   
      getDesc(): string {
         return this.desc
      }
      isLocked():boolean{
         return false;
      }
   }
   
   let index: number = 0
   let length: number = 0
   
   @ComponentV2
   struct VideoDetail {
      @Param @Require playSession: PlaySession
      @Param @Require playControl: PlayController
      @Param @Require episodeData: EpisodeData
   
      aboutToAppear(): void {
         this.playSession.onStateChange('stateChange', (state: string) => {
         // 进入详情播放页播放下一集
         if (state === 'completed') {
         hilog.info(0x000, 'VideoDetail', 'play complete, will play next')
         this.changeIndex()
      }
   })
   }
   
   build() {
      Stack({ alignContent: Alignment.Bottom }) {
         Column() {
            Text(this.episodeData.getDesc())
               .fontColor($r('sys.color.white'))
            Button('play')
               .onClick(() => {
                  this.playControl.play()
               })
            Button('pause')
               .onClick(() => {
                  this.playControl.pause()
               })
            Button('changeIndex')
               .onClick(() => {
                  this.changeIndex()
            })
         }
      }.height('100%')
   }
   
   changeIndex() {
      if (index === length - 1) {
         index = 0
      } else {
         index ++
      }
      this.playControl.changeIndex(index)
   }
   }
   
   @Entry
   @ComponentV2
   struct Index {
      data: VideoPlayDataSource = new VideoPlayDataSource()
      httpUrls: Array<string> = []
      rawUrls: Array<string> = []
      private context: common.UIAbilityContext | undefined = undefined;
      private videoIndex:number = 0;
   
      aboutToAppear() {
      //初始化数据
      this.httpUrls = ['https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/2.m3u8','https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/3.m3u8']
      this.httpUrls.forEach((item:string,index:number)=>{
         let videoData: EpisodeData =
            new EpisodeData(item,`this is episode for http ${index}`, String(this.videoIndex++))
         this.data.pushData(videoData);
      })

      this.rawUrls = ['XX.mp4','XX.mp4']//1、将本地视频放在模块的resources/rawfile文件夹下 2、数组中填写本地视频文件名称(本地视频必须为mp4格式)
      this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      this.rawUrls.forEach(async (item:string,index:number)=> {
         let fileName = item;
         let fileDescriptor = await this.context!.resourceManager.getRawFd(fileName);
         let avFileDescriptor: media.AVFileDescriptor =
            { fd: fileDescriptor.fd, offset: fileDescriptor.offset, length: fileDescriptor.length };
         let videoData: EpisodeData =
            new EpisodeData(avFileDescriptor,`this is episode for rawfile ${index}`, String(this.videoIndex++))
         this.data.pushData(videoData);
         length = this.data.totalCount()
        })
      }
   
      build() {
         Column() {
            // 视频切换组件
            VideoSwiper({
               videoPlayDataSource: this.data, // 视频数据
               contentBuilder: wrapBuilder(videoDetailComponent), // 自定义播放视频上的浮层界面
            })
         }
      }
   }
   
   @Builder
   function videoDetailComponent(videoData: VideoPlayData, playControl: PlayController,
      playerSession: PlaySession) {
   
      VideoDetail({
         episodeData: videoData as EpisodeData,
         playControl: playControl,
         playSession: playerSession
      })
   }
   ```

| 第一集                                                         | 第二集                                                         |
|-------------------------------------------------------------|-------------------------------------------------------------|
| <img src="./screenshots/video_swiper_2_1.jpeg" width="300"> | <img src="./screenshots/video_swiper_2_2.jpeg" width="300"> |
