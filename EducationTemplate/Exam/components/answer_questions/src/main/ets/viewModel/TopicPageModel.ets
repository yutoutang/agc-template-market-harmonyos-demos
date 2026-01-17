/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

interface TopicItemType {
  // 类型
  type: string
  // 标题
  title: string
  // 题目ID
  keyID: string
  // 题目选项列表
  ques: AnswerItemType[]
  // 题目答案列表
  rightQues: string[]
  // 解析
  parse: string
  // 笔记
  note: string
  // 选中的答案列表
  selectQues: string[]
  // 是否已答题
  isAnswer: boolean
  // 13位时间戳
  jlStamp: number
}

interface AnswerItemType {
  // 选项标题
  ansTitle: string
  // 选项ID
  ans: string
  // 是否选中
  isSelect: boolean
  // 正确与否
  isTrue: boolean
  ansID: string
  // 0原始状态 1错误状态 2正确状态
  state: number
}

// 题库数据
const QUESTION_DATA: TopicItemType[] = [
  {
    keyID: '001',
    title: '下列哪个是面向HarmonyOS生态的集成开发环境',
    type: '1',
    rightQues: ['A'],
    parse: 'HarmonyOS Studio 是HarmonyOS官方提供的集成开发环境，专门用于HarmonyOS应用和小程序的开发。它包含了项目模板、代码编辑、调试、模拟器等功能，是开发HarmonyOS应用的首选工具',
    note: '',
    selectQues: [],
    isAnswer: false,
    jlStamp: 0,
    ques: [
      {
        ansTitle: 'HUAWEI DevEco Studio',
        ans: 'A',
        ansID: '001',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'HUAWEI DevEco Hvigor',
        ans: 'B',
        ansID: '001',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'HUAWEI AppGallery Connect',
        ans: 'C',
        ansID: '001',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'HUAWEI DevEco Profiler',
        ans: 'D',
        ansID: '001',
        isSelect: false,
        isTrue: false,
        state: 0
      }
    ]
  },
  {
    keyID: '002',
    title: '当用户希望能够在多个设备间来回切换、完成多个任务，开发者可以使用以下哪个核心能力，以便应用不间断地给用户提供服务的能力',
    type: '1',
    rightQues: ['C'],
    parse: '在鸿蒙（HarmonyOS）系统中，整体解耦拆分成多个服务，也可以多个服务组合成一个app,多个设备之间可以接续一个应用，或者多个应用共同协作可分可合，自由流转',
    note: '',
    selectQues: [],
    isAnswer: false,
    jlStamp: 0,
    ques: [
      {
        ansTitle: '统一生态',
        ans: 'A',
        ansID: '002',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: '可分可合',
        ans: 'B',
        ansID: '002',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: '自由流转',
        ans: 'C',
        ansID: '002',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: '原生智能',
        ans: 'D',
        ansID: '002',
        isSelect: false,
        isTrue: false,
        state: 0
      }
    ]
  },
  {
    keyID: '003',
    title: '关于module.json5配置文件的标签描述，以下哪个是错误的？',
    type: '1',
    rightQues: ['A'],
    parse: 'pages标签是一个profile文件资源，用于指定描述页面信息的配置文件,在开发视图的resources/base/profile下面定义配置文件main_pages.json，其中文件名"main_pages"可自定义，需要和pages标签指定的信息对应。配置文件中列举了当前应用组件中的页面信息，包含页面的路由信息和显示窗口相关的配置。',
    note: '',
    selectQues: [],
    isAnswer: false,
    jlStamp: 0,
    ques: [
      {
        ansTitle: 'pages标签标识当前Module的配置的应用环境变量',
        ans: 'A',
        ansID: '003',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'deviceTypes标签标识当前应用可以运行在哪类设备上',
        ans: 'B',
        ansID: '003',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'abilities标签标识当前Module中UIAbility的配置信息',
        ans: 'C',
        ansID: '003',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'requestPermissions标签标识当前应用运行时需要向系统申请的权限集合',
        ans: 'D',
        ansID: '003',
        isSelect: false,
        isTrue: false,
        state: 0
      }
    ]
  },
  {
    keyID: '004',
    title: '在UIAbility实例销毁时触发什么状态？',
    type: '1',
    rightQues: ['C'],
    parse: 'UIAbility的生命周期包含四个核心状态：Create、Foreground、Background和Destroy。其中，‌Destroy状态是实例销毁时的最终阶段',
    note: '',
    selectQues: [],
    isAnswer: false,
    jlStamp: 0,
    ques: [
      {
        ansTitle: 'Background',
        ans: 'A',
        ansID: '004',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'Foreground',
        ans: 'B',
        ansID: '004',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'Destroy',
        ans: 'C',
        ansID: '004',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'Create',
        ans: 'D',
        ansID: '004',
        isSelect: false,
        isTrue: false,
        state: 0
      }
    ]
  },
  {
    keyID: '005',
    title: '以下关于指定实例启动模式说法正确的是？',
    type: '1',
    rightQues: ['C'],
    parse: '系统会根据获取的Key值来匹配UIAbility，匹配到对应的UIAbility，则会启动该UIAbility实例，无法匹配对应的UIAbility，则会创建一个新的UIAbility实例',
    note: '',
    selectQues: [],
    isAnswer: false,
    jlStamp: 0,
    ques: [
      {
        ansTitle: '系统每次启动UIAbility组件，都会创建一个新的该类型实例。',
        ans: 'A',
        ansID: '005',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: '是默认启动模式。',
        ans: 'B',
        ansID: '005',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: '支持拉起指定标识的实例。',
        ans: 'C',
        ansID: '005',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: '系统运行时，同一UIAbility组件只存在唯一实例。',
        ans: 'D',
        ansID: '005',
        isSelect: false,
        isTrue: false,
        state: 0
      }
    ]
  },
  {
    keyID: '006',
    title: 'class类中的可见性修饰符不包括下面哪一个',
    type: '1',
    rightQues: ['C'],
    parse: '可见性修饰符包括：private、protected和public。默认可见性为public',
    note: '',
    selectQues: [],
    isAnswer: false,
    jlStamp: 0,
    ques: [
      {
        ansTitle: 'protected',
        ans: 'A',
        ansID: '006',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'public',
        ans: 'B',
        ansID: '006',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'protect',
        ans: 'C',
        ansID: '006',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'private',
        ans: 'D',
        ansID: '006',
        isSelect: false,
        isTrue: false,
        state: 0
      }
    ]
  },
  {
    keyID: '007',
    title: '用户首选项的数据持久化后是放在哪里？',
    type: '1',
    rightQues: ['C'],
    parse: 'Preferences实例中的数据异步存储到用户首选项的持久化文件中',
    note: '',
    selectQues: [],
    isAnswer: false,
    jlStamp: 0,
    ques: [
      {
        ansTitle: '内存中',
        ans: 'A',
        ansID: '007',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: '数据库表中',
        ans: 'B',
        ansID: '007',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: '文件中',
        ans: 'C',
        ansID: '007',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: '云端',
        ans: 'D',
        ansID: '007',
        isSelect: false,
        isTrue: false,
        state: 0
      }
    ]
  },
  {
    keyID: '008',
    title: '关于关系型数据库模块提供的能力，说法错误的是',
    type: '1',
    rightQues: ['D'],
    parse: '已提供insertSync、updateSync、querySync、等同步接口',
    note: '',
    selectQues: [],
    isAnswer: false,
    jlStamp: 0,
    ques: [
      {
        ansTitle: 'RdbPredicates： 数据库中用来代表数据实体的性质、特征或者数据实体之间关系的词项，主要用来定义数据库的操作条件',
        ans: 'A',
        ansID: '008',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'ResultSet：提供用户调用关系型数据库查询接口之后返回的结果集合。',
        ans: 'B',
        ansID: '008',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'RdbStore：提供管理关系数据库(RDB)方法的接口',
        ans: 'C',
        ansID: '008',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: '关于数据库操作（如增删改查等），目前仅支持异步操作，并不提供同步方法。',
        ans: 'D',
        ansID: '008',
        isSelect: false,
        isTrue: false,
        state: 0
      }
    ]
  },
  {
    keyID: '009',
    title: '使用多端设备预览器功能，查看不同设备的运行效果，需要配置如下哪个字段：',
    type: '1',
    rightQues: ['C'],
    parse: '在module.json5文件中定义设备类型时，通过deviceTypes字段指定支持的设备类型',
    note: '',
    selectQues: [],
    isAnswer: false,
    jlStamp: 0,
    ques: [
      {
        ansTitle: 'abilities',
        ans: 'A',
        ansID: '009',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'skills',
        ans: 'B',
        ansID: '009',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'deviceTypes',
        ans: 'C',
        ansID: '009',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'routerMap',
        ans: 'D',
        ansID: '009',
        isSelect: false,
        isTrue: false,
        state: 0
      }
    ]
  },
  {
    keyID: '0010',
    title: '以下关于页面跳转相关方法说法不正确的是：',
    type: '1',
    rightQues: ['D'],
    parse: 'replacePathByName传NavDestination页面名称非NavPathInfo类型的对象',
    note: '',
    selectQues: [],
    isAnswer: false,
    jlStamp: 0,
    ques: [
      {
        ansTitle: 'pushPathByName方法可以将参数对应的页面栈信息进行入栈，从而完成对应页面的跳转',
        ans: 'A',
        ansID: '0010',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'pushPathByName方法需要依次传入页面名称，路由参数以及是否开启转场动画，其中转场动画默认开启',
        ans: 'B',
        ansID: '0010',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'replacePathByName方法会将页面栈栈顶元素退出，再将传入参数对应的页面栈信息进行入栈',
        ans: 'C',
        ansID: '0010',
        isSelect: false,
        isTrue: false,
        state: 0
      },
      {
        ansTitle: 'replacePathByName方法需要传入一个NavPathInfo类型的对象，该对象包含了NavDestination页面的信息',
        ans: 'D',
        ansID: '0010',
        isSelect: false,
        isTrue: false,
        state: 0
      }
    ]
  },
]

class QuestionsRouterModel {
  // 错题 历史 收藏
  sourceType: string = '错题'
  datalist: TopicItemType[] = []
}

export { TopicItemType, AnswerItemType, QUESTION_DATA, QuestionsRouterModel }