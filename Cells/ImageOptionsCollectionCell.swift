class ImageOptionsCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mediaImageView.layer.cornerRadius = 15
        self.mediaImageView.clipsToBounds = true
        self.mediaImageView.contentMode = .scaleAspectFill
    }
}

extension ImageOptionsCollectionCell: NibLoadableCell {}
