import Foundation

@objc
public protocol SIAppStateListeners {
    
    @objc optional func appWillEnterForeground()
    
    @objc optional func appDidEnterBackground()
}
