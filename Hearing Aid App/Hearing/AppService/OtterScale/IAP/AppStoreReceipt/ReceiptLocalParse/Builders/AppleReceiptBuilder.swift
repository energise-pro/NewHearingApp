//
//  AppleReceiptBuilder.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 01.02.2022.
//

import Foundation

protocol AppleReceiptBuilderProtocol {
    func build(fromContainer container: ASN1Container) throws -> AppStoreReceipt
}

final class AppleReceiptBuilder: AppleReceiptBuilderProtocol {
    private let containerBuilder: ASN1ContainerBuilderProtocol
    private let inAppPurchaseBuilder: InAppPurchaseBuilderProtocol

    private let typeContainerIndex = 0
    private let versionContainerIndex = 1 // unused
    private let attributeTypeContainerIndex = 2
    private let expectedInternalContainersCount = 3 // type + version + attribute

    init(containerBuilder: ASN1ContainerBuilderProtocol = ASN1ContainerBuilder(),
         inAppPurchaseBuilder: InAppPurchaseBuilderProtocol = InAppPurchaseBuilder()) {
        self.containerBuilder = containerBuilder
        self.inAppPurchaseBuilder = inAppPurchaseBuilder
    }

    func build(fromContainer container: ASN1Container) throws -> AppStoreReceipt {
        var bundleId: String?
        var applicationVersion: String?
        var originalApplicationVersion: String?
        var opaqueValue: Data?
        var sha1Hash: Data?
        var creationDate: Date?
        var expirationDate: Date?
        var inAppPurchases: [InAppPurchase] = []

        guard let internalContainer = container.internalContainers.first else {
            throw ReceiptReadingError.receiptParsingError
        }
        
        let receiptContainer = try containerBuilder.build(fromPayload: internalContainer.internalPayload)
        for receiptAttribute in receiptContainer.internalContainers {
            guard receiptAttribute.internalContainers.count == expectedInternalContainersCount else {
                throw ReceiptReadingError.receiptParsingError
            }
            let typeContainer = receiptAttribute.internalContainers[typeContainerIndex]
            let valueContainer = receiptAttribute.internalContainers[attributeTypeContainerIndex]
            let attributeType = ReceiptAttributeType(rawValue: typeContainer.internalPayload.toInt())
            
            guard let nonOptionalType = attributeType else {
                continue
            }
            
            let payload = valueContainer.internalPayload

            switch nonOptionalType {
            case .opaqueValue:
                opaqueValue = payload.toData()
            case .sha1Hash:
                sha1Hash = payload.toData()
            case .applicationVersion:
                let internalContainer = try containerBuilder.build(fromPayload: payload)
                applicationVersion = internalContainer.internalPayload.toString()
            case .originalApplicationVersion:
                let internalContainer = try containerBuilder.build(fromPayload: payload)
                originalApplicationVersion = internalContainer.internalPayload.toString()
            case .bundleId:
                let internalContainer = try containerBuilder.build(fromPayload: payload)
                bundleId = internalContainer.internalPayload.toString()
            case .creationDate:
                let internalContainer = try containerBuilder.build(fromPayload: payload)
                creationDate = internalContainer.internalPayload.toDate()
            case .expirationDate:
                let internalContainer = try containerBuilder.build(fromPayload: payload)
                expirationDate = internalContainer.internalPayload.toDate()
            case .inAppPurchase:
                let internalContainer = try containerBuilder.build(fromPayload: payload)
                inAppPurchases.append(try inAppPurchaseBuilder.build(fromContainer: internalContainer))
            }
        }
        
        guard
            let nonOptionalBundleId = bundleId,
            let nonOptionalApplicationVersion = applicationVersion,
            let nonOptionalOriginalApplicationVersion = originalApplicationVersion,
            let nonOptionalOpaqueValue = opaqueValue,
            let nonOptionalSha1Hash = sha1Hash,
            let nonOptionalCreationDate = creationDate
        else {
            throw ReceiptReadingError.receiptParsingError
        }

        let receipt = AppStoreReceipt(bundleId: nonOptionalBundleId,
                                      applicationVersion: nonOptionalApplicationVersion,
                                      originalApplicationVersion: nonOptionalOriginalApplicationVersion,
                                      opaqueValue: nonOptionalOpaqueValue,
                                      sha1Hash: nonOptionalSha1Hash,
                                      creationDate: nonOptionalCreationDate,
                                      expirationDate: expirationDate,
                                      inAppPurchases: inAppPurchases)
        return receipt
    }
}

// MARK: Private
private extension AppleReceiptBuilder {
    enum ReceiptAttributeType: Int {
        case bundleId = 2,
             applicationVersion = 3,
             opaqueValue = 4,
             sha1Hash = 5,
             creationDate = 12,
             inAppPurchase = 17,
             originalApplicationVersion = 19,
             expirationDate = 21
    }
}
