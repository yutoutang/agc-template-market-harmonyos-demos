export class MyConfig {
  static context:ESObject;
  static URL = ''
  static PROJECTURL = ''
  static EVENTSURL = ''
  // 议程筛选 地区的列表字典id
  static readonly MYADDRESSDICTID = '290814'
  // 议程筛选 地区的列表字典id 子集
  static readonly CHILDMYADDRESSDICTID = '283648'
  // 议程筛选 (大广场)会议类型字典id
  static readonly METTINGTYPESANID = '290815'
  // 议程筛选 (大广场)会议类型字典id 子集
  static readonly CHILDMETTINGTYPESANID = '283707'
  // 议程筛选 (小山村)会议类型字典id
  static readonly METTINGTYPEXIID = '290817'
  // 议程筛选 (小山村)会议类型字典id 子集
  static readonly CHILD_MMETTINGTY_PEXIID = '283708'
  // 议程筛选 会议类型字典id 全部
  static readonly allMmettingTypexiId = '290818'
  // 议程筛选 会议类型字典id 子集
  static readonly childAllMmettingTypexIid = '290752'
  // 议程筛选 技术领域字典id
  static readonly TECH_NOSPHERE_ID = '290816'
  // 议程筛选 技术领域字典id 子集
  static readonly CHILD_TECHNOSPHERE_ID = '290734'
  // 活动id
  static readonly ACTIVITYID = '27'
  // 添加卡片到桌面任务id
  static readonly ADDTODESKTOPTASKID = '451'

  constructor(context: Context) {
    this.initConfig(context)
  }

  initConfig(context: Context) {
    MyConfig.context = context;
    MyConfig.URL = context.resourceManager.getStringByNameSync('URL')
    MyConfig.PROJECTURL = context.resourceManager.getStringByNameSync('PROJECTURL')
    MyConfig.EVENTSURL = context.resourceManager.getStringByNameSync('EVENTSURL')
  }
}