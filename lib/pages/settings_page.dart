import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  String selectedLanguage = "id";

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("darkMode") ?? false;
      selectedLanguage = prefs.getString("language") ?? "id";
    });
  }

  Future<void> updateLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("language", lang);
    setState(() => selectedLanguage = lang);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Preferensi",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Bahasa
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Bahasa"),
            subtitle: Text(
              selectedLanguage == "id" ? "Indonesia" : "English",
            ),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              underline: Container(),
              items: const [
                DropdownMenuItem(
                  value: "id",
                  child: Text("Indonesia"),
                ),
                DropdownMenuItem(
                  value: "en",
                  child: Text("Inggris"),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  updateLanguage(value);
                }
              },
            ),
          ),

          // Mode Gelap
          SwitchListTile(
            title: const Text("Mode Gelap"),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: isDarkMode,
            onChanged: (val) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool("darkMode", val);
              setState(() => isDarkMode = val);
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Text(
              "Tentang",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Tentang Aplikasi
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("Tentang Aplikasi"),
            onTap: () {},
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}