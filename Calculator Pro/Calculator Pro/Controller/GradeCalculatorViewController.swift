
import UIKit

class GradeCalculatorViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalCreditLabel: UILabel!
    @IBOutlet weak var totalGradeLabel: UILabel!
    @IBOutlet weak var highestPossibleGradeTextField: UITextField!
    
    var selectedHighestPossibleGrade: Double = 0.0
    
    var gradeCalculatorManager = GradeCalculatorManager(totalCredit: 0, totalGrade: 0.0)
    
    var loadedGradeInfo = [GradeInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        highestPossibleGradeTextField.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        loadedGradeInfo = gradeCalculatorManager.loadUserDefaultData()
       
        tableView.register(UINib(nibName: Constants.GradeCalcStrings.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.GradeCalcStrings.cellIdentifier)
        
        createPickerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    @IBAction func pressedAddButton(_ sender: UIButton) {
        
        if totalGradeInfo.count == 10 || loadedGradeInfo.count == 10 {
            createAlertMessage("과목 수 제한", "10개 이상의 과목을 입력할 수 없습니다.")
            return
        }

        createNewGradeInfo()        // and append to totalGradeInfo[]
        gradeCalculatorManager.saveToUserDefaults(totalGradeInfo)
        loadedGradeInfo = gradeCalculatorManager.loadUserDefaultData()
        
        tableView.insertRows(at: [IndexPath(row:totalGradeInfo.count - 1, section: 0)], with: .bottom)

        
    }
    
    @IBAction func pressedCalculate(_ sender: UIButton) {

        self.view.endEditing(true)
    
        let totalCredit = gradeCalculatorManager.calculateFinalCredit(totalGradeInfo)
        let totalGrade = gradeCalculatorManager.calculateFinalGrade(totalGradeInfo)
        
        // User Defaults에 이때까지 작성한 데이터 저장
        gradeCalculatorManager.saveToUserDefaults(totalGradeInfo)
        
        print(totalCredit)
        print(totalGrade)

        totalCreditLabel.text = String(format: "%d", totalCredit)
        totalGradeLabel.text = String(format: "%.2f", totalGrade)
    }
    
    
    
}

//MARK: - Methods

extension GradeCalculatorViewController{
    
    func createNewGradeInfo(){
        
        let newGradeInfo = GradeInfo(lectureName: nil, credit: nil, grade: nil)
        totalGradeInfo.append(newGradeInfo)
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate

extension GradeCalculatorViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // User Defaults 에 정보가 저장되어 있으면~
        if loadedGradeInfo.count > 0 {
            totalGradeInfo = loadedGradeInfo
            return loadedGradeInfo.count
        } else {
            return totalGradeInfo.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.GradeCalcStrings.cellIdentifier, for: indexPath) as! GradeCell
        
        print("indexPath: \(indexPath.row)")
       
        
        if loadedGradeInfo.count > 0 {

            
            if let credit = loadedGradeInfo[indexPath.row].credit, let grade = loadedGradeInfo[indexPath.row].grade {
                
            
                let creditString = String(format: "%d", credit)
                let gradeString = cell.convertGradeDoubleToString(grade)
                
                cell.creditTextField.text = creditString
                cell.gradeTextField.text = gradeString
                cell.lectureTextField.text = loadedGradeInfo[indexPath.row].lectureName
                cell.tagNum = indexPath.row
                cell.highestPossibleGrade = selectedHighestPossibleGrade
                cell.gradeCellDelegate = self
                
            }
            else {
                cell.tagNum = indexPath.row
                cell.highestPossibleGrade = selectedHighestPossibleGrade
                cell.gradeCellDelegate = self
            }
        }
        
        else {
            cell.lectureTextField.text = ""
            cell.creditTextField.text = ""
            cell.gradeTextField.text = ""
            cell.tagNum = indexPath.row
            cell.highestPossibleGrade = selectedHighestPossibleGrade
            cell.gradeCellDelegate = self
            
            //createNewGradeInfo()
            
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
        if editingStyle == .delete{
            
            tableView.beginUpdates()
            
            print("trying to delete indexPath: \(indexPath.row)")
            
            
            totalGradeInfo.remove(at: indexPath.row)
            loadedGradeInfo.remove(at: indexPath.row)
         
            tableView.deleteRows(at: [indexPath], with: .fade )
            
            
            print("count of totalGradeInfo: \(totalGradeInfo.count)")
            
            tableView.endUpdates()
            
            gradeCalculatorManager.saveToUserDefaults(loadedGradeInfo)
            loadedGradeInfo = gradeCalculatorManager.loadUserDefaultData()
        }
    }
}

//MARK: - GradeCellDelegate

extension GradeCalculatorViewController: GradeCellDelegate{
    
    func didChangeLectureName(lecture: String, tagNum: Int, cell: GradeCell) {
        totalGradeInfo[tagNum].lectureName = lecture
        gradeCalculatorManager.saveToUserDefaults(totalGradeInfo)
    }
    
    func didChangeCredit(credit: Int, tagNum: Int, cell: GradeCell) {
        totalGradeInfo[tagNum].credit = credit
        print("didChangeCredit activated: \(credit)")
        gradeCalculatorManager.saveToUserDefaults(totalGradeInfo)
    }

    func didChangeGrade(grade: Double, tagNum: Int, cell: GradeCell) {
        totalGradeInfo[tagNum].grade = grade
        print("didChangeGrade activated: \(grade)")
        gradeCalculatorManager.saveToUserDefaults(totalGradeInfo)
    }
    
}

//MARK: - UITextFieldDelegate

extension GradeCalculatorViewController: UITextFieldDelegate{
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
          self.view.endEditing(true)
    }
}

//MARK: - Picker View Related Methods & UIPickerViewDataSource & Delegate Methods
// The below picker view related methods are for picking ["4.5", "4.3"], not the ones in Grade Cell

extension GradeCalculatorViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    func createPickerView(){
        
        let highestGradePickerView = UIPickerView()
        highestGradePickerView.backgroundColor = .white
        highestGradePickerView.dataSource = self
        highestGradePickerView.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .systemBlue
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "완료", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.dismissPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "취소", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.dismissPicker))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        highestPossibleGradeTextField.inputView = highestGradePickerView
        highestPossibleGradeTextField.inputAccessoryView = toolBar
    }
    
    @objc func dismissPicker(){
        
        highestPossibleGradeTextField.endEditing(true)
        highestPossibleGradeTextField.resignFirstResponder()
        tableView.reloadData()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.GradeCalcStrings.highestPossibleGradeArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.GradeCalcStrings.highestPossibleGradeArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let selectedOption = Constants.GradeCalcStrings.highestPossibleGradeArray[row]
        
        highestPossibleGradeTextField.text = selectedOption
        selectedHighestPossibleGrade = Double(selectedOption) ?? 4.5
    }
    
}

//MARK: - Alert Handling Method
extension GradeCalculatorViewController{
    
    func createAlertMessage(_ title: String, _ message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
