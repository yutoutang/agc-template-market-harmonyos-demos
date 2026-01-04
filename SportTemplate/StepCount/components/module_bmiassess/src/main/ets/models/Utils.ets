import { BmiParam } from './PersonalInfo';

export const padZero = (input: number): string => {
  return input.toString().padStart(2, '0');
}

export const formatDate = (datetime?: number): string => {
  if (!datetime) {
    return '';
  }
  const date = new Date(datetime);
  return `${date.getFullYear()}-${padZero(date.getMonth() + 1)}-${padZero(date.getDate())}`;
}

export function calcBMI(
  sex: string,
  birthday: string, // yyyy-MM-dd
  heightCm: number, // cm
  weightKg: number // kg
): BmiParam {
  // 1. 计算年龄（粗略）
  const birth = new Date(birthday);
  const age = (Date.now() - birth.getTime()) / (365.25 * 24 * 3600 * 1000);

  // 2. BMI 公式
  const bmi = weightKg / Math.pow(heightCm / 100, 2);

  // 3. 分级（WHO 标准，性别/年龄微调可在此扩展）
  let level: string;
  if (bmi < 18.5) {
    level = '体重过低';
  } else if (bmi < 24) {
    level = '体重正常';
  } else if (bmi < 28) {
    level = '超重';
  } else {
    level =
      '肥胖';
  }

  return { bmi: Math.round(bmi * 10) / 10, level };
}

export function bmiToPercent(bmi: number): number {
  let p = 0;
  if (bmi < 18.5) { // 过低
    p = (bmi / 18.4) * 25;
  } else if (bmi < 24) { // 正常
    p = 25 + ((bmi - 18.5) / 5.4) * 25;
  } else if (bmi < 28) { // 超重
    p = 50 + ((bmi - 24) / 4) * 25;
  } else { // 肥胖
    p = 75 + (Math.min(bmi - 28, 12) / 12) * 25;
  }
  return Math.round(Math.min(100, Math.max(0, p)));
}