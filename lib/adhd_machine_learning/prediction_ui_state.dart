abstract class PredictionUiState {}
class PredictionIdle extends PredictionUiState {}
class PredictionLoading extends PredictionUiState {}
class PredictionSuccess extends PredictionUiState { final Map<String, double> predictions; PredictionSuccess(this.predictions); }
class PredictionError extends PredictionUiState { final String message; PredictionError(this.message); }