export class GoalInfo {
  distance: string;
  steps: string;
  caloric: string;

  constructor(distance: string, steps: string, caloric: string) {
    this.distance = distance;
    this.steps = steps;
    this.caloric = caloric;
  }
}

export class GoalsInfo {
  static stepGoal: string = '10000';
  static distanceGoal: string = '5';
  static calorieGoal: string = '2000'
}