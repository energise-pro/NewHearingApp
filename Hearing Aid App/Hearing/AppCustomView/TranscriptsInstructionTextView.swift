//
//  TranscriptsInstructionTextView.swift
//  Hearing Aid App
//
//  Created by Evgeniy Zelinskiy on 05.12.2024.
//

import UIKit

@IBDesignable
class TranscriptsInstructionTextView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }

    private func setupView() {
        self.backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        // Створення шляху для View із закругленими кутами та вирізами
        let path = UIBezierPath()

        // Верхній лівий кут із закругленням
        path.move(to: CGPoint(x: rect.minX + 16, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - 72, y: rect.minY))

        // Верхній правий виріз (43x43)
        path.addArc(withCenter: CGPoint(x: rect.maxX - 143, y: rect.minY + 45),
                    radius: 43,
                    startAngle: -CGFloat.pi / 2,
                    endAngle: CGFloat.pi / 2,
                    clockwise: false)
        
        // Верхній правий виріз (32x32)
        path.addArc(withCenter: CGPoint(x: rect.maxX - 112, y: rect.minY + 73),
                    radius: 32,
                    startAngle: CGFloat.pi,
                    endAngle: 0,
                    clockwise: false)

        // Верхній правий кут
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 16))

        // Правий нижній кут із закругленням
        path.addArc(withCenter: CGPoint(x: rect.maxX - 16, y: rect.maxY - 16),
                    radius: 16,
                    startAngle: 0,
                    endAngle: CGFloat.pi / 2,
                    clockwise: true)

        // Лівий нижній кут із закругленням
        path.addLine(to: CGPoint(x: rect.minX + 16, y: rect.maxY))
        path.addArc(withCenter: CGPoint(x: rect.minX + 16, y: rect.maxY - 16),
                    radius: 16,
                    startAngle: CGFloat.pi / 2,
                    endAngle: CGFloat.pi,
                    clockwise: true)

        // Лівий верхній кут
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + 16))
        path.addArc(withCenter: CGPoint(x: rect.minX + 16, y: rect.minY + 16),
                    radius: 16,
                    startAngle: CGFloat.pi,
                    endAngle: -CGFloat.pi / 2,
                    clockwise: true)

        // Закриваємо шлях
        path.close()

        // Заливка білим кольором
        UIColor.white.setFill()
        path.fill()
    }
}
