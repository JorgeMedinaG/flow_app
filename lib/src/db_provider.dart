import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:econatu/src/user_preferences.dart';

class DBProvider {

  final _prefs = new UserPreferences();

  static Database _database; 
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database> get database async {

    if (_database != null ) return _database; 

    _database = await initDB();
    return _database; 

  }

  initDB() async {

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join( documentsDirectory.path, 'FlowDB.db');

    return await openDatabase(
      path, 
      version: 1, 
      onOpen: (db) {}, 
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE LOGGER ( start_date text, end_date text, value INTEGER)'
        );
      }
      );

  }

  registerFile(List<List<dynamic>> file) async {

      final db = await database; 
      await db.rawDelete("delete from logger;");
    //
    for (var i = 0; i < file.length; i++) {
      final row = file[i];

      if (row[0] is String && row[1] is String && row[2] is int) {
        //Check if dates and total are valid, skips to the next value if wrong
        if ( row[2] is int){
            try {
              DateTime.parse(row[0]);
              DateTime.parse(row[1]);
            } catch (e) {
              continue;
            }
        } else {
          continue;
        }
      }
      //ESP is on GMT -1, so add one hour to have the real time
      final difference = DateTime.now().timeZoneOffset;
      final date1 = DateTime.parse(row[0]).add(difference).add(Duration(hours: 1)).toString().substring(0,19);
      final date2 = DateTime.parse(row[1]).add(difference).add(Duration(hours: 1)).toString().substring(0,19);
      await insertRegister(date1,date2,row[2]);
    }

 
  }

  insertRegister(String startDate, String endDate, int value) async {

    final db = await database; 

    final sql = 'INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("$startDate"), datetime("$endDate"), $value)';

    var res;
    try {
    res = await db.rawInsert(sql);
    } catch (e) {
      print(e);
    }
    
    

    return res; 
  }

  
  getQuery() async {

  final now = new DateTime.now();
  final date = new DateTime(now.year,now.month-6,now.day).toString();

  final db = await database; 
  final res = await db.rawQuery('SELECT strftime("%d/%m %Hh", start_date ) as label, sum(value) as total FROM LOGGER WHERE start_date >= datetime("$date") GROUP BY label;'); //where start_date > datetime('$date')
  
  print(res) ;

  }

  Future<Map<String, dynamic>> getMonthlyData() async {

    final db = await database; 
    var billingDay;
    try {
      billingDay = int.parse(_prefs.closedate);
    } catch (e) {
      return {"ok" : false, "error" : "Select a billing date"};
    }
    
    Map<int, String> dates = getBillingDates(billingDay);
    Map<int, String> mnths = getMonthTag(billingDay); 
    

    final sql = 'SELECT '
                  'CASE '
                  'WHEN start_date BETWEEN datetime("${dates[7]}") and datetime("${dates[6]}")THEN "${mnths[6]}" '
                  'WHEN start_date BETWEEN datetime("${dates[6]}") and datetime("${dates[5]}")THEN "${mnths[5]}" '
                  'WHEN start_date BETWEEN datetime("${dates[5]}") and datetime("${dates[4]}")THEN "${mnths[4]}" '
                  'WHEN start_date BETWEEN datetime("${dates[4]}") and datetime("${dates[3]}")THEN "${mnths[3]}" '
                  'WHEN start_date BETWEEN datetime("${dates[3]}") and datetime("${dates[2]}")THEN "${mnths[2]}" '
                  'WHEN start_date BETWEEN datetime("${dates[2]}") and datetime("${dates[1]}")THEN "${mnths[1]}" '
                  'WHEN start_date >= datetime("${dates[1]}") THEN "${mnths[0]}" '
                'END as label, sum(value) as total '
                'FROM logger WHERE start_date >= datetime("${dates[7]}") '
                'GROUP BY label;' ;
    
    var res;
    try {
      res = await db.rawQuery(sql);
    } catch (e) {
      return {"ok" : false, "error" : e};
    }

    return {"ok" : true, "res": res};        

  }

  Future<Map<String, dynamic>> getDailyData() async {

    final db = await database;   

    final now = new DateTime.now();
    final date = new DateTime(now.year,now.month,now.day - 30 ).toString().substring(0,19);
    
    final sql = 'SELECT strftime("%d/%m", start_date) as label, sum(value) as total FROM logger where start_date >= datetime("$date") group by label;';

    var res;
    try {
      res = await db.rawQuery(sql);
    } catch (e) {
      return {"ok" : false, "error" : e};
    }
    return {"ok" : true, "res": res}; 

  }

  Future<Map<String, dynamic>> getHourlyData() async {

    final db = await database;  

    final now = new DateTime.now();
    final date = new DateTime(now.year,now.month,now.day, now.hour - 72).toString().substring(0,19);
    //final date2 = new DateTime(now.year,now.month,now.day, now.hour).toString().substring(0,19);
    final sql = 'SELECT strftime("%d/%m %Hh", start_date ) as label, sum(value) as total FROM LOGGER WHERE start_date >= datetime("$date") GROUP BY label;';
    
    var res;
    try {
     res = await db.rawQuery(sql);

    } catch (e) {
      return {"ok" : false, "error" : e};
    }
    return {"ok" : true, "res": res}; 

  }

  createTestData() async {

    final db = await database;
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-06-10 00:00:00"), datetime("2019-08-15 00:00:00"), 5)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-06-18 00:00:00"), datetime("2019-08-15 00:00:00"), 10)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-07-10 00:00:00"), datetime("2019-08-15 00:00:00"), 50)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-07-12 00:00:00"), datetime("2019-08-15 00:00:00"), 510)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-07-15 00:00:00"), datetime("2019-08-15 00:00:00"), 310)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-07-18 00:00:00"), datetime("2019-08-15 00:00:00"), 310)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-08-10 00:00:00"), datetime("2019-08-15 00:00:00"), 30)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-08-12 00:00:00"), datetime("2019-08-15 00:00:00"), 130)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-08-15 00:00:00"), datetime("2019-08-15 00:00:00"), 70)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-08-18 00:00:00"), datetime("2019-08-15 00:00:00"), 35)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-09-10 00:00:00"), datetime("2019-08-15 00:00:00"), 98)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-09-12 00:00:00"), datetime("2019-08-15 00:00:00"), 567)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-09-15 00:00:00"), datetime("2019-08-15 00:00:00"), 167)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-09-15 10:00:00"), datetime("2019-08-15 00:00:00"), 37)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-09-15 20:00:00"), datetime("2019-08-15 00:00:00"), 40)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-09-16 08:00:00"), datetime("2019-08-15 00:00:00"), 90)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-09-16 07:00:00"), datetime("2019-08-15 00:00:00"), 88)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-09-17 12:00:00"), datetime("2019-08-15 00:00:00"), 33)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-09-17 11:00:00"), datetime("2019-08-15 00:00:00"), 55)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-09-18 23:00:00"), datetime("2019-08-15 00:00:00"), 120)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-01 23:00:00"), datetime("2019-08-15 00:00:00"), 120)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-02 23:00:00"), datetime("2019-08-15 00:00:00"), 120)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-03 23:00:00"), datetime("2019-08-15 00:00:00"), 60)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-04 23:00:00"), datetime("2019-08-15 00:00:00"), 80)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-05 23:00:00"), datetime("2019-08-15 00:00:00"), 30)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-06 23:00:00"), datetime("2019-08-15 00:00:00"), 10)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-07 23:00:00"), datetime("2019-08-15 00:00:00"), 20)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-08 23:00:00"), datetime("2019-08-15 00:00:00"), 55)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-09 23:00:00"), datetime("2019-08-15 00:00:00"), 23)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-10 23:00:00"), datetime("2019-08-15 00:00:00"), 76)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-11 23:00:00"), datetime("2019-08-15 00:00:00"), 105)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-12 23:00:00"), datetime("2019-08-15 00:00:00"), 45)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-13 23:00:00"), datetime("2019-08-15 00:00:00"), 98)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-14 23:00:00"), datetime("2019-08-15 00:00:00"), 90)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-15 23:00:00"), datetime("2019-08-15 00:00:00"), 30)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-16 23:00:00"), datetime("2019-08-15 00:00:00"), 20)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-17 23:00:00"), datetime("2019-08-15 00:00:00"), 25)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-18 23:00:00"), datetime("2019-08-15 00:00:00"), 11)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-19 23:00:00"), datetime("2019-08-15 00:00:00"), 105)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-20 23:00:00"), datetime("2019-08-15 00:00:00"), 200)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-21 23:00:00"), datetime("2019-08-15 00:00:00"), 50)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-22 23:00:00"), datetime("2019-08-15 00:00:00"), 75)');
    db.rawInsert('INSERT INTO LOGGER (start_date, end_date, value) VALUES(datetime("2019-11-22 23:00:00"), datetime("2019-08-15 00:00:00"), 60)');
  }

  Map<int,String> getMonthTag(int billingDay) {

      
      final now = new DateTime.now();
      final actualMonth = now.month;
      final actualYear = now.year;
      
      //Calculates the last six billing dates
      final nextCloseDate  = new DateTime(actualYear,actualMonth+1,billingDay) ;
      final firstCloseDate = new DateTime(actualYear,actualMonth,billingDay) ; 
      final secondCloseDate = new DateTime(actualYear,actualMonth-1,billingDay) ; 
      final thirdCloseDate = new DateTime(actualYear,actualMonth-2,billingDay) ;
      final forthCloseDate = new DateTime(actualYear,actualMonth-3,billingDay) ;
      final fifthCloseDate = new DateTime(actualYear,actualMonth-4,billingDay) ;
      final sixthCloseDate = new DateTime(actualYear,actualMonth-5,billingDay) ;

      Map<int,String> billingMonths = {
        0  : nextCloseDate.month.toString()+"/"+nextCloseDate.year.toString(),
        1  : firstCloseDate.month.toString()+"/"+firstCloseDate.year.toString(),
        2  : secondCloseDate.month.toString()+"/"+secondCloseDate.year.toString(),
        3  : thirdCloseDate.month.toString()+"/"+thirdCloseDate.year.toString(),
        4  : forthCloseDate.month.toString()+"/"+forthCloseDate.year.toString(),
        5  : fifthCloseDate.month.toString()+"/"+fifthCloseDate.year.toString(),
        6  : sixthCloseDate.month.toString()+"/"+sixthCloseDate.year.toString(),
        
      };
    return billingMonths;
    }






    Map<int, String> getBillingDates(int billingDay) {

      //Takes the actual datetime
      final now = new DateTime.now();
      final actualMonth = now.month;
      final actualYear = now.year;
      
      //Calculates the last six billing dates
      final firstCloseDate = new DateTime(actualYear,actualMonth,billingDay) ; 
      final secondCloseDate = new DateTime(actualYear,actualMonth-1,billingDay) ; 
      final thirdCloseDate = new DateTime(actualYear,actualMonth-2,billingDay) ;
      final forthCloseDate = new DateTime(actualYear,actualMonth-3,billingDay) ;
      final fifthCloseDate = new DateTime(actualYear,actualMonth-4,billingDay) ;
      final sixthCloseDate = new DateTime(actualYear,actualMonth-5,billingDay) ;
      final seventhCloseDate = new DateTime(actualYear,actualMonth-6,billingDay);
      
      Map<int, String> dates = {
        1 : firstCloseDate.toString().substring(0,19),
        2 : secondCloseDate.toString().substring(0,19),
        3 : thirdCloseDate.toString().substring(0,19), 
        4 : forthCloseDate.toString().substring(0,19),
        5 : fifthCloseDate.toString().substring(0,19),
        6 : sixthCloseDate.toString().substring(0,19),
        7 : seventhCloseDate.toString().substring(0,19)
        };
    
    return dates;
    
  }

  

}