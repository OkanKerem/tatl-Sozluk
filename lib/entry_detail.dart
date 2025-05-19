import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:provider/provider.dart';
import 'package:tatli_sozluk/providers/entry_provider.dart';
import 'package:tatli_sozluk/providers/user_provider.dart';
import 'package:tatli_sozluk/providers/comment_provider.dart';
import 'package:tatli_sozluk/models/entry_model.dart';
import 'package:tatli_sozluk/models/comment_model.dart';

class EntryDetailPage extends StatefulWidget {
  final String entryId;
  
  const EntryDetailPage({super.key, required this.entryId});

  @override
  State<EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends State<EntryDetailPage> {
  bool isLoading = true;
  Entry? entry;
  final TextEditingController _commentController = TextEditingController();
  bool isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _loadEntryAndComments();
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadEntryAndComments() async {
    try {
      final entryProvider = Provider.of<EntryProvider>(context, listen: false);
      final commentProvider = Provider.of<CommentProvider>(context, listen: false);
      
      // Load entry
      final loadedEntry = await entryProvider.getEntryById(widget.entryId);
      
      // Load comments for the entry
      await commentProvider.loadComments(widget.entryId);
      
      if (mounted) {
        setState(() {
          entry = loadedEntry;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading entry: ${e.toString()}')),
        );
      }
    }
  }
  
  // Yorum ekleme fonksiyonu
  Future<void> _submitComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;
    
    setState(() {
      isSubmittingComment = true;
    });
    
    try {
      final commentProvider = Provider.of<CommentProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Use userId directly
      final success = await commentProvider.addComment(
        widget.entryId,
        commentText,
        userProvider.userId,
      );
      
      if (success && mounted) {
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding comment: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmittingComment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : entry == null
                ? const Center(child: Text('Entry not found'))
                : Column(
                    children: [
                      _buildTopBar(context),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            _buildEntry(),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Comments',
                                style: AppFonts.entriesLabelText.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildCommentsList(),
                          ],
                        ),
                      ),
                      _buildCommentInput(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pushReplacementNamed(context, '/main_page'),
      ),
      title: Text(
        'Entry Detail',
        style: AppFonts.entryTitleText.copyWith(
          color: Colors.black,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildEntry() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            entry!.title,
            style: AppFonts.entryTitleText.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            entry!.description,
            style: AppFonts.entryBodyText,
          ),
          const SizedBox(height: 20),
          
          // Author info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer<EntryProvider>(
                builder: (context, provider, child) {
                  final isLiked = entry!.likedBy.contains(provider.currentUserId);
                  return Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          provider.toggleLike(entry!.id);
                          // Update local entry state to show like status change immediately
                          setState(() {
                            if (isLiked) {
                              entry!.likedBy.remove(provider.currentUserId);
                            } else {
                              entry!.likedBy.add(provider.currentUserId);
                            }
                          });
                        },
                      ),
                      Text('${entry!.likedBy.length}'),
                    ],
                  );
                },
              ),
              FutureBuilder<Map<String, dynamic>?>(
                future: Provider.of<UserProvider>(context, listen: false).getUserById(entry!.author),
                builder: (context, snapshot) {
                  final authorName = snapshot.data?['nickname'] ?? 'Unknown User';
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the author's profile
                      Navigator.pushNamed(
                        context,
                        '/user_profile',
                        arguments: entry!.userId,
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'by $authorName',
                          style: AppFonts.usernameText.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommentsList() {
    return Consumer<CommentProvider>(
      builder: (context, commentProvider, child) {
        if (commentProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final comments = commentProvider.comments;
        
        if (comments.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'No comments yet. Be the first to comment!',
                style: AppFonts.entryBodyText.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return _buildCommentItem(comment);
          },
        );
      },
    );
  }
  
  Widget _buildCommentItem(Comment comment) {
    return Consumer2<CommentProvider, UserProvider>(
      builder: (context, commentProvider, userProvider, child) {
        final isLiked = comment.likedBy.contains(userProvider.userId);
        final isOwnComment = comment.userId == userProvider.userId;
        
        return FutureBuilder<Map<String, dynamic>?>(
          future: userProvider.getUserById(comment.author),
          builder: (context, snapshot) {
            final authorName = snapshot.data?['nickname'] ?? 'Unknown User';
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'by ',
                        style: AppFonts.entryBodyText.copyWith(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/user_profile',
                            arguments: comment.userId,
                          );
                        },
                        child: Text(
                          authorName,
                          style: AppFonts.usernameText.copyWith(
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (isOwnComment)
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Comment'),
                                content: const Text('Are you sure you want to delete this comment?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirm == true && mounted) {
                              await commentProvider.deleteComment(comment.id);
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    comment.text,
                    style: AppFonts.entryBodyText.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year}',
                        style: AppFonts.entryBodyText.copyWith(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              commentProvider.toggleLike(comment.id);
                            },
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.grey,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likedBy.length}',
                            style: AppFonts.entryBodyText.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                hintStyle: AppFonts.entryBodyText.copyWith(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: isSubmittingComment 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
                : const Icon(Icons.send, color: AppColors.primary),
            onPressed: isSubmittingComment ? null : _submitComment,
          ),
        ],
      ),
    );
  }
}