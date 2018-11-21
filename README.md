# GXHorizontalFlowLayout
UICollectionView horizontal waterfall flow layout supports multiple sections of headerView and FooterView

### 初始化
```
let flowLayout = GXHorizontalFlowLayout()
flowLayout.delegate = self
flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
let collectionview = UICollectionView(frame: CGRect(x: 0, y: 88, width: UIScreen.main.bounds.size.width, height: 400), collectionViewLayout: flowLayout)
collectionview.backgroundColor = UIColor.orange
collectionview.dataSource = self
collectionview.delegate = self
collectionview.register(iGolaCell.self, forCellWithReuseIdentifier: "cell")
collectionview.register(iGolaCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
collectionview.register(iGolaCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
view.addSubview(collectionview)
collectionview.reloadData()
```
### 自定义flowLayout代理方法
```
//MARK: - required
/// cell的高度 
func heightForItemAtIndexPath(with indexPath: IndexPath) -> CGFloat {
return 44
}
/// cell的宽度
func widthForItemAtIndexPath(with indexPath: IndexPath) -> CGFloat {
return widthArray[indexPath.section][indexPath.row]
}

mark://- optional
/// collectionview的行间距，默认10
func rowSpaceForCollectionView() -> CGFloat {
return 10
}

/// collectionview的列间距，默认10
func colSpaceForCollectionView() -> CGFloat {
return 10
}

/// collectionview的头部视图的高度
func heightForSessionHeaderView(with section : Int) -> CGFloat {
return 50
}
/// collectionview的尾部视图的高度
func heightForSessionFooterView(with section: Int) -> CGFloat {
return 50
}
```


### 数据源
```
func numberOfSections(in collectionView: UICollectionView) -> Int {
return dataArray.count
}

func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
return dataArray[section].count
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! iGolaCell
cell.title.text = dataArray[indexPath.section][indexPath.row]
return cell
}

func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
dataArray[indexPath.section].remove(at: indexPath.row)
widthArray[indexPath.section].remove(at: indexPath.row)
collectionView.reloadData()
}

func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
if kind == UICollectionView.elementKindSectionHeader {
let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as? iGolaCollectionViewHeader
guard let _ = header else{
let headView = iGolaCollectionViewHeader(frame: CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: 80))
headView.title.text = "\(indexPath.section)组"
headView.backgroundColor = UIColor.purple
return headView
}
header?.backgroundColor = UIColor.red
header?.title.text = "\(indexPath.section)组头部视图"
return header!
}else if kind == UICollectionView.elementKindSectionFooter{
let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer", for: indexPath) as? iGolaCollectionViewHeader
guard let _ = footer else{
let footer = iGolaCollectionViewHeader(frame: CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: 80))
footer.title.text = "\(indexPath.section)组"
footer.backgroundColor = UIColor.red
return footer
}
footer?.backgroundColor = UIColor.blue
footer?.title.text = "\(indexPath.section)组尾部视图"
return footer!
}
return UICollectionReusableView()
}
```


