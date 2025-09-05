import { LongTakeAnimationProperties } from '../sessions/LongTakeAnimationProperties';
import { LongTakeTransitionType } from '../constants/LongTakeTransitionConstants';
import { CardLongTakeDelegate } from './CardLongTakeDelegate';

@ComponentV2
export struct LongTakeTransitionDelegate{
  @BuilderParam contentBuilder: () => void;

  @Param @Require longTakeSession: LongTakeAnimationProperties;

  build() {
    if (this.longTakeSession.type === LongTakeTransitionType.CardLongTake) {
      CardLongTakeDelegate({
        longTakeSession: this.longTakeSession,
        contentBuilder: (): void => {
          this.contentBuilder();
        }
      })
    }
  }
}