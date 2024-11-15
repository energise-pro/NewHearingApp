//
//  TooltipView.swift
//  Hearing Aid App
//
//  Created by Evgeniy Zelinskiy on 13.11.2024.
//

import UIKit

class TooltipView: UIView {
    private let label = UILabel()
    private let tooltipHeight: CGFloat = 40
    private let tooltipPadding: CGFloat = 20

    init(text: String) {
        super.init(frame: .zero)
        setupTooltip(text: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTooltip(text: String) {
        label.text = text
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.sizeToFit()
        
        let labelWidth = label.frame.width + tooltipPadding * 2
        frame = CGRect(x: 0, y: 0, width: labelWidth, height: tooltipHeight)
        
        backgroundColor = UIColor.appColor(.Red100)
        layer.cornerRadius = tooltipHeight / 2
        clipsToBounds = false
        
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        let pointerSize: CGSize = CGSize(width: 16, height: 14)
        let pointer = UIImageView(image: UIImage(named: "tooltipArrow"))
        pointer.contentMode = .scaleAspectFit
        pointer.frame = CGRect(x: (labelWidth - pointerSize.width) / 2, y: tooltipHeight - 2, width: pointerSize.width, height: pointerSize.height)
        addSubview(pointer)
    }
}
