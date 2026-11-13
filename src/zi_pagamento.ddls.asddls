@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Pagamento'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZI_PAGAMENTO
  as select from zpagamento
  association        to parent ZI_COMPETENCIA as _Competencia    on $projection.CompetenciaId = _Competencia.CompetenciaId
  association [0..1] to ZI_JOGADOR            as _Jogador        on _Jogador.JogadorId = $projection.JogadorId
  association [0..1] to ZI_TIPO_LANCAMENTO    as _TipoLancamento on _TipoLancamento.TipoLancamento = $projection.TipoLancamento
{
  key pagamento_id                                    as PagamentoId,

      @ObjectModel.text.element: [ 'ApelidoJogador' ]
      jogador_id                                      as JogadorId,
      _Jogador.Apelido                                as ApelidoJogador,
      _Jogador.NomeCompleto                           as NomeCompleto,

      @Semantics.largeObject: {
      mimeType: 'FotoMimeTypeJogador',
      fileName: 'FotoFileNameJogador',
      acceptableMimeTypes: [ 'image/jpeg', 'image/png' ],
      contentDispositionPreference: #INLINE
      }
      _Jogador.Foto                                   as Foto,
      _Jogador.FotoMimeType                           as FotoMimeTypeJogador,
      _Jogador.FotoFileName                           as FotoFileNameJogador,

      competencia_id                                  as CompetenciaId,
      @ObjectModel.text.element: [ 'DescricaoTipo' ]
      tipo_lancamento                                 as TipoLancamento,
      _TipoLancamento.Descricao                       as DescricaoTipo,

      valor                                           as Valor,

      data_lancamento                                 as DataLancamento,
      last_changed_at                                 as LastChangedAt,





      case
        when valor  = 0 then 1
        else 3
        end                                           as CorPagamento,
        
        

      
      _Competencia,
      
      _Jogador,
      
      _TipoLancamento




}
