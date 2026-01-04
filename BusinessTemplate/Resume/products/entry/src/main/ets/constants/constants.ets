/**
 * @usage: tab 页面控制类，包括模板、简历、我的
 * @layout:
 * @constraints: tab 页面控制类，包括模板（template）、简历（resume）、我的（person）。
 * 根据用户实际需求仅修改代码中 TAB_CONFIG 变量，当前仅支持删除变量中的元素，以及修改 id，从 0 开始并保证 id 顺序，其他元素不允许修改。
 * 根据用户需求删除多余的 import 依赖，仅从 TemplatePageBuilder、ResumePageBuilder、MinePageBuilder 依赖中删除，
 * TabSingleItem 依赖需保留
 * @isGen: true
 * @fileType: tab
 * @zhName: Tab页面控制器
 * @dependencies: template, resume, person, TabSingleItem
 */

import { TabSingleItem } from '../viewmodels/TabSingleItem';
import { TemplatePageBuilder } from 'template';
import { ResumePageBuilder } from 'resume';
import { MinePageBuilder } from 'person';

export const TAB_CONFIG: TabSingleItem[] = [
  {
    label: $r('app.string.template_tab'),
    index: 0,
    fontColor: '#99000000',
    fontColorActive: '#0A59F7',
    icon: $r('app.media.template_tab'),
    iconActive: $r('app.media.template_tab_active'),
    component: wrapBuilder(TemplatePageBuilder),
  },
  {
    label: $r('app.string.resume_tab'),
    index: 1,
    fontColor: '#99000000',
    fontColorActive: '#0A59F7',
    icon: $r('app.media.resume_tab'),
    iconActive: $r('app.media.resume_tab_active'),
    component: wrapBuilder(ResumePageBuilder),
  },
  {
    label: $r('app.string.person_tab'),
    index: 2,
    fontColor: '#99000000',
    fontColorActive: '#0A59F7',
    icon: $r('app.media.person_tab'),
    iconActive: $r('app.media.person_tab_active'),
    component: wrapBuilder(MinePageBuilder),
  },
];