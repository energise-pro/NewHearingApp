//
//  UserManager.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 16.01.2022.
//

protocol UserManagerProtocol {
    func set(userID: String,
             mapper: UserSetResponseProtocol,
             completion: ((Bool) -> Void)?)
    func set(properties: [String: Any],
             mapper: UserSetResponseProtocol,
             completion: ((Bool) -> Void)?)
}

final class UserManager: UserManagerProtocol {
    private let apiEnvironment: APIEnvironmentProtocol
    private var storage: StorageProtocol
    private let requestDispatcher: RequestDispatcherProtocol
    
    private lazy var operations = [String: APIOperationProtocol]()
    private lazy var operationWrapper = APIOperationWrapper()
    
    init(apiEnvironment: APIEnvironmentProtocol,
         storage: StorageProtocol) {
        self.apiEnvironment = apiEnvironment
        self.storage = storage
        self.requestDispatcher = RequestDispatcher(environment: apiEnvironment,
                                                  networkSession: NetworkSession())
    }
}

// MARK: Internal
extension UserManager {
    func set(userID: String,
             mapper: UserSetResponseProtocol = UserSetResponse(),
             completion: ((Bool) -> Void)? = nil) {
        let userParameters = [
            "external_id": userID
        ]
        let request = UserSetRequest(apiKey: apiEnvironment.apiKey,
                                     anonymousID: storage.anonymousID,
                                     externalUserID: storage.externalUserID,
                                     internalUserID: storage.internalUserID,
                                     userParameters: userParameters)
        let operation = APIOperation(endPoint: request)
        
        let key = "set_user_id"
        
        operations[key] = operation
        
        operationWrapper.execute(operation: operation, dispatcher: requestDispatcher) { [weak self] response in
            if let response = response {
                let result = mapper.map(response: response)
                
                if result {
                    self?.storage.externalUserID = userID
                }
                
                completion?(result)
            } else {
                completion?(false)
            }
            
            self?.operations.removeValue(forKey: key)
        }
    }
    
    func set(properties: [String: Any],
             mapper: UserSetResponseProtocol = UserSetResponse(),
             completion: ((Bool) -> Void)? = nil) {
        let request = UserSetRequest(apiKey: apiEnvironment.apiKey,
                                     anonymousID: storage.anonymousID,
                                     externalUserID: storage.externalUserID,
                                     internalUserID: storage.internalUserID,
                                     userParameters: properties)
        let operation = APIOperation(endPoint: request)
        
        let key = "set_user_properties"
        
        operations[key] = operation
        
        operationWrapper.execute(operation: operation, dispatcher: requestDispatcher) { [weak self] response in
            if let response = response {
                let result = mapper.map(response: response)
                completion?(result)
            } else {
                completion?(false)
            }
            
            self?.operations.removeValue(forKey: key)
        }
    }
}
