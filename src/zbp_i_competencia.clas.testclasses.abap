CLASS  ltc_competencia DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CLASS-DATA go_environment TYPE REF TO if_osql_test_environment. " cria ambiente de test doubles, não utiliza as tabelas

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS teardown.


    METHODS duplicada_no_lote  FOR TESTING RAISING cx_static_check.
    METHODS duplicada_no_banco FOR TESTING RAISING cx_static_check.
    METHODS mes_livre_sem_erro FOR TESTING RAISING cx_static_check.
    METHODS alterar_sem_erro   FOR TESTING RAISING cx_static_check.

    METHODS mes_ano_vazios_informados FOR TESTING RAISING cx_static_check.

    METHODS inserir_competencia IMPORTING iv_mes TYPE zcompetencia-mes
                                          iv_ano TYPE zcompetencia-ano RETURNING VALUE(rv_id_competencia) TYPE zcompetencia-competencia_id
                                RAISING   cx_uuid_error.

ENDCLASS.


CLASS ltc_competencia IMPLEMENTATION.

  METHOD class_setup.
    go_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'ZCOMPETENCIA' )
                                   ( 'ZCOMPETENCIA_D' )
                                   ( 'ZPAGAMENTO' )
                                   ( 'ZPAGAMENTO_D' )
                                   ( 'ZI_COMPETENCIA' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    go_environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    go_environment->clear_doubles( ).   " cada teste começa com a tabela vazia
  ENDMETHOD.

  METHOD teardown.
    ROLLBACK ENTITIES.
  ENDMETHOD.

  METHOD inserir_competencia.


    DATA lt_competencia TYPE STANDARD TABLE OF zcompetencia WITH EMPTY KEY.

    DATA lt_cds_competencia TYPE STANDARD TABLE OF zi_competencia WITH EMPTY KEY.

    rv_id_competencia = cl_system_uuid=>create_uuid_x16_static( ).

    lt_cds_competencia = VALUE #(
    (
      CompetenciaId = rv_id_competencia
      mes            = iv_mes
      ano            = iv_ano ) ).

    go_environment->insert_test_data( lt_cds_competencia ).

    lt_competencia = VALUE #(
    ( client         = sy-mandt
      competencia_id = rv_id_competencia
      mes            = iv_mes
      ano            = iv_ano ) ).

    go_environment->insert_test_data( lt_competencia ).

  ENDMETHOD.

  METHOD duplicada_no_lote.
    MODIFY ENTITIES OF zi_competencia
     ENTITY Competencia
       CREATE FIELDS ( Mes Ano )
       WITH VALUE #( ( %cid = 'C1' Mes = '05' Ano = '2026' )
                     ( %cid = 'C2' Mes = '05' Ano = '2026' ) )
     MAPPED   DATA(mapped)
     FAILED   DATA(failed)
     REPORTED DATA(reported).

    COMMIT ENTITIES RESPONSE OF zi_competencia
 FAILED   DATA(failed_commit)
 REPORTED DATA(reported_commit).

    " THEN
    cl_abap_unit_assert=>assert_initial(
      act = failed-competencia
      msg = 'O MODIFY não deveria falhar; a validation só roda no commit' ).

    cl_abap_unit_assert=>assert_equals(
    act = lines( failed_commit-competencia )
    exp = 2
    msg = 'As duas instâncias duplicadas deveriam ser rejeitadas' ).



  ENDMETHOD.

  METHOD duplicada_no_banco.
    " GIVEN: 05/2026 já existe salva
    inserir_competencia( iv_mes = '05' iv_ano = '2026' ).

    " WHEN: tenta criar outra 05/2026
    MODIFY ENTITIES OF zi_competencia
      ENTITY Competencia
        CREATE FIELDS ( Mes Ano )
        WITH VALUE #( ( %cid = 'C1' Mes = '05' Ano = '2026' ) )
      MAPPED   DATA(mapped)
      FAILED   DATA(failed)
      REPORTED DATA(reported).

    COMMIT ENTITIES RESPONSE OF zi_competencia
      FAILED   DATA(failed_commit)
      REPORTED DATA(reported_commit).

    " THEN: foi rejeitada
    cl_abap_unit_assert=>assert_not_initial(
      act = failed_commit-competencia
      msg = 'Competência duplicada do banco deveria ser rejeitada' ).

    " THEN: a mensagem certa foi reportada
    DATA lv_achou TYPE abap_bool.
    LOOP AT reported_commit-competencia INTO DATA(ls_reported)
         WHERE %msg IS BOUND.
      IF ls_reported-%msg->if_t100_message~t100key-msgid = 'ZCM_COMPETENCIA'
         AND ls_reported-%msg->m_severity = if_abap_behv_message=>severity-error.
        lv_achou = abap_true.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_true(
      act = lv_achou
      msg = 'Deveria haver mensagem de erro da classe ZCM_COMPETENCIA' ).
  ENDMETHOD.


  METHOD mes_livre_sem_erro.
    " GIVEN: 05/2026 já existe
    inserir_competencia( iv_mes = '05' iv_ano = '2026' ).

    " WHEN: cria 06/2026 (mês diferente)
    MODIFY ENTITIES OF zi_competencia
      ENTITY Competencia
        CREATE FIELDS ( Mes Ano )
        WITH VALUE #( ( %cid = 'C1' Mes = '06' Ano = '2026' ) )
      MAPPED   DATA(mapped)
      FAILED   DATA(failed)
      REPORTED DATA(reported).

    COMMIT ENTITIES RESPONSE OF zi_competencia
      FAILED   DATA(failed_commit)
      REPORTED DATA(reported_commit).

    " THEN: aceita e grava
    cl_abap_unit_assert=>assert_initial(
      act = failed_commit-competencia
      msg = 'Mês livre não deveria ser rejeitado' ).

    SELECT COUNT(*) FROM zcompetencia INTO @DATA(lv_total).
    cl_abap_unit_assert=>assert_equals(
      act = lv_total
      exp = 2
      msg = 'Deveriam existir 2 competências: a pré-existente e a nova' ).
  ENDMETHOD.





  METHOD alterar_sem_erro.



    DATA(lv_competencia_id) =   inserir_competencia(  iv_mes = '05' iv_ano = '2026' ).

    READ ENTITIES OF zi_competencia
    ENTITY Competencia
    ALL FIELDS WITH VALUE #( ( CompetenciaId = lv_competencia_id ) )
    RESULT DATA(lt_lido).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lido ) exp = 1 ).


    MODIFY ENTITIES OF zi_competencia
    ENTITY Competencia
    UPDATE FIELDS ( mes Ano )
    WITH VALUE #(  ( CompetenciaId = lv_competencia_id  mes = '05' Ano = '2026' ) )
    MAPPED DATA(mapped)
    FAILED   DATA(failed)
    REPORTED DATA(reported).

    cl_abap_unit_assert=>assert_equals( act = lines( failed-competencia ) exp = 0 msg = 'O MODIFY não deveria apresentar falhas' ).

    COMMIT ENTITIES RESPONSE OF zi_competencia
    FAILED DATA(failed_commit)
    REPORTED DATA(reported_commit).

    cl_abap_unit_assert=>assert_initial( act = failed_commit-competencia msg = 'Update deve encontrar a instancia').




  ENDMETHOD.

  METHOD mes_ano_vazios_informados.


    "When
    MODIFY ENTITIES OF zi_competencia
    ENTITY Competencia
    CREATE FIELDS ( Mes Ano )
    WITH VALUE #( ( %cid = 'C1' Mes = '00' Ano = '0000' ) )
    MAPPED DATA(mapped)
    FAILED DATA(failed)
    REPORTED DATA(reported).

    "Then
    cl_abap_unit_assert=>assert_initial( act = failed-competencia msg = 'Mes e ano vazios não deve relattar no failed'  ).

    COMMIT ENTITIES RESPONSE OF zi_competencia
       FAILED   DATA(failed_commit)
       REPORTED DATA(reported_commit).
    "Then
    cl_abap_unit_assert=>assert_not_initial( act = failed_commit-competencia msg = 'Mes e ano vazios não deve realizar Commit').


  ENDMETHOD.

ENDCLASS.
