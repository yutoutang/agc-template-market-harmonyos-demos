# 生活服务(综合家政服务)元服务模板快速入门

## 目录

- [功能介绍](#功能介绍)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [示例效果](#示例效果)
- [开源许可协议](#开源许可协议)

## 功能介绍

您可以基于此模板直接定制元服务，也可以挑选此模板中提供的多种组件使用，从而降低您的开发难度，提高您的开发效率。

此模板提供如下组件，所有组件存放在工程根目录的components下，如果您仅需使用组件，可参考对应组件的指导链接；如果您使用此模板，请参考本文档。

| 组件                            | 描述                | 使用指导                                               |
|:------------------------------|:------------------|:---------------------------------------------------|
| 地址管理组件（module_address_manage） | 提供新增、编辑、删除地址相关功能  | [使用指导](components/module_address_manage/README.md) |
| 分类组件（module_category）         | 提供左右布局实现分类的功能     | [使用指导](components/module_category/README.md)       |
| 城市选择组件（module_city_select）    | 提供基于当前定位，搜索城市的功能  | [使用指导](components/module_city_select/README.md)    |
| 表单组件（module_form）             | 提供以表单形式录入信息的功能    | [使用指导](components/module_form/README.md)           |
| 搜索组件（module_search）           | 提供搜索服务的功能         | [使用指导](components/module_search/README.md)         |
| 时间选择弹窗组件（module_time_select）  | 提供通过底部弹窗选择日期时间的功能 | [使用指导](components/module_time_select/README.md)    |

本模板为家政类元服务提供了常用功能的开发样例，模板主要分首页、全部服务和我的三大模块：

* 首页：提供主要商品轮播图、常用类别菜单和精选服务列表，支持城市切换、商品搜索、商品价格咨询以及商品购买。

* 全部服务：展示全部品类的商品列表，支持切换城市、搜索商品。

* 我的：展示个人信息、我的订单、服务和工具以及部分商品列表，支持修改个人信息、管理订单、管理地址等。

本模板已集成华为账号、支付等服务，只需做少量配置和定制即可快速实现华为账号的登录、购买商品等功能。

| 首页                                                      | 全部服务                                                            | 我的                                                      |
|---------------------------------------------------------|-----------------------------------------------------------------|---------------------------------------------------------|
| <img src="./screenshots/home.jpg" alt="首页" width="300"> | <img src="./screenshots/allservice.jpg" alt="全部服务" width="300"> | <img src="./screenshots/mine.jpg" alt="我的" width="300"> |

本模板主要页面及核心功能如下所示：

```text
家政模板
 |-- 首页
 |    |-- 切换城市
 |    |-- 搜索
 |    |-- 轮播图
 |    |-- 品类菜单
 |    |     |-- 日常保洁
 |    |     |-- 家电维修
 |    |     |-- 保姆月嫂
 |    |     └-- 管道疏通
 |    └-- 精选服务
 |          |-- 服务列表
 |          |-- 服务详情
 |          |-- 下单页面
 |          |-- 待支付
 |          └-- 支付成功
 |-- 全部服务
 |    |-- 切换城市
 |    |-- 全部分类
 |    └-- 搜索
 |
 └-- 我的
      |-- 用户信息
      |     |-- 个人信息
      |     └-- 编辑资料
      |-- 我的订单
      |     |-- 全部订单
      |     |-- 待付款
      |     |-- 待使用
      |     └-- 退款售后
      |-- 服务与工具
      |     |-- 地址管理
      |     └-- 公共服务
      └-- 服务列表
```

本模板工程代码结构如下所示：

```text
HouseholdService
├─commons                           
│  └─lib_foundation/src/main/ets                        // 应用基础lib                                       
│       ├─common                                      
│       │   ├─Constant.ets                              // 常量定义 
│       │   └─GoodDataSource.ets                        // 商品datasource定义
│       ├─http         
│       │   ├─ApiManage.ets                             // 服务端接口定义 
│       │   ├─AxiosBase.ets                             // 接口调用基础类    
│       │   ├─HttpMockMap.ets                           // mock接口映射        
│       │   ├─MockApi.ets                               // mock接口       
│       │   └─MockData.ets                              // mock数据             
│       ├─login                                      
│       │   └─LoginUtil.ets                             // 登录工具类  
│       ├─model                              
│       │   ├─IRequest.ets                              // 接口请求定义          
│       │   ├─IResponse.ets                             // 接口响应定义                      
│       │   └─ObserveModel.ets                          // 状态管理类                    
│       ├─router         
│       │   └─RouterModule.ets                          // 路由管理     
│       └─uicomponent
│           ├─CommonCard.ets                            // 卡片组件    
│           ├─DialogCall.ets                            // 拨号弹窗
│           ├─UIBackBtn.ets                             // 返回按钮
│           └─UIOrderPart.ets                           // 订购组件           
│
├─components
│  ├─module_address_manage/src/main/ets                 // 地址管理组件  
│  │     ├─common
│  │     │   ├─Constant.ets                             // 常量定义     
│  │     │   ├─Global.ets                               // 全局变量管理             
│  │     │   └─Utils.ets                                // 方法定义            
│  │     ├─http
│  │     │   ├─Api.ets                                  // 接口调用               
│  │     │   └─Type.ets                                 // 类型定义           
│  │     ├─model
│  │     │   ├─AddressListModel.ets                     // 列表model               
│  │     │   └─AddressModel.ets                         // 地址model                
│  │     ├─pages
│  │     │   ├─AddressManage.ets                        // 地址管理                         
│  │     │   └─EditAddress.ets                          // 编辑地址                      
│  │     └─viewmodel   
│  │         ├─AddressListViewModel.ets                 // 列表viewmodel                    
│  │         └─AddrViewModel.ets                        // 地址viewmodel                     
│  │   
│  ├─module_base/src/main/ets                                          
│  │      ├─common   
│  │      │   ├─Constant.ets                            // 常量定义                
│  │      │   ├─Logger.ets                              // 日志打印            
│  │      │   ├─ObserveModel.ets                        // 状态管理类               
│  │      │   ├─PopViewUtils.ets                        // 公共弹窗                     
│  │      │   ├─Type.ets                                // 模型定义            
│  │      │   └─Utils.ets                               // 公共方法                
│  │      └─uicomponent
│  │          ├─GoodCard.ets                            // 商品卡片                             
│  │          ├─NoticeDialog.ets                        // 通知弹窗               
│  │          ├─UIEmpty.ets                             // 空白组件          
│  │          └─UILoading.ets                           // 空白组件                         
│  │
│  ├─module_category/src/main/ets                       // 分类组件                     
│  │    ├─common
│  │    │   └─Utils.ets                                 // 方法定义            
│  │    └─components
│  │        └─CategoryLayout.ets                        // 分类容器        
│  │   
│  ├─module_city_select/src/main/ets                    // 城市选择组件
│  │    ├─common
│  │    │   ├─Constant.ets                              // 常量定义      
│  │    │   ├─Model.ets                                 // 模型定义  
│  │    │   └─Utils.ets                                 // 方法定义
│  │    ├─components
│  │    │   └─SingleBtn.ets                             // 按钮组件
│  │    └─pages
│  │        └─Index.ets                                 // 城市选择主体
│  │  
│  ├─module_form/src/main/ets                           // 表单组件            
│  │    ├─common                                        
│  │    │   ├─Constant.ets                              // 常量定义           
│  │    │   └─Utils.ets                                 // 方法定义           
│  │    ├─components                                    
│  │    │   ├─FormAddress.ets                           // 表单-地址填写           
│  │    │   ├─FormAvatar.ets                            // 表单-头像编辑                 
│  │    │   ├─FormDate.ets                              // 表单-日期选择            
│  │    │   ├─FormGender.ets                            // 表单-性别选择        
│  │    │   ├─FormInput.ets                             // 表单-输入框    
│  │    │   └─FormTextReadOnly.ets                      // 表单-只读文本          
│  │    └─pages                          
│  │        └─FormItem.ets                              // 表单组件            
│  │    
│  ├─module_search/src/main/ets                         // 搜索组件              
│  │    ├─common                    
│  │    │   └─Utils.ets                                 // 方法定义   
│  │    └─components                
│  │        └─UISearch.ets                              // 搜索组件主体              
│  │
│  └─module_time_select/src/main/ets                    // 时间选择弹窗组件            
│       ├─common                        
│       │   ├─CommonUtils.ets                           // 方法定义              
│       │   ├─Constant.ets                              // 常量定义          
│       │   ├─Model.ets                                 // 模型定义                 
│       │   └─TimeUtils.ets                             // 时间工具类                     
│       ├─components                  
│       │   └─TimeSelect.ets                            // 时间选择view                    
│       └─viewmodel                  
│           └─TimeSelectVM.ets                          // 时间选择viewmodel                  
│
├─features
│  ├─business_home/src/main/ets                         // 首页模块             
│  │    ├─common                     
│  │    │   ├─Constant.ets                              // 常量定义       
│  │    │   └─Model.ets                                 // 模型定义     
│  │    ├─components                     
│  │    │   └─ServiceText.ets                           // 价格文本组件             
│  │    ├─pages                     
│  │    │   ├─CityList.ets                              // 服务地址页面         
│  │    │   ├─GoodDetail.ets                            // 商品详情页面              
│  │    │   ├─HomePage.ets                              // 首页           
│  │    │   ├─OrderPage.ets                             // 下单页面    
│  │    │   ├─SearchPage.ets                            // 搜索页面   
│  │    │   ├─SuccessPay.ets                            // 支付成功页面      
│  │    │   └─ToPay.ets                                 // 待支付页面   
│  │    └─viewmodel                     
│  │        ├─HomeVM.ets                                // 首页viewmodel 
│  │        └─OrderVM.ets                               // 下单viewmodel       
│  │   
│  └─business_mine/src/main/ets                         // 我的模块             
│        ├─components                                      
│        │   └─OrderCard.ets                            // 订单卡片组件       
│        ├─pages                                         
│        │   ├─CommonService.ets                        // 公共服务页面            
│        │   ├─EditPersonal.ets                         // 编辑个人资料页面          
│        │   ├─Mine.ets                                 // 我的页面     
│        │   ├─MyOrderDetail.ets                        // 订单详情       
│        │   ├─MyOrderList.ets                          // 订单列表        
│        │   └─OfficialWeb.ets                          // 官网H5       
│        └─viewmodel                                          
│            ├─MineVM.ets                               // 我的viewmodel        
│            ├─MyOrderDetailVM.ets                      // 订单详情viewmodel              
│            └─MyOrderVM.ets                            // 订单列表viewmodel  
│
└─products
   └─entry/src/main/ets                
        ├─components                         
        │   └─AllCategory.ets                           // 分类页面        
        ├─entryability                                       
        │   └─EntryAbility.ets                          // UIAbility生命周期
        ├─entryformability                             
        │   └─EntryFormAbility.ets                      // FormExtensionAbility生命周期
        ├─pages                                        
        │   ├─Index.ets                                 // 入口页面
        │   └─Main.ets                                  // 主页面
        └─widget/pages                                 
            └─WidgetCard.ets                            // 主页面
 
```

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.0.0 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.0 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* 系统版本：HarmonyOS 5.0.0(12)及以上

### 权限

* 位置权限：ohos.permission.APPROXIMATELY_LOCATION
* 网络权限：ohos.permission.INTERNET

## 快速入门

### 配置工程

在运行此模板前，需要完成以下配置：

1. 在AppGallery Connect创建元服务，将包名配置到模板中。

   a. 参考[创建元服务](https://developer.huawei.com/consumer/cn/doc/app/agc-help-create-atomic-service-0000002247795706)为元服务创建APP ID，并将APP ID与元服务进行关联。

   b. 返回应用列表页面，查看元服务的包名。

   c. 将模板工程根目录下AppScope/app.json5文件中的bundleName替换为创建元服务的包名。

2. 配置服务器域名。

   本模板接口均采用mock数据，由于元服务包体大小有限制，部分图片资源将从云端拉取，所以需为模板项目[配置服务器域名](https://developer.huawei.com/consumer/cn/doc/atomic-guides/agc-help-harmonyos-server-domain)，“httpRequest合法域名”需要配置为：`https://agc-storage-drcn.platform.dbankcloud.cn`

3. 配置华为账号服务。

   a. 将元服务的client ID配置到products/entry/src/main/module.json5文件，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/atomic-guides/account-atomic-client-id)。

   b. 如需获取用户真实手机号，需要申请phone权限，详细参考：[配置scope权限](https://developer.huawei.com/consumer/cn/doc/atomic-guides/account-guide-atomic-permissions)，并在端侧使用快速验证手机号码Button进行[验证获取手机号码](https://developer.huawei.com/consumer/cn/doc/atomic-guides/account-guide-atomic-get-phonenumber)。

4. 配置支付服务。

   a. 华为支付当前仅支持商户接入，在使用服务前，需要完成商户入网、开通服务等相关配置。详细参考：[支付服务接入准备](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/payment-preparations)。

   b. 当前模板仅提供端侧集成示例，修改端侧文件：features/business_home/src/main/ets/viewmodel/OrderVM.ets，主要修改点如下：

   ```
   // 付款
   payOrder() {
      CommonUtils.showLoading();
      const jumpParam = this.buildJumpParam();
      // todo: 传入false，不走mock
      SystemSceneUtils.requestPaymentPromise(false, this.uiAbilityContext).then(() => {
         payOrder(this._orderId).then(() => {
            CommonUtils.hideLoading();
            RouterModule.push({ url: RouterMap.SUCCESS_PAY, param: jumpParam });
         })
      })
   }
   ```
   c. 修改端侧文件：components/module_base/src/main/ets/common/Utils.ets，主要修改点如下：
   ```
   // 调用华为支付
   static requestPaymentPromise(ignoreRequestPayment: boolean, context: common.UIAbilityContext): Promise<void> {
      if (ignoreRequestPayment) {
         return new Promise((resolve) => resolve());
      }
      // todo: 补充订购信息
      const orderStr = '{}';
      return paymentService.requestPayment(context, orderStr)
      .then(() => {
         Logger.info('succeeded in paying');
      })
      .catch((error: BusinessError) => {
         Logger.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
         promptAction.showToast({ message: '拉起支付失败' });
      });
   }
   ```

5. 对元服务进行[手工签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section297715173233)。

6. 添加手工签名所用证书对应的公钥指纹。详细参考：[配置应用签名证书指纹](https://developer.huawei.com/consumer/cn/doc/app/agc-help-cert-fingerprint-0000002278002933)。

### 运行调试工程

1. 连接调试手机和PC。

2. 菜单选择“Run > Run 'entry' ”或者“Run > Debug 'entry' ”，运行或调试模板工程。

## 示例效果

1. [首页](./screenshots/home.mp4)

2. [购买流程](./screenshots/submitorder.mp4)

3. [全部服务](./screenshots/allservice.mp4)

4. [我的-编辑资料](./screenshots/editprofile.mp4)

5. [我的-订单管理](./screenshots/manageorder.mp4)

6. [我的-服务与工具等](./screenshots/tool.mp4)

## 开源许可协议

该代码经过[Apache 2.0 授权许可](http://www.apache.org/licenses/LICENSE-2.0)。
