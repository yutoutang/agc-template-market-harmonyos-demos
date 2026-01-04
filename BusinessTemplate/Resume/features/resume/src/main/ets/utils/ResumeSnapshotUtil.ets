/**
 * 简历快照工具类
 * 用于保存和恢复简历数据快照,支持简历数据的持久化存储
 */

import { PreferenceUtil } from 'common'
import { promptAction } from '@kit.ArkUI'
import { PersonalInformationModel } from '../viewsmodel/BasicalInformationModel'
import { SelfEvaluationModel } from '../viewsmodel/SelfEvaluationModel'
import { CareerObjectiveModel } from '../viewsmodel/CareerObjectiveModel'
import { EducationalBackgroundModel } from '../viewsmodel/EducationalBackgroundModel'
import { QualificationCertificateModel } from '../viewsmodel/QualificationCertificateModel'
import { VocationalSkillModel } from '../viewsmodel/VocationalSkillModel'
import { WorkExperienceModel } from '../viewsmodel/WorkExperienceModel'
import { ProjectExperienceModel } from '../viewsmodel/ProjectExperienceModel'

// 模板标签接口
export interface FilterTags {
  industry?: string
  position?: string
  style?: string
}

// 快照中的基本信息接口
export interface SnapshotPersonalInfo {
  name: string
  phone: string
  email: string
  avatarUrl: string // 简历基本信息页面的头像资源路径（序列化后的字符串格式）
  avatarUrlBase64?: string
}

// 快照中的自我评价接口
export interface SnapshotSelfEvaluation {
  content: string // 自我评价内容
}

// 快照中的职业技能接口
export interface SnapshotVocationalSkill {
  skills: string // 职业技能内容（多个技能合并为一个字符串）
}

// 简历快照数据接口
export interface ResumeSnapshot {
  // 必备项
  personalInfo: SnapshotPersonalInfo
  selfEvaluation: SnapshotSelfEvaluation
  careerObjective: object[] // 求职意向
  educationalBackground: object[] // 教育背景
  // 可选项
  projectExperience?: object[] // 项目经验
  workExperience?: object[] // 工作经历
  vocationalSkill?: SnapshotVocationalSkill
  qualificationCertificate?: object[] // 资格证书
}

export interface ResumeItem {
  id: string
  name: string
  coverColor: string
  templateStyle?: string // 模板风格（如：简约、大气）- 保留用于兼容旧数据，改为可选
  filterTags?: FilterTags // 完整的模板标签，用于精确识别模板
  updatedAt: number
  applied?: boolean
  snapshot?: ResumeSnapshot // 简历快照数据
  previewImage?: string // 简历预览图的 Base64 字符串
}

/**
 * 简历快照工具类
 * 用于保存和管理简历快照数据
 */
export class ResumeSnapshotUtil {
  private static store: PreferenceUtil = PreferenceUtil.getInstance(undefined, 'resume_store')

  /**
   * 验证必备项是否完整
   */
  private static validateRequiredFields(): boolean {
    const personal: PersonalInformationModel = PersonalInformationModel.instance
    const selfEval: SelfEvaluationModel = SelfEvaluationModel.instance
    const career: CareerObjectiveModel = CareerObjectiveModel.instance
    const edu: EducationalBackgroundModel = EducationalBackgroundModel.instance
    const project: ProjectExperienceModel = ProjectExperienceModel.instance

    // 检查基本信息
    if (!personal.data.name || personal.data.name.trim() === '') {
      promptAction.showToast({ message: '请先填写个人信息' })
      return false
    }

    // 检查自我评价
    if (!selfEval.content || selfEval.content.trim() === '') {
      promptAction.showToast({ message: '请先填写自我评价' })
      return false
    }

    // 检查求职意向
    if (!career.items || career.items.length === 0) {
      promptAction.showToast({ message: '请先添加求职意向' })
      return false
    }

    // 检查教育背景
    if (!edu.items || edu.items.length === 0) {
      promptAction.showToast({ message: '请先添加教育背景' })
      return false
    }

    return true
  }

  /**
   * 创建简历快照
   */
  private static createResumeSnapshot(): ResumeSnapshot {
    const personal: PersonalInformationModel = PersonalInformationModel.instance
    const selfEval: SelfEvaluationModel = SelfEvaluationModel.instance
    const career: CareerObjectiveModel = CareerObjectiveModel.instance
    const edu: EducationalBackgroundModel = EducationalBackgroundModel.instance
    const project: ProjectExperienceModel = ProjectExperienceModel.instance
    const work: WorkExperienceModel = WorkExperienceModel.instance
    const skill: VocationalSkillModel = VocationalSkillModel.instance
    const cert: QualificationCertificateModel = QualificationCertificateModel.instance

    // 转换 avatarUrl 为字符串格式
    let avatarUrlStr: string = "$r('app.media.ic_defaultAvatar')"
    if (typeof personal.data.avatarUrl === 'string') {
      avatarUrlStr = personal.data.avatarUrl
    }

    // 构建基本信息快照
    const personalInfoSnapshot: SnapshotPersonalInfo = {
      name: personal.data.name,
      phone: personal.data.phone,
      email: personal.data.email,
      avatarUrl: avatarUrlStr,
      avatarUrlBase64: personal.data.avatarUrlBase64
    }

    // 构建自我评价快照
    const selfEvaluationSnapshot: SnapshotSelfEvaluation = {
      content: selfEval.content
    }

    // 构建职业技能快照（可选）
    // 将技能数组合并为一个字符串，每个技能用换行分隔
    const vocationalSkillSnapshot: SnapshotVocationalSkill | undefined =
      skill.skills.length > 0 ? { skills: skill.skills.join('\n') } : undefined

    // 构建完整快照
    const snapshot: ResumeSnapshot = {
      // 必备项
      personalInfo: personalInfoSnapshot,
      selfEvaluation: selfEvaluationSnapshot,
      careerObjective: JSON.parse(JSON.stringify(career.items)),
      educationalBackground: JSON.parse(JSON.stringify(edu.items)),
      // 可选项
      projectExperience: project.items.length > 0 ? JSON.parse(JSON.stringify(project.items)) : undefined,
      workExperience: work.items.length > 0 ? JSON.parse(JSON.stringify(work.items)) : undefined,
      vocationalSkill: vocationalSkillSnapshot,
      qualificationCertificate: cert.items.length > 0 ? JSON.parse(JSON.stringify(cert.items)) : undefined
    }

    return snapshot
  }

  /**
   * 保存简历
   * @param templateName 模板名称
   * @param coverColor 封面颜色
   * @param templateStyle 模板风格（如：简约、大气）
   * @param filterTags 完整的模板标签
   * @param previewImage 简历预览图的 Base64 字符串
   * @returns 是否保存成功
   */
  static saveResume(templateName: string, coverColor: string, templateStyle: string, filterTags?: FilterTags,
    previewImage?: string): boolean {
    // 验证必备项
    if (!ResumeSnapshotUtil.validateRequiredFields()) {
      return false
    }

    // 创建快照
    const snapshot = ResumeSnapshotUtil.createResumeSnapshot()

    // 创建简历项
    const newResume: ResumeItem = {
      id: Date.now().toString(),
      name: templateName,
      coverColor: coverColor,
      templateStyle: templateStyle,
      filterTags: filterTags,
      updatedAt: Date.now(),
      applied: true,
      snapshot: snapshot,
      previewImage: previewImage
    }

    // 读取现有列表
    const raw = ResumeSnapshotUtil.store.get('my_resume_list', '[]') as string
    let list: Array<ResumeItem> = []
    try {
      list = JSON.parse(raw as string) as Array<ResumeItem>
    } catch (_) {
      list = []
    }

    // 添加到列表（最新的在最前面）
    list.unshift(newResume)

    // 持久化保存
    ResumeSnapshotUtil.store.put('my_resume_list', JSON.stringify(list))

    promptAction.showToast({ message: '简历保存成功' })
    return true
  }

  /**
   * 获取所有保存的简历
   */
  static getAllResumes(): Array<ResumeItem> {
    const raw = ResumeSnapshotUtil.store.get('my_resume_list', '[]') as string
    try {
      return JSON.parse(raw as string) as Array<ResumeItem>
    } catch (_) {
      return []
    }
  }
}
