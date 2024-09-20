import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hisab_kitab/DAIkoUI/sgvicons.dart';
import 'package:hisab_kitab/pages/sign_in_page.dart';
import 'package:hisab_kitab/pages/sign_up_page.dart';
import 'package:hisab_kitab/reuseable_widgets/buttons.dart';
import 'package:hisab_kitab/reuseable_widgets/loading_incidator.dart';
import 'package:hisab_kitab/utils/constants/app_text_styles.dart';
import 'package:hisab_kitab/utils/constants/default_padding.dart';
import 'package:hisab_kitab/utils/constants/sgv_assets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isConnected = true;
  bool _isLoading = false; // Loading state variable
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    // Set up connectivity change listener
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _updateConnectionStatus(result);
      },
    );

    // Initial check of connectivity status
    _checkInitialConnectivity();
  }

  @override
  void dispose() {
    // Cancel subscription to avoid memory leaks
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkInitialConnectivity() async {
    setState(() {
      _isLoading = true; // Set loading state to true when checking connectivity
    });

    bool connected = false;
    // Keep retrying until a connection is established
    while (!connected) {
      try {
        // Check initial connectivity status
        var connectivityResult = await Connectivity().checkConnectivity();
        _updateConnectionStatus(connectivityResult);
        connected = _isConnected;
      } catch (e) {
        print('Connectivity check failed: $e');
        setState(() {
          _isConnected = false;
        });
      }

      // Add a small delay before retrying
      await Future.delayed(const Duration(seconds: 2));
    }

    setState(() {
      _isLoading = false; // Reset loading state once connected
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      // Update connection status based on result
      _isConnected = result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi;
    });
    print('Connection status: ${_isConnected ? 'Connected' : 'Not Connected'}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isConnected ? _buildConnectedUI() : _buildNoConnectionUI(),
    );
  }

  Widget _buildConnectedUI() {
    return SafeArea(
      child: DefaultPadding(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgIcon(
                assetName: SvgAssets.welcome,
                height: MediaQuery.of(context).size.height * 0.4,
              ),
              const Text(
                'Hey! Welcome',
                style: AppTextStyle.header,
              ),
              const SizedBox(height: 10),
              const Text(
                'Your one-stop destination for endless variety, and effortless shopping at your fingertips!',
                style: AppTextStyle.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              AppButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpPage(),
                    ),
                  );
                },
                label: 'Let’s Get Started',
              ),
              const SizedBox(height: 10),
              AppButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInPage(),
                    ),
                  );
                },
                label: 'I already have an account',
                labelColor: const Color.fromARGB(255, 17, 24, 39),
                isNegativeButton: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoConnectionUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.signal_wifi_off, size: 80),
          const SizedBox(height: 20),
          const Text(
            'No Connection',
            style: AppTextStyle.header,
          ),
          const SizedBox(height: 10),
          const Text(
            'Please check your internet connection and try again.',
            style: AppTextStyle.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          AppButton(
            onTap: _checkInitialConnectivity,
            label: 'Retry',
          ),
          const SizedBox(height: 20),
          // Show loading animation if isLoading is true
          if (_isLoading) const LoadingIndicator(),
        ],
      ),
    );
  }
}
