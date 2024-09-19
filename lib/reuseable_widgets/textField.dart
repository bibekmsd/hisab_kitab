import 'package:flutter/material.dart';
import 'package:hisab_kitab/utils/constants/appcolors.dart';
import 'package:hisab_kitab/utils/constants/app_text_styles.dart';

class AppInputField extends StatefulWidget {
  final String hint;
  final TextEditingController? controller;
  final Widget? widget;
  final Widget? prefixIcon;
  final Widget? suffixIcon; // Suffix icon property
  final VoidCallback? onTap;
  final bool isEmail;
  final bool isPassword;
  final FocusNode? focusNode;
  final Function(String)? onFieldSubmitted; // On field submitted
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted; // New onSubmitted property

  const AppInputField({
    super.key,
    this.focusNode,
    this.onFieldSubmitted,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon, // Include in the constructor
    required this.hint,
    this.isPassword = false,
    this.controller,
    this.widget,
    this.isEmail = false,
    this.onTap,
    this.onSubmitted, // Add to constructor
  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Center(
        child: TextFormField(
          onFieldSubmitted: (value) {
            if (widget.onSubmitted != null) {
              widget.onSubmitted!(value); // Call the onSubmitted function
            }
            if (widget.onFieldSubmitted != null) {
              widget.onFieldSubmitted!(value);
            }
          },
          focusNode: widget.focusNode,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textInputAction: widget.textInputAction,
          validator: (value) {
            if (widget.isEmail) {
              final emailValid = RegExp(
                r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
              ).hasMatch(value ?? '');
              if (!emailValid) {
                return 'Invalid email format';
              }
            }
            if (value == null || value.isEmpty) {
              return 'This field cannot be empty';
            }
            return null;
          },
          onTap: widget.onTap,
          autofocus: false,
          controller: widget.controller,
          obscureText: widget.isPassword && isObscure,
          style: AppTextStyle.body.copyWith(color: AppColors.blackColor),
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon,
            hintText: widget.hint,
            filled: true,
            fillColor: AppColors.whiteColor,
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isObscure = !isObscure;
                      });
                    },
                    icon: Icon(
                      isObscure ? Icons.visibility : Icons.visibility_off,
                      color:
                          AppColors.greyColor, // Adjust visibility icon color
                    ),
                    tooltip: isObscure ? 'Show password' : 'Hide password',
                  )
                : widget.suffixIcon, // Use the custom suffix icon if provided
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            hintStyle: AppTextStyle.caption.copyWith(
              color: AppColors.greyColor, // Adjust hint text color
            ),
          ),
        ),
      ),
    );
  }
}
