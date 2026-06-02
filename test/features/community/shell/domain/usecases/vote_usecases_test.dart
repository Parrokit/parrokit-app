import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:parrokit/features/community/shell/domain/usecases/vote/vote_post_usecase.dart';
import 'mocks.mocks.dart';

void main() {
  late MockCommunityRepository mockRepository;

  setUp(() {
    mockRepository = MockCommunityRepository();
  });

  group('VoteUseCases', () {
    test('VotePostUseCase - 투표를 정상적으로 처리해야 한다', () async {
      final votePostUseCase = VotePostUseCase(mockRepository);

      when(mockRepository.votePost(any, any, any)).thenAnswer((_) async => {});

      await votePostUseCase.execute('post_123', 'user_1', 1);

      verify(mockRepository.votePost('post_123', 'user_1', 1)).called(1);
    });
  });
}
