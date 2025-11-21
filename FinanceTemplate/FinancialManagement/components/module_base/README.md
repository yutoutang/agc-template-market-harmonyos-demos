# 组件基础能力快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)

## 简介

本组件提供components目录下组件的基础能力集合。

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.0.0 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.0 Release SDK及以上
* 设备类型：华为手机（直板机）
* 系统版本：HarmonyOS 5.0.0(12)及以上

### 权限
无
## 快速入门

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_base模块。

    ```
    // 在项目根目录build-profile.json5填写module_base路径。其中XXX为组件存放的目录名
    "modules": [
        {
        "name": "module_base",
        "srcPath": "./XXX/module_base",
        }
    ]
    ```
   c. 在项目根目录oh-package.json5中添加依赖。
    ```
    // XXX为组件存放的目录名称
    "dependencies": {
      "module_base": "file:./XXX/module_base"
    }
   ```

2. 引入方法句柄。

   ```
   import { FormatUtil, WindowUtil } from 'module_base';
   ```

## API参考

### 公共组件

#### CommonFilter

数据过滤展示组件

#### CommonNavTitle

导航栏组件

#### CommonProductProfile

产品简介组件

#### CommonRow

行组件

#### CommonRuleLine

赎回时间组件

#### CommonSaveButton

保存按钮组件

#### CommonTextVisibility

文字影藏组件

### 公共方法

#### AccountUtil

通用方法类

#### FormatUtil

格式化方法类

#### Logger

日志方法类

#### PreferenceUtil

首选项方法类

#### WindowUtil

窗口方法类
