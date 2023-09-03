import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_form_builder/flutter_form_builder.dart' as formbuilder;
import 'package:form_builder_validators/form_builder_validators.dart' as form_builder_validators;
import 'dart:convert';

import 'models/User.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final _formKey = GlobalKey<formbuilder.FormBuilderState>();
  final _mainScaffoldKey = GlobalKey<ScaffoldMessengerState>();

  void registerUser(){
    _formKey.currentState!.saveAndValidate();
    Map<String, dynamic> formValues = _formKey.currentState!.value;
    print(formValues);
    User user = User(
      name: formValues['user_name'], 
      phoneNumber: formValues['user_phone'],
      email: formValues['user_email'], 
      mealPlan: MealPlan.setMealPlan(List<String>.from(formValues['meal_plan'])),
      startDate: DateTime.parse(formValues['start_date'].toString()).millisecondsSinceEpoch
    );
    print(user.toString());
    Future<http.Response> serviceResponse = createUser(user);
    serviceResponse.then((value){
      if(value.statusCode == 201){
            _mainScaffoldKey.currentState!.showSnackBar((snackBar("Registration Successful. Pending approval from ADMIN.")) as SnackBar);
            _formKey.currentState!.reset();
      }
      else{
        
        _mainScaffoldKey.currentState!.showSnackBar((snackBar("Registration Unsuccessful. Please try again after sometime.")) as SnackBar);
      }
    }).catchError((e){
       _mainScaffoldKey.currentState!.showSnackBar((snackBar("Servers are down. Please try again after sometime.")) as SnackBar);
    });
  }

  Widget snackBar(String text){
    return SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 2)
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: _mainScaffoldKey,
        title: 'Membership Register',
        theme: ThemeData(
            primarySwatch: Colors.lightGreen,
            visualDensity: VisualDensity.adaptivePlatformDensity),
        home: Scaffold(
            appBar: AppBar(
                centerTitle: true,
                title: const Text(
                  "Membership Register",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold
                  ),
                ),
                backgroundColor: Colors.lightGreen),
            body: SafeArea(child: registrationFormWidget())
      )
    );
  }

  Future<http.Response> createUser(User user) async{
      final http.Response response = await http.post(
        Uri.parse('http://localhost:8080/membership-register/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Access-Control-Allow-Origin': '*'
        },
        body: jsonEncode({
          'name': user.name,
          'mobileNumber': user.phoneNumber,
          'email': user.email,
          'mealPlan': {
              'breakfast': user.mealPlan.breakfast,
              'lunch': user.mealPlan.lunch,
              'dinner': user.mealPlan.dinner
          },
          'startDate': user.startDate,
        })
      );
    return response;
  }

  Widget registrationFormWidget(){
    return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: formbuilder.FormBuilder(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                nameWidget(),
                phoneWidget(),
                emailWidget(),
                mealPlanWidget(),
                startDateWidget(),
                registerButtonWidget()
              ]
          )
        )
      )
    );
  }

  Widget nameWidget(){
    return formbuilder.FormBuilderTextField(
        decoration: const InputDecoration(hintText: "Name"),
        name: "user_name",
        validator: form_builder_validators.FormBuilderValidators.compose([
            form_builder_validators.FormBuilderValidators.required()
    ]));
  }

  Widget emailWidget(){
    return formbuilder.FormBuilderTextField(
            decoration: const InputDecoration(hintText: "Email"),
            name: "user_email",
            validator: form_builder_validators.FormBuilderValidators.compose(
              [
                form_builder_validators.FormBuilderValidators.required(),
                form_builder_validators.FormBuilderValidators.email()
              ]
            )
    );
  }

  Widget phoneWidget(){
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  <Widget>[ 
            Expanded(
              flex: 1,
              child: countryCodeDropDownWidget(),
            ),
            const Spacer(flex: 1),
            Expanded(
              flex: 3,
              child: phoneNumberTextFieldWidget(),
            )
        ]
    );
  }

  Widget countryCodeDropDownWidget(){
    List<String> countryCodes =  ["+91","044"];
    return formbuilder.FormBuilderDropdown(
            name: "country_code",
            initialValue: countryCodes[0],
            items: countryCodes.map(
                          (countrycode) => DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: countrycode,
                            child: Text(countrycode)
                            )
              ).toList()
    );
  }

  Widget phoneNumberTextFieldWidget(){
    return formbuilder.FormBuilderTextField(
                decoration: const InputDecoration(hintText: "Phone"),
                name: "user_phone",
                validator: form_builder_validators.FormBuilderValidators.compose([
                    form_builder_validators.FormBuilderValidators.required(),
                    form_builder_validators.FormBuilderValidators.numeric(errorText: "Invalid phone number")
                ])
    );
  }

  Widget mealPlanWidget(){
    return formbuilder.FormBuilderCheckboxGroup(
              wrapSpacing: 32,
              decoration: const InputDecoration(labelText: 'Meal Plan'),
              name: 'meal_plan',
              validator: (value) {
                  return value == null ? "This field cannot be empty" : null;
              },
              options: [
                'Breakfast',
                'Lunch',
                'Dinner'
              ].map((meal) => formbuilder.FormBuilderFieldOption(
                value: meal)).toList(growable: false)
    );
  }

  Widget startDateWidget(){
    return formbuilder.FormBuilderDateTimePicker(
      name: "start_date",
      decoration: const InputDecoration(labelText: "Pick Membership Start Date"),
      validator: form_builder_validators.FormBuilderValidators.required(errorText: "Please choose membership startdate"),
      firstDate: DateTime.now(),
      inputType: formbuilder.InputType.date,
    );
  }

  Widget registerButtonWidget(){
    double height = 50;
    return SizedBox(
              height: height,
              width: height * 4,
              child: ElevatedButton(onPressed: registerUser, 
              child: const Text(
                "Register",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold
                  )
                )
              )
            );
  }

}
