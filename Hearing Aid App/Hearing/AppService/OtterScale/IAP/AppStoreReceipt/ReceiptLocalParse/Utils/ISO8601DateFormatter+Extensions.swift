//
//  ISO8601DateFormatter+Extensions.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 01.02.2022.
//

import Foundation

protocol DateFormatterType {
    func string(from date: Date) -> String
    func date(from string: String) -> Date?
}

extension DateFormatter: DateFormatterType {}
extension ISO8601DateFormatter: DateFormatterType {}

// MARK: Default formatter
extension ISO8601DateFormatter {
    final class Formatter: DateFormatterType {
        func date(from string: String) -> Date? {
            return ISO8601DateFormatter.withMilliseconds.date(from: string)
                ?? ISO8601DateFormatter.noMilliseconds.date(from: string)
        }

        func string(from date: Date) -> String {
            return ISO8601DateFormatter.withMilliseconds.string(from: date)
        }
    }
    
    static let `default`: DateFormatterType = {
        Formatter()
    }()
}

// MARK: Private
private extension ISO8601DateFormatter {
    static let withMilliseconds: DateFormatterType = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        return formatter
    }()

    static let noMilliseconds: DateFormatterType = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime
        ]

        return formatter
    }()
}
