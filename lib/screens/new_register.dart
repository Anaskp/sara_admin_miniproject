import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sara_admin/screens/screens.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final _categoryLiist = ['Road', 'Waste', 'Hotel'];
  String? _choosenCategory;
  bool _errorMessage = false;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const SpinWidget()
        : Scaffold(
            appBar: AppBar(
              title: const Text('Register new Authority'),
              centerTitle: true,
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Register',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Please enter the details below to continue',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey[200],
                          ),
                          child: TextFormField(
                            validator: (email) =>
                                email != null && !EmailValidator.validate(email)
                                    ? 'Enter valid email'
                                    : null,
                            controller: emailController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Email',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey[200],
                          ),
                          child: TextFormField(
                            validator: (pass) => pass != null && pass.length < 6
                                ? 'Enter valid password'
                                : null,
                            controller: passController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Password',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 5,
                          ),
                          width: double.infinity,
                          child: Center(
                            child: DropdownButtonHideUnderline(
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton(
                                    iconSize: 35,
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(15),
                                    value: _choosenCategory,
                                    items: _categoryLiist.map((String value) {
                                      return DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    hint: const Text('Choose category'),
                                    onChanged: (value) {
                                      setState(() {
                                        _choosenCategory = value as String?;
                                      });
                                    }),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        _choosenCategory == null && _errorMessage == true
                            ? Column(
                                children: const [
                                  Text(
                                    'Please choose a category',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.red,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              signUp();
                            },
                            child: const Text('Register'),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Future signUp() async {
    setState(() {
      _errorMessage = true;
    });
    final isValid = formKey.currentState!.validate();

    if (isValid) {
      setState(() {
        isLoading = true;
      });

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passController.text.trim(),
        );

        FirebaseFirestore.instance
            .collection('usersData')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set(
          {
            'role': 'admin',
            'email': emailController.text,
            'category': _choosenCategory,
          },
        );

        setState(() {
          isLoading = false;
        });

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false);

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New authority registered')));
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message!)));
      }
    }
  }
}

class SpinWidget extends StatelessWidget {
  const SpinWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(
              height: 20,
            ),
            Text(
              'Registering Authority',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
