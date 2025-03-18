//
//  PaywallReviewsView.swift
//  Hearing Aid App

import UIKit

final class PaywallReviewsView: UIView {
    // MARK: - Private properties
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SetupView
    private func setupView() {
        scrollView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        let reviewsData = [
            ("Perfect sound", "I recommend this app for precise, personalized sound adjustments. Great tool for enhancing clarity."),
            ("Amazing quality", "I’ve never had transcriptions this accurate—even with fast speech. Translation is a lifesaver when traveling."),
            ("Love it!", "Works like magic! One tap, and all the background noise disappears. Perfect for calls and watching videos."),
            ("Super useful", "It makes transcription fast and accurate, even with accents. Saves me tons of time at work!")
        ]
        
        var previousView: UIView?
        for (title, description) in reviewsData {
            let reviewView = PaywallReviewView()
            reviewView.configureWith(title: title, description: description)
            reviewView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(reviewView)
            
            NSLayoutConstraint.activate([
                reviewView.topAnchor.constraint(equalTo: contentView.topAnchor),
                reviewView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                reviewView.widthAnchor.constraint(equalToConstant: 300)
            ])
            
            if let previousView = previousView {
                reviewView.leadingAnchor.constraint(equalTo: previousView.trailingAnchor, constant: 8).isActive = true
            } else {
                reviewView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            }
            
            previousView = reviewView
        }
        
        if let lastReview = previousView {
            lastReview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        }
        
        activateLayoutConstraint()
    }
    
    private func activateLayoutConstraint() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
}
