# 店铺评价组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)



## 简介

本组件为店铺评价组件，可查看评价列表并发表匿名评价。

<img src="snapshots/display.PNG" width="300">



## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio5.0.4 Release及以上
* HarmonyOS SDK版本：HarmonyOS5.0.4 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* 系统版本：HarmonyOS 5.0.4(16)及以上



## 快速入门

1. 安装组件。

   如果是在DevEvo Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_ui_base和module_store_comments模块。

   ```ts
   // 项目根目录下build-profile.json5填写module_module_ui_base和module_store_comments路径。其中XXX为组件存放的目录名
   "modules": [
     {
       "name": "module_ui_base",
       "srcPath": "./XXX/module_ui_base"
     },
     {
       "name": "module_store_comments",
       "srcPath": "./XXX/module_store_comments"  
     }
   ]
   ```

   c. 在项目根目录oh-package.json5中添加依赖。

   ```ts
   // 在项目根目录oh-package.json5中添加依赖
   "dependencies": {
     "module_store_comments": "file:./XXX/module_store_comments",
   }
   ```

2. 引入组件。

   ```ts
   import { CommentListView } from 'module_store_comments';
   ```

3. 调用组件，详见[示例代码](#示例代码)。详细参数配置说明参见[API参考](#API参考)。



## API参考

CommentListView(options: CommentListViewOptions)

### CommentListViewOptions对象说明

| 名称  | 类型                                                         | 是否必填 | 说明                                                     |
| ----- | ------------------------------------------------------------ | -------- | -------------------------------------------------------- |
| stack | [NavPathStack](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-navigation#navpathstack10) | 否       | 使用评价组件的页面的路由栈，不传参可能会导致路由跳转异常 |



## 示例代码

```ts
import { CommentListView } from 'module_store_comments'

@Entry
@ComponentV2
struct StoreCommentPreview {
  @Local stack: NavPathStack = new NavPathStack()

  @Builder
  pageMap(name: string) {
    if (name === 'CommentList') {
      CommentView()
    }
  }

  build() {
    Navigation(this.stack) {
      Button('查看评论列表').onClick(() => {
        this.stack.pushPath({ name: 'CommentList' })
      })
    }
    .navDestination(this.pageMap)
  }
}

@ComponentV2
struct CommentView {
  @Local stack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      CommentListView({
        stack: this.stack,
      })
    }
    .onReady((context) => {
      this.stack = context.pathStack
    })
    .title('评论列表')
  }
}
```

<img src="snapshots/example.gif" width="300">
