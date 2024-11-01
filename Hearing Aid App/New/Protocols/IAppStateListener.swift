import Foundation

@objc
public protocol IAppStateListener {
    
    @objc optional func appWillEnterForeground()
    
    @objc optional func appDidEnterBackground()
}
