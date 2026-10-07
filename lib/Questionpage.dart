import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main/DetailPage.dart';

class Questionpage extends StatefulWidget {
 final String question;
 const Questionpage({super.key, required this.question});

 @override
 State<StatefulWidget> createState() {
  return _QuestionPage();
 }
}

class _QuestionPage extends State<Questionpage> {
 String title = '';
 int selectNumber = -1;
 late Future<String> _loadDataFuture; // 빌드 시 매번 로드되는 것을 방지하기 위한 변수

 Future<String> loadAsset(String fileName) async {
  return await rootBundle.loadString('res/api/$fileName.json');
 }

 @override
 void initState() {
  super.initState();
  // 데이터 로드를 initState에서 한 번만 실행하여 효율성을 높입니다.
  _loadDataFuture = loadAsset(widget.question);
 }

 @override
 Widget build(BuildContext context) {
  return FutureBuilder<String>(
   future: _loadDataFuture,
   builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
     return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
     );
    } else if (snapshot.hasError) {
     return Scaffold(
      body: Padding(
       padding: const EdgeInsets.all(8.0),
       child: Center(
        child: Text(
         'Error: ${snapshot.error}',
         style: const TextStyle(fontSize: 15),
        ),
       ),
      ),
     );
    } else if (snapshot.hasData) {
     Map<String, dynamic> questions = jsonDecode(snapshot.data!);
     title = questions['title'].toString(); // toSTring() 오타 수정
     List<dynamic> selects = questions['selects'] as List<dynamic>;

     return Scaffold(
      appBar: AppBar(
       title: Text(title),
      ),
      body: Column(
       children: [
        Padding(
         padding: const EdgeInsets.all(16.0),
         child: Text(
          questions['question'].toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
         ),
        ),
        // RadioGroup으로 전체 상태를 관리합니다.
        Expanded(
         child: RadioGroup<int>(
          groupValue: selectNumber,
          onChanged: (value) {
           if (value != null) {
            setState(() {
             selectNumber = value;
            });
           }
          },
          child: ListView.builder(
           itemCount: selects.length,
           itemBuilder: (context, index) {
            return SizedBox(
             height: 100,
             child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               Text(selects[index].toString()),
               // Radio 위젯에서 groupValue와 onChanged를 제거하고 value만 남겼습니다.
               Radio<int>(
                value: index,
               ),
              ],
             ),
            );
           },
          ),
         ),
        ),
        if (selectNumber != -1)
         Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: ElevatedButton(
           onPressed: () {
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (context){
                  return DetailPage(
                   answer : questions['answer'][selectNumber],
                   question : questions['question']
                  );
             }));
            // 결과 처리 로직 작성
           },
           child: const Text('성격보기'),
          ),
         ),
       ],
      ),
     );
    }
    return const Scaffold();
   },
  );
 }
}
