//
//  MainViewController.swift
//  XZImagePicker
//
//  Created by Xin Zou on 6/27/18.
//  Copyright © 2018 Xin Zou. All rights reserved.
//

import UIKit
import Photos

let iOS7Later: Bool = (Double(UIDevice.current.systemVersion) ?? 0.0) >= 7.0
let iOS8Later: Bool = (Double(UIDevice.current.systemVersion) ?? 0.0) >= 8.0
let iOS9Later: Bool = (Double(UIDevice.current.systemVersion) ?? 0.0) >= 9.0
let iOS10Later: Bool = (Double(UIDevice.current.systemVersion) ?? 0.0) >= 10.0
let iOS11Later: Bool = (Double(UIDevice.current.systemVersion) ?? 0.0) >= 11.0


class MainViewController: UIViewController {
    
    let openButton = UIButton()
    var imageArray: [UIImage] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let kCellId = "CellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupButton()
        setupCollectionView()
    }
    
    
    private func setupButton() {
        let atts: [String: Any] = [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.green]
        let title = NSAttributedString(string: "Open Gallery", attributes: atts)
        openButton.setAttributedTitle(title, for: .normal)
        openButton.addTarget(self, action: #selector(openButtonTapped), for: .touchUpInside)
        view.addSubview(openButton)
        openButton.addConstraints(left: view.leftAnchor, top: view.topAnchor, right: view.rightAnchor, bottom: nil, leftConstent: 0, topConstent: 60, rightConstent: 0, bottomConstent: 0, width: 0, height: 60)
    }
    
    @objc private func openButtonTapped() {
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            let alert = UIAlertController(title: "未获得相册权限", message: "请在iPhone的\"设置-隐私-相册\"中允许访问相册", preferredStyle: .alert)
            present(alert, animated: true) {
                //self.openButtonTapped()
            }
        }
//        openGalleryViewController() // plan A
        openGalleryWithAssetsPicker() // plan B
    }
    
    private func openGalleryViewController() {
        let gallery = GalleryViewController()
        gallery.delegate = self
        gallery.selectionLabelColor = .cyan
        gallery.sortAscendingByModificationDate = false
        gallery.isLatestImageOnTop = false
        gallery.thumbnailImageSize = CGSize(width: 200, height: 200)
        gallery.isUsingOriginImage = false
        gallery.fetchLimit = 260
        gallery.numberOfImagesForRow = 3
        gallery.maxSelection = 6
        present(gallery, animated: true, completion: nil)
    }
    
    private func openGalleryWithAssetsPicker() {
        //
    }
    
    private func setupCollectionView() {
        collectionView.register(GalleryViewCell.self, forCellWithReuseIdentifier: kCellId)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.addConstraints(left: view.leftAnchor, top: openButton.bottomAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 0, width: 0, height: 0)
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellId, for: indexPath) as? GalleryViewCell {
            cell.image = imageArray[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = view.bounds.width / 4.0 - 3
        return CGSize(width: h, height: h)
    }
}

extension MainViewController: GalleryViewControllerDataSource {
    
    func didFinishPickingImages(_ selectedImages: [UIImage]) {
        imageArray.removeAll(keepingCapacity: true)
        imageArray.append(contentsOf: selectedImages)
        print("get image setup, count = \(imageArray.count)")
    }
}

