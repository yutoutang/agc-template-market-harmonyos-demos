// 先导出所有 Model，确保它们在 ResumePage 之前加载
export { ResumeModel } from './src/main/ets/viewsmodel/ResumeModel';

export { PersonalInformationModel } from './src/main/ets/viewsmodel/BasicalInformationModel';

export { SelfEvaluationModel } from './src/main/ets/viewsmodel/SelfEvaluationModel';

export { CareerObjectiveModel } from './src/main/ets/viewsmodel/CareerObjectiveModel';

export { CareerObjectiveItem } from './src/main/ets/viewsmodel/CareerObjectiveModel';

export { WorkExperienceModel } from './src/main/ets/viewsmodel/WorkExperienceModel';

export { WorkItem } from './src/main/ets/viewsmodel/WorkExperienceModel';

export { ProjectExperienceModel } from './src/main/ets/viewsmodel/ProjectExperienceModel';

export { ProjectItem } from './src/main/ets/viewsmodel/ProjectExperienceModel';

export { EducationalBackgroundModel } from './src/main/ets/viewsmodel/EducationalBackgroundModel';

export { EducationItem } from './src/main/ets/viewsmodel/EducationalBackgroundModel';

export { VocationalSkillModel } from './src/main/ets/viewsmodel/VocationalSkillModel';

export { QualificationCertificateModel } from './src/main/ets/viewsmodel/QualificationCertificateModel';

export { CertificateItem } from './src/main/ets/viewsmodel/QualificationCertificateModel';

export { IndustrySelectPageBuilder } from './src/main/ets/comp/IndustrySelect';

export { TextEditingBuilder, TextEditingConfig } from './src/main/ets/views/DescriptionEditingPage';

export { ResumeSnapshotUtil,
  ResumeSnapshot,
  ResumeItem,
  FilterTags,
  SnapshotPersonalInfo,
  SnapshotSelfEvaluation,
  SnapshotVocationalSkill } from './src/main/ets/utils/ResumeSnapshotUtil';

export { PersonalInfo } from './src/main/ets/viewsmodel/BasicalInformationModel';

// 最后导出 ResumePage 和 ResumePageBuilder，确保所有依赖已加载
export { ResumePage, ResumePageBuilder } from './src/main/ets/views/ResumePage';
