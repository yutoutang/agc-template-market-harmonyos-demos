export interface PersonalInfo {
  userheight: string;
  gender: string;
  weight: string;
  birth: number;
}

export interface BmiParam {
  bmi: number;
  level: string
}

export interface BmiAdviceParam {
  physicalState: string,
  healthTips: string,
  healthAnalysis: string
}

export class BmiInfomation {
  static bmiAdvice: BmiAdviceParam[] = [
    {
      physicalState: '体重过低',
      healthTips: '目前 BMI 偏低，身体可能处于“能量亏损”状态，免疫力、骨密度与激素分泌均易受影响。',
      healthAnalysis: '饮食：每日热量摄入 ≥ 35 kcal/kg 体重；把三餐改为“三餐两点”，坚果、全脂奶、牛油果等高营养密度食物作加餐。\n' +
        '运动：以力量训练为主（每周 3 次哑铃/弹力带），每次≤45 min；避免长时间有氧，防止额外消耗。'
    },
    {
      physicalState: '体重正常',
      healthTips: 'BMI 处于理想区间，但“正常 ≠ 健康终点”，请继续保持均衡饮食与规律运动。',
      healthAnalysis: '饮食：遵循“521 餐盘”——每餐 50% 蔬果、20% 全谷物、20% 优质蛋白、10% 好油；每日添加糖＜25 g。\n' +
        '运动：每周≥150 min 中等强度有氧（快走、游泳）+ 2 次抗阻训练，维持基础代谢率与肌肉量。'
    },
    {
      physicalState: '超重',
      healthTips: '体重已超标，血脂、血压、血糖开始“爬坡”，现在干预可逆转！',
      healthAnalysis: '饮食：每日热量赤字 300‐500 kcal；主食粗细 1:1，瘦肉/鱼/豆制品占蛋白 70%，戒掉含糖饮料。\n' +
        '运动：有氧+抗阻联合——每周 5 次 30 min 快走/椭圆机，心率维持在（220-年龄）×60%‐70%；外加 2 次核心+大肌群力量。'
    },
    {
      physicalState: '肥胖',
      healthTips: 'BMI 已达肥胖标准，心脑血管疾病、糖尿病、脂肪肝风险显著升高，请立即启动医学减重计划。\n',
      healthAnalysis: '饮食：在医生/营养师指导下采用低热量平衡膳食（1200‐1500 kcal/d），优先选择高膳食纤维、低 GI、优质蛋白；避免极端节食。\n' +
        '运动：循序渐进——初期每天 30 min 快走或水中运动，关节友好；4 周后逐步增至 45-60 min，并加入弹力带抗阻。'
    },
  ]
}