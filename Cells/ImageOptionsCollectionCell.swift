class ImageOptionsCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mediaImageView.layer.cornerRadius = 10
    }
}

extension ImageOptionsCollectionCell: NibLoadableCell {}
