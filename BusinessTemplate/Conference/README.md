# 商务（会务）元服务模板快速入门

## 目录

- [功能介绍](#功能介绍)
- [约束和限制](#约束和限制)
- [快速入门](#快速入门)
- [示例效果](#示例效果)
- [开源许可协议](#开源许可协议)

## 功能介绍

您可以基于此模板直接定制会议类元服务。

本模板为商务会展类元服务提供了常用功能的开发样例，模板主要分首页、议程和我的三大模块：

- 首页：展示大会议程、精彩活动、会议信息等。
- 议程：展示每日的详细议程，并支持按关键字进行筛选。
- 我的：管理门票、收藏的议程和兴趣标签。

本模板已集成华为账号、地图等服务，只需做少量配置和定制即可快速实现华为账号的登录、会场位置定位导航等功能

| 首页                                                        | 会议详情                                                      | 个人中心                                                   |
|-----------------------------------------------------------|-----------------------------------------------------------|--------------------------------------------------------|
| <img src="screenshots/homepage.jpg" alt="首页" width="300"> | <img src="screenshots/meeting.jpg" alt="详情" width="300"/> | <img src="screenshots/my.jpg" alt="个人中心" width="300"/> |

功能结构如下：

```ts
会议模板
 |-- 首页
 |    |-- 搜索
 |    |-- 大会议程
 |    |-- 精彩活动
 |    |    └-- 活动简介
 |    |-- 精彩视频
 |    |    └-- 卡片视图
 |    |-- 合作伙伴
 |    |-- 广告
 |    └-- 卡片服务
 |         └-- 添加桌面卡片
 |-- 议程
 |    |-- 搜索
 |    |-- 筛选
 |    |-- 主体演讲
 |    |    |-- 议程简介
 |    |    |-- 议程安排
 |    |    |-- 直播回放
 |    |    |-- 日历添加
 |    |    └-- 收藏功能
 └-- 我的
      |-- 关联手机号
      |    |-- 查看门票
      |    |-- 查看收藏的议程
      |    └-- 查看兴趣标签
      |-- 常用服务
      |    |-- 大会地图
      |    |-- 园区餐饮
      |    |-- 交通出行
      |    └-- 常见问题
      |-- 设置
      |    └-- 查看隐私政策
      |-- 联系我们
      └-- 外部链接
      
Conference
  |- common/commons                                   // 公共层
  |   |- src/main/ets
  |   |    |- api                                     // 接口
  |   |    |     serviceArticle.ets                   // 外部数据对接
  |   |    |     serviceDict.ets                      // 人群标签
  |   |    |     serviceLogin.ets                     // 登录
  |   |    |- common                                  
  |   |    |     AvoidRepeatClick.ets                 // 防止重复点击
  |   |    |     ErrorCodeEntity.ets                  // 错误码
  |   |    |     Utils.ets                            // 工具类
  |   |    |- constants                               
  |   |    |     BreakPointConstats.ets               // 视图常量
  |   |    |     Constants.ets                        // 底部标签常量
  |   |    |     MyConfig.ets                         // 会议数据常量
  |   |    |- pages                                   
  |   |    |     Login.ets                            // 登录
  |   |    |     MyWebView.ets                        // 嵌入网页页面
  |   |    |     Ticket.ets                           // 票务页面
  |   |    |- utils     
  |   |    |     AppUtil.ets                          // app工具                            
  |   |    |     api.ets                              // 请求接口
  |   |    |     BreakPointSystem.ets                 // 响应式布局断点系统
  |   |    |     BreakPointSystem.ets                 // 一多适配类
  |   |    |     cardData.ets                         // 议程卡片数据
  |   |    |     checkStatus.ets                      // 状态确认
  |   |    |     CommonUtils.ets                      // 工具类
  |   |    |     Index.ets                            // 工具函数
  |   |    |     logger.ets                           // 日志工具
  |   |    |     PreferencesUtil.ets                  // 本地数据管理
  |   |    |     PromptActionClass.ets                // 自定义对话框
  |   |    |     SendQrcode.ets                       // 更新二维码信息
  |   |    |     TalkingData.ets                      // 用户行为数据采集
  |   |    |- view                                   
  |   |    |     Phone.ets                            // 手机号授权
  |   |    |     PrivacyDialog.ets                    // 隐私
  |   |    |     SignupModal2.ets                     // 会议报名
  |   |    |     TagChildItem.ets                     // 标签展示
  |   |    └- viewModel                              
  |   |    |     ArticleModel.ets                     // 数据模型
  |   |    |     FormDataModel.ets                    // 门票卡片模型
  |   |    |     ItineraryAndCardAgendaModel.ets      // 会议、行程接口数据模型
  |   |    |     MyTagList.ets                        // 我的标签
  |   |    |     ParamsType.ets                       // 参数类型
  |   |    |     TagModel.ets                         // 标签模型
  |   |    |     UserModel.ets                        // 用户信息数据模型
  |   |    |     VideoModel.ets                       // 视频数据模型
  |   |    |  
  |- product/phone                                    // 会议核心框架
  |   |- src/main/ets
  |   |    |- entryability                            
  |   |    |     EntryAbility.ets                     // 生命周期管理
  |   |    |- entryformability                        
  |   |    |     EntryFormAbility.ets                 // 桌面卡片能力
  |   |    |- insightintents                         
  |   |    |     IntentExecutorImpl.ets               // 意图调用
  |   |    |- pages                                   
  |   |    |     Index.ets                            // 小艺卡片入口
  |   |    |     PrepareIndex.ets                     // 主页面管理
  |   |    |- utils                                  
  |   |    |     jump.ets                             // 跳转逻辑
  |   |    |- view                                    
  |   |    |     TagListDialog.ets                    // 弹窗组件
  |   |    └- widget                                 
  |   |    |     └- model                             
  |   |    |           FormCardConstant.ets           // 路由常量
  |   |    |     └- pages                             
  |   |    |           AgendaWidget2x2.ets            // 2x2 尺寸桌面日程卡片
  |   |    |           AgendaWidget2x4.ets            // 2x4 尺寸桌面日程卡片
  |   |    |           AgendaWidget4x4.ets            // 4x4 尺寸桌面日程卡片
  |   |    └-           TicketCard2x2.ets             // 票务卡片
  |- scenes/agenda                                    // 活动会议
  |   |- src/main/ets
  |   |    |- pages                                   
  |   |    |     ActivityListLevelTwo.ets             // 活动列表
  |   |    |     Agenda.ets                           // 议程主页面
  |   |    |     AgendaDetail.ets                     // 议程详情页
  |   |    |     AgendaSearchAndFilter.ets            // 搜索筛选
  |   |    |     AgendaSearchResult.ets               // 搜索结果
  |   |    |- service                                 
  |   |    |     AgendaService.ets                    // 会议功能
  |   |    |     DictService.ets                      // 会议地点数据
  |   |    |- utils                                  
  |   |    |     CalendarUtil.ets                     // 日历工具类
  |   |    |- view                                    
  |   |    |     activityList.ets                     // 活动展示
  |   |    |     agendaList.ets                       // 差异化议程展示
  |   |    |     agendaListItem.ets                   // 议程列表子组件
  |   |    |     FilterItem.ets                       // 筛选选项组件
  |   |    |     LeveTwoActivityList.ets              // 二级活动列表
  |   |    |     ScheduleItem.ets                     // 日程
  |   |    └- viewModel                               
  |   |    |     AgendaDetailModel.ets                // 议程详情数据模型
  |   |    |     AgendaModel.ets                      // 议程数据模型
  |   |    |     DistListModel.ets                    // 地点数据模型
  |   |    |     FavoriteAgendaModel.ets              // 喜欢的会议数据模型
  |   |    |     SearchHistoryModel.ets               // 搜索历史数据模型
  |   |    |  
  |- scenes/home                                      // 主页面
  |   |- src/main/ets
  |   |    |- pages                                  
  |   |    |     ActivitiesPage.ets                   // 活动详情页
  |   |    |     MyVideoPlayer.ets                    // 精彩视频页
  |   |    |     Partner.ets                          // 活动伙伴页面
  |   |    |- service                                 
  |   |    |     ActivitisService.ets                 // 活动数据
  |   |    |     homeService.ets                      // 完成任务
  |   |    |- view                                    
  |   |    |     Countdown.ets                        // 倒计时
  |   |    |     ExcitingVideos.ets                   // 视频详情页
  |   |    |     Home.ets                             // 首页  
  |   |    |     HomeActivities.ets                   // 活动详情
  |   |    |     HomeAgenda.ets                       // 会议详情
  |   |    |     HomeItinerary.ets                    // 行程推荐
  |   |    |     HomePartner.ets                      // 伙伴组件
  |   |    |     HomeTitle.ets                        // 更多组件
  |   |    |     PreviewOfPrevious.ets                // 往届回顾组件
  |   |    └- viewModel                              
  |   |    |     ActivitisModel.ets                   // 活动列表数据模型
  |   |    |  
  └- scenes/my                                        // 我的
      └- src/main/ets
           |- pages                                   
           |     AgendaCollectionList.ets             // 收藏议程管理
           |     Catering.ets                         // 园区餐饮
           |     CateringList.ets                     // 餐饮详情列表
           |     ImagePreview.ets                     // 图片预览
           |     InterestTags.ets                     // 兴趣标签
           |     Maps.ets                             // 地图交通信息
           |     My.ets                               // 我的页面
           |     Qa.ets                               // 常见问题
           |     Setting.ets                          // 设置
           |     Traffic.ets                          // 交通信息
           |- service                                
           |     myUniversalService.ets               // 大会通用数据
           |- utils                                  
           |     Utils.ets                            // 获取组件位置和尺寸信息的工具类 Utils，主要功能是通过组件的标识（key）获取其在屏幕上的矩形区域坐标和尺寸，为布局计算、交互响应等场景提供基础数据支持。
核心功能与作用解析
           └- viewModel                             
                 MyUniversalModel.ets                 // 会议地图、餐饮数据模型
```

## 约束和限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.3 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.3 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- 系统版本：HarmonyOS 5.0.3(15)及以上

### 权限

- 获取位置权限：ohos.permission.APPROXIMATELY_LOCATION，ohos.permission.LOCATION。
- 网络权限：ohos.permission.INTERNET
- 日历读写权限：ohos.permission.READ_CALENDAR, ohos.permission.WRITE_CALENDAR

## 快速入门

### 配置工程

在运行此模板前，需要完成以下配置：

1. 在AppGallery Connect创建元服务，将包名配置到模板中。

   a. 参考[创建元服务](https://developer.huawei.com/consumer/cn/doc/app/agc-help-create-atomic-service-0000002247795706)
   为元服务创建APP ID，并将APP ID与元服务进行关联。

   b. 返回应用列表页面，查看元服务的包名。

   c. 将模板工程根目录下AppScope/app.json5文件中的bundleName替换为创建元服务的包名。

2. 配置华为账号服务。

   a. 将元服务的client
   ID配置到product/phone/src/main路径下的module.json5文件，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/atomic-guides/account-atomic-client-id)。

   b. 如需获取用户真实手机号，需要申请phone权限，详细参考：[配置scope权限](https://developer.huawei.com/consumer/cn/doc/atomic-guides/account-guide-atomic-permissions)
   ，并在端侧使用快速验证手机号码Button进行[验证获取手机号码](https://developer.huawei.com/consumer/cn/doc/atomic-guides/account-guide-atomic-get-phonenumber)。

3. 配置地图服务

   a. 将元服务的client ID配置到product/phone/src/main路径下的module.json5文件，如果华为账号服务已配置，可跳过此步骤。

   b. [开通地图服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc)。

4. 对元服务进行[手工签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section297715173233)。

5. 添加手工签名所用证书对应的公钥指纹。详细参考：[配置应用签名证书指纹](https://developer.huawei.com/consumer/cn/doc/app/agc-help-cert-fingerprint-0000002278002933)

### 运行调试工程

1. 用USB线连接调试手机和PC。

2. 菜单选择“Run > Run 'phone' ”或者“Run > Debug 'phone' ”，运行或调试模板工程。

## 示例效果
[首页](./screenshots/homepage.jpg)
[会议](./screenshots/meeting.jpg)
[我的](./screenshots/my.jpg)


## 开源许可协议

该代码经过[Apache 2.0 授权许可](http://www.apache.org/licenses/LICENSE-2.0)。