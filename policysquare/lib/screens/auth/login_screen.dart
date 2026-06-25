import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:policysquare/providers/commercial_provider.dart';
import 'package:policysquare/api/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isLoginMode = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: 'Enter your ${label.toLowerCase()}',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
            suffixIcon: suffixIcon,
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF0F4F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide:
                  const BorderSide(color: Color(0xFF0D9488), width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          if (isLargeScreen)
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF05111E), Color(0xFF0C383F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/images/RiskGo.png',
                                height: 48,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.shield,
                                        color: Color(0xFF0F172A))),
                            const SizedBox(width: 8),
                            const Text(
                              'RiskGo',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                letterSpacing: -1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Enterprise Risk\nIntelligence',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: -1.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'The premiere platform for commercial risk assessment\ninspections. Built for maximum efficiency and security.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TRUSTED BY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: Color(0xFF0EA5E9),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                      width: 24,
                                      height: 24,
                                      color: Colors.white24),
                                  const SizedBox(width: 16),
                                  Container(
                                      width: 24,
                                      height: 24,
                                      color: Colors.white24),
                                  const SizedBox(width: 16),
                                  Container(
                                      width: 24,
                                      height: 24,
                                      color: Colors.white24),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD8DEE9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                        'assets/images/SHAREINDIA.png',
                                        height: 36),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'SHARE ',
                                        style: TextStyle(
                                          color: Color(0xFF0075C4),
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'INDIA',
                                        style: TextStyle(
                                          color: Color(0xFFED1C24),
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 120.0 : 32.0,
                vertical: 48.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isLargeScreen) ...[
                    Center(
                        child: Image.asset('assets/images/RiskGo.png',
                            height: 80,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.shield,
                                    color: Color(0xFF0F172A), size: 48))),
                    const SizedBox(height: 12),
                    const Text(
                      'RiskGo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  Text(
                    _isLoginMode ? 'Welcome back' : 'Create an account',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLoginMode
                        ? 'Access your risk assessment dashboard.'
                        : 'Sign up to get started with RiskGo.',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildTextField(
                    controller: _usernameController,
                    label: 'Username',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _isLoginMode
                        ? const SizedBox.shrink()
                        : Column(
                            key: const ValueKey('signup_fields'),
                            children: [
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email address',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _mobileController,
                                label: 'Mobile Number',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                  ),

                  if (_isLoginMode)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: Color(0xFF0D9488),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (_isLoginMode) const SizedBox(height: 8),

                  if (!_isLoginMode)
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                    )
                  else
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8), letterSpacing: 2.0),
                        prefixIcon: const Icon(Icons.lock_outline,
                            size: 20, color: Color(0xFF64748B)),
                        suffixIcon: const Icon(Icons.visibility_outlined,
                            size: 20, color: Color(0xFF0F172A)),
                        filled: true,
                        fillColor: const Color(0xFFF0F4F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                              color: Color(0xFF0D9488), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                      ),
                    ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _isLoginMode
                        ? const SizedBox.shrink()
                        : Column(
                            key: const ValueKey('confirm_password'),
                            children: [
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _confirmPasswordController,
                                label: 'Confirm Password',
                                icon: Icons.lock_outline,
                                obscureText: true,
                              ),
                            ],
                          ),
                  ),

                  if (_isLoginMode) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: Checkbox(
                            value: false,
                            onChanged: (v) {},
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Stay signed in for 30 days',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF475569))),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLoginMode ? 'Sign in' : 'Create Account',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (_isLoginMode) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 18),
                              ]
                            ],
                          ),
                  ),

                  // Removed SSO and Passkey buttons here

                  const SizedBox(height: 48),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLoginMode
                            ? "Don't have an account yet? "
                            : 'Already have an account? ',
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: _switchMode,
                        child: Text(
                          _isLoginMode ? 'Create an account' : 'Sign in',
                          style: const TextStyle(
                            color: Color(0xFF0D9488),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_isLoginMode) ...[
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('© 2026 RiskGo Intelligence',
                            style: TextStyle(
                                color: Color(0xFF94A3B8), fontSize: 11)),
                        Row(
                          children: const [
                            Text('Privacy',
                                style: TextStyle(
                                    color: Color(0xFF94A3B8), fontSize: 11)),
                            SizedBox(width: 16),
                            Text('Terms',
                                style: TextStyle(
                                    color: Color(0xFF94A3B8), fontSize: 11)),
                            SizedBox(width: 16),
                            Text('Security',
                                style: TextStyle(
                                    color: Color(0xFF94A3B8), fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (!_isLoginMode) {
      final email = _emailController.text.trim();
      final mobile = _mobileController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      if (email.isEmpty || mobile.isEmpty || confirmPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
        return;
      }

      if (mobile.length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid mobile number')),
        );
        return;
      }

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      Map<String, dynamic> result;

      if (_isLoginMode) {
        result = await authService.login(username, password);
      } else {
        final email = _emailController.text.trim();
        final mobile = _mobileController.text.trim();
        result = await authService.signup(username, email, mobile, password);
      }

      final String token = result['token'];
      final String returnedMobile = result['mobileNumber'];
      final String returnedUsername = result['username'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      await prefs.setString('mobile_number', returnedMobile);
      await prefs.setString('username', returnedUsername);

      if (mounted) {
        final provider = context.read<CommercialProvider>();
        await provider.loadMobileNumber();

        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pushReplacementNamed(context, '/inspection');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication Failed: \n$e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }
}
