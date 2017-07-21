class TextOptionsCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var slotButton: UIButton!
    @IBOutlet weak var slotButtonWidthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.slotButton.layer.cornerRadius = 4
        self.slotButton.backgroundColor = UIColor.gray
        self.slotButton.titleLabel?.textColor = .white

        slotButtonWidthConstraint = slotButton.widthAnchor.constraint(equalToConstant: 0)
        slotButtonWidthConstraint.isActive = true
    }

    override var isSelected: Bool {
        didSet {
            self.slotButton.isSelected = isSelected
        }
    }
}

extension TextOptionsCollectionCell: NibLoadableCell {}
