//
//  GXHorizontalFlowLayout.swift
//  FollowLayout
//
//  Created by guan_xiang on 2018/11/17.
//  Copyright © 2018 iGola_iOS. All rights reserved.
//

import UIKit

@objc protocol GXHoritontalFlowLayoutProtocol : class {
    //MARK: - required
    /// cell的高度
    func heightForItemAtIndexPath(with indexPath : IndexPath) -> CGFloat
    
    /// cell的宽度
    func widthForItemAtIndexPath(with indexPath : IndexPath) -> CGFloat
    
    
    //MARK: - optional
    /// collectionview的行间距，默认10
    @objc optional func rowSpaceForCollectionView() -> CGFloat
    
    /// collectionview的列间距，默认10
    @objc optional func colSpaceForCollectionView() -> CGFloat
    
    /// collectionview的头部视图的高度
    @objc optional func heightForSessionHeaderView(with section : Int) -> CGFloat
    
    /// collectionview的尾部视图的高度
    @objc optional func heightForSessionFooterView(with section : Int) -> CGFloat
}

class GXHorizontalFlowLayout: UICollectionViewFlowLayout {

    public weak var delegate : GXHoritontalFlowLayoutProtocol?
    
    /// collectionview session的内边距
    private var collectionviewEdge : UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    /// collectionview的行间距
    private var rowSpace : CGFloat = 10
    
    /// collectionview的y列间距
    private var colSpace : CGFloat = 10
    
    //MARK: - 私有属性
    /// 保存所有cell的attrs
    private lazy var attrsArray : [UICollectionViewLayoutAttributes] = []
    
    /// 记录当前cell的x坐标
    private var currentX : CGFloat = 0
    
    /// 记录当前cell的y坐标
    private var currentY : CGFloat = 0
    
    /// 记录当前头部视图的高度
    private var currentHeaderH : CGFloat = 0
    
    /// 记录当前尾部视图的高度
    private var currentFooterH : CGFloat = 0
    
    /// 记录上一个cell的宽度
    private var preWidth : CGFloat = 0
    
    /// 记录最大高度，用于计算collectionVeiew.contentSize
    private var maxHeight : CGFloat = 0

    private var row : Int = 0
    override func prepare() {
        super.prepare()
        
        attrsArray.removeAll()
        currentX = 0
        currentY = 0
        preWidth = 0
        maxHeight = self.sectionInset.top
        let session = collectionView?.numberOfSections ?? 1
        
        for j in 0...(session - 1){
            let headerAttrs = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: j))
            if let headerA = headerAttrs {
                attrsArray.append(headerA)
            }
            
            let count = collectionView?.numberOfItems(inSection: j) ?? 0
            for i in 0..<count{
                let attrs = self.layoutAttributesForItem(at: IndexPath(item: i, section: j)) ?? UICollectionViewLayoutAttributes()
                attrsArray.append(attrs)
            }
            
            let footerAttrs = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: j))
            if let footerAtt = footerAttrs {
                attrsArray.append(footerAtt)
            }
        }
        
    }
    
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let collectionFrame = collectionView?.frame
        let maxWidth = (collectionFrame?.size.width ?? 0) - collectionviewEdge.left - collectionviewEdge.right

        // 获取cell宽度
        var currentWidth : CGFloat = 0.0
        currentWidth = delegate?.widthForItemAtIndexPath(with: indexPath) ?? 0
        if currentWidth > maxWidth {
            currentWidth = maxWidth
        }
        
        // 获取cell高度
        var currentHeight : CGFloat = 0.0
        currentHeight = delegate?.heightForItemAtIndexPath(with: indexPath) ?? 0
        
        // 获取内边距
        collectionviewEdge = self.sectionInset
        
        // 获取行间距
        rowSpace = delegate?.rowSpaceForCollectionView?() ?? rowSpace
        
        // 获取列间距
        colSpace = delegate?.colSpaceForCollectionView?() ?? colSpace

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                currentY = currentHeaderH + collectionviewEdge.top
                currentX = collectionviewEdge.left
            }else{
                currentX = currentX + preWidth + colSpace
                if currentWidth > maxWidth || (currentX + colSpace + currentWidth) > maxWidth {
                    currentX = collectionviewEdge.left
                    currentY = maxHeight + rowSpace
                }
            }
        }else{
            if indexPath.row == 0 {
                currentY = maxHeight + currentHeaderH
                currentX = collectionviewEdge.left
            }else{
                currentX = currentX + preWidth + colSpace
                if currentWidth > maxWidth || (currentX + colSpace + currentWidth) > maxWidth {
                    currentX = collectionviewEdge.left
                    currentY = maxHeight + rowSpace
                }
            }
        }
        preWidth = currentWidth
        maxHeight = currentY + currentHeight
        attrs.frame = CGRect(x: currentX, y: currentY, width: currentWidth, height: currentHeight)
        return attrs
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrsArray
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionView.elementKindSectionHeader {
            let headerAttr = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
            /// 获取头部视图的高度
            currentHeaderH = delegate?.heightForSessionHeaderView?(with: indexPath.section) ?? 0
            headerAttr.frame = CGRect(x: self.sectionInset.left, y: maxHeight, width: (collectionView?.bounds.size.width ?? 0) - self.sectionInset.left - self.sectionInset.right, height: currentHeaderH)
            return headerAttr
        }else if elementKind == UICollectionView.elementKindSectionFooter{
            let footerAttr = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: indexPath)
            /// 获取尾部视图的高度
            currentFooterH = delegate?.heightForSessionFooterView?(with: indexPath.section) ?? 0
            footerAttr.frame = CGRect(x: self.sectionInset.left, y: maxHeight, width: (collectionView?.bounds.size.width ?? 0) - self.sectionInset.left - self.sectionInset.right, height: currentFooterH)
            maxHeight = maxHeight + currentFooterH
            return footerAttr
        }
        return nil
    }
    
    override var collectionViewContentSize: CGSize{
        get{
            return CGSize(width: collectionView?.frame.size.width ?? 0, height: maxHeight + collectionviewEdge.bottom)
        }
    }

}
