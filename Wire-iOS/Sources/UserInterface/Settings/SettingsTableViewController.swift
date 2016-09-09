// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


import UIKit
import Cartography

class SettingsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let group: SettingsInternalGroupCellDescriptorType
    
    var tableView: UITableView?
    
    required init(group: SettingsInternalGroupCellDescriptorType) {
        self.group = group

        super.init(nibName: nil, bundle: nil)
        self.title = group.title
        
        self.group.items.flatMap { return $0.cellDescriptors }.forEach {
            if let groupDescriptor = $0 as? SettingsGroupCellDescriptorType {
                groupDescriptor.viewController = self
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError()
    }
    
    override func viewDidLoad() {
        self.createTableView()
        self.createConstraints()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SettingsTableViewController.dismissRootNavigation(_:)))
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView?.reloadData()
    }
    
    func createTableView() {
        let tableView = UITableView(frame: self.view.bounds, style: self.group.style == .plain ? .plain : .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        
        let allCellTypes: [SettingsTableCell.Type] = [SettingsGroupCell.self, SettingsButtonCell.self, SettingsToggleCell.self, SettingsValueCell.self, SettingsTextCell.self]
        
        for aClass in allCellTypes {
            tableView.register(aClass, forCellReuseIdentifier: aClass.reuseIdentifier)
        }
        self.tableView = tableView
        self.view.addSubview(tableView)
    }

    func createConstraints() {
        if let tableView = self.tableView {
            constrain(self.view, tableView) { selfView, aTableView in
                aTableView.edges == selfView.edges
            }
        }
    }
    
    func dismissRootNavigation(_ sender: AnyObject) {
        self.navigationController?.presentingViewController?.dismiss(animated: true, completion: .none)
    }
    
    // MARK: - UITableViewDelegate & UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.group.visibleItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionDescriptor = self.group.visibleItems[section]
        return sectionDescriptor.visibleCellDescriptors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionDescriptor = self.group.visibleItems[(indexPath as NSIndexPath).section]
        let cellDescriptor = sectionDescriptor.visibleCellDescriptors[(indexPath as NSIndexPath).row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: type(of: cellDescriptor).cellType.reuseIdentifier, for: indexPath) as? SettingsTableCell {
            cell.descriptor = cellDescriptor
            cellDescriptor.featureCell(cell)
            return cell
        }
        fatalError("Cannot dequeue cell for index path \(indexPath) and cellDescriptor \(cellDescriptor)")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionDescriptor = self.group.visibleItems[(indexPath as NSIndexPath).section]
        let property = sectionDescriptor.visibleCellDescriptors[(indexPath as NSIndexPath).row]
        
        property.select(.none)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionDescriptor = self.group.visibleItems[section]
        return sectionDescriptor.header
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let sectionDescriptor = self.group.visibleItems[section]
        return sectionDescriptor.footer
    }
}
