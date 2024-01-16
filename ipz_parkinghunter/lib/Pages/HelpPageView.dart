import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageViewState createState() => _HelpPageViewState();
}

class _HelpPageViewState extends State<HelpPage> {
  // Initial Full List of FAQs
  final List<Map<String, String>> _allFAQs = [
    {
      'question':
          'Jak mogę znaleźć wolne miejsce parkingowe przy użyciu aplikacji?',
      'answer':
          'Po otwarciu aplikacji zostaniesz przekierowany na mapę, na której wyświetlane są wszystkie dostępne miejsca parkingowe w Twojej okolicy. Możesz przeglądać mapę, aby znaleźć miejsce najbliższe Twojej lokalizacji lub użyć funkcji wyszukiwania, aby znaleźć parking w określonym miejscu.'
    },
    {
      'question': 'Jak mogę zająć miejsce parkingowe?',
      'answer':
          'Gdy znajdziesz wolne miejsce parkingowe, kliknij na nie na mapie, a następnie wybierz opcję "Zajmij miejsce". Upewnij się, że Twoje położenie GPS jest włączone, aby aplikacja mogła potwierdzić Twoją obecność na parkingu.'
    },
    {
      'question': 'Czy mogę dodać nowe miejsce parkingowe do aplikacji?',
      'answer':
          'Tak, aby dodać nowe miejsce parkingowe, wybierz opcję "Dodaj miejsce parkingowe" w menu aplikacji. Następnie postępuj zgodnie z instrukcjami na ekranie, aby dodać lokalizację i szczegółowe informacje o nowym miejscu parkingowym.'
    },
    {
      'question': 'Co zrobić, gdy opuszczam miejsce parkingowe?',
      'answer':
          'Po opuszczeniu miejsca parkingowego, otwórz aplikację i wybierz opcję "Zwolnij miejsce". Dzięki temu inne osoby korzystające z aplikacji będą widziały, że miejsce jest ponownie dostępne.'
    },
    {
      'question': 'Czy aplikacja informuje o opłatach parkingowych?',
      'answer':
          'Aplikacja wyświetla informacje o opłatach parkingowych, jeśli są dostępne. Podczas wyboru miejsca parkingowego możesz zobaczyć, czy parking jest płatny, oraz uzyskać informacje o stawkach i metodach płatności.'
    },
    {
      'question': 'Jak aplikacja dba o moje dane osobowe i lokalizację?',
      'answer':
          'Dbamy o prywatność naszych użytkowników. Dane lokalizacyjne są używane wyłącznie do celów funkcjonowania aplikacji i nie są udostępniane osobom trzecim. Szczegółowe informacje na temat naszej polityki prywatności znajdziesz w sekcji "Ustawienia" aplikacji.'
    },
    {
      'question': ' Czy aplikacja jest dostępna w innych miastach?',
      'answer':
          'Obecnie nasza aplikacja działa w wybranych miastach i jesteśmy w trakcie rozszerzania jej dostępności. Aby sprawdzić, czy aplikacja działa w Twoim mieście, wprowadź nazwę miasta w funkcji wyszukiwania w aplikacji.'
    },
    {
      'question': 'Co robić, gdy napotkam problem z miejscem parkingowym?',
      'answer':
          'Jeśli napotkasz problem z miejscem parkingowym, takim jak niezgodność danych lub niedostępność miejsca, skorzystaj z opcji "Zgłoś problem" dostępnej w aplikacji. Możesz tam opisać napotkany problem, a nasz zespół wsparcia zajmie się nim tak szybko, jak to możliwe.'
    },
    {
      'question':
          'Czy mogę zarezerwować miejsce parkingowe za pomocą aplikacji?',
      'answer': 'Obecnie aplikacja nie oferuje możliwości rezerwacji miejsc '
    },
    // Additional FAQs can be added here
  ];

  // Filtered List of FAQs based on search query
  List<Map<String, String>> _filteredFAQs = [];

  @override
  void initState() {
    super.initState();
    _filteredFAQs = _allFAQs;
  }

  void _filterFAQs(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredFAQs = _allFAQs;
      });
    } else {
      setState(() {
        _filteredFAQs = _allFAQs
            .where((faq) =>
                faq['question']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pomoc'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => _filterFAQs(value),
              decoration: InputDecoration(
                labelText: 'Wpisz interesujące cię pytanie...',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredFAQs.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  title: Text(_filteredFAQs[index]['question']!),
                  children: <Widget>[
                    ListTile(
                      title: Text(_filteredFAQs[index]['answer']!),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
