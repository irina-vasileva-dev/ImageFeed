import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var imageCell: UIImageView!
    
    @IBOutlet var likeButton: UIButton!
    
    @IBOutlet var dateLabel: UILabel!
    

}
