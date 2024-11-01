import AVKit

extension AVRoutePickerView {
    
    func present() {
        let routePickerButton = subviews.first(where: { $0 is UIButton }) as? UIButton
        routePickerButton?.sendActions(for: .touchUpInside)
    }
}
