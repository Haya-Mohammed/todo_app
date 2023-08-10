import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo_app1/shared/cubit/cubit.dart';

Widget buildTaskItem(Map model, BuildContext context) => Dismissible(
      key: UniqueKey(),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40.0,
              child: Text('${model['time']}'),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${model['title']}',
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('${model['date']}',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: () {
                AppCubit.get(context)
                    .updateData(status: 'done', id: model['id']);
              },
              icon: const Icon(Icons.check_box, color: Colors.green),
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context)
                    .updateData(status: 'archive', id: model['id']);
              },
              icon: const Icon(Icons.archive, color: Colors.black45),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        AppCubit.get(context).deleteData(id: model['id']);
      },
    );

Widget taskBuilder({required List<Map> tasks}) {
  return ConditionalBuilder(
    condition: tasks.length > 0,
    builder: (context) => ListView.separated(
      itemBuilder: (context, index) => buildTaskItem(tasks[index], context),
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 20.0),
        child: Container(
          width: double.infinity,
          height: 1.0,
          color: Colors.grey[300],
        ),
      ),
      itemCount: tasks.length,
    ),
    fallback: (context) => const Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.menu,
          size: 70,
          color: Colors.black45,
        ),
        Text(
          'No Tasks yet, please add some tasks!',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black45),
        ),
      ],
    )),
  );
}
