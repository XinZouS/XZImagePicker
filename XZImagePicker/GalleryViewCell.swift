//
//  GalleryViewCell.swift
//  XZImagePicker
//
//  Created by Xin Zou on 6/27/18.
//  Copyright © 2018 Xin Zou. All rights reserved.
//

import UIKit

class GalleryViewCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    private let selectionLabel = UILabel()
    private let selectionDisableMask = UIView()
    
    var selectionLabelColor = UIColor.green {
        didSet {
            selectionLabel.backgroundColor = selectionLabelColor
        }
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    static let kSelectionOrderDeselect: Int = -1
    var selectionOrder: Int = -1 {
        didSet {
            updateCellAppearance()
        }
    }
    var isSelectionEnable = true {
        didSet {
            selectionDisableMask.isHidden = isSelectionEnable
        }
    }
    
    
    // MARK: - View cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        setupSelectionViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image = nil
        imageView.image = nil
    }
    
    // MARK: - setup views
    
    private func setupImageView() {
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.addConstraints(left: leftAnchor, top: topAnchor, right: rightAnchor, bottom: bottomAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 0, width: 0, height: 0)
    }
    
    private func setupSelectionViews() {
        let w: CGFloat = max(24, self.bounds.width / 4.6)
        selectionLabel.font = UIFont.boldSystemFont(ofSize: w * 0.68)
        selectionLabel.backgroundColor = selectionLabelColor
        selectionLabel.textAlignment = .center
        selectionLabel.textColor = .white
        selectionLabel.adjustsFontSizeToFitWidth = true
        selectionLabel.layer.masksToBounds = true
        selectionLabel.layer.cornerRadius = 4
        selectionLabel.isHidden = true
        addSubview(selectionLabel)
        selectionLabel.addConstraints(left: leftAnchor, top: topAnchor, right: nil, bottom: nil, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 0, width: w, height: w)
        
        selectionDisableMask.backgroundColor = UIColor(white: 1, alpha: 0.5)
        selectionDisableMask.isHidden = isSelectionEnable
        addSubview(selectionDisableMask)
        selectionDisableMask.addConstraints(left: leftAnchor, top: topAnchor, right: rightAnchor, bottom: bottomAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 0, width: 0, height: 0)
    }
    
    func updateCellAppearance() {
        selectionLabel.isHidden = (selectionOrder == GalleryViewCell.kSelectionOrderDeselect)
        selectionLabel.text = "\(selectionOrder + 1)"
        selectionDisableMask.isHidden = isSelectionEnable
    }
    
}
