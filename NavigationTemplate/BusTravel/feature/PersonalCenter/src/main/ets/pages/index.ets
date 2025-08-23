import { MinePage } from './MinePage'

@Builder
export function PersonalCenterBuilder() {
  PersonalCenter()
}

@ComponentV2
export struct PersonalCenter {
  build() {
    MinePage()
  }
}