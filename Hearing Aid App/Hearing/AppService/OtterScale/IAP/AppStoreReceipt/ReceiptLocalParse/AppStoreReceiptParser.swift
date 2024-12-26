//
//  AppStoreReceiptParser.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 01.02.2022.
//

import Foundation

protocol AppStoreReceiptParserProtocol {
    func parse(from receiptData: Data) throws -> AppStoreReceipt
}

final class AppStoreReceiptParser: AppStoreReceiptParserProtocol {
    private let objectIdentifierBuilder: ASN1ObjectIdentifierBuilderProtocol
    private let containerBuilder: ASN1ContainerBuilderProtocol
    private let receiptBuilder: AppleReceiptBuilderProtocol

    init(objectIdentifierBuilder: ASN1ObjectIdentifierBuilderProtocol = ASN1ObjectIdentifierBuilder(),
         containerBuilder: ASN1ContainerBuilderProtocol = ASN1ContainerBuilder(),
         receiptBuilder: AppleReceiptBuilderProtocol = AppleReceiptBuilder()) {
        self.objectIdentifierBuilder = objectIdentifierBuilder
        self.containerBuilder = containerBuilder
        self.receiptBuilder = receiptBuilder
    }

    func parse(from receiptData: Data) throws -> AppStoreReceipt {
        let intData = [UInt8](receiptData)

        let asn1Container = try containerBuilder.build(fromPayload: ArraySlice(intData))
        guard let receiptASN1Container = try findASN1Container(withObjectId: ASN1ObjectIdentifier.data,
                                                               inContainer: asn1Container) else {
            throw ReceiptReadingError.dataObjectIdentifierMissing
        }
        
        let receipt = try receiptBuilder.build(fromContainer: receiptASN1Container)
        
        return receipt
    }
}

// MARK: Private
private extension AppStoreReceiptParser {
    func findASN1Container(withObjectId objectId: ASN1ObjectIdentifier,
                           inContainer container: ASN1Container) throws -> ASN1Container? {
        if container.encodingType == .constructed {
            for (index, internalContainer) in container.internalContainers.enumerated() {
                if internalContainer.containerIdentifier == .objectIdentifier {
                    let objectIdentifier = try objectIdentifierBuilder.build(
                        fromPayload: internalContainer.internalPayload)
                    if objectIdentifier == objectId && index < container.internalContainers.count - 1 {
                        return container.internalContainers[index + 1]
                    }
                } else {
                    let receipt = try findASN1Container(withObjectId: objectId, inContainer: internalContainer)
                    if receipt != nil {
                        return receipt
                    }
                }
            }
        }
        return nil
    }
}
