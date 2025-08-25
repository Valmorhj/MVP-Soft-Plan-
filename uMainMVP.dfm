object frPrincipal: TfrPrincipal
  Left = 0
  Top = 0
  Caption = 'Principal'
  ClientHeight = 310
  ClientWidth = 388
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object lbCEP: TLabel
    Left = 40
    Top = 19
    Width = 21
    Height = 15
    Caption = 'CEP'
  end
  object lbUF: TLabel
    Left = 40
    Top = 71
    Width = 14
    Height = 15
    Caption = 'UF'
  end
  object lbCidade: TLabel
    Left = 92
    Top = 71
    Width = 37
    Height = 15
    Caption = 'Cidade'
  end
  object lbLogradouro: TLabel
    Left = 238
    Top = 71
    Width = 62
    Height = 15
    Caption = 'Logradouro'
  end
  object rgOpcoes: TRadioGroup
    Left = 40
    Top = 144
    Width = 185
    Height = 105
    Caption = 'Op'#231#227'o'
    Items.Strings = (
      'Busca por JSON'
      'Busca por XML')
    TabOrder = 4
  end
  object Button1: TButton
    Left = 40
    Top = 266
    Width = 75
    Height = 25
    Caption = 'Buscar'
    TabOrder = 5
    OnClick = Button1Click
  end
  object edCidade: TEdit
    Left = 92
    Top = 92
    Width = 121
    Height = 23
    TabOrder = 2
  end
  object edLogradouro: TEdit
    Left = 238
    Top = 92
    Width = 121
    Height = 23
    TabOrder = 3
  end
  object edCep: TMaskEdit
    Left = 40
    Top = 40
    Width = 108
    Height = 23
    EditMask = '99999-999;0;'
    MaxLength = 9
    TabOrder = 0
    Text = ''
  end
  object cbUf: TComboBox
    Left = 40
    Top = 92
    Width = 46
    Height = 23
    ItemIndex = 0
    TabOrder = 1
    Text = 'AC'
    Items.Strings = (
      'AC'
      'AL'
      'AP'
      'AM'
      'BA'
      'CE'
      'DF'
      'ES'
      'GO'
      'MA'
      'MT'
      'MS'
      'MG'
      'PA'
      'PB'
      'PR'
      'PE'
      'PI'
      'RJ'
      'RN'
      'RS'
      'RO'
      'RR'
      'SC'
      'SP'
      'SE'
      'TO')
  end
  object btConsulta: TButton
    Left = 138
    Top = 266
    Width = 75
    Height = 25
    Caption = 'Consulta'
    TabOrder = 6
    OnClick = btConsultaClick
  end
end
