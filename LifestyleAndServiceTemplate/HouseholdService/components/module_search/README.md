# 搜索组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供搜索的功能。

| 搜索前                                             | 搜索后                                             |
|-------------------------------------------------|-------------------------------------------------|
| <img src="screenshots/search1.jpg" width="300"> | <img src="screenshots/search2.jpg" width="300"> |

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.0.0 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.0 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* 系统版本：HarmonyOS 5.0.0(12)及以上

## 快速入门

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_search、module_base模块。

   ```
   // 项目根目录下build-profile.json5填写module_search、module_base路径。其中XXX为组件存放的目录名
   "modules": [
     {
       "name": "module_search",
       "srcPath": "./XXX/module_search"
     },
     {
       "name": "module_base",
       "srcPath": "./XXX/module_base"
     }
   ]
   ```

   c. 在项目根目录oh-package.json5添加依赖。
   ```
   // XXX为组件存放的目录名称
   "dependencies": {
     "module_base": "file:./XXX/module_base",
     "module_search": "file:./XXX/module_search"
   }
   ```

2. 引入组件。

    ```
    import { UISearch, UISearchController } from 'module_search';
    ```
3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

## API参考

### 接口

UISearch(option: [UISearchOptions](#UISearchOptions对象说明))

搜索选择组件

**参数：**

| 参数名     | 类型                                      | 是否必填 | 说明           |
|:--------|:----------------------------------------|:-----|:-------------|
| options | [UISearchOptions](#UISearchOptions对象说明) | 是    | 配置搜索选择组件的参数。 |

### UISearchOptions对象说明

| 参数名           | 类型                                                                  | 是否必填 | 说明      |
|:--------------|:--------------------------------------------------------------------|:-----|:--------|
| recommendList | string[]                                                            | 否    | 热门搜索    |
| list          | [IGoodInfo](../module_base/README.md#IGoodInfo类型说明)[]               | 是    | 搜索结果列表  |
| controller    | [UISearchController](#UISearchController)                           | 是    | 搜索控制器   |
| query         | (content: string) => Promise<void>                                  | 是    | 触发查询    |
| goBack        | () => void                                                          | 是    | 返回上一级页面 |
| jumpDetail    | (good: [IGoodInfo](../module_base/README.md#IGoodInfo类型说明)) => void | 是    | 跳转详情页   |

### UISearchController

搜索组件的控制器。

#### constructor

constructor()

UISearchController的构造函数。

#### onBackPressed

onBackPressed(): boolean

触发组件内部返回事件

## 示例代码

```
import { router } from '@kit.ArkUI';
import { IGoodInfo, TypeGood } from 'module_base';
import { UISearch, UISearchController } from 'module_search';

const LIST: IGoodInfo[] = [
  {
    type: TypeGood.PAY,
    classId: '1',
    id: '1',
    title: '日常保洁',
    subTitle: '高温消毒｜除尘除垢',
    image: 'resourceImage://ic_placeholder_img',
    intro: [],
    price: 119,
    vipPrice: 41,
    soldNum: 800,
    serviceContentList: [],
    serviceDetailList: [],
    servicePipeList: [],
    feeList: [],
    qaList: [],
  },
];

@Entry
@ComponentV2
struct SearchSample {
  @Local list: IGoodInfo[] = [];
  controller: UISearchController = new UISearchController();

  onBackPress(): boolean | void {
    return this.controller.onBackPressed();
  }

  build() {
    NavDestination() {
      Column() {
        UISearch({
          recommendList: ['日常保洁', '开荒清洁', '住家保姆', '金牌月嫂'],
          list: this.list,
          controller: this.controller,
          query: (content) => {
            return Promise.resolve().then(() => {
              this.list = LIST;
            });
          },
          jumpDetail: (v: IGoodInfo) => {
            this.getUIContext().getPromptAction().showToast({ message: '跳转详情页' });
          },
          goBack: () => {
            router.back();
          },
        })
      }
      .width('100%')
      .height('100%')
      .padding(10)
    }
    .title('搜索组件')
  }
}
```
