/**
 * 考卷
 */
@ObservedV2
export class ExamManager {
  /**
   * 考卷Id
   */
  id: string;
  /**
   * 考卷名称
   */
  name: string | Resource;
  /**
   * 当前题目Id, 退出后重新进入时展示退出前的题目id
   */
  currentQuestionId: number;
  /**
   * 题目数量
   */
  total: number;
  /**
   * 时间限制(分钟为单位)
   */
  timeLimit: number;
  /**
   * 答题正确数量
   */
  @Trace correctNumber: number;
  /**
   * 答题错误数量
   */
  @Trace errorNumber: number;
  /**
   * 考题
   */
  examDetails: Array<ExamDetail>;

  constructor(name: string | Resource, examDetails: Array<ExamDetail>, currentQuestionId: number = 0,
    correctNumber: number = 0, errorNumber: number = 0, timeLimit: number = 0) {
    this.id = new Date().getTime().toString();
    this.name = name;
    this.currentQuestionId = currentQuestionId;
    this.timeLimit = timeLimit;
    this.correctNumber = correctNumber;
    this.errorNumber = errorNumber;
    this.examDetails = examDetails;
    this.total = examDetails.length;
  }

  /**
   * 清空已选项
   */
  clearSelectedOption() {
    for (let item of this.examDetails) {
      item.selected = [];
    }
  }

  /**
   * 清空记录（是否收藏除外）
   */
  clearRecords() {
    this.correctNumber = 0;
    this.errorNumber = 0;
    for (let item of this.examDetails) {
      item.selected = [];
      item.isCorrect = undefined;
    }
  }
}



/**
 * 题目
 */
@ObservedV2
export class ExamDetail {
  /**
   * 题目id
   */
  id: string;
  /**
   * 问题
   */
  question: string;
  /**
   * 问题图片（部分问题下面会有图片），根据图片回答问题
   */
  questionImage: string;
  /**
   * 全部选项
   */
  options: Array<string>;
  /**
   * 已选
   */
  @Trace selected: Array<string>;
  /**
   * 正确答案
   */
  answer: Array<string>;
  /**
   * 是否正确
   */
  @Trace isCorrect?: boolean;
  /**
   * 题目类型
   */
  questionType: QuestionTypeEnum;
  /**
   * 难易程度
   */
  classificationType: ClassificationTypeEnum;
  /**
   * 题目解析
   */
  analysis: string;
  /**
   * 视频讲题-视频url
   */
  videoExplainUrl: string;
  /**
   * 是否收藏
   */
  @Trace isCollect: boolean;
  /**
   * 章节名称-按章节分类
   */
  chapterName: string;

  constructor(question: string, questionImage: string, options: Array<string>, answer: Array<string>,
    questionType: QuestionTypeEnum, classificationType: ClassificationTypeEnum,
    analysis: string, chapterName: string, videoExplainUrl?: string) {
    this.id = new Date().getTime().toString();
    this.question = question;
    this.questionImage = questionImage;
    this.options = options;
    this.selected = [];
    this.answer = answer;
    this.questionType = questionType;
    this.classificationType = classificationType;
    this.analysis = analysis;
    this.isCollect = false;
    this.chapterName = chapterName;
    this.videoExplainUrl = videoExplainUrl ? videoExplainUrl : '';
  }
}

/**
 * 问题类型枚举
 */
export enum QuestionTypeEnum {
  /**
   * 单选
   */
  RADIO,
  /**
   * 多选
   */
  CHECK_BOX,
  /**
   * 判断题
   */
  JUDGE
}

/**
 * 分类枚举（按难易程度）
 */
export enum ClassificationTypeEnum {
  /**
   * 容易
   */
  EASY,
  /**
   * 简单
   */
  SIMPLE,
  /**
   * 一般
   */
  MIDDLE,
  /**
   * 困难
   */
  HARD,
  /**
   * 易错
   */
  EASY_MISTAKE
}