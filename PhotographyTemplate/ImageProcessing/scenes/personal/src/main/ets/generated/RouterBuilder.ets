import { HelpPage } from '../pages/Help';
import { OtherLogin } from '../pages/OtherLogin';
import { QuickLoginPage } from '../pages/QuickLoginPage';
import { SettingPage } from '../pages/Setting';
import { TermsPage } from '../pages/Terms';

@Builder
export function OpenVipBuilder() {
}

@Builder
export function SettingBuilder() {
  SettingPage();
}

@Builder
export function SaveSettingBuilder() {
}

@Builder
export function TermsBuilder() {
  TermsPage();
}

@Builder
export function HelpBuilder() {
  HelpPage();
}

@Builder
export function QuickLoginPageBuilder() {
  QuickLoginPage();
}

@Builder
export function OtherLoginPageBuilder() {
  OtherLogin();
}

