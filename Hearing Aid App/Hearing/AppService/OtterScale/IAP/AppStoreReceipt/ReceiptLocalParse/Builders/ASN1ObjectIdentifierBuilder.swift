//
//  ASN1ObjectIdentifierBuilder.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 01.02.2022.
//

import Foundation

protocol ASN1ObjectIdentifierBuilderProtocol {
    func build(fromPayload payload: ArraySlice<UInt8>) throws -> ASN1ObjectIdentifier?
}

final class ASN1ObjectIdentifierBuilder: ASN1ObjectIdentifierBuilderProtocol {
    func build(fromPayload payload: ArraySlice<UInt8>) throws -> ASN1ObjectIdentifier? {
        guard let firstByte = payload.first else {
            return nil
        }

        var objectIdentifierNumbers: [UInt] = []
        objectIdentifierNumbers.append(UInt(firstByte / 40))
        objectIdentifierNumbers.append(UInt(firstByte % 40))

        let trailingPayload = payload.dropFirst()
        let variableLengthQuantityNumbers = try decodeVariableLengthQuantity(payload: trailingPayload)
        objectIdentifierNumbers += variableLengthQuantityNumbers

        let objectIdentifierString = objectIdentifierNumbers.map { String($0) }
                                                            .joined(separator: ".")
        return ASN1ObjectIdentifier(rawValue: objectIdentifierString)
    }
}

// MARK: Private
private extension ASN1ObjectIdentifierBuilder {
    func decodeVariableLengthQuantity(payload: ArraySlice<UInt8>) throws -> [UInt] {
        var decodedNumbers = [UInt]()

        var currentBuffer: UInt = 0
        var isShortLength = false
        for byte in payload {
            isShortLength = try byte.bitAtIndex(0) == 0
            let byteValue = UInt(try byte.valueInRange(from: 1, to: 7))

            currentBuffer = (currentBuffer << 7) | byteValue
            if isShortLength {
                decodedNumbers.append(currentBuffer)
                currentBuffer = 0
            }
        }
        
        return decodedNumbers
    }
}
