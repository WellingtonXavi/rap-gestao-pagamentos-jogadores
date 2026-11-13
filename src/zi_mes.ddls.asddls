@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interfaces dos Meses'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_MES
  as select distinct from t000
{
      @ObjectModel.text.element: [ 'Descricao' ]
  key cast( '01' as abap.numc(2) )      as TipoMes,
      cast( 'Janeiro' as abap.char(20)) as Descricao
}


union select distinct from t000
{

      
  key cast( '02' as abap.numc(2) )      as TipoMes,
      cast( 'Fevereiro' as abap.char(20)) as Descricao

}

union select distinct from t000
{

      
  key cast( '03' as abap.numc(2) )      as TipoMes,
      cast( 'Março' as abap.char(20)) as Descricao

}

union select distinct from t000
{

      
  key cast( '04' as abap.numc(2) )      as TipoMes,
      cast( 'Abril' as abap.char(20)) as Descricao

}

union select distinct from t000
{

      
  key cast( '05' as abap.numc(2) )      as TipoMes,
      cast( 'Maio' as abap.char(20)) as Descricao

}

union select distinct from t000
{

      
  key cast( '06' as abap.numc(2) )      as TipoMes,
      cast( 'Junho' as abap.char(20)) as Descricao

}

union select distinct from t000
{

      
  key cast( '07' as abap.numc(2) )      as TipoMes,
      cast( 'Julho' as abap.char(20)) as Descricao

}

union select distinct from t000
{

      
  key cast( '08' as abap.numc(2) )      as TipoMes,
      cast( 'Agosto' as abap.char(20)) as Descricao

}

union select distinct from t000
{

      
  key cast( '09' as abap.numc(2) )      as TipoMes,
      cast( 'Setembro' as abap.char(20)) as Descricao

}

union select distinct from t000
{

      
  key cast( '10' as abap.numc(2) )      as TipoMes,
      cast( 'Outubro' as abap.char(20)) as Descricao

}

union select distinct from t000
{

      
  key cast( '11' as abap.numc(2) )      as TipoMes,
      cast( 'Novembro' as abap.char(20)) as Descricao

}

union select distinct from t000
{

      
  key cast( '12' as abap.numc(2) )      as TipoMes,
      cast( 'Dezembro' as abap.char(20)) as Descricao

}
