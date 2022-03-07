

import UIKit

class InfoVC: UIViewController {
    
    var receivedString = " "
    
    @IBOutlet weak var closeButton: UIButton!
    @IBAction func closeButtonUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var text: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        text.text = receivedString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
