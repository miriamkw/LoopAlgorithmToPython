//
//  LoopAlgorithmToPython.swift
//  LoopAlgorithm
//
//  Created by Miriam K. Wolff on 24/06/2024.
//

import Foundation
import LoopAlgorithm
/* ORIGINAL CODE COMMENTED OUT
#if os(Linux)
func handleException(signal: Int32) {
    print("Uncaught signal: \(signal)")

    // Generate a stack trace
    let symbols = Thread.callStackSymbols
    print("Stack trace:")
    for symbol in symbols {
        print(symbol)
    }

    // Exit the program with the signal code
    exit(signal)
}

@_cdecl("initializeExceptionHandler")
public func initializeExceptionHandler() {
    signal(SIGILL, handleException)
    signal(SIGABRT, handleException)
    signal(SIGFPE, handleException)
    signal(SIGSEGV, handleException)
    signal(SIGBUS, handleException)
    signal(SIGTRAP, handleException)
}

#else
func handleException(exception: NSException) {
    print("Uncaught exception: \(exception.description)")
    print("Stack trace: \(exception.callStackSymbols.joined(separator: "\n"))")
}

@_cdecl("initializeExceptionHandler")
public func initializeExceptionHandler() {
    NSSetUncaughtExceptionHandler(handleException)
}
#endif

func signalHandler(signal: Int32) {
    print("Received signal: \(signal)")

    // Generate a stack trace
    let symbols = Thread.callStackSymbols
    print("Stack trace:")
    for symbol in symbols {
        print(symbol)
    }

    // Exit the program with the signal code
    exit(signal)
}

@_cdecl("initializeSignalHandlers")
public func initializeSignalHandlers() {
    signal(SIGTRAP, signalHandler)
    signal(SIGSEGV, signalHandler)
    signal(SIGABRT, signalHandler)
    signal(SIGILL, signalHandler)
    signal(SIGFPE, signalHandler)
    // Add other signals as needed
}
*/
// ===== NEW CROSS-PLATFORM IMPLEMENTATION =====

#if os(macOS) || os(iOS)
// macOS/iOS: Full NSException and POSIX signal support
func handleException(exception: NSException) {
    print("Uncaught exception: \(exception.description)")
    print("Stack trace: \(exception.callStackSymbols.joined(separator: "\n"))")
}

@_cdecl("initializeExceptionHandler")
public func initializeExceptionHandler() {
    NSSetUncaughtExceptionHandler(handleException)
}

func signalHandler(signal: Int32) {
    print("Received signal: \(signal)")
    let symbols = Thread.callStackSymbols
    print("Stack trace:")
    for symbol in symbols {
        print(symbol)
    }
    exit(signal)
}

@_cdecl("initializeSignalHandlers")
public func initializeSignalHandlers() {
    signal(SIGTRAP, signalHandler)
    signal(SIGSEGV, signalHandler)
    signal(SIGABRT, signalHandler)
    signal(SIGILL, signalHandler)
    signal(SIGFPE, signalHandler)
    signal(SIGBUS, signalHandler)
}

#elseif os(Linux)
// Linux: POSIX signals only (no NSException)
func signalHandler(signal: Int32) {
    print("Uncaught signal: \(signal)")
    let symbols = Thread.callStackSymbols
    print("Stack trace:")
    for symbol in symbols {
        print(symbol)
    }
    exit(signal)
}

@_cdecl("initializeExceptionHandler")
public func initializeExceptionHandler() {
    signal(SIGILL, signalHandler)
    signal(SIGABRT, signalHandler)
    signal(SIGFPE, signalHandler)
    signal(SIGSEGV, signalHandler)
    signal(SIGBUS, signalHandler)
    signal(SIGTRAP, signalHandler)
}

@_cdecl("initializeSignalHandlers")
public func initializeSignalHandlers() {
    signal(SIGTRAP, signalHandler)
    signal(SIGSEGV, signalHandler)
    signal(SIGABRT, signalHandler)
    signal(SIGILL, signalHandler)
    signal(SIGFPE, signalHandler)
    signal(SIGBUS, signalHandler)
}

#elseif os(Windows)
// Windows: Limited signal support (SIGABRT, SIGFPE, SIGILL, SIGINT, SIGSEGV, SIGTERM)
func signalHandler(signal: Int32) {
    print("Received signal: \(signal)")
    print("Stack trace: (limited on Windows)")
    exit(signal)
}

@_cdecl("initializeExceptionHandler")
public func initializeExceptionHandler() {
    print("Exception handlers initialized (Windows - limited support)")
    // Windows doesn't support all POSIX signals
    signal(SIGABRT, signalHandler)
    signal(SIGFPE, signalHandler)
    signal(SIGILL, signalHandler)
    signal(SIGSEGV, signalHandler)
}

@_cdecl("initializeSignalHandlers")
public func initializeSignalHandlers() {
    print("Signal handlers initialized (Windows - limited support)")
    signal(SIGABRT, signalHandler)
    signal(SIGFPE, signalHandler)
    signal(SIGILL, signalHandler)
    signal(SIGSEGV, signalHandler)
}

#else
// Other platforms: Stub implementations
@_cdecl("initializeExceptionHandler")
public func initializeExceptionHandler() {
    print("Exception handlers not supported on this platform")
}

@_cdecl("initializeSignalHandlers")
public func initializeSignalHandlers() {
    print("Signal handlers not supported on this platform")
}
#endif

// ===== END PLATFORM-SPECIFIC SECTION =====

@_cdecl("generatePrediction") // Use @_cdecl to expose the function with a C-compatible name
public func generatePrediction(jsonData: UnsafePointer<Int8>?) -> UnsafeMutablePointer<Double> {
    // TODO: Add opportunity to get prediction effects from only one factor at a time
    
    // Enhanced input validation
    guard let jsonData = jsonData else {
        print("ERROR: generatePrediction - NULL JSON data pointer provided")
        fatalError("generatePrediction failed: NULL JSON data pointer provided")
    }
    
    let jsonLength = strlen(jsonData)
    guard jsonLength > 0 else {
        print("ERROR: generatePrediction - Empty JSON data provided (length: \(jsonLength))")
        fatalError("generatePrediction failed: Empty JSON data provided")
    }
        
    let data: Data
    do {
        data = getDataFromJson(jsonData: jsonData)
    } catch {
        print("ERROR: generatePrediction - Failed to convert JSON pointer to Data: \(error)")
        print("ERROR: generatePrediction - JSON string (first 200 chars): \(String(cString: jsonData).prefix(200))")
        fatalError("generatePrediction failed: JSON data conversion error - \(error)")
    }

    do {
        // Decode JSON data with enhanced error reporting
        let input = try getDecoder().decode(LoopPredictionInput.self, from: data)       
        
        guard !input.glucoseHistory.isEmpty else {
            print("ERROR: generatePrediction - Empty glucose history provided")
            fatalError("generatePrediction failed: Empty glucose history in input data")
        }

        let startDate = input.glucoseHistory.last?.startDate ?? Date()
               
        let prediction = LoopAlgorithm.generatePrediction(
            start: startDate,
            glucoseHistory: input.glucoseHistory,
            doses: input.doses,
            carbEntries: input.carbEntries,
            basal: input.basal,
            sensitivity: input.sensitivity,
            carbRatio: input.carbRatio,
            algorithmEffectsOptions: .all, // Here we can adjust which predictive factor to output
            useIntegralRetrospectiveCorrection: input.useIntegralRetrospectiveCorrection,
            includingPositiveVelocityAndRC: input.includePositiveVelocityAndRC,
        )
        
        
        var predictedValues: [Double] = []
                
        for val in prediction.glucose {
            predictedValues.append(val.quantity.doubleValue(for: LoopUnit(from: "mg/dL")))
        }
        
        guard !predictedValues.isEmpty else {
            print("ERROR: generatePrediction - No predicted values generated")
            fatalError("generatePrediction failed: Algorithm generated empty prediction result")
        }

        let pointer = UnsafeMutablePointer<Double>.allocate(capacity: predictedValues.count)
        pointer.initialize(from: predictedValues, count: predictedValues.count)
        
        return pointer
    } catch let decodingError as DecodingError {
        print("ERROR: generatePrediction - JSON decoding failed:")
        switch decodingError {
        case .dataCorrupted(let context):
            print("  - Data corrupted: \(context.debugDescription)")
            print("  - Coding path: \(context.codingPath)")
        case .keyNotFound(let key, let context):
            print("  - Key not found: \(key.stringValue)")
            print("  - Context: \(context.debugDescription)")
            print("  - Coding path: \(context.codingPath)")
        case .typeMismatch(let type, let context):
            print("  - Type mismatch: expected \(type)")
            print("  - Context: \(context.debugDescription)")
            print("  - Coding path: \(context.codingPath)")
        case .valueNotFound(let type, let context):
            print("  - Value not found: expected \(type)")
            print("  - Context: \(context.debugDescription)")
            print("  - Coding path: \(context.codingPath)")
        @unknown default:
            print("  - Unknown decoding error: \(decodingError)")
        }
        print("ERROR: generatePrediction - JSON content (first 500 chars): \(String(data: data, encoding: .utf8)?.prefix(500) ?? "Unable to convert to string")")
        fatalError("generatePrediction failed: JSON decoding error - \(decodingError)")
    } catch {
        print("ERROR: generatePrediction - Unexpected error during prediction generation:")
        print("  - Error type: \(type(of: error))")
        print("  - Error description: \(error)")
        print("  - JSON content (first 500 chars): \(String(data: data, encoding: .utf8)?.prefix(500) ?? "Unable to convert to string")")
        fatalError("generatePrediction failed: Unexpected error - \(error)")
    }
}

@_cdecl("getPredictionDates")
public func getPredictionDates(jsonData: UnsafePointer<Int8>?) -> UnsafePointer<CChar> {
    let data = getDataFromJson(jsonData: jsonData)

    do {
        let input = try getDecoder().decode(LoopPredictionInput.self, from: data)

        let prediction = LoopAlgorithm.generatePrediction(
            start: input.glucoseHistory.last?.startDate ?? Date(),
            glucoseHistory: input.glucoseHistory,
            doses: input.doses,
            carbEntries: input.carbEntries,
            basal: input.basal,
            sensitivity: input.sensitivity,
            carbRatio: input.carbRatio,
            algorithmEffectsOptions: .all,
            useIntegralRetrospectiveCorrection: input.useIntegralRetrospectiveCorrection
        )
        // Prepare prediction dates as a comma-separated string
        var predictionDates: String = ""
        for val in prediction.glucose {
            predictionDates += val.startDate.ISO8601Format() + ","
        }
        let cString = strdup(predictionDates)!
                
        return UnsafePointer<CChar>(cString)
    } catch {
        fatalError("Error reading or decoding JSON file: \(error)")
    }
}

@_cdecl("getDoseRecommendations")
public func getDoseRecommendations(jsonData: UnsafePointer<Int8>?) -> UnsafeMutablePointer<CChar> {
    let data = getDataFromJson(jsonData: jsonData)

    do {
        let input = try getDecoder().decode(AlgorithmInputFixture.self, from: data)
        let output = LoopAlgorithm.run(input: input)
        let recommendation = output.recommendationResult
        var result: LoopAlgorithmDoseRecommendation?
        
        switch recommendation {
            case .success(let res):
                result = res
            case .failure(let e):
                print(e)
        }
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(result)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                // Use strdup to create a mutable C-style string
                if let cString = strdup(jsonString) {
                    return cString // Return the mutable pointer directly
                } else {
                    fatalError("Failed to allocate memory for C-String.")
                }
            }
        } catch {
            print("Error encoding JSON: \(error)")
        }
    } catch {
        fatalError("Error reading or decoding JSON file: \(error)")
    }
    
    // If the function reaches here, return an empty C-string
    return strdup("")!
}

@_cdecl("getGlucoseEffectVelocity") // Use @_cdecl to expose the function with a C-compatible name
public func getGlucoseEffectVelocity(jsonData: UnsafePointer<Int8>?) -> UnsafeMutablePointer<Double> {
    let data = getDataFromJson(jsonData: jsonData)

    do {
        // Decode JSON data
        let input = try getDecoder().decode(LoopPredictionInput.self, from: data)
        
        let prediction = LoopAlgorithm.generatePrediction(
            start: input.glucoseHistory.last?.startDate ?? Date(),
            glucoseHistory: input.glucoseHistory,
            doses: input.doses,
            carbEntries: input.carbEntries,
            basal: input.basal,
            sensitivity: input.sensitivity,
            carbRatio: input.carbRatio,
            algorithmEffectsOptions: .all, // Here we can adjust which predictive factor to output
            useIntegralRetrospectiveCorrection: input.useIntegralRetrospectiveCorrection
        )
        var glucoseEffectVelocities: [Double] = []
                
        for val in prediction.effects.insulinCounteraction {
            glucoseEffectVelocities.append(val.quantity.doubleValue(for: LoopUnit(from: "mg/dL·s")))
        }
        let pointer = UnsafeMutablePointer<Double>.allocate(capacity: glucoseEffectVelocities.count)
        pointer.initialize(from: glucoseEffectVelocities, count: glucoseEffectVelocities.count)
                
        return pointer
    } catch {
        fatalError("Error reading or decoding JSON file: \(error)")
    }
}

@_cdecl("getGlucoseEffectVelocityDates")
public func getGlucoseEffectVelocityDates(jsonData: UnsafePointer<Int8>?) -> UnsafePointer<CChar> {
    let data = getDataFromJson(jsonData: jsonData)
    
    do {
        let input = try getDecoder().decode(LoopPredictionInput.self, from: data)
                            
        let prediction = LoopAlgorithm.generatePrediction(
            start: input.glucoseHistory.last?.startDate ?? Date(),
            glucoseHistory: input.glucoseHistory,
            doses: input.doses,
            carbEntries: input.carbEntries,
            basal: input.basal,
            sensitivity: input.sensitivity,
            carbRatio: input.carbRatio,
            algorithmEffectsOptions: .all,
            useIntegralRetrospectiveCorrection: input.useIntegralRetrospectiveCorrection
        )
        
        // Prepare prediction dates as a comma-separated string
        var predictionDates: String = ""
        for val in prediction.effects.insulinCounteraction {
            predictionDates += val.startDate.ISO8601Format() + ","
        }
        let cString = strdup(predictionDates)!
        return UnsafePointer<CChar>(cString)
    } catch {
        print("Error reading or decoding JSON file: \(error)")
        fatalError("Error reading or decoding JSON file: \(error)")
    }
}

@_cdecl("getGlucoseEffectVelocityAndDates")
public func getGlucoseEffectVelocityAndDates(jsonData: UnsafePointer<Int8>?) -> UnsafePointer<CChar> {
    let data = getDataFromJson(jsonData: jsonData)

    do {
        let input = try getDecoder().decode(AlgorithmInputFixture.self, from: data)
        let output = LoopAlgorithm.run(input: input)

        // Prepare prediction dates as a comma-separated string
        var predictionsAndDates: String = ""
        for val in output.effects.insulinCounteraction {
            predictionsAndDates += val.startDate.ISO8601Format() + ","
            predictionsAndDates += val.quantity.doubleValue(for: HKUnit(from: "mg/dL·s")).description + " "
        }
        let cString = strdup(predictionsAndDates)!
        
        return UnsafePointer<CChar>(cString)

    } catch {
        fatalError("Error reading or decoding JSON file: \(error)")
    }
}

@_cdecl("getActiveCarbs")
public func getActiveCarbs(jsonData: UnsafePointer<Int8>?) -> Double {
    let data = getDataFromJson(jsonData: jsonData)

    do {
        let input = try getDecoder().decode(AlgorithmInputFixture.self, from: data)
        let output = LoopAlgorithm.run(input: input)
        return output.activeCarbs!
    } catch {
        fatalError("Error reading or decoding JSON file: \(error)")
    }
}


@_cdecl("getActiveInsulin")
public func getActiveInsulin(jsonData: UnsafePointer<Int8>?) -> Double {
    let data = getDataFromJson(jsonData: jsonData)

    do {
        let input = try getDecoder().decode(AlgorithmInputFixture.self, from: data)
        let dosesRelativeToBasal = input.doses.annotated(with: input.basal)
        let activeInsulin = dosesRelativeToBasal.insulinOnBoard(at: input.predictionStart)
        return activeInsulin
    } catch {
        fatalError("Error reading or decoding JSON file: \(error)")
    }
}

@_cdecl("insulinPercentEffectRemaining")
public func insulinPercentEffectRemaining(jsonData: UnsafePointer<Int8>?) -> Double {
    let data = getDataFromJson(jsonData: jsonData)

    do {
        let input = try getDecoder().decode(InsulinPercentEffectInput.self, from: data)
        
        let actionDuration = TimeInterval(input.actionDuration * 60)
        let peakActivityTime = TimeInterval(input.peakActivityTime * 60)
        let delay = TimeInterval(input.delay * 60)
        let minutes = TimeInterval(input.minutes * 60)
        
        let model = ExponentialInsulinModel(actionDuration: actionDuration, peakActivityTime: peakActivityTime, delay: delay)
        return model.percentEffectRemaining(at: minutes)
    } catch {
        fatalError("Error reading or decoding JSON file: \(error)")
    }
}

@_cdecl("getLoopRecommendations") // Use @_cdecl to expose the function with a C-compatible name
public func getLoopRecommendations(jsonData: UnsafePointer<Int8>?) -> UnsafePointer<CChar> {
    let data: Data = getDataFromJson(jsonData: jsonData)

    do {
        let input = try getDecoder().decode(AlgorithmInputFixture.self, from: data)
        let output = LoopAlgorithm.run(input: input)
        let result = output.recommendationResult
        
        var data: LoopAlgorithmDoseRecommendation?

        switch result {
            case .success(let resp_data):
                data = resp_data
            case .failure(let e):
                print("FAIL")
                print(e)
        }
        
        let encoder: JSONEncoder = JSONEncoder()

        do {
            // Encode JSON data
            let jsonData = try encoder.encode(data)

            // Convert JSON data to string
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let cString: UnsafeMutablePointer<CChar> = strdup(jsonString)!
                return UnsafePointer<CChar>(cString)
            }

        } catch {
            print("Error encoding JSON: \(error)")
        }
      
    } catch {
        fatalError("Error reading or decoding JSON file: \(error)")
    }
    let cString: UnsafeMutablePointer<CChar> = strdup("")!
    return UnsafePointer<CChar>(cString)
}

@_cdecl("percentAbsorptionAtPercentTime")
public func percentAbsorptionAtPercentTime(_ percentTime: Double) -> Double {
    return PiecewiseLinearAbsorption().percentAbsorptionAtPercentTime(percentTime)
}

@_cdecl("percentRateAtPercentTime")
public func percentRateAtPercentTime(_ percentTime: Double) -> Double {
    return PiecewiseLinearAbsorption().percentRateAtPercentTime(percentTime)
}

@_cdecl("linearPercentRateAtPercentTime")
public func linearPercentRateAtPercentTime(_ percentTime: Double) -> Double {
    return LinearAbsorption().percentRateAtPercentTime(percentTime)
}

@_cdecl("getDynamicCarbsOnBoard")
public func getDynamicCarbsOnBoard(jsonData: UnsafePointer<Int8>?) -> Double {
    let data = getDataFromJson(jsonData: jsonData)

    do {
        let input = try getDecoder().decode(DynamicCarbsData.self, from: data)

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime, .withDashSeparatorInDate]

        let inputICE = loadICEInputFixture(from: input.inputICE)
        let carbEntries = loadCarbEntryFixture(from: encodeCarbValuesToJsonData(carbValues: input.carbEntries)!)

        let startDate = dateFormatter.date(from: input.inputICE[0].startAt)!
        let endDate = dateFormatter.date(from: input.inputICE.last!.startAt)!
        let carbRatio = [AbsoluteScheduleValue(startDate: startDate, endDate: endDate, value: input.carbRatio)]
        let isf =  [AbsoluteScheduleValue(startDate: startDate, endDate: endDate, value: LoopQuantity(unit: LoopUnit(from: "mg/dL"), doubleValue: input.sensitivity))]

        let statuses = [carbEntries[0]].map(
            to: inputICE,
            carbRatio: carbRatio,
            insulinSensitivity: isf,
            initialAbsorptionTimeOverrun: 2.0,
            absorptionModel: PiecewiseLinearAbsorption()
        )
        // TODO: Add a function for different absorbrionmodels

        // The output here is a list of CarbValues with startDate, endDate (equal to startDate), and value (ICE?)
        let carbsOnBoard = statuses.dynamicCarbsOnBoard(
            from: inputICE[0].startDate,
            to: inputICE[0].startDate.addingTimeInterval(TimeInterval(60*60*6)),
            absorptionModel: PiecewiseLinearAbsorption())

        return carbsOnBoard.first?.value ?? 100.0
    } catch {
        fatalError("Error reading or decoding JSON file: \(error)")
    }
}

func getDataFromJson(jsonData: UnsafePointer<Int8>?) -> Data {
    guard let jsonData = jsonData else {
        fatalError("No JSON data provided")
    }
    // Convert JSON data to Data
    let data = Data(bytes: jsonData, count: strlen(jsonData))
    return data
}

func getDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}

public struct DynamicCarbsData: Codable {
    let inputICE: [InputICE]
    let carbEntries: [CarbValue]
    let sensitivity: Double
    let carbRatio: Double
}

public struct InsulinPercentEffectInput: Codable {
    let minutes: Double
    let actionDuration: Double
    let peakActivityTime: Double
    let delay: Double
}

struct CarbValue: Codable {
    let grams: Int
    let absorptionTime: Int
    let date: Date
}

func encodeCarbValuesToJsonData(carbValues: [CarbValue]) -> Data? {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601 // Optional: use this to ensure dates are encoded in a standard format
    do {
        let jsonData = try encoder.encode(carbValues)
        return jsonData
    } catch {
        print("Error encoding carb values to JSON: \(error)")
        return nil
    }
}

struct InputICE: Codable {
    let velocity: Double
    let startAt: String
    let endAt: String

    enum CodingKeys: String, CodingKey {
        case velocity
        case startAt = "start_at"
        case endAt = "end_at"
    }
}

private func loadICEInputFixture(from inputs: [InputICE]) -> [GlucoseEffectVelocity] {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime, .withDashSeparatorInDate]
    
    let unit = LoopUnit(from: "mg/dL·min")

    return inputs.compactMap {
        guard let startDate = dateFormatter.date(from: $0.startAt),
              let endDate = dateFormatter.date(from: $0.endAt) else {
            return GlucoseEffectVelocity(startDate: Date(), endDate: Date(), quantity: LoopQuantity(unit: unit, doubleValue: 0))
        }

        let quantity = LoopQuantity(unit: unit, doubleValue: $0.velocity)
        return GlucoseEffectVelocity(
            startDate: startDate,
            endDate: endDate,
            quantity: quantity
        )
    }
}

public typealias JSONDictionary = [String: Any]

private func loadCarbEntryFixture(from inputs: Data) -> [FixtureCarbEntry] {
    let fixture: [JSONDictionary] = loadFixture(inputs)
    return carbEntriesFromFixture(fixture)
}

public func loadFixture<T>(_ inputs: Data) -> T {
    return try! JSONSerialization.jsonObject(with: inputs, options: []) as! T
}

private func carbEntriesFromFixture(_ fixture: [JSONDictionary]) -> [FixtureCarbEntry] {
    let dateFormatter = ISO8601DateFormatter.localTimeDate(timeZone: TimeZone(secondsFromGMT: 0)!)

    return fixture.map {
        let absorptionTime: TimeInterval?
        if let absorptionTimeMinutes = $0["absorptionTime"] as? Double {
            absorptionTime = TimeInterval(absorptionTimeMinutes * 60)
        } else {
            absorptionTime = nil
        }
        let startAt = dateFormatter.date(from: $0["date"] as! String)!
        return FixtureCarbEntry(
            absorptionTime: absorptionTime,
            startDate: startAt,
            quantity: LoopQuantity(unit: .gram, doubleValue: $0["grams"] as! Double),
            foodType: nil
        )
    }
}

public struct FixtureCarbEntry: CarbEntry, SampleValue {
    public var absorptionTime: TimeInterval?
    public var startDate: Date
    public var quantity: LoopQuantity
    public var foodType: String?

    // Explicit initializer
    public init(absorptionTime: TimeInterval?, startDate: Date, quantity: LoopQuantity, foodType: String?) {
        self.absorptionTime = absorptionTime
        self.startDate = startDate
        self.quantity = quantity
        self.foodType = foodType
    }
}

// Your Codable extension remains the same
extension FixtureCarbEntry: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            absorptionTime: try container.decodeIfPresent(TimeInterval.self, forKey: .absorptionTime),
            startDate: try container.decode(Date.self, forKey: .date),
            quantity: LoopQuantity(unit: .gram, doubleValue: try container.decode(Double.self, forKey: .grams)),
            foodType: try container.decodeIfPresent(String.self, forKey: .foodType)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(absorptionTime, forKey: .absorptionTime)
        try container.encode(startDate, forKey: .date)
        try container.encode(quantity.doubleValue(for: .gram), forKey: .grams)
        try container.encodeIfPresent(foodType, forKey: .foodType)
    }

    private enum CodingKeys: String, CodingKey {
        case date
        case grams
        case absorptionTime
        case foodType
    }
}

// Extension for ISO8601DateFormatter to handle time zone
extension ISO8601DateFormatter {
    static func localTimeDate(timeZone: TimeZone) -> ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = timeZone
        return formatter
    }
}



// Copied code because the struct was not public
struct LinearAbsorption: CarbAbsorptionComputable {
    func percentAbsorptionAtPercentTime(_ percentTime: Double) -> Double {
        switch percentTime {
        case let t where t <= 0.0:
            return 0.0
        case let t where t < 1.0:
            return t
        default:
            return 1.0
        }
    }

    func percentTimeAtPercentAbsorption(_ percentAbsorption: Double) -> Double {
        switch percentAbsorption {
        case let a where a <= 0.0:
            return 0.0
        case let a where a < 1.0:
            return a
        default:
            return 1.0
        }
    }

    func percentRateAtPercentTime(_ percentTime: Double) -> Double {
        switch percentTime {
        case let t where t > 0.0 && t <= 1.0:
            return 1.0
        default:
            return 0.0
        }
    }
}
