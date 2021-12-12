import UIKit
import CoreData

class NoteDetailVC: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var descTV: UITextView!
    @IBOutlet weak var OpenImage: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePicker = UIImagePickerController()
    var arrPhoto: [Note]?
    
    var selectedNote: Note? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(selectedNote != nil)
        {
            titleTF.text = selectedNote?.title
            descTV.text = selectedNote?.desc
        }
      
    }
    
    //MARK: - gallary photo view
    @IBAction func pickImageButtonPressed(_ sender: UIButton)
    {
        self.openImagePicker()
    }
    
//MARK: - save
    @IBAction func saveAction(_ sender: Any)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
//        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
//        let png = self.imageView.image?.pngData()
        if(selectedNote == nil)
        {
            let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)
            let neweNote = Note(entity: entity!, insertInto: context)
            let photo = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
            //일기, id, 제목, 내용저자
            neweNote.id = noteList.count as NSNumber
            neweNote.title = titleTF.text
            neweNote.desc = descTV.text
            neweNote.image = self.imageView.image?.jpegData(compressionQuality: 1.0)

            
            do
            {
                try context.save()
                noteList.append(neweNote)
                navigationController?.popViewController(animated: true)
            }
            catch
            {
                    print("context save error")
            }
        }
        else    //edit
        {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            do{
                let results:NSArray = try context.fetch(request) as NSArray
                for result in results
                {
                    let note = result as! Note
                    if(note == selectedNote)
                    {
                        note.title = titleTF.text
                        note.desc = descTV.text
                        note.image = self.imageView.image?.jpegData(compressionQuality: 1.0)
                        try context.save()
                        navigationController?.popViewController(animated: true)
                    }
                }
            }
            catch
            {
                print("Fetch Failed")
            }
        }
    }
    //MARK: - delete
    @IBAction func deleteDate(_ sender: Any)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        do{
            let results:NSArray = try context.fetch(request) as NSArray
            for result in results
            {
                let note = result as! Note
                if(note == selectedNote)
                {
                    note.deletedDate = Date()
                    try context.save()
                    navigationController?.popViewController(animated: true)
                }
            }
        }
        catch
        {
            print("Fetch Failed")
        }
    }
}
//MARK: - imageCoreData
extension NoteDetailVC: UIImagePickerControllerDelegate
{
    func openImagePicker(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion:  nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        if let img = info[.originalImage] as? UIImage
        {
            self.imageView.image = img
        }
    }
}
