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

protocol SettingsCellType: class {
    var titleText: String {get set}
    var valueText: String {get set}
    var titleColor: UIColor {get set}
    var descriptor: SettingsCellDescriptorType? {get set}
}

class SettingsTableCell: UITableViewCell, SettingsCellType {
    var cellNameLabel: UILabel = UILabel(frame: CGRect.zero)
    var valueLabel: UILabel = UILabel(frame: CGRect.zero)
    
    var titleText: String = "" {
        didSet {
            self.cellNameLabel.text = self.titleText
        }
    }
    
    var valueText: String = "" {
        didSet {
            self.valueLabel.text = self.valueText
        }
    }
    
    var titleColor: UIColor = UIColor.darkText {
        didSet {
            self.cellNameLabel.textColor = self.titleColor
        }
    }
    
    var descriptor: SettingsCellDescriptorType?
    
    override var reuseIdentifier: String {
        get {
            return type(of: self).reuseIdentifier
        }
    }
    
    static var reuseIdentifier: String {
        return "\(self)" + "ReuseIdentifier"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.cellNameLabel.font = UIFont.systemFont(ofSize: 17)
        self.cellNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.cellNameLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        self.contentView.addSubview(self.cellNameLabel)
        
        constrain(self.contentView, self.cellNameLabel) { contentView, cellNameLabel in
            cellNameLabel.left == contentView.left + 20
            cellNameLabel.top == contentView.top + 12
            cellNameLabel.bottom == contentView.bottom - 12
        }
        
        self.valueLabel.textColor = UIColor.gray
        self.valueLabel.font = UIFont.systemFont(ofSize: 17)
        self.valueLabel.translatesAutoresizingMaskIntoConstraints = false
        self.valueLabel.textAlignment = .right
        
        self.contentView.addSubview(self.valueLabel)
        
        constrain(self.contentView, self.cellNameLabel, self.valueLabel) { contentView, cellNameLabel, valueLabel in
            valueLabel.top == contentView.top - 8
            valueLabel.bottom == contentView.bottom + 8
            valueLabel.left == cellNameLabel.right + 8
            valueLabel.right == contentView.right - 16
        }
    }
}

class SettingsGroupCell: SettingsTableCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func setup() {
        super.setup()
        self.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
    }
}

class SettingsButtonCell: SettingsTableCell {
    override func setup() {
        super.setup()
        self.cellNameLabel.textColor = UIColor.accentColor
    }
}

class SettingsToggleCell: SettingsTableCell {
    var switchView: UISwitch!
    
    override func setup() {
        super.setup()
        
        self.selectionStyle = .none
        
        self.switchView = UISwitch(frame: CGRect.zero)
        self.switchView.addTarget(self, action: #selector(SettingsToggleCell.onSwitchChanged(_:)), for: .valueChanged)
        self.accessoryView = self.switchView
    }
    
    func onSwitchChanged(_ sender: UIResponder) {
        self.descriptor?.select(SettingsPropertyValue.bool(value: self.switchView.isOn))
    }
}

class SettingsValueCell: SettingsTableCell {
    override var descriptor: SettingsCellDescriptorType?{
        willSet {
            if let propertyDescriptor = self.descriptor as? SettingsPropertyCellDescriptorType {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: propertyDescriptor.settingsProperty.propertyName.changeNotificationName), object: nil)
            }
        }
        didSet {
            if let propertyDescriptor = self.descriptor as? SettingsPropertyCellDescriptorType {
                NotificationCenter.default.addObserver(self, selector: #selector(SettingsValueCell.onPropertyChanged(_:)), name: NSNotification.Name(rawValue: propertyDescriptor.settingsProperty.propertyName.changeNotificationName), object: nil)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Properties observing
    
    func onPropertyChanged(_ notification: Notification) {
        self.descriptor?.featureCell(self)
    }
}

class SettingsTextCell: SettingsTableCell, UITextFieldDelegate {
    var textInput: UITextField!

    override func setup() {
        super.setup()
        self.selectionStyle = .none
        
        self.textInput = TailEditingTextField(frame: CGRect.zero)
        self.textInput.translatesAutoresizingMaskIntoConstraints = false
        self.textInput.delegate = self
        self.textInput.textAlignment = .right

        self.contentView.addSubview(self.textInput)
        
        constrain(self.contentView, self.cellNameLabel, self.textInput) { contentView, cellNameLabel, textInput in
            textInput.top == contentView.top - 8
            textInput.bottom == contentView.bottom + 8
            textInput.left == cellNameLabel.right + 8
            textInput.right == contentView.right - 16
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.rangeOfCharacter(from: CharacterSet.newlines) != .none {
            textField.resignFirstResponder()
            return false
        }
        else {
            return true
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = self.textInput.text {
            self.descriptor?.select(SettingsPropertyValue.string(value: text))
        }
    }
}
