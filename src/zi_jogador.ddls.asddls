@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface de Jogadores'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZI_JOGADOR
  as select from zjogador
{
    
  @ObjectModel.text.element: [ 'Apelido' ] // <-- Associa o ID ao Apelido
  key jogador_id      as JogadorId,

      nome_completo   as NomeCompleto,
      apelido         as Apelido,
      telefone        as Telefone,
      email           as Email,

      data_cadastro   as DataCadastro,
      data_nascimento as DataNascimento,

      cep             as CEP,
      uf              as UF,
      cidade          as Cidade,
      bairro          as Bairro,
      logradouro      as Logradouro,
      numero          as Numero,
      complemento     as Complemento,

      ativo           as Ativo,
     

      @Semantics.largeObject: {
      mimeType: 'FotoMimeType',
      fileName: 'FotoFileName',
      acceptableMimeTypes: [ 'image/jpeg', 'image/png' ],
      contentDispositionPreference: #INLINE
      }
      foto            as Foto,
      @Semantics.mimeType: true
      foto_mimetype   as FotoMimeType,
      foto_filename   as FotoFileName,
      last_changed_at as LastChangedAt
      


}
