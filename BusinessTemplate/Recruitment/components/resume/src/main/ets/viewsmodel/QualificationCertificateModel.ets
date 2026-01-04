import { BaseViewModel, PreferenceUtil } from 'common'
import { PreferenceConstant } from 'job_intention'

export interface CertificateItem {
  name: string
}

export interface CertificateCategory {
  category: string
  certificates: string[]
}

@ObservedV2
export class QualificationCertificateModel extends BaseViewModel {
  // 用户已选择的证书列表
  @Trace items: Array<CertificateItem> = []
  // 临时选择状态（用于编辑页面）
  @Trace selectedCertificates: Set<string> = new Set()
  // 初始选择状态（用于判断是否有修改）
  private initialSelected: Set<string> = new Set()
  // 证书分类数据
  private certificateData: CertificateCategory[] = [
    {
      category: '推荐证书',
      certificates: [
        'NIT全国计算机应用水平证书',
        '普通话水平测试等级证书',
        '教师资格证',
        '法律职业资格证书',
        '注册建筑师',
        '一级建造师',
        '二级建造师'
      ]
    },
    {
      category: 'IT类',
      certificates: [
        '软件设计师',
        '系统架构设计师',
        '网络工程师',
        '信息系统项目管理师',
        '数据库系统工程师',
        'PMP项目管理专业人士',
        'CISP注册信息安全专业人员',
        'CISSP注册信息系统安全专家',
        'Oracle认证专家(OCP)',
        'Red Hat认证工程师(RHCE)',
        'AWS认证解决方案架构师',
        '华为认证ICT专家(HCIE)',
        '思科认证网络工程师(CCNA)',
        '思科认证网络专家(CCNP)'
      ]
    },
    {
      category: '会计类',
      certificates: [
        '初级会计职称',
        '中级会计职称',
        '高级会计职称',
        '注册会计师(CPA)',
        '国际注册会计师(ACCA)',
        '特许公认会计师(CPA Australia)',
        '美国注册会计师(USCPA)',
        '国际注册内部审计师(CIA)',
        '注册税务师(CTA)',
        '资产评估师',
        '审计师'
      ]
    },
    {
      category: '金融类',
      certificates: [
        '证券从业资格证',
        '基金从业资格证',
        '期货从业资格证',
        '银行从业资格证',
        '特许金融分析师(CFA)',
        '金融风险管理师(FRM)',
        '注册金融策划师(CFP)',
        '保险代理人资格证',
        '保险经纪人资格证'
      ]
    },
    {
      category: '医疗类',
      certificates: [
        '执业医师资格证',
        '执业药师资格证',
        '护士执业资格证',
        '卫生专业技术资格证',
        '医学检验技术资格证',
        '康复治疗师资格证',
        '营养师资格证',
        '心理咨询师'
      ]
    },
    {
      category: '语言类',
      certificates: [
        '大学英语四级(CET-4)',
        '大学英语六级(CET-6)',
        '英语专业四级(TEM-4)',
        '英语专业八级(TEM-8)',
        '雅思(IELTS)',
        '托福(TOEFL)',
        'GRE',
        'GMAT',
        '日语能力测试(JLPT)',
        '韩语能力考试(TOPIK)',
        '对外汉语教师资格证',
        '翻译专业资格证书(CATTI)'
      ]
    },
    {
      category: '其他',
      certificates: [
        'C1驾驶证',
        'C2驾驶证',
        'B2驾驶证',
        'A2驾驶证',
        '人力资源管理师',
        '企业培训师',
        '物流师',
        '电子商务师',
        '导游资格证',
        '房地产经纪人',
        '消防工程师',
        '安全工程师',
        '造价工程师',
        '监理工程师'
      ]
    }
  ]
  private pref = PreferenceUtil.getInstance(undefined, 'resume')

  constructor() {
    super()
    this.loadData()
  }

  // 加载数据
  private loadData() {
    const saved = this.pref.get(PreferenceConstant.RESUME_QUALIFICATION_CERT)
    if (saved) {
      // 创建新数组确保触发@Trace更新
      const loadedItems = saved as Array<CertificateItem>
      this.items = loadedItems.map(item => {
        const newItem: CertificateItem = { name: item.name }
        return newItem
      })
    } else {
      this.items = []
    }
  }

  // 重新加载数据（用于刷新）
  reload() {
    this.loadData()
  }

  // 获取所有证书分类
  getCertificateCategories(): CertificateCategory[] {
    return this.certificateData
  }

  // 开始编辑（初始化选择状态）
  startEdit() {
    this.selectedCertificates = new Set(this.items.map(item => item.name))
    this.initialSelected = new Set(this.selectedCertificates)
  }

  // 切换证书选择状态
  toggleCertificate(name: string) {
    if (this.selectedCertificates.has(name)) {
      this.selectedCertificates.delete(name)
    } else {
      this.selectedCertificates.add(name)
    }
    // 触发UI更新
    this.selectedCertificates = new Set(this.selectedCertificates)
  }

  // 检查证书是否被选中
  isCertificateSelected(name: string): boolean {
    return this.selectedCertificates.has(name)
  }

  // 检查是否有修改
  hasChanges(): boolean {
    if (this.selectedCertificates.size !== this.initialSelected.size) {
      return true
    }
    for (const cert of this.selectedCertificates) {
      if (!this.initialSelected.has(cert)) {
        return true
      }
    }
    return false
  }

  // 保存选择
  saveSelection() {
    // 创建新数组确保触发响应式更新
    this.items = Array.from(this.selectedCertificates).map(name => {
      const item: CertificateItem = { name: name }
      return item
    })
    this.save()
    this.initialSelected = new Set(this.selectedCertificates)
  }

  // 取消编辑（恢复初始状态）
  cancelEdit() {
    this.selectedCertificates = new Set(this.initialSelected)
  }

  // 搜索证书
  searchCertificates(keyword: string): CertificateCategory[] {
    if (!keyword || keyword.trim() === '') {
      return this.certificateData
    }

    const lowerKeyword = keyword.toLowerCase()
    const results: CertificateCategory[] = []

    for (const category of this.certificateData) {
      const matchedCerts = category.certificates.filter(cert =>
      cert.toLowerCase().includes(lowerKeyword)
      )
      if (matchedCerts.length > 0) {
        results.push({
          category: category.category,
          certificates: matchedCerts
        })
      }
    }

    return results
  }

  setItems(value: Array<CertificateItem>) {
    this.items = value;
    this.save()
  }

  addItem(item: CertificateItem) {
    this.items = [item, ...this.items];
    this.save()
  }

  updateItem(index: number, item: CertificateItem) {
    this.items[index] = item;
    this.save()
  }

  removeItem(index: number) {
    this.items.splice(index, 1);
    this.save()
  }

  save() {
    this.pref.put(PreferenceConstant.RESUME_QUALIFICATION_CERT, this.items)
  }

  private static _instance: QualificationCertificateModel

  public static get instance() {
    if (!QualificationCertificateModel._instance) {
      QualificationCertificateModel._instance = new QualificationCertificateModel()
    }
    return QualificationCertificateModel._instance
  }
}