# 旅游(酒店)行业模板快速入门

## 目录

- [功能介绍](#功能介绍)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [示例效果](#示例效果)
- [开源许可协议](#开源许可协议)


## 功能介绍

您可以基于此模板直接定制应用，也可以挑选此模板中提供的多种组件使用，从而降低您的开发难度，提高您的开发效率。

本模板提供如下组件，所有组件存放在工程根目录的components下，如果您仅需使用组件，可参考对应组件的指导链接；如果您使用此模板，请参考本文档。

| 组件                                   | 描述                                                         | 使用指导                                                 |
| -------------------------------------- | ------------------------------------------------------------ | -------------------------------------------------------- |
| 拨号组件（module_call_dialog）         | 可根据传入的电话号码拉起拨号弹窗，并在确认后自动拉起拨号面板 | [使用指导](./components/module_call_dialog/README.md)    |
| 酒店日期选择组件（module_date_selector） | 酒店预订时需要使用的日期选择器组件，支持选择入住时间范围和房间个数 | [使用指导](./components/module_date_selector/README.md)  |
| 店铺评价组件（module_store_comments）  | 提供店铺评价组件，可查看评价列表并发表匿名评价               | [使用指导](./components/module_store_comments/README.md) |
| 申请权限许可组件（module_privacy_agreement） | 提供申请权限许可组件，可在应用首启需要用户同意隐私政策和其他协议时使用 | [使用指导](./components/module_privacy_agreement/README.md) |



本模板为综合酒店类应用提供了常用功能的开发样例，模板主要分首页、会员和我的三大模块：

* 首页：提供公告、会员信息、热销商品的展示，支持酒店、餐饮、宴会厅的预订。

* 会员：展示不同等级的会员卡片和等级说明。

* 我的：展示会员等级，支持订单、账号的管理。

本模板已集成华为账号、地图、支付等服务，只需做少量配置和定制即可快速实现华为账号的登录、酒店位置定位导航和购买商品等功能。


| 首页                                                    | 会员                                                   | 我的                                                    |
|-------------------------------------------------------|------------------------------------------------------|-------------------------------------------------------|
| <img src="screenshots/home.png" alt="首页" width="300"> | <img src="screenshots/vip.png" alt="会员" width="300"> | <img src="screenshots/mine.png" alt="我的" width="300"> |



本模板主要页面及核心功能如下所示：

```ts
综合酒店模板
 |-- 首页
 |    |-- 顶部轮播
 |    |-- 滚动公告
 |    |    └-- 公告详情
 |    |-- 会员卡片
 |    |-- 基础服务
 |    |    |-- 酒店预订
 |    |    |    |-- 酒店列表
 |    |    |    |-- 酒店详情
 |    |    |    |-- 房间详情
 |    |    |    └-- 预订房间
 |    |    |-- 餐饮预订
 |    |    |    |-- 餐厅列表
 |    |    |    |-- 餐厅详情
 |    |    |    |-- 团购详情
 |    |    |    └-- 提交订单
 |    |    └-- 宴会厅预订
 |    |         |-- 酒店列表
 |    |         |-- 宴会厅列表
 |    |         └-- 宴会厅详情
 |    |-- 我的订单
 |    |    |-- 订单列表
 |    |    └-- 订单详情
 |    └-- 更多功能
 |         |-- 美食餐饮
 |         |    └-- 同餐饮预订
 |         |-- 集团酒店
 |         |    └-- 酒店介绍
 |         |-- 酒店位置
 |         |    └-- 地图及导航
 |         |-- 客人说
 |         |    |-- 评论列表
 |         |    └-- 发布评论
 |         └-- 热销商品
 |              |-- 商品详情
 |              |-- 提交订单
 |              └-- 订单支付
 |-- 会员
 |    └-- 会员介绍
 └-- 我的
      |-- 用户信息
      |-- 会员卡片
      |-- 我的订单
      └-- 设置
```



本模板工程代码结构如下所示：

```ts
FullServiceHotel
  |- commons                                       // 公共层
  |   |- commonlib/src/main/ets                    // 公共工具模块
  |   |    |- constants                            // 公共常量
  |   |    |- types                                // 公共类型
  |   |    └- utils 
  |   |          AccountUtil.ets                   // 账号管理工具
  |   |          FormatUtil.ets                    // 日历、图片等格式管理工具
  |   |          LocationUtil.ets                  // 定位管理工具
  |   |          Logger.ets                        // 日志管理工具
  |   |          RouterModule.ets                  // 路由管理类
  |   |          PopViewUtils.ets                  // 公共弹窗
  |   |          WindowUtil.ets                    // 窗口管理工具
  |   |  
  |   |- componentlib/src/main/ets                 // 公共组件模块
  |   |     └- components 
  |   |          CommonBanner.ets                  // 公共沉浸式顶栏             
  |   |          CommonButton.ets                  // 公共按钮         
  |   |          CommonDivider.ets                 // 公共分割线          
  |   |          CommonHeader.ets                  // 公共标题栏         
  |   |          CommonScroll.ets                  // 公共沉浸式滚动栏         
  |   |          CommonTagList.ets                 // 会员卡组件 
  |   |   
  |   └- network/src/main/ets                      // 网络模块
  |        |- apis                                 // 网络接口  
  |        |- mocks                                // 数据mock   
  |        |- models                               // 网络库封装    
  |        └- types                                // 请求和响应类型   
  |
  |- components                                    // 业务组件层
  |   |- module_call_dialog                        // 拨号组件
  |   |- module_date_selector                      // 酒店日期选择组件   
  |   |- module_login                              // 登录组件   
  |   |- module_store_comments                     // 店铺评价组件   
  |   |- module_privacy_agreement                  // 申请权限许可组件   
  |   └- module_ui_base                            // 组件通用能力封装  
  |
  |- entry                                         // 应用层主包 
  |   └-  src/main/ets                                               
  |        |- entryability                                                      
  |        |- entryformability                                                   
  |        |- pages                              
  |        |    Index.ets                          // 入口页面
  |        |    MainEntry.ets                      // 主页面
  |        |    SafePage.ets                       // 应用启动安全拦截页
  |        |- types                                // interface接口定义
  |        |- viewmodels                           // 与页面一一对应的vm层 
  |        └- widget                               // 卡片页面 
  |                                            
  └- features                                      // 特性层
      |- banquet/src/main/ets                      // 宴会厅模块    
      |    └- pages                               
      |         BanquetHotelListPage.ets           // 酒店列表页
      |         BanquetInfoPage.ets                // 宴会厅详情页
      |         BanquetListPage.ets                // 宴会厅列表页     
      |     
      |- catering/src/main/ets                     // 订餐模块 
      |    └- pages                               
      |         FoodInfoPage.ets                   // 套餐详情页
      |         FoodOrderSubmitPage.ets            // 套餐预下单页
      |         RestaurantListPage.ets             // 餐厅列表页
      |         RestaurantPage.ets                 // 餐厅详情页
      | 
      |- commonservice/src/main/ets                // 其他服务模块
      |    |- Comments                             // 评价
      |    |- Introduction                         // 酒店介绍   
      |    |- Location                             // 酒店位置 
      |    |- Login                                // 登录
      |    |- MyOrders                             // 用户订单     
      |    └- PrivacyPolicy                        // 隐私政策    
      | 
      |- hotel/src/main/ets                        // 订餐模块  
      |    └- pages                               
      |         HotelListPage.ets                  // 酒店列表页
      |         HotelOrderPage.ets                 // 酒店客房预下单页
      |         RoomInfoPage.ets                   // 客房详情页
      |         RoomListPage.ets                   // 客房列表页
	  |
      └- settings/src/main/ets                     // 设置   
           └- views                               
                AgreementPage.ets                  // 隐私政策页
                AgreementPreviewPage.ets           // 政策和协议预览页
                LoginPage.ets                      // 登录页
                ProfileEditPage.ets                // 账户信息修改页
                SettingPage.ets                    // 设置页
```






## 约束与限制

### 软件

* DevEco Studio版本：DevEco Studio5.0.4 Release及以上
* HarmonyOS SDK版本：HarmonyOS5.0.4 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* 系统版本：HarmonyOS 5.0.4(16)及以上

### 权限要求

* 获取位置权限：ohos.permission.APPROXIMATELY_LOCATION，ohos.permission.LOCATION。
* 网络权限：ohos.permission.INTERNET


## 快速入门

###  配置工程

在运行此模板前，需要完成以下配置：

1. 在AppGallery Connect创建应用，将包名配置到模板中。

   a. 参考[创建HarmonyOS应用](https://developer.huawei.com/consumer/cn/doc/app/agc-help-create-app-0000002247955506)为应用创建APP ID，并将APP ID与应用进行关联。

   b. 返回应用列表页面，查看应用的包名。

   c. 将模板工程根目录下AppScope/app.json5文件中的bundleName替换为创建应用的包名。

2. 配置华为账号服务。

   a. 将应用的client ID配置到entry/src/main路径下的module.json5文件中，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-client-id)。

   b. 申请华为账号一键登录所需的quickLoginMobilePhone权限，详细参考：[配置scope权限](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-config-permissions)。

4. 配置地图服务。

   a. 将应用的client ID配置到entry/src/main路径下的module.json5文件，如果华为账号服务已配置，可跳过此步骤。

   b. [开通地图服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc)。

4. 配置支付服务。

   华为支付当前仅支持商户接入，在使用服务前，需要完成商户入网、开发服务等相关配置，本模板仅提供了端侧集成的示例。详细参考：[支付服务接入准备](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/payment-preparations)

5. 对应用进行[手工签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section297715173233)。

6. 添加手工签名所用证书对应的公钥指纹。详细参考：[配置应用签名证书指纹](https://developer.huawei.com/consumer/cn/doc/app/agc-help-cert-fingerprint-0000002278002933)

###  运行调试工程

1. 连接调试手机和PC。

2. 菜单选择“Run > Run 'entry' ”或者“Run > Debug 'entry' ”，运行或调试模板工程。


## 示例效果

   <img src="screenshots/display.gif" alt="display" width="300">


## 开源许可协议

该代码经过[Apache 2.0 授权许可](http://www.apache.org/licenses/LICENSE-2.0)。
