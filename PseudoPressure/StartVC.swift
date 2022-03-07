
import UIKit

class StartVC: UIViewController {

    @IBOutlet weak var textID: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBAction func startButtonUpInside(_ sender: Any) {
        USER_ID = textID.text!
        performSegue(withIdentifier: "StartToTrain", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

