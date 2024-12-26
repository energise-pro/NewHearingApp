//
//  APIOperationWrapper.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 14.03.2022.
//

final class APIOperationWrapper {}

// MARK: Internal
extension APIOperationWrapper {
    func execute(operation: APIOperationProtocol,
                 dispatcher: RequestDispatcherProtocol,
                 completion: ((Any?) -> Void)? = nil) {
        perform(operation: operation, dispatcher: dispatcher, completion: completion)
    }
}

// MARK: Private
private extension APIOperationWrapper {
    func perform(operation: APIOperationProtocol,
                 dispatcher: RequestDispatcherProtocol,
                 attempt: Int = 1,
                 maxCount: Int = 3,
                 completion: ((Any?) -> Void)? = nil) {
        guard attempt <= maxCount else {
            completion?(nil)
            return
        }
        
        operation.execute(dispatcher: dispatcher) { [weak self] response in
            guard let self = self else {
                completion?(nil)
                return
            }
            
            let success = self.success(response: response as Any)
            
            if success {
                completion?(response)
            } else {
                self.perform(operation: operation,
                             dispatcher: dispatcher,
                             attempt: attempt + 1,
                             completion: completion)
            }
        }
    }
    
    func success(response: Any) -> Bool {
        guard
            let json = response as? [String: Any],
            let code = json["_code"] as? Int
        else {
            return false
        }
        
        return (code >= 200 && code <= 299) || (code >= 400 && code <= 499)
    }
}
