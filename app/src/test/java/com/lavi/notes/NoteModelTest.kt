package com.lavi.notes

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class NoteModelTest {
    @Test fun newNoteHasSafeDefaults() {
        val note = Note()
        assertEquals("", note.title)
        assertEquals("", note.body)
        assertFalse(note.pinned)
        assertFalse(note.archived)
        assertFalse(note.deleted)
    }

    @Test fun noteFieldsArePreserved() {
        val note = Note(id = 8L, title = "Ideas", body = "Build an app", pinned = true, tags = "work,ideas")
        assertEquals(8L, note.id)
        assertEquals("Ideas", note.title)
        assertEquals("Build an app", note.body)
        assertTrue(note.pinned)
        assertEquals("work,ideas", note.tags)
    }
}
