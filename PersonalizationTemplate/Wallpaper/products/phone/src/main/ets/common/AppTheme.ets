import { CustomColors, CustomTheme } from '@kit.ArkUI';

export class AppColors implements CustomColors {
  //自定义主题色
  brand: ResourceColor = '#0A59F7';
  fontPrimary = '#191919';
  fontSecondary = '#666666';
}

export class AppTheme implements CustomTheme {
  public colors: AppColors = new AppColors();
}

export const gAppTheme: CustomTheme = new AppTheme();