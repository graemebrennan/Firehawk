//
//  DetailHouseNameViewController.swift
//  FireHawk
//
//  Created by Tam Nguyen on 10/28/20.
//

import UIKit

class DetailHouseNameViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  
  static func route() -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let vc = storyboard.instantiateViewController(identifier: "DetailHouseNameViewController") as? DetailHouseNameViewController else {
      return UIViewController()
    }
    return vc
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      tableView.register(UINib(nibName: "HouseCell", bundle: nil), forCellReuseIdentifier: "HouseCellIdentifier")
      tableView.dataSource = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension DetailHouseNameViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "HouseCellIdentifier", for: indexPath) as! HouseCell
      return cell
    }
    

    
}

extension DetailHouseNameViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "menuVCToHouse", sender: self)
        print( "selected row \(indexPath.row) ")
    }
}
