@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Competência'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZI_COMPETENCIA
  as select from    zcompetencia

    left outer join zpagamento on zpagamento.competencia_id = zcompetencia.competencia_id
  association [0..1] to ZI_MES       as _Mes on _Mes.TipoMes = $projection.Mes

  composition [0..*] of ZI_PAGAMENTO as _Pagamento

{


  key zcompetencia.competencia_id                                 as CompetenciaId,
       @ObjectModel.text.element: [ 'MesDescricao' ]
      zcompetencia.mes                                            as Mes,
      _Mes.Descricao                                              as MesDescricao,
      zcompetencia.ano                                            as Ano,
      zcompetencia.data_inicio                                    as DataInicio,
      zcompetencia.data_fim                                       as DataFim,
      zcompetencia.criado_em                                      as CriadoEm,
      zcompetencia.last_changed_at                                as LastChangedAt,



      concat( zcompetencia.mes, concat( '-', zcompetencia.ano ) ) as CompetenciaFormatada,

      sum( zpagamento.valor )                                     as TotalPagamentos,


      case
        when sum( zpagamento.valor ) >= 0   and sum( zpagamento.valor ) <= 350 then 1
        when sum( zpagamento.valor ) >= 351 and sum( zpagamento.valor ) <= 699 then 2
        else 3
      end                                                         as CorTotalPagamento,




      _Pagamento,
      _Mes
}
group by
  _Mes.Descricao,
  zcompetencia.competencia_id,
  zcompetencia.mes,
  zcompetencia.ano,
  zcompetencia.data_inicio,
  zcompetencia.data_fim,
  zcompetencia.criado_em,
  zcompetencia.last_changed_at
