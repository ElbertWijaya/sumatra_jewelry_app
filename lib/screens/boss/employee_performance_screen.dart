import 'package:flutter/material.dart';

class EmployeePerformanceScreen extends StatelessWidget {
  const EmployeePerformanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Untuk implementasi lebih lanjut, Anda bisa ambil data performa dari service/REST API.
    // Contoh dummy data:
    final List<Map<String, dynamic>> employeeData = [
      {
        'name': 'Andi Carver',
        'role': 'Carver',
        'completed': 24,
        'onProgress': 3,
      },
      {
        'name': 'Budi Caster',
        'role': 'Caster',
        'completed': 18,
        'onProgress': 2,
      },
      {
        'name': 'Cici Diamond',
        'role': 'Diamond Setter',
        'completed': 30,
        'onProgress': 1,
      },
      // Tambahkan data karyawan lain sesuai kebutuhan
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Performa Karyawan')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: employeeData.length,
        itemBuilder: (context, index) {
          final emp = employeeData[index];
          return Card(
            child: ListTile(
              title: Text(emp['name']),
              subtitle: Text(emp['role']),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Selesai: ${emp['completed']}'),
                  Text('Proses: ${emp['inProgress']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
