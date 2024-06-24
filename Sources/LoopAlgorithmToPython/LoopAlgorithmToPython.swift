//
//  LoopAlgorithmToPython.swift
//  LoopAlgorithm
//
//  Created by Miriam K. Wolff on 24/06/2024.
//

import Foundation
import LoopAlgorithm
import HealthKit

@_cdecl("generatePrediction") // Use @_cdecl to expose the function with a C-compatible name
public func generatePrediction(jsonData: UnsafePointer<Int8>?) -> UnsafeMutablePointer<Double> {
    /// To generate a lib file, run:
    /// swiftc -emit-library -o libMySwiftModule.dylib Sources/LoopAlgorithmToPython/LoopAlgorithmToPython.swift
    
    // TODO: Add opportunity to get prediction effects from only one factor at a time
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    guard let jsonData = jsonData else {
        fatalError("No JSON data provided")
    }
    
    // Convert JSON data to Data
    let data = Data(bytes: jsonData, count: strlen(jsonData))

    do {
        // Decode JSON data
        let input = try decoder.decode(LoopPredictionInput.self, from: data)

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

@_cdecl("getPredictionDates") // Use @_cdecl to expose the function with a C-compatible name
public func getPredictionDates(jsonData: UnsafePointer<Int8>?) -> UnsafePointer<CChar> {
    /// To generate a lib file, run:
    /// swiftc -emit-library -o libMySwiftModule.dylib Sources/LoopAlgorithmToPython/LoopAlgorithmToPython.swift
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    guard let jsonData = jsonData else {
        fatalError("No JSON data provided")
    }
    
    // Convert JSON data to Data
    let data = Data(bytes: jsonData, count: strlen(jsonData))
    
    do {
        // Decode JSON data
        let input = try decoder.decode(LoopPredictionInput.self, from: data)

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


