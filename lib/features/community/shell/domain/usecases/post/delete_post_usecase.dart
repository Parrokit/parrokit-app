import 'package:parrokit/data/models/post.dart';
import 'package:parrokit/features/community/shell/data/repositories/community_repository.dart';
import 'package:parrokit/features/community/shell/data/services/community_image_service.dart';

class DeletePostUseCase {
  final CommunityRepository _repository;
  final CommunityImageService _imageService;

  DeletePostUseCase(this._repository, this._imageService);

  Future<void> execute(Post postToDelete) async {
    if (postToDelete.hasImage) {
      for (final url in postToDelete.imageUrls) {
        await _imageService.deleteImageFromStorage(url);
      }
    }

    await _repository.deletePost(postToDelete.id);
  }
}
