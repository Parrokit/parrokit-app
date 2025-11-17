import 'package:parrokit/mvp/recom/recom_view.dart';
import 'package:parrokit/mvp/recom/services/recommendation_service.dart';

class RecomPresenter {
  final RecommendationService service = RecommendationService();
  final RecomView view;

  RecomPresenter(this.view);
}
