import { IThemeInfo } from '../types/Types';

// 页面名
export enum ThemePage {
  /**
   * 主题列表页
   */
  THEME_LIST = 'ThemeList',
  /**
   * 主题详情页
   */
  THEME_DETAIL = 'ThemeDetail',
}

export const THEME_LIST: IThemeInfo[] = [
  {
    id: 1,
    pics: ['series2_theme3', 'series2_theme5', 'series2_theme1', 'series2_theme4', 'series2_theme2'],
    colors: ['#4F6384', '#8FC2E0', '#ADDFE3', '#86A8C6', '#044984'],
    label: '城市系列1',
    desc: '漫游城市，探索车水马龙与人文',
  },
  {
    id: 2,
    pics: ['series2_theme5', 'series2_theme2', 'series2_theme4', 'series2_theme1', 'series2_theme3'],
    colors: ['#8FC2E0', '#044984', '#86A8C6', '#ADDFE3', '#4F6384'],
    label: '城市系列2',
    desc: '漫游城市，探索车水马龙与人文',
  },
  {
    id: 3,
    pics: ['series2_theme2', 'series2_theme1', 'series2_theme5', 'series2_theme3', 'series2_theme4'],
    colors: ['#044984', '#ADDFE3', '#8FC2E0', '#4F6384', '#86A8C6'],
    label: '城市系列3',
    desc: '漫游城市，探索车水马龙与人文',
  },
  {
    id: 4,
    pics: ['series2_theme4', 'series2_theme3', 'series2_theme2', 'series2_theme5', 'series2_theme1'],
    colors: ['#86A8C6', '#4F6384', '#044984', '#8FC2E0', '#ADDFE3'],
    label: '城市系列4',
    desc: '漫游城市，探索车水马龙与人文',
  },
  {
    id: 5,
    pics: ['series2_theme1', 'series2_theme4', 'series2_theme3', 'series2_theme2', 'series2_theme5'],
    colors: ['#ADDFE3', '#86A8C6', '#4F6384', '#044984', '#8FC2E0'],
    label: '城市系列5',
    desc: '漫游城市，探索车水马龙与人文',
  },
  {
    id: 6,
    pics: ['series1_theme3', 'series1_theme5', 'series1_theme1', 'series1_theme4', 'series1_theme2'],
    colors: ['#8B87BB', '#578DCA', '#2B3D51', '#5B7ABA', '#677DAD'],
    label: '山水系列1',
    desc: '领略四季，走进自然和奇幻世界',
  },
  {
    id: 7,
    pics: ['series1_theme5', 'series1_theme2', 'series1_theme4', 'series1_theme1', 'series1_theme3'],
    colors: ['#578DCA', '#677DAD', '#5B7ABA', '#2B3D51', '#8B87BB'],
    label: '山水系列2',
    desc: '领略四季，走进自然和奇幻世界',
  },
  {
    id: 8,
    pics: ['series1_theme2', 'series1_theme1', 'series1_theme5', 'series1_theme3', 'series1_theme4'],
    colors: ['#677DAD', '#2B3D51', '#578DCA', '#8B87BB', '#5B7ABA'],
    label: '山水系列3',
    desc: '领略四季，走进自然和奇幻世界',
  },
  {
    id: 9,
    pics: ['series1_theme4', 'series1_theme3', 'series1_theme2', 'series1_theme5', 'series1_theme1'],
    colors: ['#5B7ABA', '#8B87BB', '#677DAD', '#578DCA', '#2B3D51'],
    label: '山水系列4',
    desc: '领略四季，走进自然和奇幻世界',
  },
  {
    id: 10,
    pics: ['series1_theme1', 'series1_theme4', 'series1_theme3', 'series1_theme2', 'series1_theme5'],
    colors: ['#2B3D51', '#5B7ABA', '#8B87BB', '#677DAD', '#578DCA'],
    label: '山水系列5',
    desc: '领略四季，走进自然和奇幻世界',
  },
];