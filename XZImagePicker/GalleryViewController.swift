//
//  GalleryViewController.swift
//  XZImagePicker
//
//  Created by Xin Zou on 6/27/18.
//  Copyright © 2018 Xin Zou. All rights reserved.
//

import UIKit
import Photos

protocol GalleryViewControllerDataSource: class {
    /// Get the selected image array from GalleryViewController
    func didFinishPickingImages(_ selectedImages: [UIImage])
}

class GalleryViewController: UIViewController {
    
    // UI contents
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    let cancelButton = UIButton()
    let doneButton = UIButton()
    
    // MARK: - config params
    
    var delegate: GalleryViewControllerDataSource?
    var selectionLabelColor = UIColor.green
    /// 从相册最新开始取（default:false）还是从最久的开始取（true）
    var sortAscendingByModificationDate = false
    /// 正序显示图片（default:true，最新的图在最上面）还是倒序显示（false:最新的图在最下面）
    var isLatestImageOnTop = true
    /// 显示的图初始大小
    var thumbnailImageSize = CGSize(width: 200, height: 200)
    /// 是否返回原图(default:false)
    var isUsingOriginImage = false
    /// 从相册取图个数（default:200）
    var fetchLimit = 200
    /// 每行显示的图个数（default:4.0）
    var numberOfImagesForRow: CGFloat = 4.0
    /// 最多能选的图片数，default: 9
    var maxSelection: Int = 9
    
    // MARK: - controller instance
    
    fileprivate var selectedCellsIndexPath: [Int] = []
    fileprivate var imageDatasource: [UIImage] = []
    
    fileprivate let kCellId = "GalleryViewCell"
    fileprivate let kInterItemSpace: CGFloat = 3
    
    
    // MARK: - view cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        grabPhotos()
    }
    
    private func setupView() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        view.addSubview(containerView)
        containerView.addConstraints(left: view.leftAnchor, top: nil, right: view.rightAnchor, bottom: view.bottomAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 0, width: 0, height: 50)
        
        let cancelAtts = [NSForegroundColorAttributeName: UIColor.darkGray, NSFontAttributeName: UIFont.systemFont(ofSize: 16)]
        let cancelTitle = NSAttributedString(string: "Cancel", attributes: cancelAtts)
        cancelButton.setAttributedTitle(cancelTitle, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonHandler), for: .touchUpInside)
        containerView.addSubview(cancelButton)
        cancelButton.addConstraints(left: containerView.leftAnchor, top: containerView.topAnchor, right: nil, bottom: containerView.bottomAnchor, leftConstent: 20, topConstent: 5, rightConstent: 0, bottomConstent: 5, width: 60, height: 0)
        
        let doneAtts = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 16)]
        let doneTitle = NSAttributedString(string: "Done", attributes: doneAtts)
        doneButton.setAttributedTitle(doneTitle, for: .normal)
        doneButton.backgroundColor = selectionLabelColor
        doneButton.addTarget(self, action: #selector(doneButtonHandler), for: .touchUpInside)
        containerView.addSubview(doneButton)
        doneButton.addConstraints(left: nil, top: cancelButton.topAnchor, right: containerView.rightAnchor, bottom: cancelButton.bottomAnchor, leftConstent: 0, topConstent: 0, rightConstent: 20, bottomConstent: 0, width: 60, height: 0)
        
        collectionView.register(GalleryViewCell.self, forCellWithReuseIdentifier: kCellId)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        view.addSubview(collectionView)
        collectionView.addConstraints(left: view.leftAnchor, top: view.topAnchor, right: view.rightAnchor, bottom: containerView.topAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 0, width: 0, height: 0)
    }
    
    /// 获取相册图片并显示
    func grabPhotos() {
        let imgManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchOtpions = PHFetchOptions()
        fetchOtpions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: sortAscendingByModificationDate)]
        fetchOtpions.fetchLimit = fetchLimit
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOtpions)
        if fetchResult.count > 0 {
            print("fetchResult.count = \(fetchResult.count)")
            for i in 0..<fetchResult.count {
                let asset: PHAsset = fetchResult.object(at: i)
                let sz = thumbnailImageSize
                imgManager.requestImage(for: asset, targetSize: sz, contentMode: .aspectFill, options: requestOptions) { (image, error) in
                    if let getImage = image {
                        if self.isLatestImageOnTop {
                            self.imageDatasource.append(getImage)
                        } else {
                            self.imageDatasource.insert(getImage, at: 0)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                if !self.isLatestImageOnTop {
                    let bottomIdx = IndexPath(item: self.imageDatasource.count - 1, section: 0)
                    self.collectionView.scrollToItem(at: bottomIdx, at: UICollectionViewScrollPosition.bottom, animated: false)
                }
            }
        } else {
            print("no photos!")
        }
    }
    
    @objc private func cancelButtonHandler() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneButtonHandler() {
        if selectedCellsIndexPath.count > 0 {
            if isUsingOriginImage {
                var originalPhotos = [UIImage]()
                
                
            } else {
                let images = selectedCellsIndexPath.map { (idx) -> UIImage in
                    if idx >= imageDatasource.count { return UIImage() }
                    return imageDatasource[idx] // datasource is thumbnail
                }
                delegate?.didFinishPickingImages(images)
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: -

extension GalleryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageDatasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellId, for: indexPath) as? GalleryViewCell {
            cell.selectionLabelColor = self.selectionLabelColor
            cell.image = imageDatasource[indexPath.item]
            cell.isSelectionEnable = isCellSelected(indexPath) || (selectedCellsIndexPath.count < maxSelection)
            cell.selectionOrder = cellSelectionOrderAt(indexPath)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GalleryViewCell else { return }
        let selectingOrder = selectedCellsIndexPath.count
        
        if cell.selectionOrder == GalleryViewCell.kSelectionOrderDeselect { // mark cell as selected:
            if selectingOrder == maxSelection { return } // not allow adding selection
            cell.selectionOrder = selectingOrder
            if indexPath.row < imageDatasource.count {
                selectedCellsIndexPath.append(indexPath.item)
            }
            if selectedCellsIndexPath.count == maxSelection {
                updateCellSelectionEnable(false)
            }
            
        } else { // mark deselect:
            if cell.selectionOrder >= 0 && cell.selectionOrder < selectedCellsIndexPath.count {
                selectedCellsIndexPath.remove(at: cell.selectionOrder)
                for i in cell.selectionOrder..<selectedCellsIndexPath.count {
                    let selectedItem = selectedCellsIndexPath[i]
                    if let updateCell = collectionView.cellForItem(at: IndexPath(item: selectedItem, section: 0)) as? GalleryViewCell {
                        updateCell.selectionOrder = i
                    }
                }
                cell.selectionOrder = GalleryViewCell.kSelectionOrderDeselect
                if selectedCellsIndexPath.count == maxSelection - 1 {
                    updateCellSelectionEnable(true)
                }
            }
        }
    }
    
    private func updateCellSelectionEnable(_ isSelectionEnable: Bool) {
        guard let cells = collectionView.visibleCells as? [GalleryViewCell] else { return }
        for cell in cells {
            if cell.selectionOrder == GalleryViewCell.kSelectionOrderDeselect {
                cell.isSelectionEnable = isSelectionEnable
            }
        }
    }
    
    // 返回某个cell应有的选择序号，若cell没被选中，返回 kSelectionOrderDeselect (-1)
    private func cellSelectionOrderAt(_ indexPath: IndexPath) -> Int {
        for (i, itemIdx) in selectedCellsIndexPath.enumerated() {
            if itemIdx == indexPath.item {
                return i
            }
        }
        return GalleryViewCell.kSelectionOrderDeselect
    }
    
    // 返回当前cell是否已被选中
    private func isCellSelected(_ indexPath: IndexPath) -> Bool {
        for selected in selectedCellsIndexPath {
            if indexPath.item == selected {
                return true
            }
        }
        return false
    }
    
}

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return kInterItemSpace
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kInterItemSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w: CGFloat = collectionView.frame.width / numberOfImagesForRow - kInterItemSpace
        return CGSize(width: w, height: w)
    }
    
}
