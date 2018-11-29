/****** v2 | Description: Methods for managing notes related to a parent object | 12/7/2017 | L OMeara */
public with sharing class ManageRelatedNotesController {
    /* method used by add customer lightning component to create all customer related records from 
     * customer create form */
    @AuraEnabled
    public static List<NoteWrapper> getRelatedNotes(Id parentId) 
    {
        List<NoteWrapper> notes = new List<NoteWrapper> ();
        
        List<ContentDocumentLink> linksList = [SELECT id, LinkedEntityId , contentDocumentId, 
                                               contentDocument.latestPublishedVersionId, 
                                               contentDocument.latestPublishedVersion.title, 
                                               contentDocument.latestPublishedVersion.versionData
                                               FROM ContentDocumentLink WHERE LinkedEntityId=:parentId
                                               AND contentDocument.latestPublishedVersion.fileType='SNOTE'];
        for(ContentDocumentLink cdl:linksList) {
            NoteWrapper note = new NoteWrapper(cdl.ContentDocumentId,
                cdl.contentDocument.latestPublishedVersion.title, 
                cdl.contentDocument.latestPublishedVersion.versionData.toString().replaceAll('<[^>]+>',' '));
            notes.add(note);
        }

        return notes;
    }
    
    @AuraEnabled
    public static void deleteNote(Id noteId) 
    {
        Savepoint sp = Database.setSavepoint();
        try { 
            List<ContentDocument> docs = [SELECT id FROM ContentDocument WHERE Id=:noteId];
            delete docs;
        } catch (exception e) {
            Database.rollback(sp);
            system.debug(e.getMessage());
            throw new AuraHandledException('Could not delete note: ' + e.getMessage());   
        }
    }
    
    private static id createNote(Id parentId, NoteWrapper newNote) {
        ContentNote noteEntry = new ContentNote(
            Title = newNote.title.escapeHtml4(), 
            Content = Blob.valueOf(newNote.body.escapeHtml4())
        );
        insert noteEntry; 
        
        ContentDocumentLink noteLink = new ContentDocumentLink(
            ContentDocumentId = noteEntry.Id,
            LinkedEntityId = parentId,
            Visibility = 'AllUsers', // The file is available to all users who have permission to see the file.
            ShareType = 'I' // Inferred permission. The user’s permission is determined by the related record.
        );
        insert noteLink;         
        
        return noteEntry.Id;
    }
    
    private static id updateNote(NoteWrapper newNote) {
        ContentNote noteEntry = new ContentNote(
            Id = newNote.id,
            Title = newNote.title, 
            Content = Blob.valueOf(newNote.body.escapeHtml4())
        );
        update noteEntry;
        return newNote.id;
    }
    
    @AuraEnabled
    public static Id addNote(Id parentId, String noteObjStr) 
    {
        Savepoint sp = Database.setSavepoint();
        try { 
            NoteWrapper newNote = (NoteWrapper)JSON.deserialize(noteObjStr, NoteWrapper.class);
            
            if (newNote.id == null ) {
                return createNote(parentId, newNote);
            } else {
                return updateNote(newNote);
            }
        } catch (exception e) {
            Database.rollback(sp);
            system.debug(e.getMessage());
            throw new AuraHandledException('Could not create note: ' + e.getMessage());   
        }
    }

    // method to add a list of notes to a record
    @AuraEnabled
    public static void addAllNotes(Id parentId, List<NoteWrapper> notes) 
    {
        List<ContentNote> notesList = new List<ContentNote>();        
        
        for (NoteWrapper note : notes) {
            notesList.add(new ContentNote(
                Title = note.title, 
                Content = Blob.valueOf(note.body)
            ));
        }
        
        if (notesList.size() > 0) {
            insert notesList;                 
            List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
            for (ContentNote n : notesList) {
                linkList.add(new ContentDocumentLink(
                    ContentDocumentId = n.Id,
                    LinkedEntityId = parentId,
                    Visibility = 'AllUsers', // The file is available to all users who have permission to see the file.
                    ShareType = 'I' // Inferred permission. The user’s permission is determined by the related record.
                ));
            }
            insert linkList;
        }
    }    
}