//
//  ReceiptReadingError.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 01.02.2022.
//

import Foundation

enum ReceiptReadingError: Error, Equatable {
    case missingReceipt,
         emptyReceipt,
         dataObjectIdentifierMissing,
         asn1ParsingError,
         receiptParsingError,
         inAppPurchaseParsingError
}
