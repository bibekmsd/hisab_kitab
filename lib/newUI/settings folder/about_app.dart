import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App logo
              Center(
                child: CircleAvatar(
                  radius: 50,
                  child: FaIcon(
                    FontAwesomeIcons.store,
                    size: 50,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // App name and description section
              Center(
                child: Text(
                  "Hisab Kitab",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  "An effortless billing and inventory management for local retail and departmental stores.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 30),

              // Team section with icons
              Text(
                "Our Team",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Divider(),
              SizedBox(height: 10),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.user),
                title: Text("Anup Aryal"),
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.user),
                title: Text("Baibhav Singh"),
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.user),
                title: Text("Bibek Gautam"),
              ),

              SizedBox(height: 30),

              // Contact section
              Text(
                "Contact Us",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Divider(),
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.envelope,
                ),
                title: Text("hisabkitab@gmail.com"),
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.phone),
                title: Text("Phone: +977 9012230424"),
              ),
              SizedBox(height: 30),

              // App details with icons
              Text(
                "App Information",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Divider(),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.circleInfo),
                title: Text("Version 1.0.0"),
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.clock),
                title: Text("Last updated: September 2024"),
              ),
              SizedBox(height: 30),

              // Footer with copyright and social media icons
              Center(
                child: Text(
                  "© 2024 HissabKitaab. All rights reserved.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              Center(
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
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
