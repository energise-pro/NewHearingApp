//
//  UserUpdater.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 23.02.2022.
//

final class UserUpdater {
    private let manager: UserManagerProtocol
    private let mediator: IAPMediatorProtocol
    private let infoHelper: InfoHelperProtocol
    private let storage: StorageProtocol
    
    deinit {
        mediator.remove(delegate: self)
    }
    
    init(manager: UserManagerProtocol,
         mediator: IAPMediatorProtocol,
         infoHelper: InfoHelperProtocol = InfoHelper(),
         storage: StorageProtocol) {
        self.manager = manager
        self.mediator = mediator
        self.infoHelper = infoHelper
        self.storage = storage
    }
}

// MARK: Public
extension UserUpdater {
    func startTracking() {
        mediator.add(delegate: self)
    }
}

// MARK: OtterScaleReceiptValidationDelegate
extension UserUpdater: OtterScaleReceiptValidationDelegate {
    func otterScaleDidValidatedReceipt(with result: AppStoreValidateResult?) {
        manager.set(properties: ["currency": infoHelper.currencyCode ?? "",
                                 "country": infoHelper.countryCode ?? "",
                                 "locale": infoHelper.locale ?? "",
                                 "firebase_notification_key": storage.pushNotificationsToken ?? ""],
                    mapper: UserSetResponse(),
                    completion: nil)
    }
}
