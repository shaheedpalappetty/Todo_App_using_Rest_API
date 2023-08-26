import 'package:flutter/material.dart';
import 'package:todo_app/services/todo_services.dart';
import 'package:todo_app/utils/snackbar_helper.dart';
import 'package:todo_app/widgets/todo_card.dart';
import 'add_todo.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Todo List'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: FloatingActionButton.extended(
          onPressed: navigateToAddPage,
          label: const Text('Add Todo'),
        ),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text(
                'Nothing to Display',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final item = items[index] as Map;

                return TodoCard(
                  index: index,
                  item: item,
                  deleteById: deleteById,
                  navigateEdit: navigateToEditPage,
                );
              },
            ),
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => const AddTodoPage(),
    );
    await Navigator.of(context).push(route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );
    await Navigator.of(context).push(route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async {
//Delete the item
    final isSuccess = await TodoServices.deleteById(id);
    if (isSuccess) {
      //Remove item from the list
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
      showSuccessMessage(context, message: 'Deleted Successfully');
    } else {
      //show Error
      showErrorMessage(context, message: 'Deletion Failed');
    }
  }

  Future<void> fetchTodo() async {
    final result = await TodoServices.fetchTodos();
    if (result != null) {
      setState(() {
        items = result;
      });
    } else {
      showErrorMessage(context, message: 'Something Went Wrong');
    }
    setState(() {
      isLoading = false;
    });
  }
}
