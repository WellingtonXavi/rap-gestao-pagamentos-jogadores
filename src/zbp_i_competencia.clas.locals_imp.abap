CLASS lhc_pagamento DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS dadosObrigatorios FOR VALIDATE ON SAVE
      IMPORTING keys FOR Pagamento~dadosObrigatorios.

ENDCLASS.

CLASS lhc_pagamento IMPLEMENTATION.

  METHOD dadosObrigatorios.
    CONSTANTS lc_state_area TYPE c LENGTH 30 VALUE 'DADOS_OBRIGATORIOS'.

    READ ENTITIES OF zi_competencia IN LOCAL MODE
     ENTITY Pagamento
       FIELDS ( CompetenciaId JogadorId DataLancamento )
       WITH CORRESPONDING #( keys )
     RESULT DATA(lt_pagamentos).

    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( %tky        = ls_key-%tky
                      %state_area = lc_state_area ) TO reported-pagamento.
    ENDLOOP.


    LOOP AT lt_pagamentos INTO DATA(ls_pagamento).

      IF ls_pagamento-JogadorId IS INITIAL.
        APPEND VALUE #( %tky = ls_pagamento-%tky ) TO failed-pagamento.

        APPEND VALUE #( %tky        = ls_pagamento-%tky
                        %state_area = lc_state_area

                        %element-JogadorId = if_abap_behv=>mk-on
                        %msg = new_message( id       = 'ZCM_PAGAMENTO'
                                            number   = '000'
                                            severity = if_abap_behv_message=>severity-error ) )
          TO reported-pagamento.
      ENDIF.

      IF ls_pagamento-DataLancamento IS INITIAL.
        APPEND VALUE #( %tky = ls_pagamento-%tky ) TO failed-pagamento.

        APPEND VALUE #( %tky        = ls_pagamento-%tky
                        %state_area = lc_state_area

                        %element-DataLancamento = if_abap_behv=>mk-on
                        %msg = new_message( id       = 'ZCM_PAGAMENTO'
                                            number   = '001'
                                            severity = if_abap_behv_message=>severity-error ) )
          TO reported-pagamento.
      ENDIF.

    ENDLOOP.




  ENDMETHOD.

ENDCLASS.



CLASS lhc_Competencia DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Competencia RESULT result.

    METHODS calculardatas FOR DETERMINE ON SAVE
      IMPORTING keys FOR competencia~calculardatas.
    METHODS preenchercriadoem FOR DETERMINE ON SAVE
      IMPORTING keys FOR competencia~preenchercriadoem.
    METHODS validarduplicidade FOR VALIDATE ON SAVE
      IMPORTING keys FOR competencia~validarduplicidade.
    METHODS setdefaultscompetencia FOR DETERMINE ON MODIFY
      IMPORTING keys FOR competencia~setdefaultscompetencia.
    METHODS validarano FOR VALIDATE ON SAVE
      IMPORTING keys FOR competencia~validarano.


    METHODS earlynumbering_cba_pagamento FOR NUMBERING
      IMPORTING entities FOR CREATE competencia\_pagamento.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Competencia.

ENDCLASS.

CLASS lhc_Competencia IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    LOOP AT entities INTO DATA(ls_entity).

      APPEND VALUE #(
                       %cid = ls_entity-%cid
                       %is_draft = ls_entity-%is_draft
                       CompetenciaId = cl_system_uuid=>create_uuid_x16_static(  )
                     ) TO mapped-competencia.


    ENDLOOP.


  ENDMETHOD.

  METHOD calcularDatas.



    READ ENTITIES OF zi_competencia IN LOCAL MODE
    ENTITY Competencia
    FIELDS ( Mes Ano )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_competencias).

    DATA: lt_update TYPE TABLE FOR UPDATE zi_competencia.

    LOOP AT lt_competencias INTO DATA(ls_competencia).

      CHECK ls_competencia-Mes IS NOT INITIAL AND ls_competencia-Ano IS NOT INITIAL.

      DATA(lv_data_inicio) = CONV d(  |{ ls_competencia-Ano WIDTH = 4 PAD = '0' }{ ls_competencia-Mes WIDTH = 2 PAD = '0' }01| ).



      DATA(lv_data_aux) = lv_data_inicio .
      lv_data_aux = lv_data_aux + 32.
      lv_data_aux+6(2) = '01'.
      DATA(lv_data_fim) = CONV d( lv_data_aux - 1 ).



      IF ls_competencia-DataInicio = lv_data_inicio AND ls_competencia-DataFim = lv_data_fim.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(  %tky       = ls_competencia-%tky
                       DataInicio =  lv_data_inicio
                       DataFim = lv_data_fim
                       %control-DataInicio = if_abap_behv=>mk-on
                       %control-DataFim = if_abap_behv=>mk-on
                       ) TO  lt_update.



    ENDLOOP.

    MODIFY ENTITIES OF zi_competencia IN LOCAL MODE
         ENTITY Competencia
           UPDATE FIELDS ( DataInicio DataFim )
           WITH lt_update.








  ENDMETHOD.

  METHOD preencherCriadoEm.

    READ ENTITIES OF zi_competencia IN LOCAL MODE
    ENTITY Competencia
    FIELDS ( CriadoEm )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_competencias).

    DATA: lt_update TYPE TABLE FOR UPDATE zi_competencia.

    LOOP AT lt_competencias INTO DATA(ls_competencia).

      CHECK ls_competencia-CriadoEm IS INITIAL.


      DATA(lv_timestamp_utc) = utclong_current( ).

      APPEND VALUE #( %tky = ls_competencia-%tky
       CriadoEm = lv_timestamp_utc
      %control-CriadoEm = if_abap_behv=>mk-on ) TO lt_update.

    ENDLOOP.

    MODIFY ENTITIES OF zi_competencia IN LOCAL MODE
           ENTITY Competencia
             UPDATE FIELDS ( CriadoEm )
             WITH lt_update.



  ENDMETHOD.

  METHOD earlynumbering_cba_Pagamento.



    LOOP AT entities INTO DATA(ls_entity).

      LOOP AT ls_entity-%target INTO DATA(ls_novo_pagamento).

        APPEND VALUE #(
                       %cid = ls_novo_pagamento-%cid
                       %is_draft = ls_novo_pagamento-%is_draft

                       PagamentoId = cl_system_uuid=>create_uuid_x16_static( )




         ) TO mapped-pagamento.



      ENDLOOP.

    ENDLOOP.



  ENDMETHOD.

  METHOD validarDuplicidade.

    CONSTANTS lc_state_area TYPE c LENGTH 30 VALUE 'VALIDAR_DUPLICIDADE'.

    READ ENTITIES OF zi_competencia IN LOCAL MODE
      ENTITY Competencia
      FIELDS ( Mes Ano )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_competencias).

    " 1) Limpa as mensagens antigas deste grupo, para cada instância
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( %tky        = ls_key-%tky
                      %state_area = lc_state_area ) TO reported-competencia.
    ENDLOOP.

    LOOP AT lt_competencias INTO DATA(ls_competencia).

      " 2) Ignora rascunho ainda sem Mês/Ano preenchidos
      CHECK ls_competencia-Mes IS NOT INITIAL
        AND ls_competencia-Ano IS NOT INITIAL.

      DATA(lv_duplicada) = abap_false.

      " 3a) Duplicidade contra o que já está salvo no banco
      SELECT SINGLE competencia_id FROM zcompetencia
        WHERE mes = @ls_competencia-Mes
          AND ano = @ls_competencia-Ano
          AND competencia_id <> @ls_competencia-CompetenciaId
        INTO @DATA(lv_competencia_id).
      IF sy-subrc = 0.
        lv_duplicada = abap_true.
      ENDIF.

      " 3b) Duplicidade contra outra instância do mesmo lote
      IF lv_duplicada = abap_false.
        LOOP AT lt_competencias TRANSPORTING NO FIELDS
             WHERE Mes = ls_competencia-Mes
               AND Ano = ls_competencia-Ano
               AND CompetenciaId <> ls_competencia-CompetenciaId.
          lv_duplicada = abap_true.
          EXIT.
        ENDLOOP.
      ENDIF.

      " 4) Se duplicada: bloqueia (failed) e explica (reported)
      IF lv_duplicada = abap_true.
        APPEND VALUE #( %tky = ls_competencia-%tky ) TO failed-competencia.

        APPEND VALUE #( %tky         = ls_competencia-%tky
                        %state_area  = lc_state_area
                        %element-Mes = if_abap_behv=>mk-on
                        %element-Ano = if_abap_behv=>mk-on
                        %msg         = new_message( id       = 'ZCM_COMPETENCIA'
                                                    number   = '000'
                                                    severity = if_abap_behv_message=>severity-error
                                                    v1       = ls_competencia-Mes
                                                    v2       = ls_competencia-Ano ) )
          TO reported-competencia.
      ENDIF.

    ENDLOOP.



  ENDMETHOD.





  METHOD setDefaultsCompetencia.

    READ ENTITIES OF zi_competencia IN LOCAL MODE
        ENTITY Competencia
        FIELDS ( Mes Ano )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_competencias).


    DATA: lt_update TYPE TABLE FOR UPDATE zi_competencia.

    DATA(lv_data_atual) =  cl_abap_context_info=>get_system_date( ).

    "  Extrai Ano (4 chars) e Mês (2 chars)
    DATA(lv_mes) = CONV numc2( lv_data_atual+4(2) ).
    DATA(lv_ano) = CONV numc4( lv_data_atual+0(4) ).


    LOOP AT lt_competencias INTO DATA(ls_competencia).

      IF ls_competencia-Mes IS INITIAL OR ls_competencia-Ano IS INITIAL.

        APPEND VALUE #(  %tky = ls_competencia-%tky
                         Mes = lv_mes
                         Ano = lv_ano
                         %control-Mes       = if_abap_behv=>mk-on
                         %control-Ano       = if_abap_behv=>mk-on


         ) TO lt_update.

      ENDIF.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_competencia IN LOCAL MODE
        ENTITY Competencia
          UPDATE FIELDS ( Mes Ano )
          WITH lt_update.
    ENDIF.


  ENDMETHOD.

  METHOD validarAno.
    CONSTANTS lc_state_area TYPE c LENGTH 30 VALUE 'VALIDAR_ANO'.

    READ ENTITIES OF zi_competencia IN LOCAL MODE
    ENTITY Competencia
    FIELDS ( Ano )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_competencias).


    LOOP AT keys INTO DATA(ls_key).

      APPEND VALUE #(  %tky = ls_key-%tky
                       %state_area = lc_state_area ) TO reported-competencia.

    ENDLOOP.


    LOOP AT lt_competencias INTO DATA(ls_competencia).

      IF ls_competencia-Ano IS INITIAL.

        APPEND VALUE #( %tky = ls_competencia-%tky ) TO failed-competencia.

        APPEND VALUE #( %tky         = ls_competencia-%tky
                        %state_area  = lc_state_area

                        %element-Ano = if_abap_behv=>mk-on
                        %msg         = new_message( id       = 'ZCM_COMPETENCIA'
                                                    number   = '002'
                                                    severity = if_abap_behv_message=>severity-error
                                                    ) )
          TO reported-competencia.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
