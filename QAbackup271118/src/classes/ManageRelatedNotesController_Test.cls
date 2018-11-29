/****** v1 | Description: Test methods for manage realted notes methods | 12/11/2017 | L OMeara */
@isTest
public class ManageRelatedNotesController_Test {
    static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
    static final Id AccountTypeCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ACCOUNT_TYPE_CUSTOMER).getRecordTypeId();
    
    /* test get a list of notes related to a record */
    @isTest
    static void testGetRelatedNotes() {
        // create test data
        Account testCustomer = new Account(    
            RecordtypeId = AccountTypeCustomer,
            FirstName ='TestCoverage',
            LastName = 'Person', 
            PersonEmail = 'tc@example.com', 
            Phone = '615-555-1212', 
            Primary_Language__pc = 'English'
        );
        insert testCustomer;
        List<NoteWrapper> notes = new List<NoteWrapper> ();
        integer targetSize = 10;
        for (Integer i = 0; i < targetSize; i++) {
            notes.add(new NoteWrapper(null, 'test title '+i, 'test body '+i));
        }
        
        ManageRelatedNotesController.addAllNotes(testCustomer.Id, notes);
        
        List<NoteWrapper>foundNotes = ManageRelatedNotesController.getRelatedNotes(testCustomer.id);
        system.assertEquals(foundNotes.size(), targetSize);
    }
    
    /* test adding a note to a record */
    @isTest
    static void testAddUpdateAndDeleteNote() {
        // create test data
        Account testCustomer = new Account(    
            RecordtypeId = AccountTypeCustomer,
            FirstName ='TestCoverage',
            LastName = 'Person', 
            PersonEmail = 'tc@example.com', 
            Phone = '615-555-1212', 
            Primary_Language__pc = 'English'
        );
        insert testCustomer;

        // test add
        NoteWrapper testNote = new NoteWrapper(null, 'test single note title', 'test single note body');
        ID noteId = ManageRelatedNotesController.addNote(testCustomer.Id, JSON.serialize(testNote));
        system.assertNotEquals(noteId, null);
        
        // test update
        testNote.id = noteId; 
        testNote.title = 'new title';
        testNote.body = 'new body';
        ManageRelatedNotesController.addNote(testCustomer.Id, JSON.serialize(testNote));
        
        // test delete
        ManageRelatedNotesController.deleteNote(noteId);
    }
    
    /* test adding a note, with exception */
    @isTest
    static void testAddNoteException() {
        NoteWrapper testNote = new NoteWrapper(null, 'test single note title', 'test single note body');
        try {
            ID noteId = ManageRelatedNotesController.addNote(null, JSON.serialize(testNote));
        } catch (Exception e) {
            system.debug('got exception');
		}
    }
}