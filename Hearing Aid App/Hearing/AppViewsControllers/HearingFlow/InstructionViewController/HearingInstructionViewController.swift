import UIKit

final class HearingInstructionViewController: UIViewController {
    private lazy var topBgImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    private lazy var closeBtn: UIButton = {
            let btn = UIButton(type: .custom)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
            return btn
    }()
    private lazy var scrolViews: UIScrollView = {
            let scrlV = UIScrollView()
            scrlV.translatesAutoresizingMaskIntoConstraints = false
            return scrlV
    }()
    
    private lazy var contentView: UIView = {
            let scrlV = UIView()
            scrlV.translatesAutoresizingMaskIntoConstraints = false
            return scrlV
    }()
    private lazy var topLabl: UILabel = {
            let label = UILabel()
            label.text = "Hearing Aid Guide"
            label.textAlignment = .left
            label.textColor = UIColor(red: 0.066, green: 0, blue: 0.288, alpha: 1)
            label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
    }()
    private lazy var topLablStep1: UILabel = {
            let label = UILabel()
            label.text = "1. Connect headphones"
            label.textAlignment = .left
            label.textColor = UIColor(red: 0.066, green: 0, blue: 0.288, alpha: 1)
            label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
    }()
    private lazy var topLablStep2: UILabel = {
            let label = UILabel()
            label.text = "2. Tap the On button to get started"
            label.textAlignment = .left
            label.textColor = UIColor(red: 0.066, green: 0, blue: 0.288, alpha: 1)
            label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
    }()
    private lazy var topImgStep2: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "headphoneIco")
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    private lazy var topLablStep3: UILabel = {
            let label = UILabel()
            label.text = "3. Setup Hearing Aid:"
            label.textAlignment = .left
            label.textColor = UIColor(red: 0.066, green: 0, blue: 0.288, alpha: 1)
            label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
    }()
    
    private lazy var topImgStep3: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "powerBtnIco")
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    private lazy var viewStep1: UIView = {
            let viewS = createCustomView(
                imageName: "instructionIco1",
                title: "Volume Boost",
                description: "Swipe over the volume scale to increase or decrease sound level."
            )
            viewS.translatesAutoresizingMaskIntoConstraints = false
            return viewS
    }()
    private lazy var viewStep2: UIView = {
            let viewS = createCustomView(
                imageName: "instructionIco2",
                title: "Volume Balance",
                description: "Adjust the volume balance to the left or right ear as needed."
            )
            viewS.translatesAutoresizingMaskIntoConstraints = false
            return viewS
    }()
    
    private lazy var viewStep3: UIView = {
            let viewS = createCustomView(
                imageName: "instructionIco3",
                title: "Noise Suppression",
                description: "Eliminate background noise and ambient sounds for clearer speech."
            )
            viewS.translatesAutoresizingMaskIntoConstraints = false
            return viewS
    }()
    
    private lazy var viewStep4: UIView = {
            let viewS = createCustomView(
                imageName: "instructionIco4",
                title: "Stereo",
                description: "Turn on stereo mode for spatial sound with distinct left and right channels."
            )
            viewS.translatesAutoresizingMaskIntoConstraints = false
            return viewS
    }()
    
    private lazy var viewStep5: UIView = {
            let viewS = createCustomView(
                imageName: "instructionIco5",
                title: "Templates",
                description: "Choose a preset sound profile for different environments. Each template enhances hearing based on specific conditions."
            )
            viewS.translatesAutoresizingMaskIntoConstraints = false
            return viewS
    }()
    
    private lazy var viewStep6: UIView = {
            let viewS = createCustomView(
                imageName: "instructionIco6",
                title: "Setup",
                description: "Fine-tune advanced sound settings for a personalized experience."
            )
            viewS.translatesAutoresizingMaskIntoConstraints = false
            return viewS
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiLoad()
    }
    private func uiLoad(){
        view.backgroundColor = UIColor(red: 0.968, green: 0.963, blue: 1, alpha: 1)
        closeBtn.setImage(UIImage(named: "closeBtns"), for: .normal)
        topBgImage.image = UIImage(named: "instructionTopBg")
        createElement()
        layoutElement()
    }
    private func createElement(){
        view.addSubview(topBgImage)
        view.addSubview(scrolViews)
        scrolViews.addSubview(contentView)
        contentView.addSubview(closeBtn)
        contentView.addSubview(topLabl)
        contentView.addSubview(topLablStep1)
        contentView.addSubview(topLablStep2)
        contentView.addSubview(topImgStep2)
        contentView.addSubview(topLablStep3)
        contentView.addSubview(topImgStep3)
        contentView.addSubview(viewStep1)
        contentView.addSubview(viewStep2)
        contentView.addSubview(viewStep3)
        contentView.addSubview(viewStep4)
        contentView.addSubview(viewStep5)
        contentView.addSubview(viewStep6)
           
    }
    private func layoutElement(){
        NSLayoutConstraint.activate([
            topBgImage.topAnchor.constraint(equalTo: view.topAnchor),
            topBgImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBgImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBgImage.heightAnchor.constraint(equalToConstant: 405),
            
            scrolViews.topAnchor.constraint(equalTo: view.topAnchor),
            scrolViews.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrolViews.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrolViews.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrolViews.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrolViews.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrolViews.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrolViews.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrolViews.widthAnchor),
            
            closeBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            closeBtn.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            closeBtn.widthAnchor.constraint(equalToConstant: 68),
            closeBtn.heightAnchor.constraint(equalToConstant: 68),
            
            topLabl.topAnchor.constraint(equalTo: closeBtn.bottomAnchor, constant: 10),
            topLabl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            topLabl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            topLablStep1.topAnchor.constraint(equalTo: topLabl.bottomAnchor, constant: 20),
            topLablStep1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            topLablStep1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            topLablStep2.topAnchor.constraint(equalTo: topLablStep1.bottomAnchor, constant: 20),
            topLablStep2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            //topLablStep2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            topImgStep2.leadingAnchor.constraint(equalTo: topLablStep2.trailingAnchor, constant: 8),
            topImgStep2.topAnchor.constraint(equalTo: topLablStep2.topAnchor,constant:-7),
            topImgStep2.widthAnchor.constraint(equalToConstant: 32),
            topImgStep2.heightAnchor.constraint(equalToConstant: 32),
            
            topLablStep3.topAnchor.constraint(equalTo: topLablStep2.bottomAnchor, constant: 20),
            topLablStep3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            //topLablStep3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            topImgStep3.leadingAnchor.constraint(equalTo: topLablStep3.trailingAnchor, constant: 8),
            topImgStep3.topAnchor.constraint(equalTo: topLablStep3.topAnchor,constant:-5),
            topImgStep3.widthAnchor.constraint(equalToConstant: 32),
            topImgStep3.heightAnchor.constraint(equalToConstant: 32),
            
            viewStep1.topAnchor.constraint(equalTo: topLablStep3.bottomAnchor, constant: 25),
            viewStep1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            viewStep1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            viewStep2.topAnchor.constraint(equalTo: viewStep1.bottomAnchor, constant: 12),
            viewStep2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            viewStep2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            viewStep3.topAnchor.constraint(equalTo: viewStep2.bottomAnchor, constant: 12),
            viewStep3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            viewStep3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            viewStep4.topAnchor.constraint(equalTo: viewStep3.bottomAnchor, constant: 12),
            viewStep4.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            viewStep4.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            viewStep5.topAnchor.constraint(equalTo: viewStep4.bottomAnchor, constant: 12),
            viewStep5.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            viewStep5.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            viewStep6.topAnchor.constraint(equalTo: viewStep5.bottomAnchor, constant: 12),
            viewStep6.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            viewStep6.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            
            viewStep6.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)

        ])
    }
    
    func createCustomView(imageName: String, title: String, description: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 12
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: imageName)
        containerView.addSubview(imageView)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textColor = UIColor(red: 0.066, green: 0, blue: 0.288, alpha: 1)
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        titleLabel.numberOfLines = 1
        containerView.addSubview(titleLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.textColor = UIColor(red: 0.066, green: 0, blue: 0.288, alpha: 1)
        descriptionLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        descriptionLabel.numberOfLines = 0
        containerView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 32),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 16),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor,constant: -16),
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -16),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -20),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor,constant: -16)
        ])
        
        return containerView
    }
    // MARK: - Actions
       @objc private func closeBtnTapped() {
           print("Close button tapped")
           self.dismiss(animated: true, completion: nil)
       }
}
