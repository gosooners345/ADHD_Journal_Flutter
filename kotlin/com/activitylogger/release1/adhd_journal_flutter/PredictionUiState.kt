// This can be in its own file or inside your ViewModel file
sealed class PredictionUiState {
    // 1. Before any prediction is requested
    object Idle : PredictionUiState()

    // 2. When the user has tapped "predict" and we are waiting
    object Loading : PredictionUiState()

    // 3. When the prediction comes back successfully
    data class Success(val predictions: Map<String, Double>) : PredictionUiState()

    // 4. When the prediction fails for any reason
    data class Error(val message: String) : PredictionUiState()
}