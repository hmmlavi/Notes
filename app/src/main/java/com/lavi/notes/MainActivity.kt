package com.lavi.notes

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Archive
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.EditNote
import androidx.compose.material.icons.filled.Lightbulb
import androidx.compose.material.icons.filled.PushPin
import androidx.compose.material.icons.filled.Restore
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

data class Note(
    val id: Long = 0L,
    val title: String = "",
    val body: String = "",
    val updatedAt: Long = System.currentTimeMillis(),
    val pinned: Boolean = false,
    val archived: Boolean = false,
    val deleted: Boolean = false,
    val tags: String = ""
)

private class NotesDb(context: Context) : SQLiteOpenHelper(context, "notes_by_lavi.db", null, 1) {
    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL("CREATE TABLE notes (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL DEFAULT '', body TEXT NOT NULL DEFAULT '', updated_at INTEGER NOT NULL, pinned INTEGER NOT NULL DEFAULT 0, archived INTEGER NOT NULL DEFAULT 0, deleted INTEGER NOT NULL DEFAULT 0, tags TEXT NOT NULL DEFAULT '')")
    }
    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) = Unit

    fun all(): List<Note> {
        val result = mutableListOf<Note>()
        readableDatabase.query("notes", null, null, null, null, null, "pinned DESC, updated_at DESC").use { c ->
            while (c.moveToNext()) result.add(Note(
                id = c.getLong(c.getColumnIndexOrThrow("id")),
                title = c.getString(c.getColumnIndexOrThrow("title")) ?: "",
                body = c.getString(c.getColumnIndexOrThrow("body")) ?: "",
                updatedAt = c.getLong(c.getColumnIndexOrThrow("updated_at")),
                pinned = c.getInt(c.getColumnIndexOrThrow("pinned")) == 1,
                archived = c.getInt(c.getColumnIndexOrThrow("archived")) == 1,
                deleted = c.getInt(c.getColumnIndexOrThrow("deleted")) == 1,
                tags = c.getString(c.getColumnIndexOrThrow("tags")) ?: ""
            ))
        }
        return result
    }
    fun save(note: Note): Long {
        val values = ContentValues().apply {
            put("title", note.title); put("body", note.body)
            put("updated_at", System.currentTimeMillis())
            put("pinned", if (note.pinned) 1 else 0)
            put("archived", if (note.archived) 1 else 0)
            put("deleted", if (note.deleted) 1 else 0)
            put("tags", note.tags)
        }
        return if (note.id == 0L) writableDatabase.insert("notes", null, values) else {
            writableDatabase.update("notes", values, "id=?", arrayOf(note.id.toString())); note.id
        }
    }
    fun flag(id: Long, field: String, value: Boolean) {
        require(field in setOf("pinned", "archived", "deleted"))
        val values = ContentValues().apply {
            put(field, if (value) 1 else 0); put("updated_at", System.currentTimeMillis())
        }
        writableDatabase.update("notes", values, "id=?", arrayOf(id.toString()))
    }
    fun deleteForever(id: Long) { writableDatabase.delete("notes", "id=?", arrayOf(id.toString())) }
}

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val db = NotesDb(applicationContext)
        val prefs = getSharedPreferences("notes_preferences", Context.MODE_PRIVATE)
        setContent { NotesApp(db, prefs.getBoolean("amoled", false)) { prefs.edit().putBoolean("amoled", it).apply() } }
    }
}

private val Brand = Color(0xFF7569D9)
private val BrandSoft = Color(0xFFECE9FF)
private val Muted = Color(0xFF858392)
private val LightCard = Color(0xFFF7F6FC)
private val DarkText = Color(0xFF252433)
private val Peach = Color(0xFFFFE9D8)

@Composable
private fun NotesApp(db: NotesDb, initialDark: Boolean, onThemeChanged: (Boolean) -> Unit) {
    var dark by remember { mutableStateOf(initialDark) }
    var notes by remember { mutableStateOf(db.all()) }
    var screen by remember { mutableStateOf("Notes") }
    var editing by remember { mutableStateOf<Note?>(null) }
    var query by remember { mutableStateOf("") }
    var showSettings by remember { mutableStateOf(false) }

    val canvas = if (dark) Color.Black else Color(0xFFFFFFFF)
    val ink = if (dark) Color.White else DarkText
    val card = LightCard // Intentionally light, tactile surfaces even over the AMOLED canvas.
    fun refresh() { notes = db.all() }
    fun saveNote(note: Note): Note {
        val id = db.save(note); refresh()
        return note.copy(id = if (note.id == 0L) id else note.id, updatedAt = System.currentTimeMillis())
    }

    MaterialTheme(colorScheme = lightColorScheme(primary = Brand, background = canvas, surface = card, onSurface = DarkText)) {
        Surface(Modifier.fillMaxSize(), color = canvas) {
            when {
                editing != null -> {
                    val original = editing!!
                    var title by remember(original.id) { mutableStateOf(original.title) }
                    var body by remember(original.id) { mutableStateOf(original.body) }
                    var tags by remember(original.id) { mutableStateOf(original.tags) }
                    var pinned by remember(original.id) { mutableStateOf(original.pinned) }
                    Column(Modifier.fillMaxSize().padding(horizontal = 20.dp)) {
                        Row(Modifier.fillMaxWidth().padding(top = 10.dp, bottom = 16.dp), verticalAlignment = Alignment.CenterVertically) {
                            IconButton(onClick = { editing = null }) { Icon(Icons.Default.ArrowBack, "Back", tint = ink) }
                            Column(Modifier.weight(1f)) {
                                Text("YOUR NOTE", color = Brand, fontSize = 10.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.6.sp)
                                Text("Saved on this device", color = Muted, fontSize = 12.sp)
                            }
                            IconButton(onClick = { pinned = !pinned; editing = saveNote(original.copy(title = title, body = body, tags = tags, pinned = pinned)) }) {
                                Icon(Icons.Default.PushPin, "Toggle pin", tint = if (pinned) Brand else Muted)
                            }
                            IconButton(onClick = { editing = null }) { Icon(Icons.Default.Check, "Done", tint = Brand) }
                        }
                        BasicTextField(
                            value = title,
                            onValueChange = { title = it; editing = saveNote(original.copy(title = it, body = body, tags = tags, pinned = pinned)) },
                            modifier = Modifier.fillMaxWidth().padding(top = 12.dp, bottom = 8.dp),
                            textStyle = TextStyle(color = ink, fontSize = 30.sp, fontWeight = FontWeight.Bold, lineHeight = 36.sp),
                            keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Sentences),
                            decorationBox = { inner -> Box { if (title.isEmpty()) Text("Give this note a title", color = Muted, fontSize = 30.sp, fontWeight = FontWeight.Bold); inner() } }
                        )
                        HorizontalDivider(color = if (dark) Color(0xFF242329) else Color(0xFFEAE8F1))
                        BasicTextField(
                            value = body,
                            onValueChange = { body = it; editing = saveNote(original.copy(title = title, body = it, tags = tags, pinned = pinned)) },
                            modifier = Modifier.fillMaxWidth().weight(1f).padding(top = 18.dp, bottom = 12.dp),
                            textStyle = TextStyle(color = ink, fontSize = 17.sp, lineHeight = 28.sp),
                            keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Sentences),
                            decorationBox = { inner -> Box { if (body.isEmpty()) Text("A thought, a plan, a little reminder…\n\nStart wherever you are.", color = Muted, fontSize = 17.sp, lineHeight = 27.sp); inner() } }
                        )
                        Column(Modifier.fillMaxWidth().background(card, RoundedCornerShape(18.dp)).padding(14.dp)) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text("TAGS", color = Muted, fontSize = 10.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.2.sp)
                                Spacer(Modifier.width(10.dp))
                                BasicTextField(
                                    value = tags, onValueChange = { tags = it; editing = saveNote(original.copy(title = title, body = body, tags = it, pinned = pinned)) },
                                    modifier = Modifier.weight(1f),
                                    textStyle = TextStyle(color = Brand, fontSize = 13.sp),
                                    decorationBox = { inner -> Box { if (tags.isEmpty()) Text("ideas, work, personal", color = Muted, fontSize = 13.sp); inner() } }
                                )
                            }
                            Spacer(Modifier.height(8.dp))
                            Text("${(title + " " + body).trim().split(Regex("\\s+")).count { it.isNotBlank() }} words  ·  Stored locally", color = Muted, fontSize = 11.sp)
                        }
                        Spacer(Modifier.height(12.dp))
                    }
                }
                showSettings -> {
                    Column(Modifier.fillMaxSize().padding(22.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            IconButton(onClick = { showSettings = false }) { Icon(Icons.Default.ArrowBack, "Back", tint = ink) }
                            Text("Settings", fontSize = 28.sp, fontWeight = FontWeight.Bold, color = ink)
                        }
                        Spacer(Modifier.height(20.dp))
                        Text("MAKE IT YOURS", color = Brand, fontSize = 11.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.4.sp)
                        Spacer(Modifier.height(10.dp))
                        Row(Modifier.fillMaxWidth().background(card, RoundedCornerShape(22.dp)).padding(18.dp), verticalAlignment = Alignment.CenterVertically) {
                            Box(Modifier.size(46.dp).background(BrandSoft, RoundedCornerShape(15.dp)), contentAlignment = Alignment.Center) {
                                Icon(Icons.Default.AutoAwesome, "Appearance", tint = Brand)
                            }
                            Spacer(Modifier.width(12.dp))
                            Column(Modifier.weight(1f)) {
                                Text("AMOLED dark canvas", color = DarkText, fontWeight = FontWeight.SemiBold)
                                Text("Pure black background, light cards", color = Muted, fontSize = 12.sp)
                            }
                            Switch(checked = dark, onCheckedChange = { dark = it; onThemeChanged(it) })
                        }
                        Spacer(Modifier.height(22.dp))
                        Text("PRIVACY", color = Brand, fontSize = 11.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.4.sp)
                        Spacer(Modifier.height(10.dp))
                        Column(Modifier.fillMaxWidth().background(card, RoundedCornerShape(22.dp)).padding(18.dp)) {
                            Text("Your notes stay on your device", color = DarkText, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                            Spacer(Modifier.height(6.dp))
                            Text("This preview uses a private SQLite database. There is no sign-in or cloud sync. Export and backup are not implemented yet, so keep a separate copy of anything important.", color = Color(0xFF656371), fontSize = 13.sp, lineHeight = 20.sp)
                        }
                        Spacer(Modifier.height(22.dp))
                        Text("NOTES BY LAVI", color = ink, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        Text("Version 1.0.0 · Early preview", color = Muted, fontSize = 12.sp, modifier = Modifier.padding(top = 4.dp))
                    }
                }
                else -> {
                    val visible = notes.filter { note ->
                        val included = when (screen) {
                            "Pinned" -> note.pinned && !note.archived && !note.deleted
                            "Archive" -> note.archived && !note.deleted
                            "Trash" -> note.deleted
                            else -> !note.archived && !note.deleted
                        }
                        included && (query.isBlank() || (note.title + " " + note.body + " " + note.tags).contains(query, ignoreCase = true))
                    }
                    Column(Modifier.fillMaxSize().padding(horizontal = 20.dp)) {
                        Row(Modifier.fillMaxWidth().padding(top = 22.dp, bottom = 18.dp), verticalAlignment = Alignment.CenterVertically) {
                            Box(Modifier.size(48.dp).background(BrandSoft, RoundedCornerShape(17.dp)), contentAlignment = Alignment.Center) {
                                Icon(Icons.Default.EditNote, "Notes By Lavi", tint = Brand, modifier = Modifier.size(29.dp))
                            }
                            Spacer(Modifier.width(12.dp))
                            Column(Modifier.weight(1f)) {
                                Text("Notes", fontSize = 30.sp, fontWeight = FontWeight.ExtraBold, color = ink, letterSpacing = (-1).sp)
                                Text("A little space for big ideas.", fontSize = 12.sp, color = Muted)
                            }
                            IconButton(onClick = { showSettings = true }) { Icon(Icons.Default.Settings, "Settings", tint = ink) }
                        }
                        Row(Modifier.fillMaxWidth().background(if (dark) Color(0xFF17151F) else Color(0xFFF0EDFF), RoundedCornerShape(22.dp)).padding(17.dp), verticalAlignment = Alignment.CenterVertically) {
                            Column(Modifier.weight(1f)) {
                                Text("YOUR MIND, UNCLUTTERED", color = Brand, fontSize = 10.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.1.sp)
                                Spacer(Modifier.height(6.dp))
                                Text("Catch the thought\nbefore it gets away.", color = if (dark) Color.White else DarkText, fontSize = 20.sp, fontWeight = FontWeight.Bold, lineHeight = 25.sp)
                                Spacer(Modifier.height(10.dp))
                                Text("${notes.count { !it.deleted && !it.archived }} notes in your space", color = Muted, fontSize = 12.sp)
                            }
                            Box(Modifier.size(68.dp).background(Peach, CircleShape), contentAlignment = Alignment.Center) {
                                Icon(Icons.Default.Lightbulb, "Ideas", tint = Color(0xFFB56B37), modifier = Modifier.size(34.dp))
                            }
                        }
                        Spacer(Modifier.height(16.dp))
                        Row(Modifier.fillMaxWidth().background(card, RoundedCornerShape(17.dp)).padding(horizontal = 14.dp, vertical = 14.dp), verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Default.Search, "Search", tint = Muted)
                            Spacer(Modifier.width(10.dp))
                            BasicTextField(
                                value = query, onValueChange = { query = it }, modifier = Modifier.weight(1f),
                                textStyle = TextStyle(color = DarkText, fontSize = 14.sp),
                                decorationBox = { inner -> Box { if (query.isEmpty()) Text("Search notes, words, tags…", color = Muted); inner() } }
                            )
                        }
                        Row(Modifier.fillMaxWidth().padding(vertical = 16.dp), horizontalArrangement = Arrangement.spacedBy(7.dp)) {
                            listOf("Notes", "Pinned", "Archive", "Trash").forEach { item ->
                                val selected = screen == item
                                Box(Modifier.weight(1f).background(if (selected) Brand else card, RoundedCornerShape(13.dp)).clickable { screen = item; query = "" }.padding(vertical = 11.dp), contentAlignment = Alignment.Center) {
                                    Text(item, color = if (selected) Color.White else DarkText, fontSize = 11.sp, fontWeight = if (selected) FontWeight.Bold else FontWeight.Medium)
                                }
                            }
                        }
                        Row(Modifier.fillMaxWidth().padding(bottom = 8.dp), verticalAlignment = Alignment.CenterVertically) {
                            Text(when (screen) { "Pinned" -> "Kept close"; "Archive" -> "Out of sight"; "Trash" -> "Recently deleted"; else -> "Your notes" }, color = ink, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                            Spacer(Modifier.weight(1f))
                            Text("${visible.size} items", color = Muted, fontSize = 12.sp)
                        }
                        if (visible.isEmpty()) {
                            Column(Modifier.fillMaxWidth().weight(1f), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
                                Box(Modifier.size(76.dp).background(BrandSoft, CircleShape), contentAlignment = Alignment.Center) {
                                    Icon(if (query.isNotBlank()) Icons.Default.Search else Icons.Default.EditNote, "Empty notes", tint = Brand, modifier = Modifier.size(34.dp))
                                }
                                Spacer(Modifier.height(18.dp))
                                Text(if (query.isNotBlank()) "Nothing found just yet" else if (screen == "Trash") "All clear here" else "Make room for an idea", color = ink, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                                Text(if (query.isNotBlank()) "Try a different word or tag." else "Your next note can start with one line.", color = Muted, fontSize = 13.sp, modifier = Modifier.padding(top = 6.dp))
                            }
                        } else {
                            LazyColumn(Modifier.weight(1f), contentPadding = PaddingValues(bottom = 100.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                                items(visible, key = { it.id }) { note ->
                                    Column(Modifier.fillMaxWidth().background(card, RoundedCornerShape(20.dp)).clickable { if (screen != "Trash") editing = note }.padding(16.dp)) {
                                        Row(verticalAlignment = Alignment.CenterVertically) {
                                            if (note.pinned) {
                                                Icon(Icons.Default.PushPin, "Pinned", tint = Brand, modifier = Modifier.size(15.dp))
                                                Spacer(Modifier.width(6.dp))
                                            }
                                            Text(note.title.ifBlank { "Untitled note" }, modifier = Modifier.weight(1f), color = DarkText, fontSize = 16.sp, fontWeight = FontWeight.Bold, maxLines = 1, overflow = TextOverflow.Ellipsis)
                                        }
                                        if (note.body.isNotBlank()) Text(note.body, color = Color(0xFF656371), fontSize = 13.sp, lineHeight = 20.sp, maxLines = 3, overflow = TextOverflow.Ellipsis, modifier = Modifier.padding(top = 7.dp))
                                        Row(Modifier.fillMaxWidth().padding(top = 12.dp), verticalAlignment = Alignment.CenterVertically) {
                                            Text(SimpleDateFormat("MMM d · h:mm a", Locale.getDefault()).format(Date(note.updatedAt)), color = Muted, fontSize = 10.sp)
                                            if (note.tags.isNotBlank()) {
                                                Spacer(Modifier.width(8.dp))
                                                Box(Modifier.background(BrandSoft, RoundedCornerShape(7.dp)).padding(horizontal = 7.dp, vertical = 4.dp)) {
                                                    Text(note.tags, color = Brand, fontSize = 10.sp, maxLines = 1, overflow = TextOverflow.Ellipsis)
                                                }
                                            }
                                            Spacer(Modifier.weight(1f))
                                            if (screen == "Trash") {
                                                IconButton(onClick = { db.flag(note.id, "deleted", false); refresh() }, modifier = Modifier.size(30.dp)) { Icon(Icons.Default.Restore, "Restore note", tint = Brand, modifier = Modifier.size(17.dp)) }
                                                IconButton(onClick = { db.deleteForever(note.id); refresh() }, modifier = Modifier.size(30.dp)) { Icon(Icons.Default.Delete, "Delete permanently", tint = Color(0xFFC14F61), modifier = Modifier.size(17.dp)) }
                                            } else {
                                                IconButton(onClick = { db.flag(note.id, "pinned", !note.pinned); refresh() }, modifier = Modifier.size(30.dp)) { Icon(Icons.Default.PushPin, "Toggle pin", tint = if (note.pinned) Brand else Muted, modifier = Modifier.size(17.dp)) }
                                                IconButton(onClick = { db.flag(note.id, if (screen == "Archive") "archived" else "deleted", screen != "Archive"); refresh() }, modifier = Modifier.size(30.dp)) {
                                                    Icon(if (screen == "Archive") Icons.Default.Restore else if (screen == "Notes" || screen == "Pinned") Icons.Default.Archive else Icons.Default.Delete, if (screen == "Archive") "Restore archive" else "Move to trash", tint = Muted, modifier = Modifier.size(17.dp))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        Box(Modifier.fillMaxWidth().padding(bottom = 14.dp), contentAlignment = Alignment.CenterEnd) {
                            FloatingActionButton(onClick = {
                                if (screen != "Trash") {
                                    val id = db.save(Note())
                                    refresh()
                                    editing = db.all().firstOrNull { it.id == id } ?: Note(id = id)
                                }
                            }, containerColor = Brand, contentColor = Color.White, shape = RoundedCornerShape(18.dp)) {
                                Icon(Icons.Default.Add, "Create note", modifier = Modifier.size(28.dp))
                            }
                        }
                    }
                }
            }
        }
    }
}
