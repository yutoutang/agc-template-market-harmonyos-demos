# 出行导航（公交）应用模板快速入门

## 目录

- [功能介绍](#功能介绍)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [示例效果](#示例效果)
- [开源许可协议](#开源许可协议)

## 功能介绍

您可以基于此模板直接定制应用，也可以挑选此模板中提供的多种组件使用，从而降低您的开发难度，提高您的开发效率。

此模板提供如下组件，所有组件存放在工程根目录的components下，如果您仅需使用组件，可参考对应组件的指导链接；如果您使用此模板，请参考本文档。

| 组件                     | 描述           | 使用指导                                      |
|------------------------|--------------|-------------------------------------------|
| 公交路线详情组件（route_detail） | 支持展示公交线路详情   | [使用指导](components/route_detail/README.md) |
| 公交路线搜索组件（route_search） | 支持展示公交路线搜索结果 | [使用指导](components/route_search/README.md) |
本模板为公交类应用提供了常用功能的开发样例，模板主要分为首页，出行，乘车码和我的四大模块：

* 首页：可查看最近新闻热点，开通、打开乘车码，查看禁携物品和寻找遗失物品。
* 出行：实时公交页可查看附近站点信息，包括该路线最近车辆离当前位置的距离和时间，点击对应线路可以查看该线路的地图展示。路径规划中可以根据输入的起点和终点查询推荐路线。
* 乘车码：可进行开卡，享受乘车扫码服务。
* 我的：登录后可管理钱包和订单记录，还可以设置个人信息、联系客服。

本模板已集成华为账号、地图等服务，只需做少量配置和定制即可快速实现华为账号的登录、乘车购票等功能。

| 首页                                  | 出行-实时公交                            | 出行-路线规划                            |
| ------------------------------------- |------------------------------------|------------------------------------|
| <img src="screenshots/首页.jpeg" alt="首页" width="300"> | <img src="screenshots/出行-实时公交页.jpeg" alt="实时公交" width="300"> | <img src="screenshots/出行-路线规划页.jpeg" alt="实时公交" width="300"> |

| 乘车码                                   | 我的                            |
|---------------------------------------|-------------------------------|
| <img src="screenshots/乘车码.jpeg" alt="乘车码" width="300"> | <img src="screenshots/我的.jpeg" alt="我的" width="300">  |


本模板主要页面及核心功能如下所示：

```ts
公交出行模板
 |-- 首页
 |    |-- 轮播图
 |    |-- 新闻热点
 |    |     |-- 新闻列表
 |    |     └-- 新闻详情
 |    |-- 乘车码
 |    |-- 禁携物品
 |    └-- 失物招领
 |-- 出行
 |    |-- 实时公交
 |    |     |-- 搜索
 |    |     |-- 附近公交列表
 |    |     └-- 公交详情页
 |    └-- 路线规划
 |          |-- 搜索
 |          └-- 推荐路线
 |-- 乘车码
 |    |-- 领取电子卡
 |    |-- 开通电子卡
 |    └-- 乘车码
 └-- 我的
      |-- 登录
      |-- 个人信息
      |-- 我的钱包
      |-- 我的订单
      |-- 设置
      |-- 联系客服
      |-- 隐私管理
      |     └-- 隐私服务
      └-- 关于我们
            |-- 意见建议
            └-- 版本更新
```

本模板工程代码结构如下所示：
```ts
BusTravel
├─common/src/main/ets
│  ├─AxiosHttpRequest                                  // 网络请求封装
│  ├─components                                        // 细化业务组件
│  ├─constants                                         // 公共常量
│  ├─Interface                                         // 公共接口常量
│  ├─logger                                            // 日志打印
│  ├─model                                             // 模型定义
│  ├─page                                              // 公共页面
│  └─utils                                             // 公共方法
├─components                                           // 组件
│  ├─route_detail                                      // 公交详情路线展示组件
│  ├─route_search                                      // 公交路线搜索组件  
|
├─entry
│  ├─src/main/ets
│  │  ├─constants
│  │  │  └─AppConstants.ets                            // 常量定义
│  │  ├─dataModel
│  │  │  └─HomeTab.ets                                 // Tab页定义
│  │  ├─entryability
│  │  │  └─EntryAbility.ets                            // 主入口生命周期（包含预加载）
│  │  ├─entrybackupability
│  │  │  └─EntryBackupAbility.ets                      // 主入口生命周期（包含预加载）
│  │  ├─pages
│  │  │  └─Index.ets                                   // 主页
│  │  │  └─AgreeDialogPage.ets                         // 确认取消隐私协议弹框
│  │  │  └─SafePage.ets                                // 隐私协议声明页
│  │  └─viewmodels
│  │  │  └─EntryVM.ets                                 // 路由管理
│        └─SafePageVm.ets                              // 隐私协议管理VM
├─feature
│  ├─CodeScan/src/main/ets
│  │  └─index
│  │     ├─ActivateCloudCard.ets                       // 常量定义
│  │     ├─CloudCard.ets                               // 模型定义
│  │     └─CodeScanPage.ets                            // 方法定义
│  ├─frontpage/src/main/ets
│  │  ├─mock
│  │  │  └─MockData.ets                                // mock数据
│  │  ├─model
│  │  │  └─Interface.ets                               // 接口定义
│  │  └─pages
│  │     ├─HomePage.ets                                // 首页
│  │     ├─LostFind.ets                                // 失物招领
│  │     ├─NewsDetail.ets                              // 新闻详情
│  │     ├─NewsHotspot.ets                             // 新闻热点
│  │     └─ProhibitedItemsPage.ets                     // 禁携物品
│  ├─PersonalCenter/src/main/ets
│  │  ├─components
│  │  │  └─PageHeader.ets                              // 页面标题栏组件
│  │  ├─model                                          // 模型定义
│  │  └─pages
│  │     ├─AboutUs.ets                                 // 关于我们
│  │     ├─index.ets                                   // 首页
│  │     ├─Login.ets                                   // 华为一键登录
│  │     ├─MinePage.ets                                // 个人中心主页面
│  │     ├─MineWallet.ets                              // 我的钱包
│  │     ├─MyOrder.ets                                 // 我的订单
│  │     ├─PersonalSetting.ets                         // 个人设置
│  │     ├─PrivacyPage.ets                             // 隐私协议
│  │     ├─SettingsPage.ets                            // 设置页面
│  │     └─Suggestion.ets                              // 意见建议
│  └─RouteDesign/src/main/ets
│     ├─components
│     │  ├─BusInfo.ets                                 // 公交列表组件
│     │  ├─BusLine.ets                                 // 公交地图信息组件
│     │  ├─BusLineView.ets                             // 公交附图站点展示组件
│     │  ├─BusStationRandom.ets                        // 站点信息
│     │  └─RandomCountdown.ets                         // 站点信息
│     ├─constants
│     │  └─MapConstants.ets                            // 常量
│     ├─index
│     │  └─index.ets                                   // 主页
│     ├─page
│     │  ├─BusLinePlan.ets                             // 出行页
│     │  ├─realTimeBus.ets                             // 实时公交
│     │  ├─routeDetailPage.ets                             // 公交地图详情页
│     │  └─TravelPlan.ets                              // 路径规划
│     └─viewmodels
│        └─RouterParams.ets                            // 路由参数
```

## 约束与限制
### 环境
* DevEco Studio版本：DevEco Studio 5.1.0 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.1.0 Release SDK及以上
* 设备类型：华为手机（直板机、双折叠）
* HarmonyOS版本：HarmonyOS 5.0.0(12)及以上

### 权限
* 网络权限：ohos.permission.INTERNET
* 获取位置权限：ohos.permission.LOCATION
* 模糊位置信息：ohos.permission.APPROXIMATELY_LOCATION


## 快速入门

### 配置工程

在运行此模板前，需要完成以下配置：

1. 在AppGallery Connect创建应用，将包名配置到模板中。

   a. 参考[创建HarmonyOS应用](https://developer.huawei.com/consumer/cn/doc/app/agc-help-create-app-0000002247955506)为应用创建APP ID，并将APP ID与应用进行关联。

   b. 返回应用列表页面，查看应用的包名。

   c. 将AppScope/app.json5文件中的bundleName替换为创建应用的包名。

2. 配置华为账号服务。

   a. 将应用的client ID配置到entry模块的[module.json5](entry/src/main/module.json5)文件，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-client-id)。

   b. 申请华为账号一键登录所需的quickLoginMobilePhone权限，详细参考：[配置scope权限](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-config-permissions)。在端侧使用快速验证手机号码Button进行[验证获取手机号码](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-get-phonenumber)。

3. 配置地图服务。

   a. 将应用的client ID配置到entry模块的[module.json5](entry/src/main/module.json5)文件，如果华为账号服务已配置，可跳过此步骤。

   b. [开通地图服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc)。

4. 对应用进行[手工签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section297715173233)。

5. 添加手工签名所用证书对应的公钥指纹。详细参考：[配置应用签名证书指纹](https://developer.huawei.com/consumer/cn/doc/app/agc-help-cert-fingerprint-0000002278002933)

### 运行调试工程

1. 连接调试手机和PC。

2. 菜单选择“Run > Run 'entry' ”或者“Run > Debug 'entry' ”，运行或调试模板工程。


## 示例效果
[应用示例效果](./screenshots/应用使用示例效果.mp4)

## 开源许可协议
该代码经过[Apache 2.0 授权许可](http://www.apache.org/licenses/LICENSE-2.0)。