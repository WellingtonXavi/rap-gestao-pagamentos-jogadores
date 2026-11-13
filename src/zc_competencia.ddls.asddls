@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projecao Competencia'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_COMPETENCIA
  provider contract transactional_query 
 as projection on ZI_COMPETENCIA

{
    key CompetenciaId,
    @Consumption.valueHelpDefinition: [{
        entity: {
          name: 'ZI_MES',
          element: 'TipoMes'
        }
      }]
      @ObjectModel.text.element: [ 'DescricaoMes' ]
      @UI.textArrangement: #TEXT_ONLY
    Mes,
    _Mes.Descricao as DescricaoMes ,
    Ano,
    DataInicio,
    DataFim,
    CriadoEm,
    LastChangedAt,
    
   CompetenciaFormatada,
   
   TotalPagamentos,
   
   
   CorTotalPagamento,
   
   
   
    
    _Pagamento : redirected to composition child ZC_PAGAMENTO
}
