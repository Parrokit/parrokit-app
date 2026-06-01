import 'dart:io';
import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/features/community/shell/data/repositories/community_repository.dart';
import 'package:parrokit/features/community/shell/data/services/community_image_service.dart';
import 'package:parrokit/features/community/shell/domain/validators/post_validator.dart';

class EditPostUseCase {
  final CommunityRepository _repository;
  final CommunityImageService _imageService;

  EditPostUseCase(this._repository, this._imageService);

  Future<void> execute({
    required Post existingPost,
    required String title,
    required String content,
    required String category,
    required List<String> tags,
    required List<String> existingImageUrls,
    required List<File> newImageFiles,
    required String authorId,
    void Function(int current, int total, double progress)? onImageProgress,
  }) async {
    PostValidator.validateForCreate(
      title: title,
      content: content,
      category: category,
      tags: tags,
    );

    final deletedImageUrls =
        existingPost.imageUrls.where((url) => !existingImageUrls.contains(url)).toList();
    for (final url in deletedImageUrls) {
      await _imageService.deleteImageFromStorage(url);
    }

    List<String> newUploadedUrls = [];
    for (int i = 0; i < newImageFiles.length; i++) {
      final file = newImageFiles[i];
      final url = await _imageService.uploadImageToStorage(
        file,
        userId: authorId,
        postId: existingPost.id,
        onProgress: (progress) {
          if (onImageProgress != null) {
            onImageProgress(i + 1, newImageFiles.length, progress);
          }
        },
      );
      if (url != null) {
        newUploadedUrls.add(url);
      }
    }

    final finalImageUrls = [...existingImageUrls, ...newUploadedUrls];

    final updateData = {
      'title': title,
      'content': content,
      'category': category,
      'tags': tags,
      'hasImage': finalImageUrls.isNotEmpty,
      'imageUrls': finalImageUrls,
      'snippet': content.length > 50 ? '${content.substring(0, 50)}...' : content,
    };

    await _repository.updatePost(existingPost.id, updateData);
  }
}
