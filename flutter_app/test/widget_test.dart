import 'package:flutter_test/flutter_test.dart';
import 'package:notes_by_lavi/main.dart';
void main(){test('note data round-trips',(){final n=Note(id:'n1',title:'Idea',body:'Hello',tags:'work',pinned:true,updated:DateTime.utc(2026));final r=Note.fromJson(n.toJson());expect(r.title,'Idea');expect(r.body,'Hello');expect(r.pinned,isTrue);});}
