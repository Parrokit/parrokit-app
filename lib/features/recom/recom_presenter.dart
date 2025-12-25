import 'package:parrokit/features/recom/recom_view.dart';
import 'package:parrokit/features/recom/services/recommendation_service.dart';

class RecomPresenter {
  final RecommendationService service = RecommendationService();
  final RecomView view;

  RecomPresenter(this.view);
}
