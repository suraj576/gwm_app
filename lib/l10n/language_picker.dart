import 'package:flutter/material.dart';
import 'package:groundwater_management/l10n/l10n.dart';
import 'package:groundwater_management/provider/locale_provider.dart';
import 'package:provider/provider.dart';


class LanguagePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final locale = provider.locale ?? Locale('en');

    return DropdownButtonHideUnderline(
        child: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: DropdownButton(
            icon: Icon(
              Icons.language_sharp,
              color: Colors.red[900],
              ),
            items: L10n.all.map(
              (locale) {
                final lang = L10n.getText(locale.languageCode);
                return DropdownMenuItem(
                  child: Text(
                      lang,
                      style: TextStyle(
                        fontSize: 18,
                        ),
                    ),
                  value: locale,
                  onTap: () {
                    final provider =
                        Provider.of<LocaleProvider>(context, listen: false);
                    provider.setLocale(locale);
                  },
                );
              },
            ).toList(),
            onChanged: (_) {},
          ),
        ),
    );
  }
}
