import 'package:callinfologger/app/data/models/call_log_model.dart';
import 'package:callinfologger/app/data/models/contact_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper{
  static final DBHelper instance =DBHelper._internal();
  static Database? _db;
  DBHelper._internal();

  Future<Database> get database async{
    if(_db!=null)return _db!;
    _db=await initDB();
    return _db!;
  }
  
  Future<Database> initDB()async{
    final path =join(await getDatabasesPath(),'call_recorder.db');
    return await openDatabase( path,version: 1,onCreate: _onCreate);
  }

  Future<void>_onCreate(Database db,int version)async{
    await db.execute(
      '''
      CREATE TABLE contacts(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      phone TEXT NOT NULL,
      email TEXT,
      notes TEXT,
      createdAt TEXT NOT NULL
      )'''
    );

    await db.execute(
      '''
      CREATE TABLE call_logs(
      id TEXT PRIMARY KEY,
      contactId TEXT NOT NULL,
      contactName TEXT NOT NULL,
      phoneNumber TEXT NOT NULL,
      callType TEXT NOT NULL,
      calledAt TEXT NOT NULL,
      durationSeconds INTEGER NOT NULL,
      recondingPath TEXT,
      notes TEXT
      )
'''
    );
  }
  //contact operations
  Future<void >insertContact(ContactModel c)async{
    final db= await database;
    await db.insert('contacts', c.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);

  }
  Future<List<ContactModel>>getAllContacts()async{
    final db= await database;
    final maps =await db.query('contacts',orderBy: 'name ASC');
    return maps.map((m)=>ContactModel.fromMap(m)).toList();
  }
  Future<ContactModel?>getContactByPhone(String phone)async{
    final db= await database;
    final maps= await db.query('contacts',where: 'phone=?',whereArgs:[phone]);
    if(maps.isNotEmpty){
      return ContactModel.fromMap(maps.first);
    }
    return null;
  }
  Future<void>updateContact(ContactModel c)async{
    final db=await database;
    await db.update('contacts', c.toMap(),where: 'id=?',whereArgs: [c.id]);
  }
  Future<void>deleteContact(String id)async{
    final db= await database;
    await db.delete('contacts',where: 'id=?',whereArgs: [id]);
  }

  //call log operations
  Future<void>insertCallLog(CallLogModel log)async{
    final db= await database;
    await db.insert('call_logs', log.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);

  }
  Future<List<CallLogModel>>getAllCallLogs()async{
    final db= await database;
    final maps= await db.query('call_logs',orderBy: 'calledAt DESC');
    return maps.map((c)=>CallLogModel.fromMap(c)).toList();
  }
  Future<List<CallLogModel>>getCallLogsByContact(String contactId)async{
    final db= await database;
    final maps= await db.query('call_logs',where: 'contactId=?',whereArgs: [contactId],orderBy: 'calledAt DESC');
    return maps.map((c)=>CallLogModel.fromMap(c)).toList();
  }
  Future<void>deleteCallLog(String id)async{
    final db= await database;
    await db.delete('call_logs',where: 'id=?',whereArgs: [id]);
  }
}