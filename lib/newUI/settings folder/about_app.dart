import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About HissabKitaab"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App logo
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green.shade200,
                  child: FaIcon(
                    FontAwesomeIcons.store,
                    size: 50,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // App name and description section
              Center(
                child: Text(
                  "Hisab Kitab",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "An effortless billing and inventory management for local retail and departmental stores.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),

              // Team section with icons
              const Text(
                "Our Team",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Divider(),
              const SizedBox(height: 10),
              const ListTile(
                leading: FaIcon(FontAwesomeIcons.user, color: Colors.green),
                title: Text("Member One"),
              ),
              const ListTile(
                leading: FaIcon(FontAwesomeIcons.user, color: Colors.green),
                title: Text("Member Two"),
              ),
              const ListTile(
                leading: FaIcon(FontAwesomeIcons.user, color: Colors.green),
                title: Text("Member Three"),
              ),
              const ListTile(
                leading: FaIcon(FontAwesomeIcons.user, color: Colors.green),
                title: Text("Member Four"),
              ),
              const SizedBox(height: 30),

              // Contact section
              const Text(
                "Contact Us",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Divider(),
              const ListTile(
                leading: FaIcon(FontAwesomeIcons.envelope, color: Colors.green),
                title: Text("egteamname@gmail.com"),
              ),
              const ListTile(
                leading: FaIcon(FontAwesomeIcons.phone, color: Colors.green),
                title: Text("Phone: +1 234 567 890"),
              ),
              const SizedBox(height: 30),

              // App details with icons
              const Text(
                "App Information",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Divider(),
              const ListTile(
                leading:
                    FaIcon(FontAwesomeIcons.circleInfo, color: Colors.green),
                title: Text("Version 1.0.0"),
              ),
              const ListTile(
                leading: FaIcon(FontAwesomeIcons.clock, color: Colors.green),
                title: Text("Last updated: September 2024"),
              ),
              const SizedBox(height: 30),

              // Footer with copyright and social media icons
              const Center(
                child: Text(
                  "© 2024 HissabKitaab. All rights reserved.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
                    SizedBox(width: 10),
                    FaIcon(FontAwesomeIcons.twitter, color: Colors.lightBlue),
                    SizedBox(width: 10),
                    FaIcon(FontAwesomeIcons.linkedin, color: Colors.blueAccent),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
