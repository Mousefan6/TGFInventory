import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/bulletin_service.dart';
import '../../ui/theme/colors.dart';
import '../../ui/widgets/dashboard_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = BulletinService();

  List<Map<String, dynamic>> _bulletinPosts = [];
  bool _isLoading = true;
  bool _isPosting = false;
  Set<String> _deletingPosts = {};

  @override
  void initState() {
    super.initState();
    _fetchBulletins();
  }

  Future<void> _fetchBulletins() async {
    setState(() => _isLoading = true);

    try {
      final posts = await _apiService.readAllBulletinPosts();

      setState(() {
        _bulletinPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePost(Map<String, dynamic> post) async {
    final postId = post['ID'].toString();

    // Prevent duplicate deletes
    if (_deletingPosts.contains(postId)) return;

    setState(() {
      _deletingPosts.add(postId);
    });

    final success = await _apiService.deleteBulletinPost(post);

    if (!mounted) return;

    setState(() {
      _deletingPosts.remove(postId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Bulletin deleted!"
              : "Failed to delete bulletin.",
        ),
      ),
    );

    if (success) {
      await _fetchBulletins();
    }
  }

  void _showBulletinDetails(BuildContext context, String user, String formattedDate, String note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            if (formattedDate.isNotEmpty)
              Text(
                formattedDate,
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            note.isEmpty ? 'No description' : note,
            style: GoogleFonts.outfit(fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.greenButton),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _waitForBulletinUpdate() async {
    const maxAttempts = 10;
    const checkInterval = Duration(milliseconds: 500);

    for (int i = 0; i < maxAttempts; i++) {
      final posts = await _apiService.readAllBulletinPosts();

      if (posts.length != _bulletinPosts.length) {
        setState(() {
          _bulletinPosts = posts;
        });
        return;
      }

      await Future.delayed(checkInterval);
    }

    // Fallback refresh if it never detects the change
    _fetchBulletins();
  }
  Future<void> _showBulletinDialog() async {
    final homeContext = context;
    final nameController = TextEditingController();
    final noteController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isSubmitting = false;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: isSubmitting ? null : () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "USER",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: AppColors.greyText,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    TextField(
                      controller: nameController,
                      enabled: !isSubmitting,
                      decoration: InputDecoration(
                        hintText: "Your name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "NOTE",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: AppColors.greyText,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      enabled: !isSubmitting,
                      decoration: InputDecoration(
                        hintText: "Note",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenButton,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isPosting
                            ? null
                            : () async {
                          final user = nameController.text.trim();
                          final comment = noteController.text.trim();

                          if (user.isEmpty || comment.isEmpty) {
                            return;
                          }

                          setState(() {
                            _isPosting = true;
                          });

                          Navigator.pop(context);

                          final success = await _apiService.createBulletinPost(
                            user: user,
                            comment: comment,
                          );

                          if (!mounted) return;

                          ScaffoldMessenger.of(homeContext).showSnackBar(                            SnackBar(
                            content: Text(
                              success
                                  ? "Bulletin posted!"
                                  : "Failed to post bulletin.",
                            ),
                          ),
                          );

                          if (success) {
                            await _fetchBulletins();
                          }

                          setState(() {
                            _isPosting = false;
                          });
                        },

                        child: isSubmitting
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : Text(
                          "Post",
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDateTime(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final parsed = DateTime.parse(rawDate);
      final hour = parsed.hour > 12 ? parsed.hour - 12 : (parsed.hour == 0 ? 12 : parsed.hour);
      final period = parsed.hour >= 12 ? 'PM' : 'AM';
      final minute = parsed.minute.toString().padLeft(2, '0');

      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final month = months[parsed.month - 1];

      return '$month ${parsed.day}, ${parsed.year} - $hour:$minute $period';
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Image.asset(
                "assets/images/TGFLogo.png",
                height: 70,
              ),

              const SizedBox(height: 10),

              Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      "Bulletin",
                      style: GoogleFonts.outfit(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 45,
                      width: 45,
                      child: FloatingActionButton(
                        elevation: 0,
                        backgroundColor: Colors.white,
                        onPressed: _showBulletinDialog,
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _bulletinPosts.isEmpty
                      ? Center(
                    child: Text(
                      "Bulletin posts will appear here.",
                      style: GoogleFonts.outfit(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                  )
                      : ListView.builder(
                    itemCount: _bulletinPosts.length,
                    itemBuilder: (context, index) {
                      final post = _bulletinPosts[index];
                      final userName = post['User'] ?? 'Unknown User';
                      final userNote = post['Comment'] ?? '';
                      final rawTimestamp = post['Timestamp'];
                      final formattedDate = _formatDateTime(rawTimestamp);
                      final postId = post['ID'].toString();
                      final isDeleting = _deletingPosts.contains(postId);

                      return Card(
                        elevation: 0,
                        color: AppColors.background,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          userName,
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.greyText,
                                          ),
                                        ),
                                        if (formattedDate.isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              "•  $formattedDate",
                                              style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: isDeleting
                                        ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                        : const Icon(
                                      Icons.close,
                                      size: 26,
                                      color: Colors.red,
                                    ),
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    onPressed: isDeleting
                                        ? null
                                        : () => _deletePost(post),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _showBulletinDetails(context, userName, formattedDate, userNote),
                                child: Text(
                                  userNote,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: DashboardCard(
                  width: 150,
                  height: 130,
                  title: "Low Stock!",
                  value: "4",
                  valueColor: AppColors.red,
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}