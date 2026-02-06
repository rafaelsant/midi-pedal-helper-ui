import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/setlist_service.dart';
import '../models/song.dart';
import '../providers/pedal_provider.dart';

class SetlistScreen extends StatefulWidget {
  const SetlistScreen({super.key});
  @override
  State<SetlistScreen> createState() => _SetlistScreenState();
}

class _SetlistScreenState extends State<SetlistScreen> {
  final SetlistService _setlistService = SetlistService();
  List<Song> mySetlist = [];

  @override
  void initState() {
    super.initState();
    _loadSetlist();
  }

  Future<void> _loadSetlist() async {
    final data = await _setlistService.readSetlist();
    if (mounted) {
      setState(() => mySetlist = data);
    }
  }

  Future<void> _addSong(String title) async {
    final newSong = Song.empty(title);
    setState(() {
      mySetlist.add(newSong);
    });
    await _setlistService.saveSetlist(mySetlist);
    HapticFeedback.lightImpact();
  }

  Future<void> _deleteSong(int index) async {
    setState(() {
      mySetlist.removeAt(index);
    });
    await _setlistService.saveSetlist(mySetlist);
    HapticFeedback.heavyImpact();
  }

  Future<void> _showAddSongDialog() async {
    final TextEditingController titleController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Nova Música"),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(labelText: "Título da Música"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCELAR"),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addSong(titleController.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text("SALVAR", style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text("SETLIST"), backgroundColor: Colors.transparent),
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            final item = mySetlist.removeAt(oldIndex);
            mySetlist.insert(newIndex, item);
          });
          _setlistService.saveSetlist(mySetlist);
        },
        children: [
          for (int i = 0; i < mySetlist.length; i++)
            Dismissible(
              key: Key("${mySetlist[i].title}_$i"),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) => _confirmDelete(mySetlist[i].title),
              onDismissed: (_) => _deleteSong(i),
              child: ListTile(
                key: Key("tile_$i"),
                title: Text(mySetlist[i].title, style: const TextStyle(color: Colors.white)),
                leading: const Icon(Icons.drag_handle, color: Colors.white24),
                onTap: () {
                  context.read<PedalProvider>().loadSong(mySetlist[i]);
                  Navigator.pop(context);
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSongDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Future<bool?> _confirmDelete(String title) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remover Música"),
        content: Text("Deseja apagar '$title'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("NÃO")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("SIM", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
