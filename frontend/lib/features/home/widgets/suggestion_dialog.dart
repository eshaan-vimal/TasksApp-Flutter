import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/core/services/connectivity_service.dart';
import 'package:intl/intl.dart';

import 'package:frontend/features/auth/cubits/auth_cubit.dart';
import 'package:frontend/features/home/cubits/task_cubit.dart';


void showSuggestionsDialog(BuildContext context) 
{
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => BlocConsumer<TaskCubit, TaskState>(
      listener: (context, state) {

        if (state is TaskError) 
        {
          Navigator.of(dialogContext).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text(state.error),
              )
            ),
          );
        }

      },
      builder: (context, state) {

        if (state is TaskSuggesting) 
        {
          return const LoadingSuggestionDialog();
        } 
        else if (state is TaskSuggestSuccess) 
        {
          return SuggestionDialog(
            suggestedTasks: state.suggestTasks,
            hints: state.suggestHints,
          );
        } 
        else 
        {
          return const SizedBox.shrink();
        }

      },
    ),
  );
}

class LoadingSuggestionDialog extends StatelessWidget 
{
  const LoadingSuggestionDialog({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return AlertDialog(
      title: const Text(
        'Task Suggestions',
        style: TextStyle(
          letterSpacing: 1.5,
        ),
      ),
      content: SizedBox(
        height: 100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Analyzing your task history...',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SuggestionDialog extends StatefulWidget 
{
  final List<dynamic> suggestedTasks;
  final List<dynamic> hints;

  const SuggestionDialog({
    super.key,
    required this.suggestedTasks,
    required this.hints,
  });

  @override
  State<SuggestionDialog> createState() => _SuggestionDialogState();
}

class _SuggestionDialogState extends State<SuggestionDialog> 
{
  late List<bool> _selected;
  bool _isAddingTasks = false;

  @override
  void initState() 
  {
    super.initState();
    _selected = List<bool>.filled(widget.suggestedTasks.length, false);
  }

  void handleGetTasks ()
  {
    final authCreds = context.read<AuthCubit>().state as AuthLoggedIn;
    final taskCubit = context.read<TaskCubit>();

    ConnectivityService().isOnline.then((isOnline) async {
      if (isOnline)
      {
        await taskCubit.syncTasks(token: authCreds.user.token!);
        taskCubit.getTasks(token: authCreds.user.token!);
      } 
      else 
      {
        taskCubit.getTasks(token: authCreds.user.token!);
      }
    });
  }



  String _formatTime(String? iso) 
  {
    if (iso == null) return 'N/A';
    try 
    {
      return DateFormat('MMM d, hh:mm a').format(DateTime.parse(iso).toLocal());
    } 
    catch (_) 
    {
      return 'Invalid Date';
    }
  }


  // Add selected tasks
  void _addSelectedTasks() async 
  {
    if (_isAddingTasks)
    {
      return;
    }

    setState(() { _isAddingTasks = true; });

    final authCreds = context.read<AuthCubit>().state as AuthLoggedIn;
    final taskCubit = context.read<TaskCubit>();

    // Process selected tasks
    for (int i = 0; i < widget.suggestedTasks.length; i++) 
    {
      if (!_selected[i]) 
      {
        continue;
      }
      
      final task = widget.suggestedTasks[i];
      final title = task['title'] as String?;
      final description = task['description'] as String?;
      final hexColour = task['hexColour'] as String?;
      final dueAtString = task['dueAt'] as String?;

      if (title == null || hexColour == null || dueAtString == null) 
      {
        continue;
      }

      try 
      {
        taskCubit.newTask(
          token: authCreds.user.token!,
          uid: authCreds.user.id,
          title: title,
          description: description ?? '',
          colour: hexToRgb(hexColour),
          dueAt: DateTime.parse(dueAtString),
        );
      } 
      catch (e) 
      {
        if (mounted) 
        {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error adding: $title"), backgroundColor: Colors.orange),
          );
        }
      }
    }

    taskCubit.getTasks(token: authCreds.user.token!);

    if (mounted) 
    {
      Navigator.of(context).pop();
    }
  }


  @override
  Widget build(BuildContext context) 
  {
    final bool anySelected = _selected.any((selected) => selected);

    return AlertDialog(
      title: const Text(
        'Task Suggestions',
        style: TextStyle(
          letterSpacing: 1.5,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: widget.suggestedTasks.isEmpty
          ? const Text("No suggestions available.")
          : ListView.builder(
              itemCount: widget.suggestedTasks.length,
              shrinkWrap: true,
              itemBuilder: (context, index) 
              {
                final task = widget.suggestedTasks[index];
                final hint = index < widget.hints.length ? widget.hints[index] : '';
                final title = task['title'] as String? ?? 'No Title';
                final color = hexToRgb(task['hexColour']);
                final dueAt = _formatTime(task['dueAt'] as String?);

                return CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 255, 0, 127),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _selected[index],
                  onChanged: _isAddingTasks ? null : (value) => 
                    setState(() => _selected[index] = value ?? false),
                  secondary: CircleAvatar(backgroundColor: color, radius: 10),
                  title: Text(title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hint, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
                      Text("Due: $dueAt", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                );
              },
            ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isAddingTasks ? null : () {
            Navigator.of(context).pop();
            handleGetTasks();
          },
          child: const Text(
            'Discard',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 0, 127),
            ),
          ),
        ),
        TextButton(
          onPressed: anySelected && !_isAddingTasks ? _addSelectedTasks : null,
          child: _isAddingTasks
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                'Set',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 0, 127),
                ),
              ),
        ),
      ],
    );
  }
}