import CoreML
import Foundation
import Flutter
// A struct to easily decode the ml_definitions2.json file
struct MLDefinitions: Codable {
    let success_labels: [String]
    let day_type_labels: [String]
}

class CoreMLManager {
    private let model: ADHD_Predictor?
    
    // Properties to hold the vocabularies and labels
    private var keywordVocab: [String: Int] = [:]
    private var medicationVocab: [String: Int] = [:]
    private var contentVocab: [String: Int] = [:]
    private var successLabels: [String] = []
    private var dayTypeLabels: [String] = []
    var initialized = false

    init() {
        // Load the Core ML model
        do {
            self.model = try ADHD_Predictor(configuration: MLModelConfiguration())
            self.initialized = true
            print("✅ Core ML model loaded successfully.")
        } catch {
            // Use fatalError because the app cannot function without the model.
            fatalError("❌ Error initializing Core ML model: \(error)")
        }
        
        // Load all necessary assets for preprocessing and post-processing
        loadDefinitions()
        self.keywordVocab = loadVocabulary(from: "vocab_keywords")
        self.medicationVocab = loadVocabulary(from: "vocab_medication")
        self.contentVocab = loadVocabulary(from: "vocab_content")
    }

    /// Loads and parses the ml_definitions2.json file from the app bundle.
    private func loadDefinitions() {
        guard let url = Bundle.main.url(forResource: "ml_definitions2", withExtension: "json") else {
            fatalError("FATAL: ml_definitions2.json not found in bundle.")
        }
        do {
            let data = try Data(contentsOf: url)
            let definitions = try JSONDecoder().decode(MLDefinitions.self, from: data)
            self.successLabels = definitions.success_labels
            self.dayTypeLabels = definitions.day_type_labels
            print("✅ Successfully loaded ML definitions.")
        } catch {
            fatalError("FATAL: Failed to load or parse ml_definitions2.json: \(error)")
        }
    }

    private func loadVocabulary(from fileName: String) -> [String: Int] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "txt"),
              let vocabString = try? String(contentsOf: url) else {
            fatalError("Vocabulary file \(fileName).txt not found.")
        }
        
        let words = vocabString.split(separator: "\n").map { String($0) }
        var vocabDict: [String: Int] = [:]
        for (index, word) in words.enumerated() {
            vocabDict[word] = index
        }
        return vocabDict
    }
    
    func predict(arguments: Any?, result: @escaping FlutterResult) {
        guard let model = self.model else {
            result(FlutterError(code: "MODEL_ERROR", message: "Core ML model not loaded.", details: nil))
            return
        }
        guard let model = self.model else {
                result(FlutterError(code: "MODEL_ERROR", message: "Core ML model not loaded.", details: nil))
                return
            }
            
            guard let args = arguments as? [String: Any] else {
                print("❌ PREDICTION FAILED: Arguments are not a valid dictionary.")
                result(FlutterError(code: "INVALID_ARGS", message: "Arguments are not a valid dictionary.", details: nil))
                return
            }

            // --- Individual Argument Checks with Logging ---
            
            guard let keywordblob = args["keywords"] as?  FlutterStandardTypedData else {
                print(args["keywords"])
                print("❌ PREDICTION FAILED: 'keywords' are missing or not a [Int].")
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid 'keywords' argument.", details: nil))
                return
            }
            
            guard let contentblob = args["content"] as? FlutterStandardTypedData else {
                print("❌ PREDICTION FAILED: 'content' is missing or not a [Int].")
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid 'content' argument.", details: nil))
                return
            }
            
            guard let medicationblob = args["medication"] as? FlutterStandardTypedData else {
                print("❌ PREDICTION FAILED: 'medication' is missing or not a [Int].")
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid 'medication' argument.", details: nil))
                return
            }
            
            guard let ratingblob = args["rating"] as? FlutterStandardTypedData else {
                print("❌ PREDICTION FAILED: 'rating' is missing or not a [Double].")
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid 'rating' argument.", details: nil))
                return
            }
            
            guard let sleepblob = args["sleep"] as? FlutterStandardTypedData else {
                print("❌ PREDICTION FAILED: 'sleep' is missing or not a [Double].")
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid 'sleep' argument.", details: nil))
                return
            }
          print("all things are good here")
        let kwInts = int32Array(from: keywordblob)
        let contentInts = int32Array(from: contentblob)
        let medicationInts = int32Array(from: medicationblob)
        let ratingDoubles = float32Array(from: ratingblob)
        let sleepDoubles = float32Array(from: sleepblob)
        //    print("✅ All arguments parsed successfully.")
        
        let kwNUMs = kwInts.map { NSNumber(value: $0)}
        let contentNUMs = contentInts.map { NSNumber(value: $0)}
        let medicationNUMs = medicationInts.map { NSNumber(value: $0)}
        let ratingnNUMs = ratingDoubles.map { NSNumber(value: $0)}
        let sleepNUMS = sleepDoubles.map { NSNumber(value: $0)}
        
        


        do {
            // Prepare inputs for the model
       

                    // Prepare inputs for the model
            let keywordInput = try toMLMultiArray(array:kwNUMs, shape: [1, 64])
            let contentInput = try toMLMultiArray(array: contentNUMs, shape: [1, 256])
            let medicationInput = try toMLMultiArray(array: medicationNUMs, shape: [1, 16])
            let ratingInput = try toMLMultiArray(array: ratingnNUMs, shape: [1, 1])
            let sleepInput = try toMLMultiArray(array: sleepNUMS, shape: [1, 1])
            // FIX: Corrected the argument order to match the model's definition
            let input = ADHD_PredictorInput(
                input_1_keywords: keywordInput,
                input_2_content: contentInput,
                input_5_medication: medicationInput, input_3_rating: ratingInput,
                input_4_sleep: sleepInput
            )
            
            // Get the raw prediction output
            let predictionOutput = try model.prediction(input: input)
            
            // FIX: Cleanly process the two separate outputs
            
            // 1. Get the raw logit outputs from the model
            // NOTE: The names 'success_logits' and 'day_type_logits' must match the output names
            // you see when inspecting the .mlpackage file in Xcode.
            let successLogitsMultiArray = predictionOutput.success_logits
            let dayTypeLogitsMultiArray = predictionOutput.day_type_logits

            // 2. Convert MLMultiArray to Swift arrays of Floats
            let successLogits = logits(from: successLogitsMultiArray)
            let dayTypeLogits = logits(from: dayTypeLogitsMultiArray)

            // 3. Find the winning class index for each task
            let successIndex = argmax(array: successLogits)
            let dayTypeIndex = argmax(array: dayTypeLogits)

            // 4. Map the index to the label string using the loaded labels
            let successPrediction = self.successLabels[successIndex]
            let dayTypePrediction = self.dayTypeLabels[dayTypeIndex]
            
            // 5. Get full probability dictionaries by applying softmax
            let successProbabilities = softmax(successLogits, labels: self.successLabels)
            let dayTypeProbabilities = softmax(dayTypeLogits, labels: self.dayTypeLabels)
            
            // 6. Return the structured results to Flutter
            let resultData: [String: Any] = [
                "success_prediction": successPrediction,
                "day_type_prediction": dayTypePrediction,
                "success_probabilities": successProbabilities,
                "day_type_probabilities": dayTypeProbabilities,
            ]
            result(resultData)
            
        } catch {
            result(FlutterError(code: "PREDICTION_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    // Convert Data to Int or float
    func int32Array(from blob: FlutterStandardTypedData) -> [Int32] {
        let count = blob.data.count / MemoryLayout<Int32>.size
        return blob.data.withUnsafeBytes { raw in
          Array(UnsafeBufferPointer(
            start: raw.bindMemory(to: Int32.self).baseAddress,
            count: count))
        }
      }
      func float32Array(from blob: FlutterStandardTypedData) -> [Float32] {
        let count = blob.data.count / MemoryLayout<Float32>.size
        return blob.data.withUnsafeBytes { raw in
          Array(UnsafeBufferPointer(
            start: raw.bindMemory(to: Float32.self).baseAddress,
            count: count))
        }
      }
    
    
    // --- Helper Functions ---
    private func intTokensToMLMultiArray(_ array: [Int], shape: [NSNumber]) throws -> MLMultiArray {
        let multiArray = try MLMultiArray(shape: shape, dataType: .float32) // Core ML often expects Int inputs as Floats
        for (index, element) in array.enumerated() {
            multiArray[index] = NSNumber(value: element)
        }
        return multiArray
    }
    private func doublesToMLMultiArray(_ array: [Double], shape: [NSNumber]) throws -> MLMultiArray {
        let multiArray = try MLMultiArray(shape: shape, dataType: .float32)
        for (index, element) in array.enumerated() {
            multiArray[index] = NSNumber(value: element)
        }
        return multiArray
    }
    private func dataToArray<T>(data: Data) -> [T] {
        return data.withUnsafeBytes { buffer in
            Array(buffer.bindMemory(to: T.self))
        }
    }
    private func toMLMultiArray<T: NSNumber>(array: [T], shape: [NSNumber], dataType: MLMultiArrayDataType = .float32) throws -> MLMultiArray {
        let multiArray = try MLMultiArray(shape: shape, dataType: dataType)
        for (index, element) in array.enumerated() {
            multiArray[index] = element
        }
        return multiArray
    }
    
    private func logits(from multiArray: MLMultiArray) -> [Float] {
        let pointer = multiArray.dataPointer.bindMemory(to: Float.self, capacity: multiArray.count)
        let buffer = UnsafeBufferPointer(start: pointer, count: multiArray.count)
        return Array(buffer)
    }
    
    private func argmax(array: [Float]) -> Int {
        if let maxVal = array.max(), let index = array.firstIndex(of: maxVal) {
            return index
        }
        return 0
    }

    private func softmax(_ logits: [Float], labels: [String]) -> [String: Float] {
        let maxLogit = logits.max() ?? 0
        let exps = logits.map { exp($0 - maxLogit) }
        let sumExps = exps.reduce(0, +)
        let probabilities = exps.map { $0 / sumExps }
        
        var probabilityDict: [String: Float] = [:]
        for (index, label) in labels.enumerated() {
            probabilityDict[label] = probabilities[index]
        }
        return probabilityDict
    }
}
