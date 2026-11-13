@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projecao Pagamento'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_PAGAMENTO  
  as projection on ZI_PAGAMENTO
{
  key PagamentoId,

      @Consumption.valueHelpDefinition: [{
        entity: {
          name: 'ZC_JOGADOR',
          element: 'JogadorId'
        }
      }]
      JogadorId,
      ApelidoJogador,
      NomeCompleto,
      Foto,
      FotoMimeTypeJogador,
      FotoFileNameJogador,
     
      CompetenciaId,
      @Consumption.valueHelpDefinition: [{
        entity: {
          name: 'ZI_TIPO_LANCAMENTO',
          element: 'TipoLancamento'
        }
      }]
      @ObjectModel.text.element: [ 'DescricaoTipo' ]
      TipoLancamento,
      _TipoLancamento.Descricao as DescricaoTipo, 
      Valor,
      
      CorPagamento,
      DataLancamento,
      LastChangedAt,

      _Jogador,
      _Competencia : redirected to parent ZC_COMPETENCIA
}
