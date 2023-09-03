class User{
  String name;
  String phoneNumber;
  String email;
  MealPlan mealPlan;
  int startDate;

  User({required this.name, required this.phoneNumber, required this.email, required this.mealPlan, required this.startDate});

  @override
  String toString() {
    return "Name: $name ,PhoneNumber: $phoneNumber ,email: $email ,mealPlan: $mealPlan ,startDate: $startDate";
  }
}

class MealPlan {
  bool breakfast;
  bool lunch;
  bool dinner;

  MealPlan({required this.breakfast, required this.lunch, required this.dinner});

  factory MealPlan.setMealPlan(List<String> values){
    bool breakfast = false, lunch = false, dinner = false;
    for(String meal in values){
      if(meal == 'Breakfast'){
        breakfast = true;
      }
      if(meal == 'Lunch'){
        lunch = true;  
      }
      if(meal == 'Dinner'){
        dinner = true;
      }
    }
    return MealPlan(breakfast: breakfast, lunch: lunch, dinner: dinner);
  }
  
  @override
  String toString() {
    return "Breakfast: $breakfast, Lunch: $lunch, Dinner: $dinner";
  }
}