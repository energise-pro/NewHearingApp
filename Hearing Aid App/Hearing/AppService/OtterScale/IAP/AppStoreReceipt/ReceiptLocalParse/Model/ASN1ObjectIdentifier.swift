//
//  ASN1ObjectIdentifier.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 01.02.2022.
//

enum ASN1ObjectIdentifier: String {
    case data = "1.2.840.113549.1.7.1"
    case signedData = "1.2.840.113549.1.7.2"
    case envelopedData = "1.2.840.113549.1.7.3"
    case signedAndEnvelopedData = "1.2.840.113549.1.7.4"
    case digestedData = "1.2.840.113549.1.7.5"
    case encryptedData = "1.2.840.113549.1.7.6"
}
