@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projeção de Jogadores'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_JOGADOR
  provider contract transactional_query
  as projection on ZI_JOGADOR
{
  key JogadorId,
      NomeCompleto,
      Apelido,
      Telefone,
      Email,


      DataCadastro,
      DataNascimento,


      CEP,
      UF,
      Cidade,
      Bairro,
      Logradouro,
      Numero,
      Complemento,
      Ativo,
     

      @Semantics.largeObject: {
      mimeType: 'FotoMimeType',
      fileName: 'FotoFileName',
      acceptableMimeTypes: [ 'image/jpeg', 'image/png' ],
      contentDispositionPreference: #INLINE
      }
      Foto,
      @Semantics.mimeType: true
      FotoMimeType,
      FotoFileName
}
