import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/datasources/remote/firebase_storage_datasource.dart';
import '../../../data/datasources/remote/firestore_datasource.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/theme_provider.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/orders_history_widget.dart';
import '../widgets/profile_info_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploadingAvatar = false;

  Future<void> _changeAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null || !mounted) return;

    setState(() => _uploadingAvatar = true);
    try {
      final auth = context.read<AuthProvider>();
      final uid = auth.user!.uid;
      final file = File(picked.path);

      // Upload to Firebase Storage
      final storage = FirebaseStorageDatasourceImpl();
      final url = await storage.uploadProfileImage(uid, file);

      // Update Firestore
      final firestore = FirestoreDatasourceImpl();
      await firestore.updateUser(uid, {'photoUrl': url});

      // Update local provider
      final updated = auth.user!.copyWith(photoUrl: url);
      auth.updateUser(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar actualizado correctamente'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar avatar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _loadOrders() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    await context.read<OrderProvider>().loadOrders(auth.user!.uid);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.user;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar with gradient ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Avatar
                    Stack(
                      children: [
                        AvatarWidget(
                          photoUrl: user?.photoUrl,
                          radius: 46,
                          isLoading: _uploadingAvatar,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _uploadingAvatar ? null : _changeAvatar,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.primary, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_outlined,
                                  size: 15, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Info card ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: ProfileInfoCard(user: user),
            ),
          ),

          // ── Settings tiles ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Card(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      label: AppStrings.notifications,
                      onTap: () => context.push(AppRoutes.notifications),
                    ),
                    const Divider(height: 1, indent: 56),
                    SwitchListTile(
                      secondary: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.dark_mode_outlined,
                            color: AppColors.primary, size: 20),
                      ),
                      title: const Text(AppStrings.darkMode),
                      value: themeProvider.isDark,
                      onChanged: (_) => themeProvider.toggleTheme(),
                      activeColor: AppColors.primary,
                    ),
                    const Divider(height: 1, indent: 56),
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      label: AppStrings.signOut,
                      color: AppColors.error,
                      onTap: () async {
                        await context.read<AuthProvider>().signOut();
                        if (context.mounted) context.go(AppRoutes.login);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Orders history ───────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Mis pedidos',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins'),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: OrdersHistoryWidget(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── Settings Tile ──────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? AppColors.primary;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: tileColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: tileColor, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins'),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: AppColors.textHint, size: 20),
      onTap: onTap,
    );
  }
}
