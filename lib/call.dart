import 'makehive.dart';

void main() async {
  // Adicionar JSON
  //await addJsonToDatabase('assets/json/N2.json');

  // Listar filenames
  //final filenames = await listFilenames();
  //print('Filenames disponíveis: $filenames');

  // Obter dados por filenames
  final words = await getWordsByFilenames(['N1', 'N2']);
  print('Palavras associadas:');
  for (var word in words) {
    print('Word: ${word.word}, Reading: ${word.reading}, Mean: ${word.mean}');
  }

  // Exportar dados para JSON
  //await exportWordsToJson(['N1'], 'output/N1.json');

  // Deletar filename
  //await deleteFilename('N1');
}
