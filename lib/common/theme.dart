import 'package:flutter/material.dart';

// Classe para gerenciar a paleta de cores
class ColorPalette with ChangeNotifier {
  // Cores principais
  Color _background =
      Color(0xFF1C1F27); // fundo escuro, mas suave (cinza-azulado)
  Color _highlight = Color(0xFF61B6D6); // cor de destaque (azul suave)
  Color _text = Color(0xFFEBEBEB); // cor do texto (branco suave)
  Color _secondaryText = Color(0xFFB3B3B3); // texto secundário (cinza claro)
  Color _button = Color(0xFF61B6D6); // cor do botão (azul suave)
  Color _error = Color(0xFFF76C6C); // cor para erro (vermelho suave)

// Cores para campos de entrada e botões
  final List<Color> _fillColor = [
    Color(0xFF2A2D3B), // fundo dos campos de entrada (cinza-escuro)
    Color(0xFF3A4055), // fundo dos campos de entrada (azul-escuro)
  ]; // Cores para campos de entrada

  final List<Color> _dropdownColor = [
    Color(0xFF3A4055), // fundo do dropdown
    Color(0xFF2A2D3B), // fundo do dropdown
  ]; // Cores para o dropdown

  final List<Color> _inputBorderColor = [
    Color(0xFF61B6D6), // borda de entrada (azul suave)
    Color(0xFFB3B3B3), // borda de entrada (cinza)
  ]; // Cores para bordas de entrada

  final List<Color> _buttonHoverColor = [
    Color(0xFF4A9FBF), // cor do botão no hover (azul mais forte)
    Color(0xFF3E8FA0), // cor do botão no hover (azul mais escuro)
  ]; // Cores para o hover do botão

// Cores de bordas
  Color _borderColor = Color(0xFF3A4055); // cor da borda (azul escuro)
  Color _focusedBorderColor =
      Color(0xFF61B6D6); // cor da borda quando em foco (azul suave)
  Color _errorBorderColor =
      Color(0xFFF76C6C); // cor da borda quando há erro (vermelho suave)

// Cores de sombra
  Color _shadowColor = Color(0x55000000); // cor da sombra (semi-transparente)
  Color _elevationColor = Color(0x22000000); // cor para o efeito de elevação

// Cores de ícones
  Color _iconColor = Color(0xFFEBEBEB); // cor dos ícones (branco suave)
  Color _disabledIconColor =
      Color(0xFF6E6E6E); // cor dos ícones desativados (cinza)

// Gradientes
  LinearGradient _selectedCardGradient = LinearGradient(
    colors: [
      Color(0xFF4F5D6E), // gradiente para card selecionado (azul acinzentado)
      Color(0xFF3A4750), // gradiente para card selecionado (azul mais escuro)
    ], // gradiente para um card selecionado
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient _unselectedCardGradient = LinearGradient(
    colors: [
      Color(0xFF2A2D3B), // gradiente para card não selecionado (cinza escuro)
      Color(
          0xFF1C1F27), // gradiente para card não selecionado (cinza muito escuro)
    ], // gradiente para um card não selecionado
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Getters para acessar as cores
  Color get background => _background;
  Color get highlight => _highlight;
  Color get text => _text;
  Color get secondaryText => _secondaryText;
  Color get button => _button;
  Color get error => _error;
  Color get borderColor => _borderColor;
  Color get focusedBorderColor => _focusedBorderColor;
  Color get errorBorderColor => _errorBorderColor;
  Color get shadowColor => _shadowColor;
  Color get elevationColor => _elevationColor;
  Color get iconColor => _iconColor;
  Color get disabledIconColor => _disabledIconColor;

  // Getters para acessar as listas de cores
  List<Color> get fillColor => _fillColor;
  List<Color> get dropdownColor => _dropdownColor;
  List<Color> get inputBorderColor => _inputBorderColor;
  List<Color> get buttonHoverColor => _buttonHoverColor;

  // Getters para acessar os gradientes
  LinearGradient get selectedCardGradient => _selectedCardGradient;
  LinearGradient get unselectedCardGradient => _unselectedCardGradient;

  // Método para alterar uma cor específica da paleta e notificar os ouvintes
  void updateColor(String colorKey, Color color) {
    switch (colorKey) {
      case 'background':
        _background = color;
        break;
      case 'highlight':
        _highlight = color;
        break;
      case 'text':
        _text = color;
        break;
      case 'secondaryText':
        _secondaryText = color;
        break;
      case 'button':
        _button = color;
        break;
      case 'error':
        _error = color;
        break;
      case 'fillColor':
        if (_fillColor.length < 6)
          _fillColor.add(color);
        else
          _fillColor[0] = color; // Substitui a cor mais antiga
        break;
      case 'dropdownColor':
        if (_dropdownColor.length < 6)
          _dropdownColor.add(color);
        else
          _dropdownColor[0] = color; // Substitui a cor mais antiga
        break;
      case 'inputBorderColor':
        if (_inputBorderColor.length < 6)
          _inputBorderColor.add(color);
        else
          _inputBorderColor[0] = color; // Substitui a cor mais antiga
        break;
      case 'buttonHoverColor':
        if (_buttonHoverColor.length < 6)
          _buttonHoverColor.add(color);
        else
          _buttonHoverColor[0] = color; // Substitui a cor mais antiga
        break;
      case 'borderColor':
        _borderColor = color;
        break;
      case 'focusedBorderColor':
        _focusedBorderColor = color;
        break;
      case 'errorBorderColor':
        _errorBorderColor = color;
        break;
      case 'shadowColor':
        _shadowColor = color;
        break;
      case 'elevationColor':
        _elevationColor = color;
        break;
      case 'iconColor':
        _iconColor = color;
        break;
      case 'disabledIconColor':
        _disabledIconColor = color;
        break;
      default:
        throw ArgumentError('Cor inválida: $colorKey');
    }
    notifyListeners(); // Notificar os ouvintes para atualizar a UI
  }

  // Método para alterar várias cores ao mesmo tempo
  void updateColors(Map<String, Color> newColors) {
    newColors.forEach((key, value) {
      updateColor(key, value);
    });
  }

  // Método para atualizar gradientes
  void updateGradient(String gradientKey, LinearGradient gradient) {
    switch (gradientKey) {
      case 'selectedCardGradient':
        _selectedCardGradient = gradient;
        break;
      case 'unselectedCardGradient':
        _unselectedCardGradient = gradient;
        break;
      default:
        throw ArgumentError('Gradiente inválido: $gradientKey');
    }
    notifyListeners(); // Notificar os ouvintes para atualizar a UI
  }
}
