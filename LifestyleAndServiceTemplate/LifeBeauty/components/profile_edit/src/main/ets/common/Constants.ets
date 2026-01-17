import { GenderOption } from '../types/Gender';

// 手机号正则
export const PHONE_REG = /^[1][3,4,5,6,7,8,9][0-9]{9}$/;

// 性别
export const GENDER_OPTIONS: GenderOption[] = [
  {
    value: '3',
    label: '保密',
  },
  {
    value: '0',
    label: '男',
  },
  {
    value: '1',
    label: '女',
  },
];