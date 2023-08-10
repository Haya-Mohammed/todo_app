import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app1/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app1/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app1/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app1/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;
  int currentIndex = 0;

  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles = [
    "New Tasks",
    "Done Tasks",
    "Archived Tasks",
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  Database? database;
  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        database
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) {
          print("table created");
        }).catchError((error) {
          print('Error when creating table ${error.toString()}');
        });
      },
      onOpen: (database) {
        getDataFromDatabase(database);
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  Future insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database
        ?.transaction((txn) => txn.rawInsert(
            'INSERT INTO tasks (title, date, time, status) VALUES("$title","$date","$time","new")'))
        .then((value) {
      print('$value inserted successfully!');
      emit(AppInsertDatabaseState());
      getDataFromDatabase(database);
    }).catchError((error) {
      print('Error when creating table ${error.toString()}');
    });
  }

  void updateData({
    required String status,
    required int id,
  }) async {
    emit(AppUpdateDatabaseState());
    return await database!.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id]).then((value) {
      getDataFromDatabase(database);
    });
  }

  void deleteData({
    required int id,
  }) async {
    emit(AppDeleteDatabaseState());
    return await database!
        .rawUpdate('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDatabase(database);
    });
  }

  void getDataFromDatabase(database) async {
    emit(AppGetDatabaseLoadingState());
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    await database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });
    });
    emit(AppGetDatabaseState());
  }

  void changeBottomSheetState({required bool isShown, required IconData icon}) {
    isBottomSheetShown = isShown;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }
}
