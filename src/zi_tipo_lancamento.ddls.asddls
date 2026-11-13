@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tipo Lancamento'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_TIPO_LANCAMENTO
  as select distinct from t000
{

      @ObjectModel.text.element: [ 'Descricao' ]
  key cast( 'P' as abap.char(1) )    as TipoLancamento,
      cast( 'PIX' as abap.char(20) ) as Descricao
}


union select distinct from t000
{
  key cast( 'D' as abap.char(1) )       as TipoLancamento,
      cast( 'Débito' as abap.char(20) ) as Descricao
}

union select distinct from t000
{
  key cast( 'C' as abap.char(1) )        as TipoLancamento,
      cast( 'Crédito' as abap.char(20) ) as Descricao
}
union select distinct from t000
{
  key cast( 'M' as abap.char(1) )         as TipoLancamento,
      cast( 'Dinheiro' as abap.char(20) ) as Descricao
}
