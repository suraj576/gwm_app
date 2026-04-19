import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:groundwater_management/functions/rounded_button.dart';
import 'package:groundwater_management/l10n/language_picker.dart';
import 'package:groundwater_management/screens/components/background.dart';
import '../../authentication/login.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // This size provide us total height and width of our screen
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        actions: [
          LanguagePicker(),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage('assets/well1.png'), height: size.height * 0.45),
              SizedBox(height: size.height * 0.05),
              SizedBox(
                child: DefaultTextStyle(
                  style: const TextStyle(
                      color: Colors.teal,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText('Ground Water Management',
                        speed: const Duration(milliseconds: 150),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    repeatForever: true,
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.05),
              RoundedButton(
                text: AppLocalizations.of(context)!.signin,  // FIXED: Added !
                color: Colors.orange[700]!,  // FIXED: Added !
                textColor: Colors.white,
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Login();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
