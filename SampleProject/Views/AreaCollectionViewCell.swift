//
//  ArearCollectionViewCell.swift
//  SampleProject
//
//  Created by hideto.higashi on 2022/12/20.
//

import UIKit

class AreaCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "AreaCollectionViewCell"
    private var areaNameLabel: UILabel!
    private var arrowLabel: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
        configureView()
        applyConstraints()
        setBottomLine()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - configure
extension AreaCollectionViewCell {
    private func configure() {
        configureAreaNameLabel()
        configureArrowLabel()
    }

    private func configureView() {
        self.addSubview(areaNameLabel)
        self.addSubview(arrowLabel)
    }

    private func configureAreaNameLabel() {
        areaNameLabel = UILabel()
        areaNameLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureArrowLabel() {
        arrowLabel = UIImageView()
        arrowLabel.image = UIImage(named: "rightArrow")
        arrowLabel.contentMode = .scaleAspectFit
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
    }
}

// MARK: - constraints
extension AreaCollectionViewCell {
    private func applyConstraints() {
        let areaNameLabelConstraints = [
            areaNameLabel.topAnchor.constraint(equalTo: self.topAnchor),
            areaNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            areaNameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]

        let arrowLabelConstraints = [
            arrowLabel.topAnchor.constraint(equalTo: self.topAnchor),
            arrowLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            arrowLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]

        NSLayoutConstraint.activate(areaNameLabelConstraints)
        NSLayoutConstraint.activate(arrowLabelConstraints)
    }
}

// MARK: - others
extension AreaCollectionViewCell {
    func setAreaName(areaName: String) {
        areaNameLabel.text = areaName
    }

    private func setBottomLine() {
        let bottomLine = CALayer()
        bottomLine.backgroundColor = UIColor.darkGray.cgColor
        bottomLine.frame = CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: 0.5)
        self.layer.addSublayer(bottomLine)
    }
}
