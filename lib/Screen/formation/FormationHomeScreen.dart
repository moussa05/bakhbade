import 'package:bakhbade/Services/api_service.dart';
import 'package:bakhbade/models/Formation.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;
import 'package:flutter_html/flutter_html.dart';

class FormationListScreen extends StatefulWidget {
  @override
  _FormationListScreenState createState() => _FormationListScreenState();
}

class _FormationListScreenState extends State<FormationListScreen> {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<TypeFormation>>(
        future: apiService.fetchFormations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Vérification de l'erreur
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 10),
                  const Text(
                    'Vérifiez votre connexion',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Réessayer
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            final formations = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: formations.length,
              itemBuilder: (context, index) {
                return FormationCard(formations[index]);
              },
            );
          } else {
            return const Center(child: Text('Aucune formation trouvée'));
          }
        },
      ),
    );
  }
}

class FormationCard extends StatelessWidget {
  final TypeFormation typeFormation;

  FormationCard(this.typeFormation);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ExpansionTile(
        title: Text(
          typeFormation.nom,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        children: typeFormation.formations.map((formation) {
          return ListTile(
            title: Text(formation.nom),
            subtitle: Text('Coût: ${formation.coutMin} CFA'),
            trailing: Text(
              formation.modePaiementTranches
                  ? 'Payable par tranches'
                  : 'Paiement unique',
              style: TextStyle(
                  color: formation.modePaiementTranches
                      ? Colors.green
                      : Colors.red),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormationDetailScreen(formation),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class FormationDetailScreen extends StatelessWidget {
  final Formation formation;

  const FormationDetailScreen(this.formation, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(formation.nom),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formation.nom,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Html(
                data: formation.description,
                style: {
                  "body": Style(
                      fontSize:
                          FontSize(16)), // Style personnalisé pour le texte
                },
              ),
              const SizedBox(height: 20),
              Text('Coût: ${formation.coutMin} CFA',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text(
                formation.modePaiementTranches
                    ? 'Payable par tranches'
                    : 'Paiement unique',
                style: TextStyle(
                  fontSize: 18,
                  color: formation.modePaiementTranches
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
