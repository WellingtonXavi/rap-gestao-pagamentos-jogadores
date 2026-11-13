CLASS lhc_Jogador DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Jogador RESULT result.


    METHODS setdefaults FOR DETERMINE ON MODIFY
      IMPORTING keys FOR jogador~setdefaults.
    METHODS validardadosobrigatorio FOR VALIDATE ON SAVE
      IMPORTING keys FOR jogador~validardadosobrigatorio.
    METHODS validarformatoemailtelefone FOR VALIDATE ON SAVE
      IMPORTING keys FOR jogador~validarformatoemailtelefone.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE jogador.

ENDCLASS.

CLASS lhc_Jogador IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    LOOP AT entities INTO DATA(ls_entity).


      APPEND VALUE #(
      %cid = ls_entity-%cid
      %is_draft  = ls_entity-%is_draft
      jogadorid = cl_system_uuid=>create_uuid_x16_static( )


      ) TO mapped-jogador.




    ENDLOOP.

  ENDMETHOD.

  METHOD setDefaults.

    READ ENTITIES OF zi_jogador IN LOCAL MODE
    ENTITY Jogador
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_jogadores).

    MODIFY ENTITIES OF zi_jogador IN LOCAL MODE
    ENTITY Jogador
    UPDATE FIELDS ( DataCadastro Ativo )
    WITH VALUE #( FOR  ls_jogador IN lt_jogadores
                  (

                    %tky = ls_jogador-%tky
                    DataCadastro = cl_abap_context_info=>get_system_date( )
                    Ativo        = abap_true
                 )



                ).


  ENDMETHOD.

  METHOD validarDadosObrigatorio.

    CONSTANTS lc_state_area TYPE c LENGTH 30 VALUE 'VALIDAR_CAMPOS'.

    READ ENTITIES OF zi_jogador IN LOCAL MODE
    ENTITY Jogador
    FIELDS ( NomeCompleto Telefone Email )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_jogadores).

    LOOP AT keys INTO DATA(ls_key).

      APPEND VALUE #( %tky = ls_key-%tky %state_area = lc_state_area ) TO reported-jogador.

    ENDLOOP.



    LOOP AT lt_jogadores INTO DATA(ls_jogador).

      DATA(lv_jogador_invalido) = abap_false.

      IF ls_jogador-NomeCompleto IS INITIAL.

        lv_jogador_invalido = abap_true.




        APPEND VALUE #( %tky = ls_jogador-%tky
                        %state_area  = lc_state_area
                        %element-NomeCompleto = if_abap_behv=>mk-on
                        %msg         = new_message( id       = 'ZCM_JOGADOR'
                                                    number   = '000'
                                                    severity = if_abap_behv_message=>severity-error
                                                     )


         ) TO reported-jogador.

      ENDIF.


      IF ls_jogador-Telefone IS INITIAL.

        lv_jogador_invalido = abap_true.




        APPEND VALUE #( %tky = ls_jogador-%tky
                        %state_area  = lc_state_area
                        %element-Telefone = if_abap_behv=>mk-on
                        %msg         = new_message( id       = 'ZCM_JOGADOR'
                                                    number   = '001'
                                                    severity = if_abap_behv_message=>severity-error
                                                     )


         ) TO reported-jogador.

      ENDIF.


      IF ls_jogador-Email IS INITIAL.

        lv_jogador_invalido = abap_true.




        APPEND VALUE #( %tky = ls_jogador-%tky
                        %state_area  = lc_state_area
                        %element-Email = if_abap_behv=>mk-on
                        %msg         = new_message( id       = 'ZCM_JOGADOR'
                                                    number   = '002'
                                                    severity = if_abap_behv_message=>severity-error
                                                     )


         ) TO reported-jogador.

      ENDIF.

      IF lv_jogador_invalido = abap_true.

        APPEND VALUE #(
          %tky = ls_jogador-%tky
        ) TO failed-jogador.

      ENDIF.


    ENDLOOP.



  ENDMETHOD.

  METHOD validarFormatoEmailTelefone.

    CONSTANTS lc_state_area TYPE c LENGTH 30 VALUE 'VALIDAR_CONTATO'.

    READ ENTITIES OF zi_jogador IN LOCAL MODE
      ENTITY Jogador
      FIELDS ( Email Telefone )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_jogadores).

    LOOP AT lt_jogadores INTO DATA(ls_jogador).

      DATA(lv_jogador_invalido) = abap_false.

      " Validar formato do e-mail
      IF ls_jogador-Email IS NOT INITIAL.

        FIND REGEX '@' IN ls_jogador-Email.

        IF sy-subrc <> 0.

          lv_jogador_invalido = abap_true.

          APPEND VALUE #(
            %tky                  = ls_jogador-%tky
            %state_area           = lc_state_area
            %element-Email        = if_abap_behv=>mk-on
            %msg                  = new_message(
              id       = 'ZCM_JOGADOR'
              number   = '003'
              severity = if_abap_behv_message=>severity-error )
          ) TO reported-jogador.

        ENDIF.

      ENDIF.

      " Validar formato do telefone
      IF ls_jogador-Telefone IS NOT INITIAL.

        DATA(lv_telefone) = CONV string( ls_jogador-Telefone ).

        " Remover caracteres de formatação permitidos
        REPLACE ALL OCCURRENCES OF '(' IN lv_telefone WITH ''.
        REPLACE ALL OCCURRENCES OF ')' IN lv_telefone WITH ''.
        REPLACE ALL OCCURRENCES OF '-' IN lv_telefone WITH ''.


        " Verificar se restaram apenas dígitos
        FIND REGEX '^[0-9]+$' IN lv_telefone.

        IF sy-subrc <> 0
           OR ( strlen( lv_telefone ) <> 10
            AND strlen( lv_telefone ) <> 11 ).

          lv_jogador_invalido = abap_true.

          APPEND VALUE #(
            %tky                  = ls_jogador-%tky
            %state_area           = lc_state_area
            %element-Telefone     = if_abap_behv=>mk-on
            %msg                  = new_message(
              id       = 'ZCM_JOGADOR'
              number   = '004'
              severity = if_abap_behv_message=>severity-error )
          ) TO reported-jogador.

        ENDIF.

      ENDIF.

      " Registrar a instância como falha uma única vez
      IF lv_jogador_invalido = abap_true.

        APPEND VALUE #(
          %tky = ls_jogador-%tky
        ) TO failed-jogador.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
