import UIKit

class UnitConverterViewController: UIViewController {
    
    @IBOutlet weak var fromBackgroundTextField: UITextField!
    @IBOutlet weak var toBackgroundTextField: UITextField!
    @IBOutlet var textFieldCollection: [UITextField]!
    
    @IBOutlet weak var unitFromButton: UIButton!
    @IBOutlet weak var unitToButton: UIButton!
    @IBOutlet weak var unitFromTextField: UITextField!
    @IBOutlet weak var unitToTextField: UITextField!
    
    @IBOutlet var numberButtonCollection: [UIButton]!
    @IBOutlet var operationButtonCollection: [UIButton]!
    
    var inputWorkings: String = ""
    
    var unitConverterManager = UnitConverterManager(selectedSection: 0)
    
    var selectedSection: Int = 0
    
    var unitFromLength: UnitLength = .millimeter
    var unitToLength: UnitLength = .centimeter
    
    var unitFromMass: UnitMass = .gram
    var unitToMass: UnitMass = .kilogram
    
    var unitFromTemperature: UnitTemperature = .celsius
    var unitToTemperature: UnitTemperature = .fahrenheit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        unitFromTextField.becomeFirstResponder()
        unitFromTextField.delegate = self
        unitToTextField.delegate = self

        configureTextFieldUI()
        unitFromTextField.inputView = UIView()
        configureUIButton()
    }
    
    @IBAction func pressedClearButton(_ sender: UIButton) {
        
        inputWorkings = ""
        unitFromTextField.text = ""
        unitToTextField.text = ""
    }
    
    @IBAction func pressedDeleteButton(_ sender: UIButton) {
     
        if(!inputWorkings.isEmpty){
            
            inputWorkings.removeLast()
            unitFromTextField.text = inputWorkings
            
            if inputWorkings.isEmpty {
                unitToTextField.text = ""
                return
            }
            
            calculateResult()
        }
    }

    @IBAction func pressedNumber(_ sender: UIButton) {
        
        inputWorkings += sender.currentTitle!
        unitFromTextField.text = inputWorkings
        calculateResult()
    }
    
    @IBAction func pressedCalculate(_ sender: UIButton) {
        calculateResult()
    }
    
    @IBAction func pressedSwap(_ sender: UIButton) {
        
        let temp: String = unitToButton.currentTitle!
        unitToButton.setTitle(unitFromButton.currentTitle!, for: .normal)
        unitFromButton.setTitle(temp, for: .normal)
        
        if selectedSection == 0 {
            let temp: UnitLength = unitFromLength
            unitFromLength = unitToLength
            unitToLength = temp
        } else if selectedSection == 1 {
            let temp: UnitMass = unitFromMass
            unitFromMass = unitToMass
            unitToMass = temp
        } else if selectedSection == 2 {
            let temp: UnitTemperature = unitFromTemperature
            unitFromTemperature = unitToTemperature
            unitToTemperature = temp
        }
        
        pressedClearButton(sender)
    }

    func calculateResult() {
        
        var result: Double = 0.0
        
        if let inputText = unitFromTextField.text {
            
            if !inputText.isEmpty{
                
                let inputNum = Double(inputText)!
                
                if selectedSection == 0 {
                    result = unitFromLength.convertTo(unit: unitToLength, value: inputNum)
                } else if selectedSection == 1 {
                    result = unitFromMass.convertTo(unit: unitToMass, value: inputNum)
                } else if selectedSection == 2 {
                    result = unitFromTemperature.convertTo(unit: unitToTemperature, value: inputNum)
                }
                
                let formattedResult = String(format: "%.1f", locale: Locale.current, Double(result))
                unitToTextField.text = formattedResult

            }
        }
    }
   
}

//MARK: - UnitPopOverFromContentControllerDelegate

extension UnitConverterViewController: UnitPopOverFromContentControllerDelegate{
    
    func didSelectFromUnit(controller: UnitPopOverFromContentController, name: String, selectedSection: Int) {
        self.selectedSection = selectedSection
        unitFromButton.setTitle(name, for: .normal)
        
        switch selectedSection{
        case 0: setUnitFromLength(for: name)
        case 1: setUnitFromMass(for: name)
        case 2: setUnitFromTemperature(for: name)
        default: return
        }
    }

    func setUnitFromLength(for name: String){
        
        if let unitLength = UnitLength.setUnit(name){
            unitFromLength = unitLength
            return
        }
        else { print("Error while setUnitFromLength()") }
    }
    
    func setUnitFromMass(for name: String){
        
        if let unitMass = UnitMass.setUnit(name){
            unitFromMass = unitMass
            return
        }
        else{ print("Error while setUnitFromMass()") }
    }
    
    func setUnitFromTemperature(for name: String){
        
        if let unitTemp = UnitTemperature.setUnit(name){
            unitFromTemperature = unitTemp
            return
        }
        else{ print("Error while setUnitFromTemperature()") }
    }
    
    func showUnitToSelectionList(){

        let button = unitToButton!
        let buttonFrame = button.frame
    
        let popoverContentController = storyboard?.instantiateViewController(withIdentifier: Constants.StoryboardID.unitPopoverToStoryboardID) as? UnitPopOverToContentController
        
        popoverContentController?.selectedSection = self.selectedSection
        popoverContentController?.modalPresentationStyle = .popover
        
        if let popoverPresentationController = popoverContentController?.popoverPresentationController{
            
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = self.unitToButton
            popoverPresentationController.sourceRect = buttonFrame
            popoverPresentationController.delegate = self
            
            popoverContentController?.unitPopOverToDelegate = self
            
            if let popoverController = popoverContentController{
                present(popoverController, animated: true, completion: nil)
            }
        }
    }
}

//MARK: - UnitPopOverToContentControllerDelegate

extension UnitConverterViewController: UnitPopOverToContentControllerDelegate{
    
    func didSelectToUnit(controller: UnitPopOverToContentController, name: String) {
        
        unitToButton.setTitle(name, for: .normal)
        switch selectedSection{
        case 0: setUnitToLength(for: name)
        case 1: setUnitToMass(for: name)
        case 2: setUnitToTemperature(for: name)
        default: return
        }
        unitFromTextField.text = ""
        unitToTextField.text = ""
        inputWorkings = ""
    }
    
    func setUnitToLength(for name: String){
        
        if let unitLength = UnitLength.setUnit(name){
            unitToLength = unitLength
            return
        }
        else { print("Error while setUnitToLength()") }
    }
    
    func setUnitToMass(for name: String){
        
        if let unitMass = UnitMass.setUnit(name){
            unitToMass = unitMass
            return
        }
        else { print("Error while setUnitToMass()") }
        
    }
    
    func setUnitToTemperature(for name: String){
        
        if let unitTemp = UnitTemperature.setUnit(name){
            unitToTemperature = unitTemp
            return
        }
        else { print("Error while setUnitToTemperature()") }
    }
 
}

//MARK: - @IBAction Methods to show Unit Selection Popovers

extension UnitConverterViewController{
    
    @IBAction func showUnitFromSelectionListButton(_ sender: UIButton) {
        
        let button = sender as UIButton
        let buttonFrame = button.frame
        
        let popoverContentController = storyboard?.instantiateViewController(withIdentifier: Constants.StoryboardID.unitPopoverFromStoryboardID) as? UnitPopOverFromContentController
        popoverContentController?.modalPresentationStyle = .popover
        
        if let popoverPresentationController = popoverContentController?.popoverPresentationController{
            
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = self.unitFromButton
            popoverPresentationController.sourceRect = buttonFrame
            popoverPresentationController.delegate = self
            
            popoverContentController?.unitPopOverDelegate = self
            
            if let popoverController = popoverContentController{
                present(popoverController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func showUnitToSelectionListButton(_ sender: UIButton) {
        showUnitToSelectionList()
    }
}

//MARK: - UIPopoverPresentationControllerDelegate

extension UnitConverterViewController: UIPopoverPresentationControllerDelegate{

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return true
    }
}

//MARK: - UITextFieldDelegate

extension UnitConverterViewController: UITextFieldDelegate{
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
          self.view.endEditing(true)
    }
}

//MARK: - UI Configuration Methods

extension UnitConverterViewController {
    
    func setButtonUI(for button: UIButton, color: UIColor) {
        
        button.backgroundColor = color
        button.layer.cornerRadius = button.frame.width / 2
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 35)
        //button.titleLabel?.font = UIFont(name: "Apple SD Gothic Neo Bold", size: 30)
    }
    
    func configureUIButton() {
    
        // Number buttons
        for button in numberButtonCollection {
            setButtonUI(for: button, color: .white)
        }
        
        // Operation buttons - Basic configurations
        for button in operationButtonCollection {
            
            let color = UIColor(red: 0.98, green: 0.70, blue: 0.26, alpha: 1.00)
            
            setButtonUI(for: button, color: color)
        }
        
        // Separate button configurations for each operation buttons
        let smallConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .small)
        
        // Equal button
        let equalButtonImage = UIImage(systemName: "equal", withConfiguration: smallConfiguration)
        operationButtonCollection[0].setImage(equalButtonImage, for: .normal)
        
        // Swap button
        var swapButtonImage = UIImage(named: "swapbutton_icon2")
        swapButtonImage = swapButtonImage?.scalePreservingAspectRatio(targetSize: CGSize(width: 60, height: 60))
        operationButtonCollection[1].setImage(swapButtonImage, for: .normal)
        
        
        // Clear button
        operationButtonCollection[2].titleLabel?.font = UIFont(name: "Helvetica", size: 40)

        // Delete button
        let deleteButtonImage = UIImage(systemName: "delete.left.fill", withConfiguration: smallConfiguration)
        operationButtonCollection[3].setImage(deleteButtonImage, for: .normal)
    }
    
    func configureTextFieldUI() {
 
        for textField in textFieldCollection {

            textField.borderStyle = .none
            textField.backgroundColor = .white

            //To apply corner radius
            textField.layer.cornerRadius = 30

            //To apply border
            textField.layer.borderWidth = 0.25
            textField.layer.borderColor = UIColor.white.cgColor
        }
        
    }
}
