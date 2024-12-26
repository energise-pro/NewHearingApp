//
//  InAppPurchaseBuilder.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 01.02.2022.
//

import Foundation

protocol InAppPurchaseBuilderProtocol {
    func build(fromContainer container: ASN1Container) throws -> InAppPurchase
}

final class InAppPurchaseBuilder: InAppPurchaseBuilderProtocol {
    private let containerBuilder: ASN1ContainerBuilderProtocol
    private let typeContainerIndex = 0
    private let versionContainerIndex = 1 // unused
    private let attributeTypeContainerIndex = 2
    private let expectedInternalContainersCount = 3 // type + version + attribute

    init(containerBuilder: ASN1ContainerBuilderProtocol = ASN1ContainerBuilder()) {
        self.containerBuilder = containerBuilder
    }

    func build(fromContainer container: ASN1Container) throws -> InAppPurchase {
        var quantity: Int?
        var productId: String?
        var transactionId: String?
        var originalTransactionId: String?
        var productType: InAppPurchaseProductType?
        var purchaseDate: Date?
        var originalPurchaseDate: Date?
        var expiresDate: Date?
        var cancellationDate: Date?
        var isInTrialPeriod: Bool?
        var webOrderLineItemId: Int64?
        var promotionalOfferIdentifier: String?

        for internalContainer in container.internalContainers {
            guard internalContainer.internalContainers.count == expectedInternalContainersCount else {
                throw ReceiptReadingError.inAppPurchaseParsingError
            }
            
            let typeContainer = internalContainer.internalContainers[typeContainerIndex]
            let valueContainer = internalContainer.internalContainers[attributeTypeContainerIndex]

            guard let attributeType = InAppPurchaseAttributeType(rawValue: typeContainer.internalPayload.toInt()) else {
                continue
            }

            let internalContainer = try containerBuilder.build(fromPayload: valueContainer.internalPayload)
            
            guard internalContainer.length.value > 0 else {
                continue
            }

            switch attributeType {
            case .quantity:
                quantity = internalContainer.internalPayload.toInt()
            case .webOrderLineItemId:
                webOrderLineItemId = internalContainer.internalPayload.toInt64()
            case .productType:
                productType = InAppPurchaseProductType(rawValue: internalContainer.internalPayload.toInt())
            case .isInTrialPeriod:
                isInTrialPeriod = internalContainer.internalPayload.toBool()
            case .productId:
                productId = internalContainer.internalPayload.toString()
            case .transactionId:
                transactionId = internalContainer.internalPayload.toString()
            case .originalTransactionId:
                originalTransactionId = internalContainer.internalPayload.toString()
            case .promotionalOfferIdentifier:
                promotionalOfferIdentifier = internalContainer.internalPayload.toString()
            case .cancellationDate:
                cancellationDate = internalContainer.internalPayload.toDate()
            case .expiresDate:
                expiresDate = internalContainer.internalPayload.toDate()
            case .originalPurchaseDate:
                originalPurchaseDate = internalContainer.internalPayload.toDate()
            case .purchaseDate:
                purchaseDate = internalContainer.internalPayload.toDate()
            }
        }

        guard
            let nonOptionalQuantity = quantity,
            let nonOptionalProductId = productId,
            let nonOptionalTransactionId = transactionId,
            let nonOptionalOriginalTransactionId = originalTransactionId,
            let nonOptionalPurchaseDate = purchaseDate,
            let nonOptionalOriginalPurchaseDate = originalPurchaseDate,
            let nonOptionalWebOrderLineItemId = webOrderLineItemId
        else {
            throw ReceiptReadingError.inAppPurchaseParsingError
        }

        return InAppPurchase(quantity: nonOptionalQuantity,
                             productId: nonOptionalProductId,
                             transactionId: nonOptionalTransactionId,
                             originalTransactionId: nonOptionalOriginalTransactionId,
                             productType: productType,
                             purchaseDate: nonOptionalPurchaseDate,
                             originalPurchaseDate: nonOptionalOriginalPurchaseDate,
                             expiresDate: expiresDate,
                             cancellationDate: cancellationDate,
                             isInTrialPeriod: isInTrialPeriod,
                             webOrderLineItemId: nonOptionalWebOrderLineItemId,
                             promotionalOfferIdentifier: promotionalOfferIdentifier)
    }
}

// MARK: Private
private extension InAppPurchaseBuilder {
    enum InAppPurchaseAttributeType: Int {
        case quantity = 1701,
             productId = 1702,
             transactionId = 1703,
             purchaseDate = 1704,
             originalTransactionId = 1705,
             originalPurchaseDate = 1706,
             productType = 1707,
             expiresDate = 1708,
             webOrderLineItemId = 1711,
             cancellationDate = 1712,
             isInTrialPeriod = 1713,
             promotionalOfferIdentifier = 1721
    }
}
