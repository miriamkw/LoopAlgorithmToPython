//
//  LoopAlgorithmToPython.swift
//  LoopAlgorithm
//
//  Created by Miriam K. Wolff on 24/06/2024.
//

import Foundation
import LoopAlgorithm
import HealthKit


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

@_cdecl("generatePrediction") // Use @_cdecl to expose the function with a C-compatible name
public func generatePrediction(jsonData: UnsafePointer<Int8>?) -> UnsafeMutablePointer<Double> {
    // TODO: Add opportunity to get prediction effects from only one factor at a time
    
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
        
        var predictedValues: [Double] = []
                
        for val in prediction.glucose {
            predictedValues.append(val.quantity.doubleValue(for: HKUnit(from: "mg/dL")))
        }
        let pointer = UnsafeMutablePointer<Double>.allocate(capacity: predictedValues.count)
        pointer.initialize(from: predictedValues, count: predictedValues.count)
                
        return pointer
    } catch {
        fatalError("Error reading or decoding JSON file: \(error)")
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
            glucoseEffectVelocities.append(val.quantity.doubleValue(for: HKUnit(from: "mg/dL·s")))
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
        let output = LoopAlgorithm.run(input: input)
                        
        return output.activeInsulin!
    } catch {
        fatalError("Error reading or decoding JSON file: \(error)")
    }
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
        print("carbentries ok")
        print(input.inputICE[0].startAt)
        
        // Parse the date string
        if let date = dateFormatter.date(from: input.inputICE[0].startAt) {
            print("Parsed date: \(date)")
        } else {
            print("Failed to parse date string.")
        }

        let startDate = dateFormatter.date(from: input.inputICE[0].startAt)!
        print("startdate ok")
        let endDate = dateFormatter.date(from: input.inputICE.last!.startAt)!
        print("enddate ok")
        let carbRatio = [AbsoluteScheduleValue(startDate: startDate, endDate: endDate, value: input.carbRatio)]
        print("carbratio ok")
        let isf =  [AbsoluteScheduleValue(startDate: startDate, endDate: endDate, value: HKQuantity(unit: HKUnit(from: "mg/dL"), doubleValue: input.sensitivity))]
        print("isf ok")

        let statuses = [carbEntries[0]].map(
            to: inputICE,
            carbRatio: carbRatio,
            insulinSensitivity: isf,
            initialAbsorptionTimeOverrun: 2.0,
            absorptionModel: PiecewiseLinearAbsorption()
        )
        print("STATUSES!")
        print(statuses)
        // TODO: Add a function for different absorbrionmodels
        
        print(inputICE[0].startDate)
        print(inputICE[0].startDate.addingTimeInterval(TimeInterval(60*60*6)))
        
        // The output here is a list of CarbValues with startDate, endDate (equal to startDate), and value (ICE?)
        let carbsOnBoard = statuses.dynamicCarbsOnBoard(
            from: inputICE[0].startDate,
            to: inputICE[0].startDate.addingTimeInterval(TimeInterval(60*60*6)),
            absorptionModel: PiecewiseLinearAbsorption())
        
        print("CARBS ON BOARD")
        print(carbsOnBoard)
                
        // Do something
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
    
    let unit = HKUnit(from: "mg/dL").unitDivided(by: .minute())

    return inputs.compactMap {
        guard let startDate = dateFormatter.date(from: $0.startAt),
              let endDate = dateFormatter.date(from: $0.endAt) else {
            return nil
        }

        let quantity = HKQuantity(unit: unit, doubleValue: $0.velocity)
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
            quantity: HKQuantity(unit: .gram(), doubleValue: $0["grams"] as! Double), foodType: nil
        )
    }
}

public struct FixtureCarbEntry: CarbEntry {
    public var absorptionTime: TimeInterval?
    public var startDate: Date
    public var quantity: HKQuantity
    public var foodType: String?

    // Explicit initializer
    public init(absorptionTime: TimeInterval?, startDate: Date, quantity: HKQuantity, foodType: String?) {
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
            quantity: HKQuantity(unit: .gram(), doubleValue: try container.decode(Double.self, forKey: .grams)),
            foodType: try container.decodeIfPresent(String.self, forKey: .foodType)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(absorptionTime, forKey: .absorptionTime)
        try container.encode(startDate, forKey: .date)
        try container.encode(quantity.doubleValue(for: .gram()), forKey: .grams)
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




